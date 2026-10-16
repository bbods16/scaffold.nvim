(* lib/session.ml  -- The prompting state machine (Part 6). *)
type state = Collecting | Ready | Cancelled

type t = {
  lang : Lang.t;
  algo : Catalog.algo;
  rev_answers : (string * string) list;
  st : state;
}

(* F-035  Session.create : Lang.t -> Catalog.algo -> Session.t
   Start a prompting session: no answers yet, state Collecting.
   Requires: none
   Produces: A Session.t.
   Tests: T-145   Diagram: AD-035   Part 6
   Challenge: Notice that nothing outside the module can build or inspect a Session.t. *)
let create _ _ = failwith "not implemented: F-035 Session.create"

(* F-036  Session.state : Session.t -> Session.state
   Report Collecting, Ready or Cancelled.
   Requires: none
   Produces: A state.
   Tests: T-146, T-147   Diagram: AD-036   Part 6
   Challenge: One line. *)
let state _ = failwith "not implemented: F-036 Session.state"

(* F-037  Session.answers : Session.t -> (string * string) list
   Answers recorded so far, oldest first, as (param name, raw text).
   Requires: none
   Produces: An association list.
   Tests: T-148, T-149   Diagram: AD-037   Part 6
   Challenge: One line. *)
let answers _ = failwith "not implemented: F-037 Session.answers"

(* F-038  Session.pending : Session.t -> (Catalog.param * string) option
   The next question (parameter and ghost), or None when none is left.
   Requires: none
   Produces: Some (param, ghost) or None.
   Tests: T-150, T-151   Diagram: AD-038   Part 6
   Challenge: One line. *)
let pending _ = failwith "not implemented: F-038 Session.pending"

(* F-039  Session.record : Session.t -> string -> (Session.t, Err.t) result
   Record the answer to the pending question; become Ready when it was the last one.
   Requires: none
   Produces: Ok t' (new value; t is untouched) or Error (Session_closed state).
   Returns an error: Session_closed 'ready' | 'cancelled'
   Tests: T-152, T-153, T-154, T-155   Diagram: AD-039   Part 6
   Challenge: Do not accept answers after Ready or Cancelled. *)
let record _ _ = failwith "not implemented: F-039 Session.record"

(* F-040  Session.cancel : Session.t -> Session.t
   Cancel a Collecting session; Ready and Cancelled sessions are returned unchanged.
   Requires: none
   Produces: A session.
   Tests: T-156, T-157, T-158   Diagram: AD-040   Part 6
   Challenge: Do not touch recorded answers. *)
let cancel _ = failwith "not implemented: F-040 Session.cancel"
