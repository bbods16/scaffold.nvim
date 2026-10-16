(* lib/util.ml  -- String helpers with no dependencies (Part 0-1). *)
(* F-001  Util.trim : string -> string
   Remove leading and trailing ASCII whitespace (space, tab, newline, CR, VT, FF).
   Requires: none
   Produces: A new string; the input is never modified (OCaml strings are immutable).
   Tests: T-001, T-002, T-003   Diagram: AD-001   Part 0
   Challenge: Handle the all-whitespace string and the empty string without raising Invalid_argument. *)
let trim _ = failwith "not implemented: F-001 Util.trim"

(* F-002  Util.starts_with : string -> prefix:string -> bool
   True when the string begins with the prefix (labelled argument ~prefix).
   Requires: none
   Produces: true or false.
   Tests: T-004, T-005, T-006   Diagram: AD-002   Part 0
   Challenge: Make it safe when the prefix is longer than the string, without catching an exception. *)
let starts_with _ ~prefix:_ = failwith "not implemented: F-002 Util.starts_with"

(* F-003  Util.find_sub : string -> sub:string -> from:int -> int option
   Index of the first occurrence of sub at or after from, or None. Plain text search, no patterns.
   Requires: from >= 0
   Produces: Some index (0-based) or None.
   Raises (exception/error): Invalid_argument if from is negative
   Tests: T-007, T-008, T-009, T-010   Diagram: AD-003   Part 1
   Challenge: Return None (not an exception) when from is past the end of the string. *)
let find_sub _ ~sub:_ ~from:_ = failwith "not implemented: F-003 Util.find_sub"

(* F-004  Util.split : string -> sep:string -> string list
   Split a string on a non-empty separator, keeping empty pieces (like String.split_on_char but for multi-character separators).
   Requires: sep <> ''
   Produces: A list with (number of separators + 1) strings.
   Raises (exception/error): Invalid_argument if sep is the empty string
   Tests: T-011, T-012, T-013, T-014   Diagram: AD-004   Part 1
   Challenge: Keep the trailing empty string in split 'a,b,' ~sep:','. *)
let split _ ~sep:_ = failwith "not implemented: F-004 Util.split"

(* F-005  Util.leading_ws : string -> string
   The run of spaces and tabs at the start of a line (the line's indentation).
   Requires: none
   Produces: A (possibly empty) string made only of spaces and tabs.
   Tests: T-015, T-016, T-017   Diagram: AD-005   Part 1
   Challenge: Decide what '\n' and '\r' do (they are not indentation). *)
let leading_ws _ = failwith "not implemented: F-005 Util.leading_ws"
