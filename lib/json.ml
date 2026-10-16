(* lib/json.ml  -- A tiny hand-written JSON encoder (Part 2). *)
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
let escape _ = failwith "not implemented: F-010 Json.escape"

(* F-011  Json.to_string : Json.t -> string
   Serialise a Json.t as compact JSON (no spaces, object keys in the given order).
   Requires: none
   Produces: Compact JSON text.
   Tests: T-040, T-041, T-042, T-043, T-044   Diagram: AD-011   Part 2
   Challenge: Escape object keys as well as string values. *)
let to_string _ = failwith "not implemented: F-011 Json.to_string"
