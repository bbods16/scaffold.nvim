(* lib/session.mli  -- the INTERFACE. Read the contract above each val; you implement it in session.ml. *)
type state = Collecting | Ready | Cancelled
type t

(* F-035  Session.create : Lang.t -> Catalog.algo -> Session.t
   Start a prompting session: no answers yet, state Collecting.
   Requires: none
   Produces: A Session.t.
   Tests: T-145   Diagram: AD-035   Part 6
   Challenge: Notice that nothing outside the module can build or inspect a Session.t. *)
val create : Lang.t -> Catalog.algo -> t
(* F-036  Session.state : Session.t -> Session.state
   Report Collecting, Ready or Cancelled.
   Requires: none
   Produces: A state.
   Tests: T-146, T-147   Diagram: AD-036   Part 6
   Challenge: One line. *)
val state : t -> state
(* F-038  Session.pending : Session.t -> (Catalog.param * string) option
   The next question (parameter and ghost), or None when none is left.
   Requires: none
   Produces: Some (param, ghost) or None.
   Tests: T-150, T-151   Diagram: AD-038   Part 6
   Challenge: One line. *)
val pending : t -> (Catalog.param * string) option
(* F-039  Session.record : Session.t -> string -> (Session.t, Err.t) result
   Record the answer to the pending question; become Ready when it was the last one.
   Requires: none
   Produces: Ok t' (new value; t is untouched) or Error (Session_closed state).
   Returns an error: Session_closed 'ready' | 'cancelled'
   Tests: T-152, T-153, T-154, T-155   Diagram: AD-039   Part 6
   Challenge: Do not accept answers after Ready or Cancelled. *)
val record : t -> string -> (t, Err.t) result
(* F-037  Session.answers : Session.t -> (string * string) list
   Answers recorded so far, oldest first, as (param name, raw text).
   Requires: none
   Produces: An association list.
   Tests: T-148, T-149   Diagram: AD-037   Part 6
   Challenge: One line. *)
val answers : t -> (string * string) list
(* F-040  Session.cancel : Session.t -> Session.t
   Cancel a Collecting session; Ready and Cancelled sessions are returned unchanged.
   Requires: none
   Produces: A session.
   Tests: T-156, T-157, T-158   Diagram: AD-040   Part 6
   Challenge: Do not touch recorded answers. *)
val cancel : t -> t
