(* test/test_session.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "session" >::: [
    "T-145 Session.create: fresh" >:: (fun _ -> let s = Session.create (lang "python") (algo "stack") in assert_bool "collecting" (Session.state s = Session.Collecting); assert_bool "empty" (Session.answers s = []));
    "T-146 Session.state: walk the states" >:: (fun _ -> let s0 = Session.create (lang "python") (algo "stack") in let s1 = get_ok (Session.record s0 "a") in assert_bool "c" (Session.state s1 = Session.Collecting); let s2 = get_ok (Session.record s1 "int") in assert_bool "r" (Session.state s2 = Session.Ready));
    "T-147 Session.state: cancelled" >:: (fun _ -> assert_bool "x" (Session.state (Session.cancel (Session.create (lang "python") (algo "stack"))) = Session.Cancelled));
    "T-148 Session.answers: order" >:: (fun _ -> let s = get_ok (Session.record (get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A")) "bool") in assert_bool "order" (Session.answers s = [("type_name","A");("elem","bool")]));
    "T-149 Session.answers: empty" >:: (fun _ -> assert_bool "empty" (Session.answers (Session.create (lang "python") (algo "stack")) = []));
    "T-150 Session.pending: first and second" >:: (fun _ -> let s = Session.create (lang "python") (algo "binary-search") in (match Session.pending s with Some (p, _) -> eq_str "fn" p.Catalog.name | None -> assert_failure "some"); (match Session.pending (get_ok (Session.record s "f")) with Some (p, _) -> eq_str "elem" p.Catalog.name | None -> assert_failure "some"));
    "T-151 Session.pending: none when complete" >:: (fun _ -> assert_bool "none" (Session.pending (get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u")) = None));
    "T-152 Session.record: records and does not mutate" >:: (fun _ -> let s = Session.create (lang "python") (algo "stack") in let s' = get_ok (Session.record s "A") in assert_bool "orig" (Session.answers s = []); assert_bool "new" (Session.answers s' = [("type_name","A")]));
    "T-153 Session.record: ready exactly after the last answer" >:: (fun _ -> let s = get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A") in assert_bool "not yet" (Session.state s = Session.Collecting); assert_bool "now" (Session.state (get_ok (Session.record s "int")) = Session.Ready));
    "T-154 Session.record: after ready" >:: (fun _ -> let s = get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u") in assert_bool "err" (Session.record s "x" = Error (Err.Session_closed "ready")) );
    "T-155 Session.record: after cancel" >:: (fun _ -> assert_bool "err" (Session.record (Session.cancel (Session.create (lang "python") (algo "stack"))) "x" = Error (Err.Session_closed "cancelled")));
    "T-156 Session.cancel: cancel" >:: (fun _ -> assert_bool "c" (Session.state (Session.cancel (Session.create (lang "python") (algo "stack"))) = Session.Cancelled));
    "T-157 Session.cancel: ready is not cancelled" >:: (fun _ -> assert_bool "r" (Session.state (Session.cancel (get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u"))) = Session.Ready));
    "T-158 Session.cancel: answers survive a cancel" >:: (fun _ -> let s = get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A") in assert_bool "kept" (Session.answers (Session.cancel s) = [("type_name","A")]));
  ]
