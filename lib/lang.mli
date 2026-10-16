(* lib/lang.mli  -- the INTERFACE. Read the contract above each val; you implement it in lang.ml. *)
type elem = Int | Float | String | Bool

type types = {
  int_t : string;
  float_t : string;
  string_t : string;
  bool_t : string;
}

type cfg = {
  id : string;
  filetypes : string list;
  extension : string;
  indent_width : int;
  camel_case : bool;
  types : types;
  def_markers : string list;
}

type t = { cfg : cfg; indent : string; fn_style : Naming.style }

(* F-012  Lang.validate : Lang.cfg -> (Lang.cfg, Err.t) result
   Check a language configuration and return it unchanged, or the first problem as Bad_lang_config {field; reason}.
   Requires: none
   Produces: Ok cfg when every rule holds; otherwise Error (Bad_lang_config {field; reason}).
   Returns an error: Bad_lang_config for the first violated rule
   Tests: T-045, T-046, T-047, T-048, T-049, T-050, T-051, T-052   Diagram: AD-012   Part 3
   Challenge: Write one local helper bad field reason so each check is one line. *)
val validate : cfg -> (cfg, Err.t) result
(* F-013  Lang.derive : Lang.cfg -> Lang.t
   Compute the derived fields of a validated config: the indent string and the function-name style.
   Requires: indent_width >= 0
   Produces: A Lang.t holding the same cfg.
   Raises (exception/error): Invalid_argument from String.make when indent_width < 0 (validate prevents it)
   Tests: T-053, T-054, T-055, T-056   Diagram: AD-013   Part 3
   Challenge: Return the same cfg value rather than a copy of its fields. *)
val derive : cfg -> t
(* F-014  Lang.register : Lang.t list -> Lang.cfg -> (Lang.t list, Err.t) result
   Validate a config, reject duplicate ids and duplicate filetypes, and append the derived language to the registry.
   Requires: none
   Produces: Ok (reg @ [derive cfg]) or the first error.
   Returns an error: Bad_lang_config
   Returns an error: Duplicate_id
   Returns an error: Duplicate_filetype {filetype; owner}
   Tests: T-057, T-058, T-059, T-060, T-061   Diagram: AD-014   Part 3
   Challenge: Report WHICH language owns the clashing filetype. *)
val register : t list -> cfg -> (t list, Err.t) result
(* F-015  Lang.find : Lang.t list -> string -> Lang.t option
   Look a language up by its id.
   Requires: none
   Produces: Some lang or None.
   Tests: T-062, T-063, T-064   Diagram: AD-015   Part 3
   Challenge: One line. *)
val find : t list -> string -> t option
(* F-016  Lang.find_by_filetype : Lang.t list -> string -> Lang.t option
   Look a language up by a Neovim filetype (a language may own several, e.g. javascript and javascriptreact).
   Requires: none
   Produces: Some lang or None.
   Tests: T-065, T-066, T-067   Diagram: AD-016   Part 3
   Challenge: One line. *)
val find_by_filetype : t list -> string -> t option
(* F-017  Lang.file_name : Lang.t -> string -> string
   Build the file name for File insert mode: the base converted to the language's function style plus its extension.
   Requires: base has at least one word
   Produces: e.g. 'binary_search.py'.
   Raises (exception/error): Invalid_argument when base has no words
   Tests: T-068, T-069, T-070, T-071   Diagram: AD-017   Part 3
   Challenge: Make the empty-stem case fail loudly instead of returning '.py'. *)
val file_name : t -> string -> string
(* F-018  Lang.elem_type : Lang.t -> Lang.elem -> string
   The language's spelling of an element type (int, float, string, bool).
   Requires: none
   Produces: A non-empty type name.
   Tests: T-072, T-073, T-074   Diagram: AD-018   Part 3
   Challenge: No wildcard arm. *)
val elem_type : t -> elem -> string
