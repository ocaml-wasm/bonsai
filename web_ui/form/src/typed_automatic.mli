open! Core
open! Bonsai_web
module Form := Form_automatic

(** The functions in this module can be hard to understand
    Please look at the examples in lib/bonsai/examples/forms/typed.ml *)

module Record : sig
  module type S = sig
    module Typed_field : Typed_fields_lib.S

    (** The label to use for each field of your record. If this value is [`Inferred], each
        field will be labelled with its name. If this value is [`Computed f], then each
        field will be labelled with the result of calling [f] on it. *)
    val label_for_field
      : [ `Inferred
        | `Computed of 'a Typed_field.t -> string
          (** The value passed to [`Dynamic] is used in many [let%arr]s within [make]. Thus,
            it's possible to accidentally duplicate work, if the provided value is built
            using [let%map] instead of [let%arr]. *)
        | `Dynamic of (Typed_field.Packed.t -> string) Value.t
        ]

    (** For each of the fields in your record, you need to provide a form
        component which produces values of that type. *)
    val form_for_field : 'a Typed_field.t -> 'a Form.t Computation.t
  end

  val make : (module S with type Typed_field.derived_on = 'a) -> 'a Form.t Computation.t

  (** Creates a table whose columns are the fields of the record, and whose rows
      correspond to list items. *)
  val make_table
    :  (module S with type Typed_field.derived_on = 'a)
    -> 'a list Form.t Computation.t
end

module Variant : sig
  module type S = sig
    (**  This module should be generated by deriving [typed_variants] on a
         sum type. *)
    module Typed_variant : Typed_variants_lib.S

    (** The label to use for each variant in your sum type in the dropdown. If this value
        is [`Inferred], the name of the variant constructor will be used. If this value is
        [`Computed f], then the dropdown labels will be the result of calling [f] on each
        of the variants. *)
    val label_for_variant
      : [ `Inferred
        | `Computed of 'a Typed_variant.t -> string
          (** The value passed to [`Dynamic] is used in many [let%arr]s within [make]. Thus,
            it's possible to accidentally duplicate work, if the provided value is built
            using [let%map] instead of [let%arr]. *)
        | `Dynamic of (Typed_variant.Packed.t -> string) Value.t
        ]

    (** For each of the variants in your sum type, you need to provide a form
        component which produces values of that type. *)
    val form_for_variant : 'a Typed_variant.t -> 'a Form.t Computation.t

    (* [initial_choice] can be used to change which constructor in the variant is
       initially selected. *)
    val initial_choice : [ `First_constructor | `Empty | `This of Typed_variant.Packed.t ]
  end

  module type S_set = sig
    include Comparator.S

    (**  This module should be generated by deriving [typed_variants] on a
         sum type. *)
    module Typed_variant : Typed_variants_lib.S with type derived_on = t

    (** The label to use for each variant in your sum type. If this value is [`Inferred],
        the name of the variant constructor will be used. If this value is [`Computed f],
        then the labels will be the result of calling [f] on each of the variants. *)
    val label_for_variant
      : [ `Inferred
        | `Computed of 'a Typed_variant.t -> string
          (** The value passed to [`Dynamic] is used in many [let%arr]s within [make]. Thus,
            it's possible to accidentally duplicate work, if the provided value is built
            using [let%map] instead of [let%arr]. *)
        | `Dynamic of (Typed_variant.Packed.t -> string) Value.t
        ]

    (** The sexp_of function to use in the comparator. If `Use_sexp_of_variant is
        provided, the argument will be used to construct a value of type t, and
        that sexp of that value will be used.
    *)
    val sexp_of_variant_argument
      : [ `Use_sexp_of_variant | `Custom of 'a Typed_variant.t -> 'a -> Sexp.t ]

    (** For each of the variants in your sum type, you need to provide a form
        component which produces sets of values of that type. *)
    val form_for_variant
      :  'a Typed_variant.t
      -> ('a, 'cmp) Bonsai.comparator
      -> ('a, 'cmp) Set.t Form.t Computation.t
  end

  (** [picker_attr] will be added to the picker for selecting a variant constructor.
      Default appearance is a dropdown, but it can be changed through [?picker].

  *)
  val make
    :  ?picker:[ `Dropdown | `Radio of [ `Horizontal | `Vertical ] ]
    -> ?picker_attr:Vdom.Attr.t Value.t
    -> (module S with type Typed_variant.derived_on = 'a)
    -> 'a Form.t Computation.t

  (* Like [make], but the dropdown/radio button list will have an extra option that parses
     to [None] with the other options parsing to [Some (* same result as
     with [Variant.make] *)]*)
  val make_optional
    :  ?picker:[ `Dropdown | `Radio of [ `Horizontal | `Vertical ] ]
    -> ?picker_attr:Vdom.Attr.t Value.t
    -> ?empty_label:string
    -> (module S with type Typed_variant.derived_on = 'a)
    -> 'a option Form.t Computation.t

  (** This creates a form to pick a set of values of a particular variant.
      Each variant will have a separate set picker for its possible values,
      and the value of the form is the union of the set.
  *)
  val make_set
    :  (module S_set with type t = 'a and type comparator_witness = 'cmp)
    -> ('a, 'cmp) Set.t Form.t Computation.t
end