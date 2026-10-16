(* lib/insert.ml  -- Where generated text goes, as data (Part 7). *)
type mode = Cursor | Function | File
type plan = { text : string; file : string option }

(* F-041  Insert.reindent : string -> string -> string
   Prefix every non-blank line of a block with an indent string; blank lines stay blank.
   Requires: none
   Produces: The re-indented block with the same number of lines.
   Tests: T-159, T-160, T-161, T-162, T-163   Diagram: AD-041   Part 7
   Challenge: A line holding only spaces counts as blank. *)
let reindent _ _ = failwith "not implemented: F-041 Insert.reindent"

(* F-042  Insert.place : Lang.t -> Insert.mode -> cursor_indent:string -> name:string -> body:string -> Insert.plan
   Decide what to insert and where: Cursor re-indents; Function adds a blank line before and a newline after; File adds a final newline and a file name.
   Requires: File mode: name has at least one word
   Produces: A plan: text, and Some file name only for File mode.
   Raises (exception/error): Invalid_argument from Lang.file_name in File mode when name has no words
   Tests: T-164, T-165, T-166, T-167   Diagram: AD-042   Part 7
   Challenge: File names use the language's own style. *)
let place _ _ ~cursor_indent:_ ~name:_ ~body:_ = failwith "not implemented: F-042 Insert.place"
