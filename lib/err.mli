(* lib/err.mli  -- the INTERFACE. Read the contract above each val; you implement it in err.ml. *)
type template_error =
  | Unclosed of int
  | Empty_var of int
  | Bad_name of string
  | Bad_filter of string
  | Unbound of string

type t =
  | Bad_lang_config of { field : string; reason : string }
  | Duplicate_id of string
  | Duplicate_filetype of { filetype : string; owner : string }
  | Unknown_lang of string
  | Unknown_algo of string
  | No_template of { algo : string; lang : string }
  | Unknown_param of string
  | Bad_ident of { param : string; value : string }
  | Bad_elem of string
  | Template of template_error
  | Session_closed of string
  | Unknown_flag of string
  | Missing_value of string
  | Bad_set of string
  | Unexpected_arg of string
  | Unknown_command of string
  | Bad_value of { flag : string; value : string }

(* F-008  Err.code : Err.t -> string
   Map every error constructor to its stable snake_case code string.
   Requires: none
   Produces: One of 17 fixed codes, e.g. 'unknown_lang'.
   Tests: T-028, T-029, T-030   Diagram: AD-008   Part 2
   Challenge: Do not use a catch-all _ -> arm: let the compiler tell you when a constructor is missing. *)
val code : t -> string
(* F-009  Err.message : Err.t -> string
   Render any error as a one-line human message. Template errors render through a nested match.
   Requires: none
   Produces: A single-line string with no trailing newline.
   Tests: T-031, T-032, T-033, T-034, T-035   Diagram: AD-009   Part 2
   Challenge: Write the helper for template errors so that Unclosed 7 says where the tag opened (byte offset). *)
val message : t -> string
