(* lib/cli.ml  -- The command line as a pure function (Part 8). *)
type parsed = {
  cmd : string option;
  set : (string * string) list;
  flags : (string * string) list;
  json : bool;
}

type outcome = { code : int; stdout : string; stderr : string }
type ask = prompt:string -> ghost:string -> string option

(* F-045  Cli.parse_flags : string list -> (Cli.parsed, Err.t) result
   Parse argv (without the program name) into command, --set pairs, value flags and the --json switch.
   Requires: none
   Produces: Ok parsed, or Unknown_flag / Missing_value / Bad_set / Unexpected_arg.
   Returns an error: Unknown_flag f
   Returns an error: Missing_value f
   Returns an error: Bad_set v
   Returns an error: Unexpected_arg a
   Tests: T-182, T-183, T-184, T-185, T-186, T-187, T-188, T-189, T-190   Diagram: AD-045   Part 8
   Challenge: Treat --set a=b=c as name a, value b=c. *)
let parse_flags _ = failwith "not implemented: F-045 Cli.parse_flags"

(* F-046  Cli.resolve_lang : Lang.t list -> (string * string) list -> string option
   Pick the language id from the flags: --lang wins; otherwise map --ft through the registry; an unmapped --ft is returned as is (so the engine reports unknown_lang with that text).
   Requires: none
   Produces: Some id or None when neither flag is present.
   Tests: T-191, T-192, T-193, T-194   Diagram: AD-046   Part 8
   Challenge: Do not validate the id here; the engine owns that error. *)
let resolve_lang _ _ = failwith "not implemented: F-046 Cli.resolve_lang"

(* F-047  Cli.run_list : Lang.t list -> (string * string) list -> (Engine.item list, Err.t) result
   The list command: resolve the language and list its algorithms.
   Requires: none
   Produces: Engine.list's result.
   Returns an error: Unknown_lang
   Tests: T-195, T-196, T-197   Diagram: AD-047   Part 8
   Challenge: One line. *)
let run_list _ _ = failwith "not implemented: F-047 Cli.run_list"

(* F-048  Cli.run_prompts : Lang.t list -> (string * string) list -> ((Catalog.param * string) list, Err.t) result
   The prompts command: every parameter of an algorithm, each with its ghost text.
   Requires: none
   Produces: Ok list or Unknown_lang / Unknown_algo.
   Returns an error: Unknown_lang
   Returns an error: Unknown_algo
   Tests: T-198, T-199, T-200   Diagram: AD-048   Part 8
   Challenge: Same check order as Engine.generate. *)
let run_prompts _ _ = failwith "not implemented: F-048 Cli.run_prompts"

(* F-049  Cli.run_gen : Lang.t list -> (string * string) list -> (string * string) list -> (Insert.plan, Err.t) result
   The gen command: validate --mode and --indent, collect existing names (from --scan text, else --existing list), then call Engine.generate.
   Requires: none
   Produces: Ok plan or the first error.
   Returns an error: Bad_value --mode
   Returns an error: Bad_value --indent
   Returns an error: then every Engine.generate error
   Tests: T-201, T-202, T-203, T-204, T-205, T-206, T-207, T-208, T-209, T-210, T-211   Diagram: AD-049   Part 8
   Challenge: --indent -3, --indent x and --mode zzz must all be Bad_value, even if the language is also unknown. *)
let run_gen _ _ _ = failwith "not implemented: F-049 Cli.run_gen"

(* F-050  Cli.run_ask : Lang.t list -> (string * string) list -> ask:Cli.ask -> (Insert.plan option, Err.t) result
   The interactive ask command: drive a Session by calling the ask callback for each pending question, then run_gen with the collected answers. A callback answer of None cancels.
   Requires: none
   Produces: Ok (Some plan), Ok None on cancel, or an error.
   Returns an error: Unknown_lang
   Returns an error: Unknown_algo
   Returns an error: anything run_gen returns
   Tests: T-212, T-213, T-214, T-215, T-216, T-217   Diagram: AD-050   Part 8
   Challenge: No mutable state: the session value flows through the loop. *)
let run_ask _ _ ~ask:_ = failwith "not implemented: F-050 Cli.run_ask"

(* F-051  Cli.run : ?stdin:(unit -> string) -> ?ask:Cli.ask -> string list -> Cli.outcome
   The command line as a pure function: argv in, {code; stdout; stderr} out. Dispatches list / prompts / gen / ask and formats results as text or JSON.
   Requires: none
   Produces: An outcome record.
   Returns an error: exit code 1 domain error
   Returns an error: exit code 2 usage error
   Tests: T-218, T-219, T-220, T-221, T-222, T-223, T-224, T-225, T-226, T-227, T-228, T-229, T-230, T-231, T-232, T-233, T-234, T-235, T-236, T-237, T-238   Diagram: AD-051   Part 8
   Challenge: ask without a callback is Unknown_command 'ask' (exit 2). *)
let run ?stdin:_ ?ask:_ _ = failwith "not implemented: F-051 Cli.run"
