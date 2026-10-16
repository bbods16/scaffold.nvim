(* lib/langs.mli  -- the INTERFACE. Read the contract above each val; you implement it in langs.ml. *)
val configs : Lang.cfg list
(* F-019  Langs.install : Lang.t list -> Lang.t list
   Add the three built-in languages that are missing from a registry (python, javascript, ocaml).
   Requires: none
   Produces: The registry plus any missing built-ins, in config order.
   Raises (exception/error): Failure if a built-in config is invalid (cannot happen with the shipped data)
   Tests: T-075, T-076, T-077, T-078   Diagram: AD-019   Part 3
   Challenge: Make a user override of python survive. *)
val install : Lang.t list -> Lang.t list
