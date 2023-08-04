# Bonsai / Wasm

## Installation:

You need to install the following dependencies:
```
opam pin -n async_js git@github.com:ocaml-wasm/async_js#wasm
opam pin -n base git@github.com:ocaml-wasm/base#wasm
opam pin -n base_bigstring git@github.com:ocaml-wasm/base_bigstring#wasm
opam pin -n bigstringaf git@github.com:ocaml-wasm/bigstringaf#wasm
opam pin -n bin_prot git@github.com:ocaml-wasm/bin_prot#wasm
opam pin -n dune git@github.com:ocaml-wasm/dune#wasm
opam pin -n core git@github.com:ocaml-wasm/core#wasm
opam pin -n core_kernel git@github.com:ocaml-wasm/core_kernel#wasm
opam pin -n gen_js_api git@github.com:ocaml-wasm/gen_js_api#wasm
opam pin -n incr_dom git@github.com:ocaml-wasm/incr_dom#wasm
opam pin -n js_of_ocaml_patches git@github.com:ocaml-wasm/js_of_ocaml_patches#wasm
opam pin -n ojs git@github.com:ocaml-wasm/ojs#wasm
opam pin -n ppx_css git@github.com:ocaml-wasm/ppx_css#wasm
opam pin -n ppx_expect git@github.com:ocaml-wasm/ppx_expect#wasm
opam pin -n ppx_inline_test git@github.com:ocaml-wasm/ppx_inline_test#wasm
opam pin -n time_now git@github.com:ocaml-wasm/time_now#wasm
opam pin -n virtual_dom git@github.com:ocaml-wasm/virtual_dom#wasm
opam pin -n zarith_stubs_js git@github.com:ocaml-wasm/zarith_stubs_js#wasm
opam install async_js base base_bigstring bigstringaf bin_prot dune core core_kernel gen_js_api incr_dom js_of_ocaml_patches ojs ppx_css ppx_expect ppx_inline_test time_now virtual_dom zarith_stubs_js
```

## Running tests

```
dune runtest --profile wasm
```
It's a bit slow for now since `wasm_of_ocaml` does not yet support separate compilation.

## Running benchmarks

```
cd web_ui/partial_render_table/bench/bin
dune build @all --profile wasm
node --experimental-wasm-gc --experimental-wasm-stringref ../../../../_build/default/web_ui/partial_render_table/bench/bin/main.bc.js
```

You can remove the `--profile_wasm` option to compile to JavaScript instead.

## Running examples

```
dune build @all --profile wasm
cd _build/default/examples/partial_render_table/bin
python3 -m http.server 8000 --directory .
```
Then open https://localhost:8000 in your browser.


# Bonsai

Bonsai is a library for building interactive browser-based UI.

Documentation can be found in the [docs](./docs) directory, and API documentation
can be found in [src/bonsai.mli](./src/bonsai.mli).
