(* test/test_insert.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "insert" >::: [
    "T-159 Insert.reindent: indents each line" >:: (fun _ -> eq_str "  a\n  b" (Insert.reindent "  " "a\nb"));
    "T-160 Insert.reindent: blank lines untouched" >:: (fun _ -> eq_str "  a\n\n  b" (Insert.reindent "  " "a\n\nb"));
    "T-161 Insert.reindent: trailing newline" >:: (fun _ -> eq_str "\ta\n" (Insert.reindent "\t" "a\n"));
    "T-162 Insert.reindent: empty indent is identity" >:: (fun _ -> eq_str "a\nb" (Insert.reindent "" "a\nb"));
    "T-163 Insert.reindent: whitespace-only line is blank" >:: (fun _ -> eq_str "  " (Insert.reindent "xx" "  "));
    "T-164 Insert.place: cursor" >:: (fun _ -> let p = Insert.place (lang "python") Insert.Cursor ~cursor_indent:"  " ~name:"f" ~body:"a\nb" in eq_str "  a\n  b" p.Insert.text; assert_bool "nofile" (p.Insert.file = None));
    "T-165 Insert.place: function" >:: (fun _ -> let p = Insert.place (lang "python") Insert.Function ~cursor_indent:"  " ~name:"f" ~body:"a" in eq_str "\na\n" p.Insert.text; assert_bool "nofile" (p.Insert.file = None));
    "T-166 Insert.place: file" >:: (fun _ -> let p = Insert.place (lang "python") Insert.File ~cursor_indent:"" ~name:"Binary Search" ~body:"a" in eq_str "a\n" p.Insert.text; assert_bool "file" (p.Insert.file = Some "binary_search.py"));
    "T-167 Insert.place: file with empty stem raises" >:: (fun _ -> raises_invalid (fun () -> Insert.place (lang "python") Insert.File ~cursor_indent:"" ~name:"--" ~body:"x"));
  ]
