# scaffold.nvim (starter skeleton)

A Neovim plugin that inserts correct starter code for binary search, insertion sort, stack and union-find in Python, JavaScript and OCaml. **The engine is OCaml; Lua is only the thin Neovim edge.** You implement every function; every test is already written.

- Start here: `SETUP.md` (toolchain, first build, first red run), then `PROGRESS.md` (the checklist, by Part).
- The specification and diagrams are NOT in this folder. They are in the sibling folder `../scaffold.nvim-docs/` (`PROJECT_SPEC.html`, `PROJECT_DIAGRAMS.html`, and the `.md` versions).
- Every stub says which function it is (`F-nnn`), which Part it belongs to, and carries a short contract comment. The full contract is in the spec, Section 15.

```text
Neovim --(vim.system, JSON)--> _build/default/bin/main.exe   (OCaml: lib/ + bin/main.ml)
 lua/scaffold/*.lua (6 modules)
```

Counts: 72 functions (52 OCaml, 20 Lua), 238 OCaml tests, 102 Lua tests, 6 acceptance checks.
Rule: never edit a provided test to make it pass.

## References: books, pages and links

Everything the spec cites, in one place. Marks: verified = the page was fetched and loaded when this skeleton was built; `:help` topics were checked against the Neovim 0.10.4 tags file.

### Books

- **CS3110, _OCaml Programming: Correct + Efficient + Beautiful_** (online textbook, https://cs3110.github.io/textbook/cover.html). It is the only book used. It is an online book with no printed page numbers, so **no page numbers are cited and none are claimed**; each Part cites the chapter pages below. If you want an OCaml book with exact printed pages aligned (or any course PDF), attach it and the pages will be added.
- No algorithms textbook and no Lua book is cited: the algorithms here are fixed templates, and the Lua edge is covered by `:help` topics.

### Reading by Part (minutes are budgeted inside each Part)

| Part | Item | Min | Link |
|---|---|---|---|
| 0 | dune quick start (project layout, `dune build`, `dune test`) | 5 | https://dune.readthedocs.io/en/stable/quick-start.html |
| 0 | CS3110: OUnit (how a test file is shaped) | 5 | https://cs3110.github.io/textbook/chapters/data/ounit.html |
| 0 | CS3110: references, `!`, `:=` and loops | 5 | https://cs3110.github.io/textbook/chapters/mut/refs.html |
| 1 | OCaml `String` API (`length`, `sub`, `get`, `make`) | 8 | https://ocaml.org/manual/5.2/api/String.html |
| 1 | OCaml `Char` API (`lowercase_ascii`, `code`) | 4 | https://ocaml.org/manual/5.2/api/Char.html |
| 1 | OCaml `Buffer` API (`create`, `add_char`, `add_string`, `contents`) | 6 | https://ocaml.org/manual/5.2/api/Buffer.html |
| 1 | CS3110: arrays (indexing and loops over positions) | 6 | https://cs3110.github.io/textbook/chapters/mut/arrays.html |
| 2 | CS3110: variants | 10 | https://cs3110.github.io/textbook/chapters/data/variants.html |
| 2 | CS3110: advanced pattern matching | 8 | https://cs3110.github.io/textbook/chapters/data/pattern_matching_advanced.html |
| 2 | OCaml `Printf` API (`sprintf`, `%s`, `%d`, `%S`) | 6 | https://ocaml.org/manual/5.2/api/Printf.html |
| 3 | CS3110: records and tuples | 8 | https://cs3110.github.io/textbook/chapters/data/records_tuples.html |
| 3 | CS3110: options | 6 | https://cs3110.github.io/textbook/chapters/data/options.html |
| 3 | OCaml `Result` API | 6 | https://ocaml.org/manual/5.2/api/Result.html |
| 3 | OCaml `List` API (`mem`, `find_opt`, `exists`, `fold_left`) | 8 | https://ocaml.org/manual/5.2/api/List.html |
| 4 | CS3110: folding | 8 | https://cs3110.github.io/textbook/chapters/hop/fold.html |
| 4 | OCaml `List` API (`rev`, `map`, `assoc_opt`, `sort_uniq`) | 5 | https://ocaml.org/manual/5.2/api/List.html |
| 4 | OCaml `Buffer` API | 4 | https://ocaml.org/manual/5.2/api/Buffer.html |
| 4 | CS3110: modules (how `.mli` hides helpers) | 8 | https://cs3110.github.io/textbook/chapters/modules/modules.html |
| 5 | OCaml `List` API (`find_opt`, `filter`, `mem`) | 6 | https://ocaml.org/manual/5.2/api/List.html |
| 5 | OCaml `Option` API | 5 | https://ocaml.org/manual/5.2/api/Option.html |
| 5 | CS3110: map | 6 | https://cs3110.github.io/textbook/chapters/hop/map.html |
| 6 | OCaml `Result` API | 5 | https://ocaml.org/manual/5.2/api/Result.html |
| 6 | CS3110: modules and encapsulation (abstract types) | 8 | https://cs3110.github.io/textbook/chapters/modules/encapsulation.html |
| 6 | CS3110: options | 4 | https://cs3110.github.io/textbook/chapters/data/options.html |
| 7 | CS3110: pipelining and composition | 6 | https://cs3110.github.io/textbook/chapters/hop/pipelining.html |
| 7 | CS3110: modules | 6 | https://cs3110.github.io/textbook/chapters/modules/modules.html |
| 7 | OCaml `Result` API (`bind`, `map`) | 4 | https://ocaml.org/manual/5.2/api/Result.html |
| 8 | OCaml `Sys` API (`argv`) | 5 | https://ocaml.org/manual/5.2/api/Sys.html |
| 8 | OCaml `In_channel` API (reading all of stdin) | 5 | https://ocaml.org/manual/5.2/api/In_channel.html |
| 8 | OCaml `Stdlib` (`exit`, `print_string`, `prerr_string`) | 5 | https://ocaml.org/manual/5.2/api/Stdlib.html |
| 8 | OCaml `Printf` API | 3 | https://ocaml.org/manual/5.2/api/Printf.html |
| 9 | `:help lua-guide` | 10 | `:help lua-guide` |
| 9 | `:help vim.system()` | 6 | `:help vim.system()` |
| 9 | `:help vim.json.decode()` | 4 | `:help vim.json.decode()` |
| 9 | `:help nvim_buf_set_lines()` | 6 | `:help nvim_buf_set_lines()` |
| 10 | `:help nvim_open_win()` | 6 | `:help nvim_open_win()` |
| 10 | `:help nvim_buf_set_extmark()` | 6 | `:help nvim_buf_set_extmark()` |
| 10 | `:help nvim_create_user_command()` | 5 | `:help nvim_create_user_command()` |
| 10 | `:help vim.keymap.set()` | 4 | `:help vim.keymap.set()` |

### Other pages cited (setup, extras)

| Page | Link | Used for |
|---|---|---|
| CS3110 textbook: cover / table of contents | https://cs3110.github.io/textbook/cover.html | start here |
| CS3110: lists | https://cs3110.github.io/textbook/chapters/data/lists.html | extra |
| CS3110: higher-order functions, intro | https://cs3110.github.io/textbook/chapters/hop/intro.html | extra |
| CS3110: modules, intro | https://cs3110.github.io/textbook/chapters/modules/intro.html | extra |
| CS3110: mutability, intro | https://cs3110.github.io/textbook/chapters/mut/intro.html | extra |
| CS3110: testing and debugging | https://cs3110.github.io/textbook/chapters/correctness/test_debug.html | extra |
| dune: running tests (describes the plural `tests` stanza; the skeleton uses the singular `test`, checked by building) | https://dune.readthedocs.io/en/stable/tests.html | Part 0 |
| OCaml install (ocaml.org) | https://ocaml.org/docs/install.html | setup |
| WSL install (Microsoft Learn) | https://learn.microsoft.com/en-us/windows/wsl/install | setup, Windows |

### Neovim help topics used (open with `:help <topic>`)

`executable()`, `fnameescape()`, `lua-guide`, `maparg()`, `nvim_buf_set_extmark()`, `nvim_buf_set_lines()`, `nvim_create_augroup()`, `nvim_create_user_command()`, `nvim_open_win()`, `vim.NIL`, `vim.deep_equal()`, `vim.json.decode()`, `vim.keymap.set()`, `vim.notify()`, `vim.schedule()`, `vim.system()`, `vim.tbl_deep_extend()`, `vim.ui.select()`, `vim.wait()`, `writefile()`

### Not verified

- lazy.nvim documentation (not reachable when this was built; the option names in spec FX-17 are unverified).
- neovim.io pages, realworldocaml.org and github.com pages were not reachable or not checked; use `:help` instead.
- The opam install commands in SETUP.md were not run by the author (no opam in the build environment). Native Windows OCaml is untested.
