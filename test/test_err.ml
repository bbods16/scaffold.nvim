(* test/test_err.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "err" >::: [
    "T-028 Err.code: a few codes" >:: (fun _ -> eq_str "unknown_lang" (Err.code (Err.Unknown_lang "x")); eq_str "bad_ident" (Err.code (Err.Bad_ident { param = "fn"; value = "" })));
    "T-029 Err.code: all 17 codes are distinct and non-empty" >:: (fun _ -> let codes = List.map Err.code all_errs in eq_int 17 (List.length codes); eq_int 17 (List.length (List.sort_uniq compare codes)); assert_bool "non-empty" (List.for_all (fun c -> c <> "") codes));
    "T-030 Err.code: template errors share one code" >:: (fun _ -> eq_str "template" (Err.code (Err.Template (Err.Unbound "x"))); eq_str "template" (Err.code (Err.Template (Err.Unclosed 0))));
    "T-031 Err.message: unknown language" >:: (fun _ -> eq_str "unknown language: cobol" (Err.message (Err.Unknown_lang "cobol")));
    "T-032 Err.message: template unclosed shows offset" >:: (fun _ -> eq_str "template: unclosed <% at 12" (Err.message (Err.Template (Err.Unclosed 12))));
    "T-033 Err.message: quoted values" >:: (fun _ -> eq_str "bad value for --mode: \"zzz\"" (Err.message (Err.Bad_value { flag = "--mode"; value = "zzz" })));
    "T-034 Err.message: empty command has its own text" >:: (fun _ -> eq_str "unknown command" (Err.message (Err.Unknown_command "")); eq_str "unknown command: x" (Err.message (Err.Unknown_command "x")));
    "T-035 Err.message: no message contains a newline" >:: (fun _ -> assert_bool "newline" (List.for_all (fun e -> not (String.contains (Err.message e) '\n')) all_errs));
  ]
