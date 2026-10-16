(* test/test_util.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "util" >::: [
    "T-001 Util.trim: trims both sides" >:: (fun _ -> eq_str "x" (Util.trim "  x  "));
    "T-002 Util.trim: empty and blank strings" >:: (fun _ -> eq_str "" (Util.trim ""); eq_str "" (Util.trim " \t\r\n"));
    "T-003 Util.trim: inner whitespace survives" >:: (fun _ -> eq_str "a  b" (Util.trim "\ta  b\n"));
    "T-004 Util.starts_with: true on match" >:: (fun _ -> eq_bool true (Util.starts_with "def f" ~prefix:"def "));
    "T-005 Util.starts_with: empty prefix always matches" >:: (fun _ -> eq_bool true (Util.starts_with "" ~prefix:""));
    "T-006 Util.starts_with: longer prefix does not raise" >:: (fun _ -> eq_bool false (Util.starts_with "de" ~prefix:"def "));
    "T-007 Util.find_sub: finds first match" >:: (fun _ -> eq_io (Some 1) (Util.find_sub "xabcabc" ~sub:"abc" ~from:0));
    "T-008 Util.find_sub: from skips earlier match" >:: (fun _ -> eq_io (Some 4) (Util.find_sub "xabcabc" ~sub:"abc" ~from:2));
    "T-009 Util.find_sub: not found and past-the-end" >:: (fun _ -> eq_io None (Util.find_sub "abc" ~sub:"z" ~from:0); eq_io None (Util.find_sub "abc" ~sub:"c" ~from:3));
    "T-010 Util.find_sub: negative from raises" >:: (fun _ -> raises_invalid (fun () -> Util.find_sub "abc" ~sub:"a" ~from:(-1)));
    "T-011 Util.split: splits on comma" >:: (fun _ -> eq_strs ["a";"b";"c"] (Util.split "a,b,c" ~sep:","));
    "T-012 Util.split: keeps empty pieces" >:: (fun _ -> eq_strs ["a";"b";""] (Util.split "a,b," ~sep:","); eq_strs [""] (Util.split "" ~sep:","));
    "T-013 Util.split: multi-character separator" >:: (fun _ -> eq_strs ["a";"b"] (Util.split "a<>b" ~sep:"<>"));
    "T-014 Util.split: empty separator raises" >:: (fun _ -> raises_invalid (fun () -> Util.split "abc" ~sep:""));
    "T-015 Util.leading_ws: spaces" >:: (fun _ -> eq_str "  " (Util.leading_ws "  x"));
    "T-016 Util.leading_ws: tabs and empty" >:: (fun _ -> eq_str "\t " (Util.leading_ws "\t x"); eq_str "" (Util.leading_ws ""));
    "T-017 Util.leading_ws: newline stops the scan" >:: (fun _ -> eq_str "" (Util.leading_ws "\n  x"));
  ]
