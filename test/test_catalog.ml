(* test/test_catalog.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "catalog" >::: [
    "T-102 Catalog.find: four algorithms" >:: (fun _ -> List.iter (fun id -> assert_bool id (Catalog.find id <> None)) ["binary-search";"insertion-sort";"stack";"union-find"]);
    "T-103 Catalog.find: exact match" >:: (fun _ -> assert_bool "none" (Catalog.find "Stack" = None); assert_bool "none" (Catalog.find "" = None));
    "T-104 Catalog.find: unknown" >:: (fun _ -> assert_bool "none" (Catalog.find "quicksort" = None));
    "T-105 Catalog.template: all built-in pairs exist" >:: (fun _ -> List.iter (fun l -> List.iter (fun a -> assert_bool (l ^ a) (Catalog.template ~algo_id:a ~lang_id:l <> None)) ["binary-search";"insertion-sort";"stack";"union-find"]) ["python";"javascript";"ocaml"]);
    "T-106 Catalog.template: unknown language/algo" >:: (fun _ -> assert_bool "l" (Catalog.template ~algo_id:"stack" ~lang_id:"cobol" = None); assert_bool "a" (Catalog.template ~algo_id:"zzz" ~lang_id:"python" = None));
    "T-107 Catalog.template: every template parses and renders against its algo params" >:: (fun _ -> List.iter (fun (a : Catalog.algo) -> List.iter (fun l -> let text = Option.get (Catalog.template ~algo_id:a.id ~lang_id:l) in let segs = get_ok_t (Template.parse text) in List.iter (fun v -> assert_bool (a.id ^ " uses " ^ v) (List.exists (fun (p : Catalog.param) -> p.name = v) a.params)) (Template.vars segs)) ["python";"javascript";"ocaml"]) Catalog.all);
    "T-108 Catalog.for_lang: python has all four in order" >:: (fun _ -> eq_strs ["binary-search";"insertion-sort";"stack";"union-find"] (List.map (fun a -> a.Catalog.id) (Catalog.for_lang "python")));
    "T-109 Catalog.for_lang: unknown language" >:: (fun _ -> eq_int 0 (List.length (Catalog.for_lang "cobol")));
    "T-110 Catalog.for_lang: empty id" >:: (fun _ -> eq_int 0 (List.length (Catalog.for_lang "")));
  ]
