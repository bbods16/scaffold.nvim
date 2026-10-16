(* lib/catalog.ml  -- Algorithms and their parameters (data provided; lookup functions are yours) (Part 5). *)
type param_kind = Ident_fn | Ident_type | Elem
type param = { name : string; prompt : string; kind : param_kind; default : string }
type algo = { id : string; title : string; group : string; params : param list }

let elem_prompt = "Element type (int, float, string, bool)"

let all : algo list =
  [
    {
      id = "binary-search";
      title = "Binary search";
      group = "searching";
      params =
        [
          { name = "fn"; prompt = "Function name"; kind = Ident_fn; default = "binary search" };
          { name = "elem"; prompt = elem_prompt; kind = Elem; default = "int" };
        ];
    };
    {
      id = "insertion-sort";
      title = "Insertion sort";
      group = "sorting";
      params =
        [
          { name = "fn"; prompt = "Function name"; kind = Ident_fn; default = "insertion sort" };
          { name = "elem"; prompt = elem_prompt; kind = Elem; default = "int" };
        ];
    };
    {
      id = "stack";
      title = "Stack";
      group = "data structures";
      params =
        [
          { name = "type_name"; prompt = "Type name"; kind = Ident_type; default = "stack" };
          { name = "elem"; prompt = elem_prompt; kind = Elem; default = "int" };
        ];
    };
    {
      id = "union-find";
      title = "Union-find";
      group = "data structures";
      params =
        [ { name = "type_name"; prompt = "Type name"; kind = Ident_type; default = "union find" } ];
    };
  ]

(* F-025  Catalog.find : string -> Catalog.algo option
   Look an algorithm up by id in the fixed catalog (binary-search, insertion-sort, stack, union-find).
   Requires: none
   Produces: Some algo or None.
   Tests: T-102, T-103, T-104   Diagram: AD-025   Part 5
   Challenge: One line. *)
let find _ = failwith "not implemented: F-025 Catalog.find"

(* F-026  Catalog.template : algo_id:string -> lang_id:string -> string option
   The template text for an (algorithm, language) pair, or None when no template exists.
   Requires: none
   Produces: Some text or None.
   Tests: T-105, T-106, T-107   Diagram: AD-026   Part 5
   Challenge: Unknown language gives None, not an exception. *)
let template ~algo_id:_ ~lang_id:_ = failwith "not implemented: F-026 Catalog.template"

(* F-027  Catalog.for_lang : string -> Catalog.algo list
   The algorithms that have a template for the given language id, in catalog order.
   Requires: none
   Produces: A (possibly empty) list.
   Tests: T-108, T-109, T-110   Diagram: AD-027   Part 5
   Challenge: Write it as a single filter, without a loop. *)
let for_lang _ = failwith "not implemented: F-027 Catalog.for_lang"
