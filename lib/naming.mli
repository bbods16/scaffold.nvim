(* lib/naming.mli  -- the INTERFACE. Read the contract above each val; you implement it in naming.ml. *)
type style = Snake | Camel | Pascal | Upper_snake

(* F-006  Naming.words : string -> string list
   Split an identifier-like string into lowercase words at separators, lower-to-upper transitions, digit-to-upper transitions and acronym ends.
   Requires: none
   Produces: Lowercase words in order; [] when there is no alphanumeric character.
   Tests: T-018, T-019, T-020, T-021, T-022   Diagram: AD-006   Part 1
   Challenge: Get 'HTTPServer' = [http; server] and 'x2Y' = [x2; y] right without special-casing either string. *)
val words : string -> string list
(* F-007  Naming.convert : Naming.style -> string -> string
   Re-style a string as snake_case, camelCase, PascalCase or UPPER_SNAKE using words.
   Requires: Naming.words works
   Produces: The restyled string; '' when there are no words.
   Tests: T-023, T-024, T-025, T-026, T-027   Diagram: AD-007   Part 1
   Challenge: Camel case keeps the first word lowercase. Express that without an index counter. *)
val convert : style -> string -> string
