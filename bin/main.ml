(* bin/main.ml  -- the only impure module (Part 8). *)
(* F-052  Main.main : unit  (the program's entry point)
   Connect Cli.run to the real process: read argv, stdin, an interactive ask callback on the terminal, print the outcome, and exit with its code.
   Requires: none
   Produces: Process exit status = outcome.code.
   Tests: see test/acceptance.sh   Diagram: AD-052   Part 8
   Challenge: Print nothing at all when stdout/stderr are empty. *)
let () =
  prerr_endline "not implemented: F-052 Main.main";
  exit 2
