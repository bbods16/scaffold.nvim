(* test/test_engine.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "engine" >::: [
    "T-168 Engine.generate: every language x algo generates and mentions its default name" >:: (fun _ -> let regs = regs () in List.iter (fun l -> List.iter (fun (a : Catalog.algo) -> let p = get_ok (Engine.generate regs (opts l a.id [])) in assert_bool (l ^ "/" ^ a.id) (String.length p.Insert.text > 20)) Catalog.all) ["python";"javascript";"ocaml"]);
    "T-169 Engine.generate: python binary search default name" >:: (fun _ -> let regs = regs () in let p = get_ok (Engine.generate regs (opts "python" "binary-search" [])) in assert_bool "def" (contains p.Insert.text "def binary_search("));
    "T-170 Engine.generate: javascript uses camel case" >:: (fun _ -> let regs = regs () in let p = get_ok (Engine.generate regs (opts "javascript" "binary-search" [])) in assert_bool "fn" (contains p.Insert.text "function binarySearch("));
    "T-171 Engine.generate: existing name is suffixed" >:: (fun _ -> let regs = regs () in let p = get_ok (Engine.generate regs { (opts "python" "binary-search" []) with Engine.existing = ["binary_search"] }) in assert_bool "_2" (contains p.Insert.text "def binary_search_2("));
    "T-172 Engine.generate: file mode names the file after the first non-elem param" >:: (fun _ -> let regs = regs () in let p = get_ok (Engine.generate regs { (opts "javascript" "stack" [("type_name","int stack")]) with Engine.mode = Insert.File }) in assert_bool "file" (p.Insert.file = Some "intStack.js"));
    "T-173 Engine.generate: union-find has no elem param" >:: (fun _ -> let regs = regs () in let p = get_ok (Engine.generate regs (opts "ocaml" "union-find" [])) in assert_bool "text" (String.length p.Insert.text > 20));
    "T-174 Engine.generate: unknown language" >:: (fun _ -> let regs = regs () in is_err "unknown_lang" (Engine.generate regs (opts "cobol" "stack" [])));
    "T-175 Engine.generate: unknown algorithm" >:: (fun _ -> let regs = regs () in is_err "unknown_algo" (Engine.generate regs (opts "python" "quicksort" [])));
    "T-176 Engine.generate: language beats algorithm in the check order" >:: (fun _ -> let regs = regs () in is_err "unknown_lang" (Engine.generate regs (opts "cobol" "quicksort" [])));
    "T-177 Engine.generate: parameter errors surface" >:: (fun _ -> let regs = regs () in is_err "unknown_param" (Engine.generate regs (opts "python" "stack" [("colour","x")])); is_err "bad_elem" (Engine.generate regs (opts "python" "stack" [("elem","double")])));
    "T-178 Engine.generate: language registered without templates" >:: (fun _ -> let regs = regs () in let r = get_ok (Lang.register regs cfg0) in is_err "no_template" (Engine.generate r (opts "demo" "stack" [])));
    "T-179 Engine.list: four items for python" >:: (fun _ -> let regs = regs () in let items = get_ok (Engine.list regs "python") in eq_strs ["binary-search";"insertion-sort";"stack";"union-find"] (List.map (fun (i : Engine.item) -> i.id) items));
    "T-180 Engine.list: fields filled" >:: (fun _ -> let regs = regs () in let items = get_ok (Engine.list regs "ocaml") in let i = List.hd items in eq_str "searching" i.Engine.group; eq_str "Binary search" i.Engine.title);
    "T-181 Engine.list: unknown language" >:: (fun _ -> let regs = regs () in is_err "unknown_lang" (Engine.list regs "cobol"); is_err "unknown_lang" (Engine.list regs ""));
  ]
