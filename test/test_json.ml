(* test/test_json.ml -- PROVIDED. Do not edit; make the code pass. Each test id (T-nnn) is quoted in the spec. *)
open OUnit2
open Scaffold
open Test_helpers

let tests =
  "json" >::: [
    "T-036 Json.escape: quote and newline" >:: (fun _ -> eq_str "a\\\"b\\n" (Json.escape "a\"b\n"));
    "T-037 Json.escape: backslash tab CR" >:: (fun _ -> eq_str "\\\\ \\t \\r" (Json.escape "\\ \t \r"));
    "T-038 Json.escape: control byte" >:: (fun _ -> eq_str "\\u0001" (Json.escape "\001"));
    "T-039 Json.escape: UTF-8 untouched, empty ok" >:: (fun _ -> eq_str "\xc3\xa9" (Json.escape "\xc3\xa9"); eq_str "" (Json.escape ""));
    "T-040 Json.to_string: scalars" >:: (fun _ -> eq_str "null" (Json.to_string Json.Null); eq_str "true" (Json.to_string (Json.Bool true)); eq_str "7" (Json.to_string (Json.Int 7)); eq_str "\"x\"" (Json.to_string (Json.Str "x")));
    "T-041 Json.to_string: nested" >:: (fun _ -> eq_str "{\"a\":[1,null]}" (Json.to_string Json.(Obj [("a", List [Int 1; Null])])));
    "T-042 Json.to_string: empty list/object" >:: (fun _ -> eq_str "[]" (Json.to_string (Json.List [])); eq_str "{}" (Json.to_string (Json.Obj [])));
    "T-043 Json.to_string: keys are escaped" >:: (fun _ -> eq_str "{\"a\\\"b\":0}" (Json.to_string (Json.Obj [("a\"b", Json.Int 0)])));
    "T-044 Json.to_string: negative number" >:: (fun _ -> eq_str "-4" (Json.to_string (Json.Int (-4))));
  ]
