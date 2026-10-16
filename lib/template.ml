(* lib/template.ml  -- The <% name | filter %> template language (Part 4). *)
type filter = Snake | Camel | Pascal | Upper_snake | Upper | Lower
type seg = Text of string | Var of { name : string; filters : filter list }

(* F-020  Template.scan_tag : string -> int -> (Template.seg * int, Err.template_error) result
   Given the text and the byte offset of a <%, parse one tag <% name | filter | filter %> and return the Var segment plus the offset just after %>.
   Requires: text at open_pos starts with <%
   Produces: Ok (Var {name; filters}, next_index) or an Err.template_error.
   Returns an error: Unclosed open_pos
   Returns an error: Empty_var open_pos
   Returns an error: Bad_name n
   Returns an error: Bad_filter f
   Tests: T-079, T-080, T-081, T-082, T-083, T-084, T-085   Diagram: AD-020   Part 4
   Challenge: Reject <% %>, <% 1x %> and <% x | nope %> with three different errors. *)
let scan_tag _ _ = failwith "not implemented: F-020 Template.scan_tag"

(* F-021  Template.parse : string -> (Template.seg list, Err.template_error) result
   Split template text into Text and Var segments, in order, with no empty Text segments.
   Requires: none
   Produces: Ok segments, or the first tag error.
   Returns an error: any scan_tag error
   Tests: T-086, T-087, T-088, T-089, T-090   Diagram: AD-021   Part 4
   Challenge: Preserve a lone < and a lone % as ordinary text. *)
let parse _ = failwith "not implemented: F-021 Template.parse"

(* F-022  Template.vars : Template.seg list -> string list
   The distinct variable names used by a template, in order of first appearance.
   Requires: none
   Produces: Names without duplicates.
   Tests: T-091, T-092, T-093   Diagram: AD-022   Part 4
   Challenge: Ignore Text segments without an explicit else branch per case. *)
let vars _ = failwith "not implemented: F-022 Template.vars"

(* F-023  Template.apply_filter : Template.filter -> string -> string
   Apply one filter (snake, camel, pascal, upper_snake, upper, lower) to a value.
   Requires: none
   Produces: The transformed string.
   Tests: T-094, T-095, T-096   Diagram: AD-023   Part 4
   Challenge: No wildcard arm. *)
let apply_filter _ _ = failwith "not implemented: F-023 Template.apply_filter"

(* F-024  Template.render : Template.seg list -> (string * string) list -> (string, Err.template_error) result
   Produce the output text: Text as is, each Var looked up in the environment and passed through its filters left to right.
   Requires: none
   Produces: Ok text or Error (Unbound name).
   Returns an error: Unbound name
   Tests: T-097, T-098, T-099, T-100, T-101   Diagram: AD-024   Part 4
   Challenge: Apply filters in written order: x | upper | snake is not x | snake | upper. *)
let render _ _ = failwith "not implemented: F-024 Template.render"
