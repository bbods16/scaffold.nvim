(* lib/collision.mli  -- the INTERFACE. Read the contract above each val; you implement it in collision.ml. *)
(* F-028  Collision.unique_name : string list -> string -> string
   Return the name unchanged if free, otherwise name_2, name_3, ... the first free suffix.
   Requires: none
   Produces: A name not in existing.
   Tests: T-111, T-112, T-113, T-114   Diagram: AD-028   Part 5
   Challenge: Skip over suffixes that are themselves taken (x, x_2 taken gives x_3). *)
val unique_name : string list -> string -> string
(* F-029  Collision.defined_names : Lang.t -> string -> string list
   Names the buffer text defines, found by looking at the start of each trimmed line for one of the language's def_markers.
   Requires: none
   Produces: Names in order of appearance, duplicates kept.
   Tests: T-115, T-116, T-117, T-118, T-119, T-120, T-121   Diagram: AD-029   Part 5
   Challenge: Do not mistake define x for def x: the marker includes its trailing space. *)
val defined_names : Lang.t -> string -> string list
