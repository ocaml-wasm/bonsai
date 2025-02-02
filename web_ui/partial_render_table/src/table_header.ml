open! Core
open! Bonsai_web
open! Js_of_ocaml
open! Incr_map_collate
open! Bonsai.Let_syntax

module Acc = struct
  type t =
    { level_map : Table_view.Header.Header_cell.t list Int.Map.t
    ; leaf_index : int
    }

  let empty = { level_map = Int.Map.empty; leaf_index = 0 }

  let visit_leaf { level_map; leaf_index } ~level ~node =
    let data = node leaf_index in
    let level_map = Map.add_multi level_map ~key:level ~data in
    { leaf_index = leaf_index + 1; level_map }
  ;;

  let visit_non_leaf { level_map; leaf_index } ~level ~node =
    let level_map = Map.add_multi level_map ~key:level ~data:node in
    { leaf_index; level_map }
  ;;

  let finalize { level_map; leaf_index = _ } =
    level_map
    |> Map.data
    |> List.map ~f:(fun seq -> Table_view.Header.Header_row.view (List.rev seq))
  ;;
end

let rec render_header header ~level ~acc ~column_widths ~set_column_width =
  let recurse = render_header ~level:(level + 1) ~column_widths ~set_column_width in
  let recurse_no_level_change = render_header ~level ~column_widths ~set_column_width in
  match header with
  | Header_tree.Leaf { visible; leaf_header; initial_width } ->
    let node index =
      let column_width =
        match Map.find column_widths index with
        | Some (Column_size.Visible { width_px = width })
        | Some (Hidden { prev_width_px = Some width }) -> `Px_float width
        | None | Some (Hidden { prev_width_px = None }) -> initial_width
      in
      Table_view.Header.Header_cell.leaf_view
        ~column_width
        ~set_column_width:(set_column_width ~index)
        ~visible
        ~label:leaf_header
        ()
    in
    Acc.visit_leaf acc ~level ~node
  | Spacer inside ->
    let node =
      Table_view.Header.Header_cell.spacer_view ~colspan:(Header_tree.colspan header) ()
    in
    let acc = Acc.visit_non_leaf acc ~level ~node in
    recurse inside ~acc
  | Group { children; group_header } ->
    let node =
      Table_view.Header.Header_cell.group_view
        ~colspan:(Header_tree.colspan header)
        ~label:group_header
        ()
    in
    let acc = Acc.visit_non_leaf acc ~level ~node in
    List.fold children ~init:acc ~f:(fun acc -> recurse ~acc)
  | Organizational_group children ->
    List.fold children ~init:acc ~f:(fun acc -> recurse_no_level_change ~acc)
;;

let render_header headers ~column_widths ~set_column_width =
  headers
  |> render_header ~acc:Acc.empty ~level:0 ~column_widths ~set_column_width
  |> Acc.finalize
;;

let component
  (headers : Header_tree.t Value.t)
  ~column_widths
  ~set_column_width
  ~set_header_client_rect
  =
  let%arr set_column_width = set_column_width
  and set_header_client_rect = set_header_client_rect
  and headers = headers
  and column_widths = column_widths in
  let header_rows = render_header headers ~set_column_width ~column_widths in
  Table_view.Header.view ~set_header_client_rect header_rows
;;
