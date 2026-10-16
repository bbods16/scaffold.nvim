(* test/test_params.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "params" >::: [
    "T-122 Params.normalize_ident: function style per language" >:: (fun _ -> eq_str_e "binary_search" (Params.normalize_ident (lang "python") (param "fn") "Binary Search"); eq_str_e "binarySearch" (Params.normalize_ident (lang "javascript") (param "fn") "binary search"));
    "T-123 Params.normalize_ident: types are Pascal everywhere" >:: (fun _ -> eq_str_e "UnionFind" (Params.normalize_ident (lang "python") (param "type_name") "union find"); eq_str_e "UnionFind" (Params.normalize_ident (lang "ocaml") (param "type_name") "union_find"));
    "T-124 Params.normalize_ident: surrounding space is trimmed" >:: (fun _ -> eq_str_e "stack" (Params.normalize_ident (lang "python") (param "fn") "  stack "));
    "T-125 Params.normalize_ident: digit first" >:: (fun _ -> is_err "bad_ident" (Params.normalize_ident (lang "python") (param "fn") "2fast"));
    "T-126 Params.normalize_ident: empty / no words" >:: (fun _ -> is_err "bad_ident" (Params.normalize_ident (lang "python") (param "fn") ""); is_err "bad_ident" (Params.normalize_ident (lang "python") (param "fn") "--"));
    "T-127 Params.normalize_elem: per language" >:: (fun _ -> eq_str_e "str" (Params.normalize_elem (lang "python") "string"); eq_str_e "number" (Params.normalize_elem (lang "javascript") "float"));
    "T-128 Params.normalize_elem: case and spaces" >:: (fun _ -> eq_str_e "bool" (Params.normalize_elem (lang "ocaml") " BOOL "));
    "T-129 Params.normalize_elem: unknown" >:: (fun _ -> is_err "bad_elem" (Params.normalize_elem (lang "python") "double"); is_err "bad_elem" (Params.normalize_elem (lang "python") ""));
    "T-130 Params.ghost: function" >:: (fun _ -> eq_str "binary_search" (Params.ghost (lang "python") (param "fn")); eq_str "binarySearch" (Params.ghost (lang "javascript") (param "fn")));
    "T-131 Params.ghost: element" >:: (fun _ -> eq_str "int" (Params.ghost (lang "python") (param "elem")));
    "T-132 Params.ghost: type is Pascal" >:: (fun _ -> eq_str "Stack" (Params.ghost (lang "python") (param "type_name")));
    "T-133 Params.resolve: defaults" >:: (fun _ -> assert_bool "defaults" (Params.resolve (lang "python") (algo "binary-search") [] = Ok [("fn","binary_search");("elem","int")]));
    "T-134 Params.resolve: answers override and normalise" >:: (fun _ -> assert_bool "answers" (Params.resolve (lang "javascript") (algo "stack") [("type_name","int stack");("elem","String")] = Ok [("type_name","IntStack");("elem","string")]));
    "T-135 Params.resolve: existing names get suffixed" >:: (fun _ -> assert_bool "unique" (Params.resolve ~existing:["binary_search"] (lang "python") (algo "binary-search") [] = Ok [("fn","binary_search_2");("elem","int")]));
    "T-136 Params.resolve: blank means default" >:: (fun _ -> assert_bool "blank" (Params.resolve (lang "python") (algo "stack") [("elem","  ")] = Ok [("type_name","Stack");("elem","int")]));
    "T-137 Params.resolve: element types are never renamed" >:: (fun _ -> assert_bool "elem" (Params.resolve ~existing:["int"] (lang "python") (algo "stack") [] = Ok [("type_name","Stack");("elem","int")]));
    "T-138 Params.resolve: unknown param" >:: (fun _ -> assert_bool "unknown" (Params.resolve (lang "python") (algo "stack") [("colour","red")] = Error (Err.Unknown_param "colour")));
    "T-139 Params.resolve: unknown param is reported even when another answer is bad" >:: (fun _ -> assert_bool "first" (Params.resolve (lang "python") (algo "stack") [("elem","double");("colour","red")] = Error (Err.Unknown_param "colour")));
    "T-140 Params.resolve: bad elem and bad ident" >:: (fun _ -> is_err "bad_elem" (Params.resolve (lang "python") (algo "stack") [("elem","double")]); is_err "bad_ident" (Params.resolve (lang "python") (algo "stack") [("type_name","9")]));
    "T-141 Params.next_prompt: first" >:: (fun _ -> (match Params.next_prompt (lang "python") (algo "stack") [] with Some (p, g) -> eq_str "type_name" p.Catalog.name; eq_str "Stack" g | None -> assert_failure "some"));
    "T-142 Params.next_prompt: second" >:: (fun _ -> (match Params.next_prompt (lang "python") (algo "stack") [("type_name","x")] with Some (p, _) -> eq_str "elem" p.Catalog.name | None -> assert_failure "some"));
    "T-143 Params.next_prompt: done" >:: (fun _ -> assert_bool "none" (Params.next_prompt (lang "python") (algo "stack") [("type_name","x");("elem","int")] = None));
    "T-144 Params.next_prompt: unknown answers are ignored" >:: (fun _ -> (match Params.next_prompt (lang "python") (algo "stack") [("zzz","1")] with Some (p, _) -> eq_str "type_name" p.Catalog.name | None -> assert_failure "some"));
  ]
