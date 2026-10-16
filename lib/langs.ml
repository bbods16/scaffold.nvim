(* lib/langs.ml  -- Built-in language data (provided) and install (Part 3). *)
let configs : Lang.cfg list =
  [
    {
      Lang.id = "python";
      filetypes = [ "python" ];
      extension = ".py";
      indent_width = 4;
      camel_case = false;
      types = { int_t = "int"; float_t = "float"; string_t = "str"; bool_t = "bool" };
      def_markers = [ "async def "; "def "; "class " ];
    };
    {
      Lang.id = "javascript";
      filetypes = [ "javascript"; "javascriptreact" ];
      extension = ".js";
      indent_width = 2;
      camel_case = true;
      types =
        { int_t = "number"; float_t = "number"; string_t = "string"; bool_t = "boolean" };
      def_markers = [ "async function "; "function "; "class "; "const "; "let " ];
    };
    {
      Lang.id = "ocaml";
      filetypes = [ "ocaml" ];
      extension = ".ml";
      indent_width = 2;
      camel_case = false;
      types = { int_t = "int"; float_t = "float"; string_t = "string"; bool_t = "bool" };
      def_markers = [ "let rec "; "let "; "type "; "module " ];
    };
  ]

(* F-019  Langs.install : Lang.t list -> Lang.t list
   Add the three built-in languages that are missing from a registry (python, javascript, ocaml).
   Requires: none
   Produces: The registry plus any missing built-ins, in config order.
   Raises (exception/error): Failure if a built-in config is invalid (cannot happen with the shipped data)
   Tests: T-075, T-076, T-077, T-078   Diagram: AD-019   Part 3
   Challenge: Make a user override of python survive. *)
let install _ = failwith "not implemented: F-019 Langs.install"
