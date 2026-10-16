(* lib/json.mli  -- the INTERFACE. Read the contract above each val; you implement it in json.ml. *)
type t =
  | Null
  | Bool of bool
  | Int of int
  | Str of string
  | List of t list
  | Obj of (string * t) list

(* F-010  Json.escape : string -> string
   Escape a string for use inside a JSON string literal (quotes, backslash, control characters).
   Requires: none
   Produces: A string safe to wrap in double quotes.
   Tests: T-036, T-037, T-038, T-039   Diagram: AD-010   Part 2
   Challenge: Escape 0x01 as \u0001 (lowercase hex, four digits). *)
val escape : string -> string
(* F-011  Json.to_string : Json.t -> string
   Serialise a Json.t as compact JSON (no spaces, object keys in the given order).
   Requires: none
   Produces: Compact JSON text.
   Tests: T-040, T-041, T-042, T-043, T-044   Diagram: AD-011   Part 2
   Challenge: Escape object keys as well as string values. *)
val to_string : t -> string
