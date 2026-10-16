(* test/test_helpers.ml  -- PROVIDED. Shared assertions and fixtures for every test file.
   Nothing here runs at start-up: fixtures are functions or lazies, so a module you have
   not written yet cannot crash the whole test program. *)
open OUnit2
open Scaffold

let eq_str e a = assert_equal ~printer:(Printf.sprintf "%S") e a
let eq_int e a = assert_equal ~printer:string_of_int e a
let eq_bool e a = assert_equal ~printer:string_of_bool e a
let eq_strs e a =
  assert_equal
    ~printer:(fun l -> "[" ^ String.concat "; " (List.map (Printf.sprintf "%S") l) ^ "]")
    e a
let eq_so e a =
  assert_equal
    ~printer:(function None -> "None" | Some s -> Printf.sprintf "Some %S" s)
    e a
let eq_io e a =
  assert_equal
    ~printer:(function None -> "None" | Some i -> Printf.sprintf "Some %d" i)
    e a

let raises_invalid f =
  match f () with
  | exception Invalid_argument _ -> ()
  | _ -> assert_failure "expected Invalid_argument"

let get_ok = function
  | Ok v -> v
  | Error e -> assert_failure ("unexpected Error: " ^ Err.code e ^ ": " ^ Err.message e)

let get_ok_t = function
  | Ok v -> v
  | Error te -> assert_failure ("unexpected template error: " ^ Err.message (Err.Template te))

let is_err code = function
  | Ok _ -> assert_failure ("expected Error " ^ code)
  | Error e -> eq_str code (Err.code e)

let bad_field field = function
  | Error (Err.Bad_lang_config { field = f; _ }) -> eq_str field f
  | Error e -> assert_failure ("wrong error: " ^ Err.code e)
  | Ok _ -> assert_failure "expected Bad_lang_config"

let eq_str_e e = function
  | Ok v -> eq_str e v
  | Error x -> assert_failure ("unexpected Error: " ^ Err.code x)

let eq_str_t e = function
  | Ok v -> eq_str e v
  | Error te -> assert_failure ("unexpected template error: " ^ Err.message (Err.Template te))

let contains s sub =
  let n = String.length s and m = String.length sub in
  let rec go i = i + m <= n && (String.sub s i m = sub || go (i + 1)) in
  go 0

(* ---- fixtures (all lazy) ---- *)
let regs_l = lazy (Langs.install [])
let regs () = Lazy.force regs_l
let lang id = Option.get (Lang.find (regs ()) id)
let algo id = Option.get (Catalog.find id)

let param name =
  List.find
    (fun (p : Catalog.param) -> p.name = name)
    (List.concat_map (fun (a : Catalog.algo) -> a.params) Catalog.all)

let opts l a answers : Engine.opts =
  { Engine.lang = l; algo = a; answers; existing = []; mode = Insert.Cursor; cursor_indent = "" }

let cfg0 : Lang.cfg =
  {
    Lang.id = "demo";
    filetypes = [ "demo" ];
    extension = ".dm";
    indent_width = 2;
    camel_case = false;
    types = { Lang.int_t = "i"; float_t = "f"; string_t = "s"; bool_t = "b" };
    def_markers = [ "fn " ];
  }

let all_errs : Err.t list =
  [
    Err.Bad_lang_config { field = "id"; reason = "r" };
    Err.Duplicate_id "x";
    Err.Duplicate_filetype { filetype = "f"; owner = "o" };
    Err.Unknown_lang "x";
    Err.Unknown_algo "x";
    Err.No_template { algo = "a"; lang = "l" };
    Err.Unknown_param "x";
    Err.Bad_ident { param = "p"; value = "v" };
    Err.Bad_elem "x";
    Err.Template (Err.Unclosed 1);
    Err.Session_closed "ready";
    Err.Unknown_flag "--x";
    Err.Missing_value "--x";
    Err.Bad_set "x";
    Err.Unexpected_arg "x";
    Err.Unknown_command "x";
    Err.Bad_value { flag = "--x"; value = "v" };
  ]
