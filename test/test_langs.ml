(* test/test_langs.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "langs" >::: [
    "T-075 Langs.install: adds three" >:: (fun _ -> eq_strs ["python";"javascript";"ocaml"] (List.map (fun l -> l.Lang.cfg.Lang.id) (Langs.install [])));
    "T-076 Langs.install: idempotent" >:: (fun _ -> eq_int 3 (List.length (Langs.install (Langs.install []))));
    "T-077 Langs.install: user language survives and keeps position" >:: (fun _ -> let r = get_ok (Lang.register [] cfg0) in eq_strs ["demo";"python";"javascript";"ocaml"] (List.map (fun l -> l.Lang.cfg.Lang.id) (Langs.install r)));
    "T-078 Langs.install: override kept" >:: (fun _ -> let mine = get_ok (Lang.register [] { (List.hd Langs.configs) with Lang.indent_width = 8 }) in eq_str (String.make 8 ' ') (Lang.find (Langs.install mine) "python" |> Option.get).Lang.indent);
  ]
