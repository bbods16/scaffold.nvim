(* test/test_template.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "template" >::: [
    "T-079 Template.scan_tag: name only" >:: (fun _ -> (match Template.scan_tag "<%x%>" 0 with Ok (Template.Var { name; filters }, next) -> eq_str "x" name; eq_int 0 (List.length filters); eq_int 5 next | _ -> assert_failure "expected Var"));
    "T-080 Template.scan_tag: filters in order" >:: (fun _ -> (match Template.scan_tag "<% fn | snake | upper %>" 0 with Ok (Template.Var { name; filters }, _) -> eq_str "fn" name; assert_bool "order" (filters = [Template.Snake; Template.Upper]) | _ -> assert_failure "expected Var"));
    "T-081 Template.scan_tag: starts mid-text and reports next offset" >:: (fun _ -> (match Template.scan_tag "ab<%x%>cd" 2 with Ok (_, next) -> eq_int 7 next | _ -> assert_failure "expected Ok"));
    "T-082 Template.scan_tag: unclosed" >:: (fun _ -> assert_bool "unclosed" (Template.scan_tag "ab <% x" 3 = Error (Err.Unclosed 3)));
    "T-083 Template.scan_tag: empty placeholder" >:: (fun _ -> assert_bool "empty" (Template.scan_tag "<%  %>" 0 = Error (Err.Empty_var 0)));
    "T-084 Template.scan_tag: bad name" >:: (fun _ -> assert_bool "bad" (Template.scan_tag "<% 1x %>" 0 = Error (Err.Bad_name "1x")); assert_bool "upper" (Template.scan_tag "<% Fn %>" 0 = Error (Err.Bad_name "Fn")));
    "T-085 Template.scan_tag: bad filter" >:: (fun _ -> assert_bool "filter" (Template.scan_tag "<% x | shout %>" 0 = Error (Err.Bad_filter "shout")));
    "T-086 Template.parse: text var text" >:: (fun _ -> (match Template.parse "a<%x%>b" with Ok [Template.Text "a"; Template.Var { name = "x"; filters = [] }; Template.Text "b"] -> () | _ -> assert_failure "shape"));
    "T-087 Template.parse: adjacent tags" >:: (fun _ -> (match Template.parse "<%a%><%b%>" with Ok [Template.Var _; Template.Var _] -> () | _ -> assert_failure "two Vars, no Text"));
    "T-088 Template.parse: empty input and plain text" >:: (fun _ -> assert_bool "empty" (Template.parse "" = Ok []); assert_bool "plain" (Template.parse "a < b % c" = Ok [Template.Text "a < b % c"]));
    "T-089 Template.parse: error from a later tag" >:: (fun _ -> assert_bool "err" (Template.parse "ok <% a %> then <% b" = Error (Err.Unclosed 16)));
    "T-090 Template.parse: first error wins" >:: (fun _ -> assert_bool "first" (Template.parse "<% 1 %><% b" = Error (Err.Bad_name "1")));
    "T-091 Template.vars: order of first appearance" >:: (fun _ -> eq_strs ["b";"a"] (Template.vars (get_ok_t (Template.parse "<%b%> <%a%> <%b | upper%>"))));
    "T-092 Template.vars: text only and empty" >:: (fun _ -> eq_strs [] (Template.vars (get_ok_t (Template.parse "plain"))); eq_strs [] (Template.vars []));
    "T-093 Template.vars: filters do not create new names" >:: (fun _ -> eq_strs ["x"] (Template.vars (get_ok_t (Template.parse "<%x|upper%><%x|lower%>"))));
    "T-094 Template.apply_filter: four naming filters" >:: (fun _ -> eq_str "foo_bar" (Template.apply_filter Template.Snake "fooBar"); eq_str "fooBar" (Template.apply_filter Template.Camel "foo bar"); eq_str "FooBar" (Template.apply_filter Template.Pascal "foo_bar"); eq_str "FOO_BAR" (Template.apply_filter Template.Upper_snake "fooBar"));
    "T-095 Template.apply_filter: case filters" >:: (fun _ -> eq_str "FOOBAR" (Template.apply_filter Template.Upper "fooBar"); eq_str "foobar" (Template.apply_filter Template.Lower "fooBar"));
    "T-096 Template.apply_filter: empty" >:: (fun _ -> eq_str "" (Template.apply_filter Template.Pascal ""));
    "T-097 Template.render: substitutes with filters" >:: (fun _ -> eq_str_t "def binary_search()" (Template.render (get_ok_t (Template.parse "def <% fn | snake %>()")) [("fn","binarySearch")]));
    "T-098 Template.render: filter order matters" >:: (fun _ -> eq_str_t "FOO_BAR" (Template.render (get_ok_t (Template.parse "<% x | snake | upper %>")) [("x","fooBar")]));
    "T-099 Template.render: empty template, extra env" >:: (fun _ -> eq_str_t "" (Template.render [] [("a","1")]));
    "T-100 Template.render: unbound" >:: (fun _ -> assert_bool "unbound" (Template.render (get_ok_t (Template.parse "<% q %>")) [] = Error (Err.Unbound "q")));
    "T-101 Template.render: same variable used twice" >:: (fun _ -> eq_str_t "aa" (Template.render (get_ok_t (Template.parse "<%x%><%x%>")) [("x","a")]));
  ]
