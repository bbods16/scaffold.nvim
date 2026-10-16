(* test/test_lang.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "lang" >::: [
    "T-045 Lang.validate: built-ins are valid" >:: (fun _ -> List.iter (fun c -> assert_bool "valid" (Result.is_ok (Lang.validate c))) Langs.configs);
    "T-046 Lang.validate: bad id" >:: (fun _ -> is_err "bad_lang_config" (Lang.validate { cfg0 with Lang.id = "Bad Id" }); bad_field "id" (Lang.validate { cfg0 with Lang.id = "" }));
    "T-047 Lang.validate: filetypes" >:: (fun _ -> bad_field "filetypes" (Lang.validate { cfg0 with Lang.filetypes = [] }); bad_field "filetypes" (Lang.validate { cfg0 with Lang.filetypes = [""] }));
    "T-048 Lang.validate: extension" >:: (fun _ -> bad_field "extension" (Lang.validate { cfg0 with Lang.extension = "py" }); bad_field "extension" (Lang.validate { cfg0 with Lang.extension = "." }));
    "T-049 Lang.validate: indent" >:: (fun _ -> bad_field "indent_width" (Lang.validate { cfg0 with Lang.indent_width = -1 }); assert_bool "zero ok" (Result.is_ok (Lang.validate { cfg0 with Lang.indent_width = 0 })));
    "T-050 Lang.validate: each type is checked" >:: (fun _ -> bad_field "types" (Lang.validate { cfg0 with Lang.types = { cfg0.Lang.types with Lang.bool_t = "" } }));
    "T-051 Lang.validate: def_markers" >:: (fun _ -> bad_field "def_markers" (Lang.validate { cfg0 with Lang.def_markers = [""] }));
    "T-052 Lang.validate: first failure wins" >:: (fun _ -> bad_field "id" (Lang.validate { cfg0 with Lang.id = "X"; extension = "nope" }));
    "T-053 Lang.derive: indent string" >:: (fun _ -> eq_str "    " (Lang.derive { cfg0 with Lang.indent_width = 4 }).Lang.indent);
    "T-054 Lang.derive: style flag" >:: (fun _ -> assert_bool "camel" ((Lang.derive { cfg0 with Lang.camel_case = true }).Lang.fn_style = Naming.Camel); assert_bool "snake" ((Lang.derive cfg0).Lang.fn_style = Naming.Snake));
    "T-055 Lang.derive: zero width" >:: (fun _ -> eq_str "" (Lang.derive { cfg0 with Lang.indent_width = 0 }).Lang.indent);
    "T-056 Lang.derive: cfg is kept" >:: (fun _ -> assert_bool "same" ((Lang.derive cfg0).Lang.cfg == cfg0));
    "T-057 Lang.register: appends" >:: (fun _ -> let r = get_ok (Lang.register [] cfg0) in eq_int 1 (List.length r); let r2 = get_ok (Lang.register r { cfg0 with Lang.id = "two"; filetypes = ["two"] }) in eq_strs ["demo";"two"] (List.map (fun l -> l.Lang.cfg.Lang.id) r2));
    "T-058 Lang.register: duplicate id" >:: (fun _ -> let r = get_ok (Lang.register [] cfg0) in is_err "duplicate_id" (Lang.register r { cfg0 with Lang.filetypes = ["other"] }));
    "T-059 Lang.register: duplicate filetype names the owner" >:: (fun _ -> let r = get_ok (Lang.register [] cfg0) in (match Lang.register r { cfg0 with Lang.id = "two" } with Error (Err.Duplicate_filetype { filetype; owner }) -> eq_str "demo" filetype; eq_str "demo" owner | _ -> assert_failure "expected Duplicate_filetype"));
    "T-060 Lang.register: invalid config propagates" >:: (fun _ -> is_err "bad_lang_config" (Lang.register [] { cfg0 with Lang.extension = "x" }));
    "T-061 Lang.register: input registry untouched" >:: (fun _ -> let r = get_ok (Lang.register [] cfg0) in ignore (Lang.register r { cfg0 with Lang.id = "two"; filetypes = ["two"] }); eq_int 1 (List.length r));
    "T-062 Lang.find: found" >:: (fun _ -> let regs = regs () in assert_bool "some" (Lang.find regs "ocaml" <> None));
    "T-063 Lang.find: case sensitive" >:: (fun _ -> let regs = regs () in assert_bool "none" (Lang.find regs "OCaml" = None));
    "T-064 Lang.find: unknown and empty registry" >:: (fun _ -> let regs = regs () in assert_bool "none" (Lang.find regs "x" = None); assert_bool "none" (Lang.find [] "python" = None));
    "T-065 Lang.find_by_filetype: secondary filetype" >:: (fun _ -> let regs = regs () in eq_so (Some "javascript") (Option.map (fun l -> l.Lang.cfg.Lang.id) (Lang.find_by_filetype regs "javascriptreact")));
    "T-066 Lang.find_by_filetype: empty string" >:: (fun _ -> let regs = regs () in assert_bool "none" (Lang.find_by_filetype regs "" = None));
    "T-067 Lang.find_by_filetype: unknown" >:: (fun _ -> let regs = regs () in assert_bool "none" (Lang.find_by_filetype regs "lua" = None));
    "T-068 Lang.file_name: snake language" >:: (fun _ -> eq_str "binary_search.py" (Lang.file_name (lang "python") "Binary Search"));
    "T-069 Lang.file_name: camel language" >:: (fun _ -> eq_str "binarySearch.js" (Lang.file_name (lang "javascript") "binary search"));
    "T-070 Lang.file_name: idempotent on styled input" >:: (fun _ -> eq_str "union_find.ml" (Lang.file_name (lang "ocaml") "union_find"));
    "T-071 Lang.file_name: empty stem raises" >:: (fun _ -> raises_invalid (fun () -> Lang.file_name (lang "python") "--"));
    "T-072 Lang.elem_type: python" >:: (fun _ -> eq_str "str" (Lang.elem_type (lang "python") Lang.String); eq_str "int" (Lang.elem_type (lang "python") Lang.Int));
    "T-073 Lang.elem_type: javascript" >:: (fun _ -> eq_str "number" (Lang.elem_type (lang "javascript") Lang.Float); eq_str "boolean" (Lang.elem_type (lang "javascript") Lang.Bool));
    "T-074 Lang.elem_type: all four non-empty for every built-in" >:: (fun _ -> let regs = regs () in List.iter (fun l -> List.iter (fun e -> assert_bool "nonempty" (Lang.elem_type l e <> "")) Lang.[Int;Float;String;Bool]) regs);
  ]
