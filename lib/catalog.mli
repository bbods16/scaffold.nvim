(* lib/catalog.mli  -- the INTERFACE. Read the contract above each val; you implement it in catalog.ml. *)
type param_kind = Ident_fn | Ident_type | Elem
type param = { name : string; prompt : string; kind : param_kind; default : string }
type algo = { id : string; title : string; group : string; params : param list }

val all : algo list
(* F-025  Catalog.find : string -> Catalog.algo option
   Look an algorithm up by id in the fixed catalog (binary-search, insertion-sort, stack, union-find).
   Requires: none
   Produces: Some algo or None.
   Tests: T-102, T-103, T-104   Diagram: AD-025   Part 5
   Challenge: One line. *)
val find : string -> algo option
(* F-026  Catalog.template : algo_id:string -> lang_id:string -> string option
   The template text for an (algorithm, language) pair, or None when no template exists.
   Requires: none
   Produces: Some text or None.
   Tests: T-105, T-106, T-107   Diagram: AD-026   Part 5
   Challenge: Unknown language gives None, not an exception. *)
val template : algo_id:string -> lang_id:string -> string option
(* F-027  Catalog.for_lang : string -> Catalog.algo list
   The algorithms that have a template for the given language id, in catalog order.
   Requires: none
   Produces: A (possibly empty) list.
   Tests: T-108, T-109, T-110   Diagram: AD-027   Part 5
   Challenge: Write it as a single filter, without a loop. *)
val for_lang : string -> algo list
