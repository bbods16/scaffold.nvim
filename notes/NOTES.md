# NOTES

Your answers to the research questions, in your own words. Model answers are in the spec, Appendix R: try first.

## Part 0: Setup and first red tests

### RQ-0-1
`dune test` prints one error per not-yet-written function and keeps going. Why does it not stop at the first failure?

(your answer)

### RQ-0-2
Why can `String.sub s 0 (-1)` happen inside a careless `trim`, and what does your loop do for the all-blank string?

(your answer)

### RQ-0-3
What is the type of `ref 0`, and how do `!x`, `x := 1` and `x = 1` differ?

(your answer)

## Part 1: Strings and names (find_sub, split, leading_ws, words, convert)

### RQ-1-1
By hand, write the result of `Naming.words` for `HTTPServer`, `x2Y` and `foo_bar-baz`. State the rule you used for each boundary.

(your answer)

### RQ-1-2
`Util.split "a,b," ~sep:","` has three pieces. Why is the empty last piece the right answer?

(your answer)

### RQ-1-3
Why does `find_sub` raise `Invalid_argument` for a negative `from` instead of returning `None`?

(your answer)

## Part 2: Errors and JSON (Err, Json)

### RQ-2-1
Why is `Err.t` a variant with one case per failure rather than a string?

(your answer)

### RQ-2-2
Which characters must `Json.escape` change, and why are bytes 0x80 and above passed through unchanged?

(your answer)

### RQ-2-3
`Json` knows nothing about `Err`. Where is the conversion done and why there?

(your answer)

## Part 3: Language registry (Lang, Langs)

### RQ-3-1
`register` takes the list and returns a new list instead of changing a global. Name two benefits for testing.

(your answer)

### RQ-3-2
Which rule in `validate` does `derive` rely on so that `derive` can be total (cannot fail)?

(your answer)

### RQ-3-3
Why does `find` return an `option` while `register` returns a `result`?

(your answer)

## Part 4: Template language (Template)

### RQ-4-1
By hand: what does `Template.scan_tag "a<% fn | snake | upper %>b" 1` return, including the next position?

(your answer)

### RQ-4-2
`Template.parse "ok <% a %> then <% b"` reports `Unclosed 16`. Count the bytes to show why 16.

(your answer)

### RQ-4-3
Why is `Bad_filter` found while parsing but `Unbound` only while rendering?

(your answer)

## Part 5: Catalog and collisions (Catalog, Collision)

### RQ-5-1
`Catalog.template` is keyed by two strings. What does this buy you, and what bug class does it allow that a variant would prevent?

(your answer)

### RQ-5-2
Name three source-text situations where `defined_names` gives a wrong answer.

(your answer)

### RQ-5-3
What are the first four results of `unique_name` when the existing list is `["s"; "s_2"; "s_3"]`?

(your answer)

## Part 6: Parameters and sessions (Params, Session)

### RQ-6-1
In `Params.resolve`, why is the unknown-parameter check done before any parameter is processed?

(your answer)

### RQ-6-2
What does making `Session.t` abstract forbid, and which test shows you cannot build a `Ready` session by hand?

(your answer)

### RQ-6-3
Why does `Params.ghost` live in `Params` and not in `Cli`?

(your answer)

## Part 7: Placement and the pipeline (Insert, Engine)

### RQ-7-1
Why must `Engine.generate` check the language before the algorithm?

(your answer)

### RQ-7-2
Which module owns indentation, `Insert` or `Engine`? What goes wrong if both do it?

(your answer)

### RQ-7-3
`Engine.generate` never prints. Name two things that become possible because of that.

(your answer)

## Part 8: Command line and main (Cli, Main)

### RQ-8-1
Why does `Cli.run` return an `outcome` record instead of printing and exiting?

(your answer)

### RQ-8-2
List which `Err.t` cases map to exit code 2 and which to 1, and say why the split is useful to a shell script.

(your answer)

### RQ-8-3
`main.ml` is the only file allowed to call `exit`. Which tests would be impossible if `Cli.run` called it?

(your answer)

## Part 9: Lua edge I: config, client, buffer

### RQ-9-1
`client.call` appends `--json` itself and never mutates the caller's table. Why is each of those two choices good?

(your answer)

### RQ-9-2
Convert 1-based `row` to the two 0-based arguments of `nvim_buf_set_lines` for inserting after the line, and say why start equals end.

(your answer)

### RQ-9-3
Why does `client.call` wrap `vim.system` and `vim.json.decode` in `pcall`?

(your answer)

## Part 10: Lua edge II: ui, commands, init and lazy.nvim

### RQ-10-1
Why is `on_done` scheduled with `vim.schedule` instead of called directly from the key handler?

(your answer)

### RQ-10-2
How does `nvim_create_augroup('scaffold', { clear = true })` make `setup` safe to call twice?

(your answer)

### RQ-10-3
What would the user see if the engine binary were missing, and which function produces that message?

(your answer)
