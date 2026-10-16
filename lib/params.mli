(* lib/params.mli  -- the INTERFACE. Read the contract above each val; you implement it in params.ml. *)
(* F-030  Params.normalize_ident : Lang.t -> Catalog.param -> string -> (string, Err.t) result
   Turn what the user typed for a name parameter into a valid identifier in the right style for the language and parameter kind.
   Requires: none
   Produces: Ok identifier or Error (Bad_ident {param = name; value = raw}).
   Returns an error: Bad_ident
   Tests: T-122, T-123, T-124, T-125, T-126   Diagram: AD-030   Part 6
   Challenge: Include the original (untrimmed) text in the error so the user sees what they typed. *)
val normalize_ident : Lang.t -> Catalog.param -> string -> (string, Err.t) result
(* F-031  Params.normalize_elem : Lang.t -> string -> (string, Err.t) result
   Map the user's element-type word (int, float, string, bool; any case) to the language's own type name.
   Requires: none
   Produces: Ok type name or Error (Bad_elem raw).
   Returns an error: Bad_elem
   Tests: T-127, T-128, T-129   Diagram: AD-031   Part 6
   Challenge: Keep the original text in the error. *)
val normalize_elem : Lang.t -> string -> (string, Err.t) result
(* F-032  Params.ghost : Lang.t -> Catalog.param -> string
   The ghost text (placeholder preview) for a prompt: the default, styled as the final identifier would be.
   Requires: none
   Produces: A string.
   Tests: T-130, T-131, T-132   Diagram: AD-032   Part 6
   Challenge: Do not duplicate the style choice. *)
val ghost : Lang.t -> Catalog.param -> string

(* F-033  Params.resolve : ?existing:string list -> Lang.t -> Catalog.algo -> (string * string) list -> ((string * string) list, Err.t) result
   Turn the user's raw answers into final template values for every parameter of the algorithm: fill defaults, normalise, avoid existing names.
   Requires: none
   Produces: Ok (name, value) list in the algorithm's parameter order, or the first error.
   Returns an error: Unknown_param
   Returns an error: Bad_ident
   Returns an error: Bad_elem
   Tests: T-133, T-134, T-135, T-136, T-137, T-138, T-139, T-140   Diagram: AD-033   Part 6
   Challenge: Check unknown answers BEFORE normalising anything, so the error does not depend on parameter order. *)
val resolve :
  ?existing:string list ->
  Lang.t ->
  Catalog.algo ->
  (string * string) list ->
  ((string * string) list, Err.t) result

(* F-034  Params.next_prompt : Lang.t -> Catalog.algo -> (string * string) list -> (Catalog.param * string) option
   The first parameter that has no answer yet, with its ghost text; None when all are answered.
   Requires: none
   Produces: Some (param, ghost) or None.
   Tests: T-141, T-142, T-143, T-144   Diagram: AD-034   Part 6
   Challenge: Answers for unknown names must not confuse it. *)
val next_prompt :
  Lang.t -> Catalog.algo -> (string * string) list -> (Catalog.param * string) option
