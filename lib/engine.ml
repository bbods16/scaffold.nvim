(* lib/engine.ml  -- The whole pipeline (Part 7). *)
type opts = {
  lang : string;
  algo : string;
  answers : (string * string) list;
  existing : string list;
  mode : Insert.mode;
  cursor_indent : string;
}

type item = { id : string; group : string; title : string }

(* F-043  Engine.generate : Lang.t list -> Engine.opts -> (Insert.plan, Err.t) result
   The whole pipeline: language, algorithm, template, parameters, parse, render, place. The first failing stage returns its error.
   Requires: none
   Produces: Ok plan or the first stage's error.
   Returns an error: Unknown_lang
   Returns an error: Unknown_algo
   Returns an error: No_template
   Returns an error: Unknown_param
   Returns an error: Bad_ident
   Returns an error: Bad_elem
   Returns an error: Template _
   Tests: T-168, T-169, T-170, T-171, T-172, T-173, T-174, T-175, T-176, T-177, T-178   Diagram: AD-043   Part 7
   Challenge: Wrap template errors with the Template constructor. *)
let generate _ _ = failwith "not implemented: F-043 Engine.generate"

(* F-044  Engine.list : Lang.t list -> string -> (Engine.item list, Err.t) result
   The algorithms available for a language id, as {id; group; title} items.
   Requires: none
   Produces: Ok items or Error (Unknown_lang id).
   Returns an error: Unknown_lang
   Tests: T-179, T-180, T-181   Diagram: AD-044   Part 7
   Challenge: Copy exactly three fields. *)
let list _ _ = failwith "not implemented: F-044 Engine.list"
