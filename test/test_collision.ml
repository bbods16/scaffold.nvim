(* test/test_collision.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "collision" >::: [
    "T-111 Collision.unique_name: free name unchanged" >:: (fun _ -> eq_str "f" (Collision.unique_name [] "f"); eq_str "g" (Collision.unique_name ["f"] "g"));
    "T-112 Collision.unique_name: taken gets _2" >:: (fun _ -> eq_str "f_2" (Collision.unique_name ["f"] "f"));
    "T-113 Collision.unique_name: chain" >:: (fun _ -> eq_str "f_4" (Collision.unique_name ["f";"f_2";"f_3"] "f"));
    "T-114 Collision.unique_name: a gap is filled" >:: (fun _ -> eq_str "f_2" (Collision.unique_name ["f";"f_3"] "f"));
    "T-115 Collision.defined_names: python" >:: (fun _ -> eq_strs ["foo";"Bar"] (Collision.defined_names (lang "python") "import os\n\ndef foo(x):\n    return x\nclass Bar:\n  pass"));
    "T-116 Collision.defined_names: javascript" >:: (fun _ -> eq_strs ["a";"b";"c"] (Collision.defined_names (lang "javascript") "const a = 1;\n  let b;\nfunction c() {}"));
    "T-117 Collision.defined_names: ocaml let rec" >:: (fun _ -> eq_strs ["go";"x"] (Collision.defined_names (lang "ocaml") "let rec go n = n\nlet x = 1"));
    "T-118 Collision.defined_names: async def wins over def" >:: (fun _ -> eq_strs ["fetch"] (Collision.defined_names (lang "python") "async def fetch():"));
    "T-119 Collision.defined_names: marker needs its trailing space" >:: (fun _ -> eq_strs [] (Collision.defined_names (lang "python") "define x"));
    "T-120 Collision.defined_names: no name / empty" >:: (fun _ -> eq_strs [] (Collision.defined_names (lang "python") "def (x)"); eq_strs [] (Collision.defined_names (lang "python") ""));
    "T-121 Collision.defined_names: duplicates are kept" >:: (fun _ -> eq_strs ["f";"f"] (Collision.defined_names (lang "python") "def f(): pass\ndef f(): pass"));
  ]
