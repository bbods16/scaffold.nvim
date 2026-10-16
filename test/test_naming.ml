(* test/test_naming.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "naming" >::: [
    "T-018 Naming.words: camel and snake" >:: (fun _ -> eq_strs ["foo";"bar"] (Naming.words "fooBar"); eq_strs ["foo";"bar"] (Naming.words "foo_bar"));
    "T-019 Naming.words: acronym" >:: (fun _ -> eq_strs ["http";"server"] (Naming.words "HTTPServer"));
    "T-020 Naming.words: digits" >:: (fun _ -> eq_strs ["x2";"y"] (Naming.words "x2Y"));
    "T-021 Naming.words: empty and separators only" >:: (fun _ -> eq_strs [] (Naming.words ""); eq_strs [] (Naming.words "_-_"));
    "T-022 Naming.words: non-ASCII bytes are separators, never an exception" >:: (fun _ -> eq_strs ["a";"bc"] (Naming.words "\xc3\xa9ABc"));
    "T-023 Naming.convert: snake" >:: (fun _ -> eq_str "binary_search" (Naming.convert Naming.Snake "Binary Search"));
    "T-024 Naming.convert: camel and pascal" >:: (fun _ -> eq_str "binarySearch" (Naming.convert Naming.Camel "binary search"); eq_str "BinarySearch" (Naming.convert Naming.Pascal "binary search"));
    "T-025 Naming.convert: upper snake" >:: (fun _ -> eq_str "UNION_FIND" (Naming.convert Naming.Upper_snake "unionFind"));
    "T-026 Naming.convert: empty" >:: (fun _ -> eq_str "" (Naming.convert Naming.Camel ""));
    "T-027 Naming.convert: separators only" >:: (fun _ -> eq_str "" (Naming.convert Naming.Pascal "--"));
  ]
