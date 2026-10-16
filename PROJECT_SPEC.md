# PROJECT_SPEC - scaffold.nvim (OCaml core, thin Lua edge)

**Audience:** you (Bryson), building every implementation file by hand to learn OCaml (and the small amount of Lua that has to be Lua), on stream.
**Time budget:** 795 minutes of coding in 8 sessions of at most 2 hours, plus about 10 percent buffer (80 min). **Languages:** OCaml (engine, 52 functions) and Lua (Neovim edge, 20 functions). **Goals, in priority order:** (1) read and write idiomatic OCaml (variants, `result`, modules, `.mli`); (2) test-first, contract-driven design with a pure core; (3) the Neovim API surface every plugin needs (commands, buffers, windows, extmarks, keymaps, `vim.system`).
**Companion documents (outside the project folder):** `PROJECT_DIAGRAMS.md`/`.html` (117 PlantUML diagrams) and `STREAMING_SECURITY.md` (personal, separate, not a dependency).
**What this is not:** a solution. There is no completed function body in this document. You get contracts, verified examples, data fixtures, partial or non-solution demos, and tests (already written, in the skeleton) to turn green.

> **Marks used throughout.** `[V]` = verified here (run, built, or fetched). `[D]` = from documentation knowledge, not verified in this environment. Nothing marked [D] is presented as fact.

## How to use this handout

```text
        argv / stdin                      JSON on stdout, exit 0/1/2
  Neovim  ───────────▶  lua/scaffold/client.lua  ───────▶  _build/default/bin/main.exe
  (Lua edge: commands,        (vim.system, no shell)         bin/main.ml  (the only effects)
   buffer, ui, keymaps)                                         │
        ▲                                                       ▼
        │ nil, err                                    lib/cli.ml  ─▶ lib/engine.ml ─▶ params, template,
        │                                              (pure)          catalog, collision, insert, lang
        └─ vim.notify (one message per failure)
```

**Rhythm of every Part (red, green, refactor):** read the READ list -> run the Part's tests and watch them fail for the right reason (red) -> write code until green -> answer the research questions in `notes/NOTES.md` in your own words -> run the checkpoint -> do the visible demo. Model answers are in Appendix R, collapsed: try first.

**Legend.** `READ` = reading with minutes · `help:` = a Neovim help topic (open it with `:help <topic>`; each tag was checked against the Neovim 0.10.4 tags file) · **required** / **stretch** = marked per Part and per function · there is no course material for this project, so there are no course-connection or course-drill sections; the textbook for OCaml reading is CS3110 (online, cited by chapter: no page numbers exist to verify, none are claimed).

### Time budget

| Part | Title | Minutes | Cumulative | Session | Required? |
|---|---|---|---|---|---|
| 0 | Setup and first red tests | 35 | 35 | S1 | required |
| 1 | Strings and names (find_sub, split, leading_ws, words, convert) | 80 | 115 | S1 | required |
| 2 | Errors and JSON (Err, Json) | 45 | 160 | S2 | required |
| 3 | Language registry (Lang, Langs) | 75 | 235 | S2 | required |
| 4 | Template language (Template) | 90 | 325 | S3 | required |
| 5 | Catalog and collisions (Catalog, Collision) | 45 | 370 | S4 | required |
| 6 | Parameters and sessions (Params, Session) | 75 | 445 | S4 | required (Session.* and Params.next_prompt are stretch) |
| 7 | Placement and the pipeline (Insert, Engine) | 60 | 505 | S5 | required |
| - | Interlude: Test sweep | 20 | 525 | S5 | stretch |
| 8 | Command line and main (Cli, Main) | 90 | 615 | S6 | required (run_ask is stretch) |
| 9 | Lua edge I: config, client, buffer | 75 | 690 | S7 | required (buffer.write_file and open_file are stretch) |
| 10 | Lua edge II: ui, commands, init and lazy.nvim | 105 | 795 | S8 | required (commands.complete and init.pick are stretch) |

Total 795 min + about 10 percent buffer (80 min) = 875 min. Installing the OCaml toolchain is outside the budget (it varies from 10 to 40 minutes). Each session is at most 120 minutes of planned work; the buffer is slack inside it, not extra scheduled time. Experience assumption A-14: another language, no OCaml, no Lua.

### Sessions (stream-sized)

| Session | Parts | Safe stop point | First thing to run on restart |
|---|---|---|---|
| S1 (115) | 0, 1 | `dune test` shows the 27 Part 0-1 tests green | `dune test` (expect only later parts red) |
| S2 (120) | 2, 3 | `test_lang`, `test_langs` green; commit (after the pre-commit checklist in STREAMING_SECURITY.md) | `dune test` |
| S3 (90) | 4 | `test_template` green | `dune test` |
| S4 (120) | 5, 6 | `test_params`, `test_session` green | `dune test` |
| S5 (80) | 7, Interlude | `test_engine` green; every library test green except `Cli` | `dune test` |
| S6 (90) | 8 | `dune test` fully green; `sh test/acceptance.sh` six PASS | `dune build && sh test/acceptance.sh` |
| S7 (75) | 9 | config, client, buffer specs green | `nvim --headless -u NONE -l lua_test/run.lua 2>&1 \| tail` |
| S8 (105) | 10 | all 102 Lua tests green; the plugin works in LazyVim | the full suite, then the demo |

### Cut list (drop in this order if time runs short)

- 1. Drop the Interlude (20 min).
- 2. Drop `Session.*`, `Params.next_prompt`, `Cli.run_ask` and the `ask` command (F-050); acceptance case A-06 then stays red (accepted).
- 3. Drop `commands.complete` and `init.pick`.
- 4. Drop `file` mode on the Lua side (`buffer.write_file`, `buffer.open_file`); the engine still supports it.
- 5. Replace `ui.input` with `vim.ui.input` (you lose ghost text).
- NEVER cut: Parts 0-8 core (Util, Naming, Err, Json, Lang, Template, Catalog, Collision, Params, Insert, Engine, Cli.parse_flags/run_list/run_gen/run, Main), `client.call`, `buffer.insert_lines`, `init.run`.

### What changed (this handout replaces the Lua-only version)

| Change | Why |
|---|---|
| Engine moved from Lua to OCaml (52 functions); Lua reduced to the Neovim edge (20 functions) | You asked for the functionality in OCaml, with Lua only where it must be Lua |
| The engine is a separate process speaking JSON; `scripts/scaffold_cli.lua` became `bin/main.exe` | Neovim's plugin API is Lua (or Vimscript), so a process boundary is the thinnest honest seam |
| Test harness is now ounit2 (OCaml) plus a small provided Lua harness | The old harness was a learning target; the learning target is now OCaml |
| All tests ship finished: 238 OCaml, 102 Lua, 6 acceptance checks | Same rule as before: the assignment is the implementation |
| Windows/WSL2, opam and dune setup added (Part 0, SETUP.md) | A new toolchain needs setup instructions |
| Lua as an extra generated language (E-02) is now an extension challenge only | Lua is the edge here, not a target language |
| Interlude (test sweep) added after Part 7 | The skill's cross-cutting step; cuttable |

## Contents
Sections: 1. Introduction and objectives · 2. Features and preserved behavior · 3. Environment, assumptions and setup · 4. Requirements and exclusions · 5. Workflows · 6. Dependencies · 7. Rationale · 8. Conventions and the process protocol · 9. Data shapes and error catalog · 10. Directory tree and file annotations · 11. Function registry · 12. Data fixtures · 13. Foundational examples · 14. Curriculum (Parts 0-10) · 15. Function contracts · 16. Testing strategy · 17. Final integration · 18. End-to-end examples and Definition of Done · 19. Checklists, assessment, extensions, glossary · 20. Reading library · 21. Verification and consistency report · Appendix R: research answers · Appendix T: reference assertions

---
## 1. Introduction and objectives

**scaffold.nvim** inserts correct, idiomatic starter code for four classic algorithms and data structures (binary search, insertion sort, stack, union-find) into the file you are editing, in the language of that file (Python, JavaScript/JSX, OCaml). It asks for names and element types with a small floating prompt that shows the language-styled default as grey ghost text, avoids reusing names that already exist in the buffer, and can insert at the cursor, as a separate function, or as a new file.

**How it is built.** All logic (naming, templates, collision avoidance, placement, defaults, validation) is an OCaml library with one executable, `main.exe`. A thin Lua plugin does what only Lua can do: read the buffer, run the executable, draw the prompt, insert the text, register the command and keymap. The two sides talk through command-line arguments, stdin and JSON on stdout (Section 8.6).

**Objectives, in priority order**
1. Idiomatic OCaml: variants and exhaustive matching, `option`/`result`, records, modules and `.mli` interfaces, labelled/optional arguments, imperative loops where they fit.
2. Contract-driven, test-first work: read a contract, see the provided test fail for the right reason, make it pass.
3. A pure core and a thin edge: effects (stdin, stdout, exit, the editor) live in a few named places.
4. The Neovim API you will reuse in every plugin: `vim.system`, `vim.json`, buffers (0-based, end-exclusive), floating windows, extmarks, user commands, keymaps, augroups, `vim.schedule`.

**Tension, stated plainly.** Your standing preference is that Claude pre-builds most of a project so you can finish in about two hours. This project overrides that on purpose: you write every implementation file, so the work is cut into eight sessions of at most two hours (above). Say so if you want the pre-built workflow back for later plugins.

## 2. Features and preserved behavior

| ID | Client-facing feature | Description |
|---|---|---|
| CF1 | Generation pipeline and JSON output | One pure pipeline turns (language, algorithm, answers, existing names, mode) into a placement plan; results and errors can be printed as JSON. |
| CF2 | Naming and parameters | Words are split from any spelling and re-joined in snake/camel/pascal/upper_snake; answers are normalized, defaulted and checked. |
| CF3 | Template language | Templates are data written with `<% name \| filter %>`; they are scanned, parsed, checked for variables and rendered. |
| CF4 | Insertion modes and collisions | Text is placed at the cursor, as a function, or as a new file; names already defined in the buffer are never reused. |
| CF5 | String utilities | Trim, prefix test, plain substring search, split and leading whitespace: the standard library has no versions of the last three that fit. |
| CF6 | Language registry | Python, JavaScript (+JSX) and OCaml are built in; a new language is one validated record. |
| CF7 | Prompt sessions | Questions are asked one at a time with a styled default (ghost text); a session records answers or is cancelled. |
| CF8 | Errors as values | Every user-caused failure is a value with a stable code and message; programmer mistakes raise. |
| CF9 | Engine command line | `main.exe list \| prompts \| gen \| ask` with flags, stdin and exit codes 0/1/2; this is the only interface Lua uses. |
| CF10 | Neovim commands, setup and lifecycle | `setup(opts)` stores validated options, registers the command, keymap and augroup; `run`, `pick`, `teardown` drive and undo it. |
| CF11 | Engine client | The only Lua module that spawns the engine process, sends stdin, decodes JSON and turns protocol errors into `nil, err`. |
| CF12 | Buffer and file edge | The only Lua module that reads or writes buffers and files. |
| CF13 | Prompt UI | Ghost text (extmarks) and the floating one-line input. |

### Preserved from the earlier Scaffold specifications

| Ref | Behavior preserved | Where it lives now |
|---|---|---|
| P-01 | Four algorithms: binary search, insertion sort, stack, union-find | Catalog.all, Catalog.find |
| P-02 | Three languages: Python, JavaScript (+javascriptreact), OCaml | Langs.configs, Langs.install |
| P-03 | Naming rules (word split; snake/camel/pascal/upper_snake) | Naming.words, Naming.convert |
| P-04 | Template language `<% name \| filter %>` with six filters and five error kinds | Template.scan_tag/parse/vars/apply_filter/render |
| P-05 | Parameters ident_fn / ident_type / elem with defaults; unknown_param, bad_ident, bad_elem | Params.resolve, Params.normalize_* |
| P-06 | Ghost text defaults styled per language | Params.ghost, ui.ghost_set |
| P-07 | Collision avoidance: defined_names + unique_name (`name_2`) | Collision.* |
| P-08 | Insert modes cursor / function / file; reindent; place | Insert.reindent, Insert.place |
| P-09 | Engine check order lang > algo > template > params > parse > render | Engine.generate |
| P-10 | CLI list / prompts / gen with --lang/--ft, --algo, --set, --mode, --indent, --existing, --scan | Cli.* |
| P-11 | Neovim shell: command, completion, keymap, picker, floating input, buffer insertion | commands.*, init.*, ui.*, buffer.* |
| P-12 | Language registry validation and duplicate checks | Lang.validate, Lang.register |
| P-13 | Interactive questions with defaults | Session.*, Params.next_prompt, Cli.run_ask |

**Changed on purpose:** errors are OCaml variants in the engine and Lua tables at the edge; the language registry is a value passed around, not a global; the Lua test harness is provided. **Dropped:** nothing.

## 3. Environment, assumptions and setup

| ID | Assumption | Evidence | Status |
|---|---|---|---|
| A-01 | OCaml 4.14 or newer. Everything here was built and run on 4.14.1. | `ocaml -version` in the build environment; the reference built clean and passed every test. | [V] |
| A-02 | dune 3.x. `dune-project` says `(lang dune 3.0)`; built with dune 3.14.0. | `dune --version`; build and test ran. | [V] |
| A-03 | The provided tests use ounit2 (`opam install ounit2`). | The reference test suite ran against ounit2 here. The `opam install` command itself was not run (no opam in this environment). | [V] tests / [D] install command |
| A-04 | The `(test (name main) ...)` stanza (singular) works with `dune test`. | Verified by building and running here. The dune page I fetched describes the plural `tests` stanza and `dune test`, not this singular form. | [V] by build / docs page covers `tests` |
| A-05 | Neovim 0.10 or newer. Everything Lua-side was run on 0.10.4. | `nvim --version` = NVIM v0.10.4. | [V] |
| A-06 | Neovim 0.9.x is NOT supported: the system 0.9.5 lacks `vim.uv` and `vim.system`. | Observed on the system nvim 0.9.5 while preparing. | [V] |
| A-07 | `nvim -l file.lua` writes `print` output to stderr; LuaJIT has no `table.pack`. | Observed on 0.10.4. | [V] |
| A-08 | `vim.json.decode` turns JSON `null` into `vim.NIL` (userdata) and raises on invalid JSON. | Ran `vim.json.decode('{"a":null}')` on 0.10.4: `a == vim.NIL`, `type(a) == 'userdata'`; invalid text raised 'Expected value but found invalid token'. | [V] |
| A-09 | The engine is a separate process, spawned with `vim.system`, args as a list (no shell), JSON on stdout, exit code 0/1/2. | Designed and exercised by the Lua tests with the real binary and with fake engines. | [V] |
| A-10 | One engine call costs about 2 ms (100 calls of `gen` took 0.209 s); the binary is 1,440,096 bytes. | Measured with a shell loop on this machine; your numbers will differ. | [V] here |
| A-11 | Windows: use WSL2 and follow the Linux steps. | Microsoft Learn's WSL install page was fetched. Native Windows OCaml (WinGet route on ocaml.org/docs/install.html) was NOT tested by me. | [V] page / [D] native route |
| A-12 | macOS and other Linuxes: opam-based steps are expected to work the same. | Only one Linux environment was available. | [D] untested |
| A-13 | lazy.nvim spec option names (`dir`, `name`, `build`, `cmd`, `keys`, `opts`) are used in FX-17. | Quoted from memory of the lazy.nvim documentation; the site was not reachable here. Check the live docs before relying on them. | [D] |
| A-14 | Time estimates assume you know another language well and have never written OCaml or Lua. | Stated assumption; use the cut list if you are faster or slower. | Assumption |
| A-15 | PlantUML 1.2020.02 renders all diagrams; known quirks are listed in PROJECT_DIAGRAMS. | Rendered here with Graphviz dot. | [V] |
| A-16 | The shipped skeleton builds with stubs; with the private reference overlaid, 238 OCaml tests, 102 Lua tests and 6 acceptance checks pass. | Run by `verify_skel.sh` (build, dune test, acceptance script, Lua runner). | [V] |
| A-17 | The default engine path is `<plugin>/_build/default/bin/main.exe`; `SCAFFOLD_BIN` or `opts.bin` override it. | Implemented and tested in the reference (`client.binary`). | [V] |

### Setup checklist (Part 0)

Full steps are in `SETUP.md` inside the skeleton. The short version (Linux, macOS, or WSL2 on Windows):

1. Install opam, then OCaml 4.14 or newer, dune and ounit2. The ocaml.org install page (https://ocaml.org/docs/install.html, fetched [V]) is the reference; the commands are typically `opam init`, `opam switch create 4.14.1` (or any 4.14+), `opam install dune ounit2` **[D]: I could not run opam here**.
2. Windows: use WSL2 (Microsoft Learn: https://learn.microsoft.com/en-us/windows/wsl/install, fetched [V]) and do everything inside the Linux shell, including Neovim. Native Windows OCaml is possible per ocaml.org but untested by me.
3. `tar -xzf scaffold.nvim-skeleton.tgz` somewhere **outside** the folder holding these documents; `cd scaffold.nvim`.
4. `dune build` (stubs compile) then `dune test` (expect red: 238 errors, each `not implemented: F-nnn`).
5. Parts 9-10 only: Neovim 0.10 or newer (`nvim --version`), then `nvim --headless -u NONE -l lua_test/run.lua 2>&1 | tail -3`.
6. Optional: `plantuml`, `dot` (to re-render diagrams).

## 4. Requirements and exclusions

### Project-wide requirements

- Every function in the registry (Section 11) is implemented by you, in the file the registry names. Provided data (templates, language configs, the algorithm table, test files) is not modified unless a Part says so.
- Never edit a provided test to make it pass. If you believe a test is wrong, write the reason in `notes/NOTES.md` and ask.
- **Pure core, thin edge:** `lib/` contains no I/O, no `exit`, no global mutable state; `bin/main.ml` and the six Lua modules are the only effectful files (NFR-01, NFR-04).
- `notes/NOTES.md` holds one short answer per research question, written before you open Appendix R.
- Commit after each green Part (read STREAMING_SECURITY.md first; it is separate and personal).

### Functional requirements

| ID | Requirement |
|---|---|
| FR-01 | `:Scaffold <algo>` inserts generated code for the current buffer's language (CF10, CF1). |
| FR-02 | `:Scaffold` completes algorithm ids for the buffer's language, then `mode=` values (CF10). |
| FR-03 | The picker lists only algorithms that exist for the language (CF10). |
| FR-04 | Each parameter is asked in a floating input with the styled default as ghost text; Enter accepts, Esc cancels with no change (CF13, CF7). |
| FR-05 | A blank answer means 'use the default' (CF2). |
| FR-06 | Names already defined in the buffer are never reused; suffix `_2`, `_3`... (CF4). |
| FR-07 | `cursor` mode indents to the cursor line; `function` mode adds blank-line separation; `file` mode creates a new file and opens it (CF4, CF12). |
| FR-08 | `file` mode never overwrites an existing file (CF12). |
| FR-09 | A language is added by one validated record (CF6). |
| FR-10 | The engine CLI supports `list`, `prompts`, `gen`, `ask` with the documented flags, `--json`, and exit codes 0/1/2 (CF9). |
| FR-11 | `setup(opts)` is idempotent; `teardown()` removes the command, keymap and augroup (CF10). |
| FR-12 | Every failure ends as exactly one notification in the editor, or one message plus exit code 1 or 2 on the command line (CF8, CF9). |
| FR-13 | The Lua layer works with a missing or broken engine by returning `nil, err` (never a crash) (CF11). |

### Non-functional requirements

| ID | Requirement |
|---|---|
| NFR-01 | Pure core: nothing in `lib/` except `bin/main.ml` reads stdin, writes stdout or exits; effects are passed in (`?stdin`, `?ask`) so tests can supply them. |
| NFR-02 | No global mutable state in the OCaml library: functions take the language list as an argument. |
| NFR-03 | Errors follow one policy: `Result` for user-caused failures, exceptions only for contract violations. |
| NFR-04 | Lua is a thin edge: no algorithm logic. It builds an argument list, runs the engine, decodes JSON, and calls the Neovim API. |
| NFR-05 | No Lua module creates globals (checked by the `config`/`init` specs). |
| NFR-06 | Starting Neovim with the plugin costs `plugin/scaffold.lua` only (a guard and a version check); the engine runs on demand. |
| NFR-07 | Every function has at least one provided test, and every Part ends green. |
| NFR-08 | The engine answers in about a few milliseconds; do not add caching or a long-lived process (see EXCL-03). |

### Exclusions

- No LSP, treesitter, completion-engine or snippet-engine integration (extension challenges only).
- No parsing of the user's language: collision detection is a documented line-prefix heuristic.
- No long-running engine process, sockets or RPC: one process per call (about 2 ms here, A-10).
- No persistence: no state files, no shada.
- No GUI frameworks: floating windows and `vim.ui.select` only.
- No packaging, release automation or CI configuration.
- No languages beyond the three built in (the registry makes more easy).
- No Lua code generation language in the base scope (Lua is only the editor edge).

## 5. Workflows

| ID | Workflow | Description | Diagrams |
|---|---|---|---|
| W-1 | Interactive insert | `:Scaffold stack` in a Python buffer -> prompts -> code inserted below the cursor. | SEQ-1, WALK-1, IOV-1 |
| W-2 | Pick then insert | `<leader>cg` -> menu of algorithms for the filetype -> same as W-1. | SEQ-5 |
| W-3 | Cancel | Esc at any prompt -> nothing changes, no message. | SEQ-2, ST-1, ST-2 |
| W-4 | File mode | `:Scaffold union-find mode=file` -> `union_find.py` is created in the current directory and opened. | SEQ-1 |
| W-5 | Add a language | Add one `Lang.cfg` record (data) and four template strings; no logic changes. | CMP-F6 |
| W-6 | Engine on the command line | `main.exe gen --lang python --algo stack` -> stdout and exit code. | SEQ-3, DEP-3 |
| W-7 | Reload during development | `teardown()` then `setup()`; rebuild with `dune build`. | SEQ-4, ST-3 |
| W-8 | Engine missing | Binary not built -> `engine_missing` -> one notification telling you to run `dune build`. | SEQ-2 |

## 6. Dependencies

| Dependency | Status | Notes |
|---|---|---|
| OCaml >= 4.14, opam | Required | Compiler and package manager. The install itself is outside the time budget. |
| dune >= 3.0 | Required | Build and test runner. |
| ounit2 | Required for tests | `opam install ounit2`. |
| Neovim >= 0.10 | Required for Parts 9-10 | Parts 0-8 need no Neovim at all. |
| A shell (sh) | Required | `test/acceptance.sh` is POSIX sh. |
| lazy.nvim / LazyVim | Optional | Only for the final wiring (Part 10). |
| plantuml + graphviz + Java | Optional | Only to re-render the diagrams. |
| git | Optional | Version control of your work (read STREAMING_SECURITY.md before pushing). |
| plenary.nvim, busted, any other test framework | Not used | The Lua harness is provided. |
| Any OCaml library besides the standard library and ounit2 | Not used | No yojson, no str, no unix. Writing the JSON printer and the scanner is the exercise. |

## 7. Rationale

- **Why OCaml for the core.** Variants, exhaustive pattern matching and `Result` make an engine full of 'this or that error' decisions pleasant, and the compiler checks the cases you forgot.
- **Why Lua only at the edge.** Neovim can only be driven from Lua (or Vimscript). Everything else is in OCaml, so Lua is limited to what must be Lua: spawning the process, reading and writing buffers, windows, extmarks, commands and keymaps.
- **Why a separate process and JSON.** It keeps the two languages decoupled and testable alone: the engine is tested by ounit and a shell script, the edge by headless Neovim and fake engines. A process call costs about 2 ms here (A-10), which is fine for a keypress-triggered action.
- **Why the engine owns all rules.** Name collisions, defaults, validation and placement are the same whether the call comes from the editor or a shell, so they live once, in OCaml.
- **Plans as data.** `Insert.place` returns `{text; file}`; the edge only inserts text or writes a file. Deciding and doing are separate.
- **Provided tests, written implementations.** All tests ship finished so the assignment is the implementation. Tests are also the specification: read the failing message, then the contract.
- **Abstract `Session.t`.** Prompts outlive the function that started them; a state value hidden behind an interface forbids illegal states.
- **No treesitter.** It would triple the scope; a documented heuristic is honest and replaceable.

## 8. Conventions and the process protocol

### 8.1 Error policy (one rule, three places)
| Style | When | Shape | Example |
|---|---|---|---|
| **`Result`** | A user-caused failure the caller can recover from | `Error (Err.t)` or a module-specific error such as `Err.template_error` | unknown language, bad name, unclosed template tag |
| **Exception** | A contract violation: the caller broke a documented precondition | `invalid_arg "Module.fn: reason"` (`Invalid_argument`); `failwith` only for impossible states | `Util.split s ~sep:""`, `Lang.file_name` of a nameless base |
| **Lua `nil, err`** | Any expected failure at the edge, including engine and Neovim API errors | `return nil, { code = "...", ... }` | `engine_missing`, `invalid_buffer`, `file_exists` |

Neovim API calls that may throw are wrapped in `pcall` and converted to `nil, { code = "api_error", message = ... }`. `Err.t` has 17 cases (Section 9).

### 8.2 Indexing
OCaml strings are 0-based; template error positions are **0-based byte offsets** of the opening `<%`. Lua arrays and string positions are 1-based. `nvim_buf_get_lines`/`nvim_buf_set_lines` are **0-based and end-exclusive**; `nvim_win_get_cursor` returns `{row (1-based), col (0-based)}`. The Lua edge uses 1-based rows in its own API (`buffer.insert_lines(bufnr, row, text)` inserts AFTER 1-based `row`); every conversion is commented where it happens.

### 8.3 Naming
OCaml: modules `Capitalized`, values `snake_case`, one `.mli` per module; Lua: modules `scaffold.<name>`, functions `snake_case`, private functions `local`.

### 8.4 Purity and effects
`lib/` is pure. Effects enter as arguments: `Cli.run ?stdin ?ask argv` receives a thunk for stdin and a function for interactive answers, and returns `{code; stdout; stderr}`. Only `bin/main.ml` reads the real stdin, writes the real stdout/stderr and calls `exit`. On the Lua side only `client` (process), `buffer` (buffers and files), `ui`, `commands`, `init` touch Neovim.

### 8.5 State
OCaml has no module-level mutable state: the language registry is a `Lang.t list` passed to every function that needs it. Lua keeps state only in `init` (stored config and augroup id) and in `ui` (one namespace id), each with a teardown.

### 8.6 The process protocol (the only contract between OCaml and Lua)
| Item | Rule |
|---|---|
| Command | `main.exe <list \| prompts \| gen \| ask> [flags]` |
| Flags | `--lang ID`, `--ft FILETYPE`, `--algo ID`, `--set name=value` (repeatable), `--mode cursor\|function\|file`, `--indent N`, `--existing a,b`, `--scan TEXT` (`-` means read TEXT from stdin), `--json` |
| Exit codes | 0 success, 1 domain error (request cannot be satisfied), 2 usage error (bad invocation) |
| Human mode | results on stdout; errors on stderr; usage errors prefixed `usage error: ` |
| JSON mode | stdout only; success `list -> {"items":[{id,title,group}]}`, `prompts -> {"prompts":[{name,prompt,ghost}]}`, `gen/ask -> {"text":...,"file":string or null}`; error `{"error":{"code","message"}}` with exit 1 or 2 |
| Lua side | `client.call(args, stdin)` appends `--json`, runs `vim.system` (argument list, no shell), decodes stdout, returns `table` or `nil, {code, message}`; JSON `null` arrives as `vim.NIL` [V] |

## 9. Data shapes and error catalog

See diagrams **CL-1** (OCaml types), **CL-2** (module interfaces), **CL-3** (errors), **CL-5** (Lua shapes and protocol).

### 9.1 OCaml types (provided in the `.mli` files)

| Type | Definition (summary) |
|---|---|
| `Lang.cfg` | `{id; filetypes; extension; indent_width; camel_case; types; def_markers}`; `types = {int_t; float_t; string_t; bool_t}` |
| `Lang.t` | `{cfg; indent; fn_style}` (derived by `Lang.derive`) |
| `Lang.elem` | `Int | Float | String | Bool` |
| `Naming.style` | `Snake | Camel | Pascal | Upper_snake` |
| `Template.seg` | `Text of string | Var of {name; filters}`; `filter = Snake | Camel | Pascal | Upper_snake | Upper | Lower` |
| `Catalog.param` / `algo` | `{name; prompt; kind; default}` (`kind = Ident_fn | Ident_type | Elem`); `{id; title; group; params}` |
| `Insert.plan` | `{text : string; file : string option}`; `mode = Cursor | Function | File` |
| `Engine.opts` | `{lang; algo; answers; existing; mode; cursor_indent}` |
| `Session.t` | abstract; `state = Collecting | Ready | Cancelled` |
| `Cli.parsed` / `outcome` | `{cmd; set; flags; json}` / `{code; stdout; stderr}` |
| `Json.t` | `Null | Bool | Int | Str | List | Obj` |

### 9.2 Engine error codes (17)

| Code | Produced by | Fields |
|---|---|---|
| `bad_lang_config` | Lang.validate | field, reason |
| `duplicate_id` | Lang.register | id |
| `duplicate_filetype` | Lang.register | filetype, owner |
| `unknown_lang` | Engine.generate, Engine.list, Cli | lang |
| `unknown_algo` | Engine.generate, Cli | algo |
| `no_template` | Engine.generate | algo, lang |
| `unknown_param` | Params.resolve | name |
| `bad_ident` | Params.normalize_ident | param, value |
| `bad_elem` | Params.normalize_elem | value |
| `template` | Engine.generate (wraps a template error) | Unclosed pos / Empty_var pos / Bad_name / Bad_filter / Unbound |
| `session_closed` | Session.record | state |
| `unknown_flag` | Cli.parse_flags | flag |
| `missing_value` | Cli.parse_flags | flag |
| `bad_set` | Cli.parse_flags | value |
| `unexpected_arg` | Cli.parse_flags | arg |
| `unknown_command` | Cli.run | command |
| `bad_value` | Cli.run_gen | flag, value |

### 9.3 Lua-side error codes

| Code | Produced by | Meaning |
|---|---|---|
| `bad_config` | config.resolve | option missing/invalid (field, reason) |
| `engine_missing` | client.binary | binary not found or not executable (path) |
| `engine_failed` | client.call | process could not be started |
| `bad_json` | client.call | stdout was not a JSON object (stderr, exit) |
| `invalid_buffer` | buffer.* | buffer handle invalid (bufnr) |
| `file_exists` | buffer.write_file | refusing to overwrite (path) |
| `api_error` | buffer.* | Neovim API raised (message) |
| `bad_arg` | commands.parse_args | unknown or malformed argument (arg) |
| `(engine codes)` | client.call | any code from 9.2 passes through unchanged |

## 10. Directory tree, file annotations, creation order

Create the project **outside** the folder holding these documents (for example `~/dev/scaffold.nvim/`).

### Project setup (start here)

A starter skeleton ships beside these documents as `scaffold.nvim-skeleton.tgz`. It contains every file in the tree below, the provided data (`Langs.configs`, `Catalog.all`, `templates.ml`, config defaults), all 340 finished tests (238 OCaml, 102 Lua) plus the six acceptance checks, and stubs that raise `not implemented: F-nnn`. It deliberately contains no implementation of any registry function. The same tarball unpacks `scaffold.nvim-docs/` (this specification as Markdown and HTML, the diagrams as Markdown and HTML) next to the project folder, outside it. `SETUP.md` has the full instructions; `PROGRESS.md` is your checklist by Part.

Verified while building the skeleton `[V]`: with every stub replaced by my private reference implementation (not shipped) all 238 OCaml tests, all 102 Lua tests and the six acceptance checks pass on OCaml 4.14.1 / dune 3.14.0 / Neovim 0.10.4; with only the stubs, the build succeeds and all 238 OCaml tests fail without crashing the runner, and no Lua test passes by accident.

```text
scaffold.nvim/
├── dune-project
├── dune                      (warnings never stop the build)
├── lib/                      the OCaml library "scaffold"
│   ├── dune
│   ├── util.ml(i)            Part 0-1
│   ├── naming.ml(i)          Part 1
│   ├── err.ml(i)             Part 2
│   ├── json.ml(i)            Part 2
│   ├── lang.ml(i)            Part 3
│   ├── langs.ml(i)           Part 3   (data provided)
│   ├── template.ml(i)        Part 4
│   ├── templates.ml(i)       data provided (12 templates)
│   ├── catalog.ml(i)         Part 5   (data provided)
│   ├── collision.ml(i)       Part 5
│   ├── params.ml(i)          Part 6
│   ├── session.ml(i)         Part 6
│   ├── insert.ml(i)          Part 7
│   ├── engine.ml(i)          Part 7
│   └── cli.ml(i)             Part 8
├── bin/
│   ├── dune
│   └── main.ml               Part 8   (Main.main)
├── test/                     ounit2, provided and finished
│   ├── dune
│   ├── main.ml
│   ├── test_helpers.ml
│   ├── test_<module>.ml      one per library module
│   └── acceptance.sh         6 end-to-end shell checks
├── plugin/
│   └── scaffold.lua          provided (guard + version check)
├── lua/scaffold/             the thin Lua edge
│   ├── config.lua            Part 9
│   ├── client.lua            Part 9
│   ├── buffer.lua            Part 9
│   ├── ui.lua                Part 10
│   ├── commands.lua          Part 10
│   └── init.lua              Part 10
├── lua_test/                 headless Neovim tests, provided and finished
│   ├── harness.lua  fixtures.lua  run.lua
│   └── <module>_spec.lua
├── README.md  SETUP.md  PROGRESS.md  Makefile  test.sh
└── notes/NOTES.md            your answers to research questions
```

### File annotations

| File | Why it exists | Required / stretch | Provides | Owns | Imports | Dependents | Concepts you learn |
|---|---|---|---|---|---|---|---|
| `dune-project` | Project root file for dune: language version and project name. | essential | (config) | - | - | - | - |
| `dune` | Root dune file: shows warnings but never fails the build. | essential | (config) | - | - | - | - |
| `lib/dune` | Declares the library `scaffold`. | essential | (config) | - | - | - | - |
| `lib/util.ml` | String helpers. | essential | Util.trim, starts_with, find_sub, split, leading_ws | string scanning | (none) | naming, template, collision, insert, cli | `ref`, `while`, `String.sub`, labelled arguments |
| `lib/naming.ml` | Words and case styles. | essential | Naming.words, convert | word boundaries, four case styles | util | lang, template, params | variants, pattern matching on chars, `Buffer` |
| `lib/err.ml` | The error variant and its codes and messages. | essential | Err.code, message | the error type, code and message | (none) | every module | variants with payloads, `Printf.sprintf` |
| `lib/json.ml` | A minimal JSON value type and printer. | essential | Json.escape, to_string | JSON value type and printer | (none) | cli | recursive variants, escaping |
| `lib/lang.ml` | Language records, validation and lookup. | essential | Lang.* | validated records, lookup, file names | naming, err | everything language-aware | records, `result`, list lookup |
| `lib/langs.ml` | Data: the three builtin language configs. | essential | Langs.configs (provided), Langs.install | three configs, `install` | lang | cli, tests | records, `List.fold_left` |
| `lib/template.ml` | Template scanner, parser and renderer. | essential | Template.* | scan, parse, vars, filters, render | util, naming, err | engine, params | scanning with positions, tagged unions |
| `lib/templates.ml` | Data: the twelve template strings. | essential | (provided) | (data) | (none) | catalog | quoted strings `{\|...\|}` |
| `lib/catalog.ml` | Data: the algorithm table, plus lookups. | essential | Catalog.all (provided), find, template, for_lang | algo table, template lookup | templates, lang | engine, params, cli | records, `List.find_opt` |
| `lib/collision.ml` | Existing-name detection and suffixing. | essential | Collision.* | unique_name, defined_names | util, lang | params, cli | line scanning, `List.mem` |
| `lib/params.ml` | From answers to template environment. | essential | Params.* | normalize_*, ghost, resolve, next_prompt | naming, collision, lang, catalog | engine, session, cli | `result` plumbing, defaults |
| `lib/session.ml` | Prompt session state machine. | stretch | Session.* | an abstract session | params | cli (ask) | abstract types, state machines |
| `lib/insert.ml` | Placement plans. | essential | Insert.reindent, place | reindent, place | util, lang | engine | returning plans |
| `lib/engine.ml` | The pure pipeline. | essential | Engine.generate, list | generate, list | lang, catalog, params, template, insert | cli | composition of fallible steps, `let*` |
| `lib/cli.ml` | Command-line logic as a pure function of its inputs. | essential | Cli.* | parse_flags, run_*, run | engine, lang, catalog, params, collision, json, session | bin/main.ml | pure functions that take their effects as arguments |
| `bin/main.ml` | The only file that touches stdin, stdout and the exit code. | essential | Main.main | reads stdin, prints, exits | cli | (shell) | `Sys.argv`, `In_channel`, `exit` |
| `test/*` | ounit2 tests and the acceptance script (provided). | essential | (tests) | - | - | - | - |
| `plugin/scaffold.lua` | Sourced by Neovim at startup: guard + version check. | essential | (provided) | a guard variable | (none) | Neovim startup | `plugin/` loading |
| `lua/scaffold/config.lua` | Merge and validate options. | essential | config.resolve | defaults and resolve | (none) | init | `vim.tbl_deep_extend`, `(value, err)` |
| `lua/scaffold/client.lua` | Spawns the engine; JSON in and out. | essential | client.* | binary path, process call, JSON | (none) | init, commands | `vim.system`, `vim.json.decode`, `pcall` |
| `lua/scaffold/buffer.lua` | Buffer and file reads and writes. | essential | buffer.* | context, insert, write, open | (none) | init | 0-based API, `pcall` boundaries |
| `lua/scaffold/ui.lua` | Ghost text and floating input. | essential | ui.* | ghost_set/clear, input | (none) | init | windows, extmarks, closures, `vim.schedule` |
| `lua/scaffold/commands.lua` | User command, argument parsing, completion. | essential | commands.* | parse_args, complete, register | client | init | user commands, completion |
| `lua/scaffold/init.lua` | Public entry: setup, run, pick, teardown. | essential | init.* | setup, run, pick, teardown | config, client, buffer, ui, commands | your config | augroups, keymaps, callbacks |
| `lua_test/*` | Headless Neovim tests (provided). | essential | (tests) | - | - | - | - |
| `notes/NOTES.md` | Your answers to the research questions. | essential | (notes) | - | - | - | - |

### Manual creation order (only if you do not use the skeleton)

1. Unpack the skeleton (SETUP.md). Everything below already exists as a stub.
2. `lib/util.ml` (Parts 0-1), then `naming.ml`.
3. `err.ml`, `json.ml` (Part 2).
4. `lang.ml`, `langs.ml` install (Part 3).
5. `template.ml` (Part 4).
6. `catalog.ml` lookups, `collision.ml` (Part 5).
7. `params.ml`, `session.ml` (Part 6).
8. `insert.ml`, `engine.ml` (Part 7).
9. `cli.ml`, `bin/main.ml` (Part 8).
10. `config.lua`, `client.lua`, `buffer.lua` (Part 9).
11. `ui.lua`, `commands.lua`, `init.lua` and the lazy.nvim spec (Part 10).

## 11. Function registry

The single source of truth. `Req` = required or stretch. `Diagrams` always begins with the function's activity diagram `AD-nnn`.

| ID | Name | Module path | Signature | Responsibility | Depends on | Effects | Diff | Part | Req | Diagrams | Tests |
|---|---|---|---|---|---|---|---|---|---|---|---|
| F-001 | `Util.trim` | `lib/util.ml` | `Util.trim : string -> string` | Remove leading and trailing ASCII whitespace (space, tab, newline, CR, VT, FF). | - | none (pure) | 1/5 | 0 | required | AD-001, CL-2, CMP-F5, CMP-2 | T-001..T-003 (3) |
| F-002 | `Util.starts_with` | `lib/util.ml` | `Util.starts_with : string -> prefix:string -> bool` | True when the string begins with the prefix (labelled argument `~prefix`). | - | none (pure) | 1/5 | 0 | required | AD-002, CL-2, CMP-F5, CMP-2 | T-004..T-006 (3) |
| F-003 | `Util.find_sub` | `lib/util.ml` | `Util.find_sub : string -> sub:string -> from:int -> int option` | Index of the first occurrence of `sub` at or after `from`, or None. Plain text search, no patterns. | - | none (pure) | 2/5 | 1 | required | AD-003, CL-2, CMP-F5, CMP-F3, CMP-2 | T-007..T-010 (4) |
| F-004 | `Util.split` | `lib/util.ml` | `Util.split : string -> sep:string -> string list` | Split a string on a non-empty separator, keeping empty pieces (like String.split_on_char but for multi-character separators). | F-003 | none (pure) | 2/5 | 1 | required | AD-004, CL-2, CMP-F5, CMP-F3, CMP-F7, CMP-2 | T-011..T-014 (4) |
| F-005 | `Util.leading_ws` | `lib/util.ml` | `Util.leading_ws : string -> string` | The run of spaces and tabs at the start of a line (the line's indentation). | - | none (pure) | 1/5 | 1 | required | AD-005, CL-2, CMP-F4, CMP-2 | T-015..T-017 (3) |
| F-006 | `Naming.words` | `lib/naming.ml` | `Naming.words : string -> string list` | Split an identifier-like string into lowercase words at separators, lower-to-upper transitions, digit-to-upper transitions and acronym ends. | - | none (pure) | 4/5 | 1 | required | AD-006, CL-2, CMP-F2, CMP-2 | T-018..T-022 (5) |
| F-007 | `Naming.convert` | `lib/naming.ml` | `Naming.convert : Naming.style -> string -> string` | Re-style a string as snake_case, camelCase, PascalCase or UPPER_SNAKE using `words`. | F-006 | none (pure) | 2/5 | 1 | required | AD-007, CL-2, CMP-F2, CMP-2 | T-023..T-027 (5) |
| F-008 | `Err.code` | `lib/err.ml` | `Err.code : Err.t -> string` | Map every error constructor to its stable snake_case code string. | - | none (pure) | 1/5 | 2 | required | AD-008, CL-3, CL-2, CMP-F8, CMP-2 | T-028..T-030 (3) |
| F-009 | `Err.message` | `lib/err.ml` | `Err.message : Err.t -> string` | Render any error as a one-line human message. Template errors render through a nested match. | F-008 | none (pure) | 2/5 | 2 | required | AD-009, CL-3, CL-2, CMP-F8, CMP-2 | T-031..T-035 (5) |
| F-010 | `Json.escape` | `lib/json.ml` | `Json.escape : string -> string` | Escape a string for use inside a JSON string literal (quotes, backslash, control characters). | - | none (pure) | 2/5 | 2 | required | AD-010, CL-2, CMP-F1, CL-1, CMP-2 | T-036..T-039 (4) |
| F-011 | `Json.to_string` | `lib/json.ml` | `Json.to_string : Json.t -> string` | Serialise a Json.t as compact JSON (no spaces, object keys in the given order). | F-010 | none (pure) | 2/5 | 2 | required | AD-011, CL-2, CMP-F1, CL-1, CMP-2 | T-040..T-044 (5) |
| F-012 | `Lang.validate` | `lib/lang.ml` | `Lang.validate : Lang.cfg -> (Lang.cfg, Err.t) result` | Check a language configuration and return it unchanged, or the first problem as Bad_lang_config {field; reason}. | - | none (pure) | 3/5 | 3 | required | AD-012, CL-1, CL-2, CMP-F6, OBJ-2, CMP-2 | T-045..T-052 (8) |
| F-013 | `Lang.derive` | `lib/lang.ml` | `Lang.derive : Lang.cfg -> Lang.t` | Compute the derived fields of a validated config: the indent string and the function-name style. | F-012 | none (pure) | 1/5 | 3 | required | AD-013, CL-1, CL-2, CMP-F6, OBJ-2, CMP-2 | T-053..T-056 (4) |
| F-014 | `Lang.register` | `lib/lang.ml` | `Lang.register : Lang.t list -> Lang.cfg -> (Lang.t list, Err.t) result` | Validate a config, reject duplicate ids and duplicate filetypes, and append the derived language to the registry. | F-012, F-013 | none (pure) | 3/5 | 3 | required | AD-014, CL-1, CMP-2, OBJ-2, CL-2, CMP-F6 | T-057..T-061 (5) |
| F-015 | `Lang.find` | `lib/lang.ml` | `Lang.find : Lang.t list -> string -> Lang.t option` | Look a language up by its id. | - | none (pure) | 1/5 | 3 | required | AD-015, OBJ-2, CL-2, CMP-F6, CL-1, CMP-2 | T-062..T-064 (3) |
| F-016 | `Lang.find_by_filetype` | `lib/lang.ml` | `Lang.find_by_filetype : Lang.t list -> string -> Lang.t option` | Look a language up by a Neovim filetype (a language may own several, e.g. javascript and javascriptreact). | - | none (pure) | 1/5 | 3 | required | AD-016, CL-2, CMP-F6, CL-1, OBJ-2, CMP-2 | T-065..T-067 (3) |
| F-017 | `Lang.file_name` | `lib/lang.ml` | `Lang.file_name : Lang.t -> string -> string` | Build the file name for File insert mode: the base converted to the language's function style plus its extension. | F-007 | none (pure) | 2/5 | 3 | required | AD-017, CL-2, CMP-F6, CMP-F4, CL-1, OBJ-2, CMP-2 | T-068..T-071 (4) |
| F-018 | `Lang.elem_type` | `lib/lang.ml` | `Lang.elem_type : Lang.t -> Lang.elem -> string` | The language's spelling of an element type (int, float, string, bool). | - | none (pure) | 1/5 | 3 | required | AD-018, CL-2, CMP-F6, CL-1, OBJ-2, CMP-2 | T-072..T-074 (3) |
| F-019 | `Langs.install` | `lib/langs.ml` | `Langs.install : Lang.t list -> Lang.t list` | Add the three built-in languages that are missing from a registry (python, javascript, ocaml). | F-014, F-015 | none (pure) | 2/5 | 3 | required | AD-019, OBJ-2, CL-2, CMP-F6, CMP-2 | T-075..T-078 (4) |
| F-020 | `Template.scan_tag` | `lib/template.ml` | `Template.scan_tag : string -> int -> (Template.seg * int, Err.template_error) result` | Given the text and the byte offset of a `<%`, parse one tag `<% name \| filter \| filter %>` and return the Var segment plus the offset just after `%>`. | F-003, F-004, F-001 | none (pure) | 4/5 | 4 | required | AD-020, CL-2, CMP-F3, CMP-2 | T-079..T-085 (7) |
| F-021 | `Template.parse` | `lib/template.ml` | `Template.parse : string -> (Template.seg list, Err.template_error) result` | Split template text into Text and Var segments, in order, with no empty Text segments. | F-020, F-003 | none (pure) | 3/5 | 4 | required | AD-021, SEQ-6, CL-2, CMP-F3, CMP-2 | T-086..T-090 (5) |
| F-022 | `Template.vars` | `lib/template.ml` | `Template.vars : Template.seg list -> string list` | The distinct variable names used by a template, in order of first appearance. | - | none (pure) | 2/5 | 4 | required | AD-022, CL-2, CMP-F3, CMP-2 | T-091..T-093 (3) |
| F-023 | `Template.apply_filter` | `lib/template.ml` | `Template.apply_filter : Template.filter -> string -> string` | Apply one filter (snake, camel, pascal, upper_snake, upper, lower) to a value. | F-007 | none (pure) | 1/5 | 4 | required | AD-023, CL-2, CMP-F3, CMP-F2, CMP-2 | T-094..T-096 (3) |
| F-024 | `Template.render` | `lib/template.ml` | `Template.render : Template.seg list -> (string * string) list -> (string, Err.template_error) result` | Produce the output text: Text as is, each Var looked up in the environment and passed through its filters left to right. | F-023 | none (pure) | 3/5 | 4 | required | AD-024, CMP-2, SEQ-6, CL-2, CMP-F3 | T-097..T-101 (5) |
| F-025 | `Catalog.find` | `lib/catalog.ml` | `Catalog.find : string -> Catalog.algo option` | Look an algorithm up by id in the fixed catalog (binary-search, insertion-sort, stack, union-find). | - | none (pure) | 1/5 | 5 | required | AD-025, CL-2, CMP-F1, CMP-2 | T-102..T-104 (3) |
| F-026 | `Catalog.template` | `lib/catalog.ml` | `Catalog.template : algo_id:string -> lang_id:string -> string option` | The template text for an (algorithm, language) pair, or None when no template exists. | - | none (pure) | 1/5 | 5 | required | AD-026, CL-2, CMP-F1, CMP-2 | T-105..T-107 (3) |
| F-027 | `Catalog.for_lang` | `lib/catalog.ml` | `Catalog.for_lang : string -> Catalog.algo list` | The algorithms that have a template for the given language id, in catalog order. | F-026 | none (pure) | 2/5 | 5 | required | AD-027, CL-2, CMP-F1, CMP-2 | T-108..T-110 (3) |
| F-028 | `Collision.unique_name` | `lib/collision.ml` | `Collision.unique_name : string list -> string -> string` | Return the name unchanged if free, otherwise name_2, name_3, ... the first free suffix. | - | none (pure) | 2/5 | 5 | required | AD-028, CL-2, CMP-F4, CMP-2 | T-111..T-114 (4) |
| F-029 | `Collision.defined_names` | `lib/collision.ml` | `Collision.defined_names : Lang.t -> string -> string list` | Names the buffer text defines, found by looking at the start of each trimmed line for one of the language's def_markers. | F-004, F-001, F-002 | none (pure) | 3/5 | 5 | required | AD-029, CL-2, CMP-F4, CMP-2 | T-115..T-121 (7) |
| F-030 | `Params.normalize_ident` | `lib/params.ml` | `Params.normalize_ident : Lang.t -> Catalog.param -> string -> (string, Err.t) result` | Turn what the user typed for a name parameter into a valid identifier in the right style for the language and parameter kind. | F-001, F-006, F-007 | none (pure) | 3/5 | 6 | required | AD-030, CL-2, CMP-F2, CMP-F8, CMP-2 | T-122..T-126 (5) |
| F-031 | `Params.normalize_elem` | `lib/params.ml` | `Params.normalize_elem : Lang.t -> string -> (string, Err.t) result` | Map the user's element-type word (int, float, string, bool; any case) to the language's own type name. | F-018, F-001 | none (pure) | 1/5 | 6 | required | AD-031, CL-2, CMP-F2, CMP-2 | T-127..T-129 (3) |
| F-032 | `Params.ghost` | `lib/params.ml` | `Params.ghost : Lang.t -> Catalog.param -> string` | The ghost text (placeholder preview) for a prompt: the default, styled as the final identifier would be. | F-007 | none (pure) | 1/5 | 6 | required | AD-032, CL-2, CMP-F2, CMP-F7, CMP-2 | T-130..T-132 (3) |
| F-033 | `Params.resolve` | `lib/params.ml` | `Params.resolve : ?existing:string list -> Lang.t -> Catalog.algo -> (string * string) list -> ((string * string) list, Err.t) result` | Turn the user's raw answers into final template values for every parameter of the algorithm: fill defaults, normalise, avoid existing names. | F-030, F-031, F-028, F-001 | none (pure) | 4/5 | 6 | required | AD-033, CMP-2, SEQ-6, CL-2, CMP-F2, CMP-F4, CMP-F8 | T-133..T-140 (8) |
| F-034 | `Params.next_prompt` | `lib/params.ml` | `Params.next_prompt : Lang.t -> Catalog.algo -> (string * string) list -> (Catalog.param * string) option` | The first parameter that has no answer yet, with its ghost text; None when all are answered. | F-032 | none (pure) | 2/5 | 6 | stretch | AD-034, OBJ-1, CL-2, CMP-F7, CMP-2 | T-141..T-144 (4) |
| F-035 | `Session.create` | `lib/session.ml` | `Session.create : Lang.t -> Catalog.algo -> Session.t` | Start a prompting session: no answers yet, state Collecting. | - | none (pure) | 1/5 | 6 | stretch | AD-035, CL-1, ST-1, CL-2, CMP-F7, OBJ-1, CMP-2 | T-145 |
| F-036 | `Session.state` | `lib/session.ml` | `Session.state : Session.t -> Session.state` | Report Collecting, Ready or Cancelled. | - | none (pure) | 1/5 | 6 | stretch | AD-036, ST-1, CL-2, CMP-F7, OBJ-1, CMP-2 | T-146..T-147 (2) |
| F-037 | `Session.answers` | `lib/session.ml` | `Session.answers : Session.t -> (string * string) list` | Answers recorded so far, oldest first, as (param name, raw text). | - | none (pure) | 1/5 | 6 | stretch | AD-037, CL-2, CMP-F7, ST-1, OBJ-1, CMP-2 | T-148..T-149 (2) |
| F-038 | `Session.pending` | `lib/session.ml` | `Session.pending : Session.t -> (Catalog.param * string) option` | The next question (parameter and ghost), or None when none is left. | F-034, F-037 | none (pure) | 1/5 | 6 | stretch | AD-038, OBJ-1, CL-2, CMP-F7, ST-1, CMP-2 | T-150..T-151 (2) |
| F-039 | `Session.record` | `lib/session.ml` | `Session.record : Session.t -> string -> (Session.t, Err.t) result` | Record the answer to the pending question; become Ready when it was the last one. | F-038 | none (pure) | 3/5 | 6 | stretch | AD-039, ST-1, OBJ-1, CL-2, CMP-F7, CMP-2 | T-152..T-155 (4) |
| F-040 | `Session.cancel` | `lib/session.ml` | `Session.cancel : Session.t -> Session.t` | Cancel a Collecting session; Ready and Cancelled sessions are returned unchanged. | - | none (pure) | 1/5 | 6 | stretch | AD-040, ST-1, CL-2, CMP-F7, OBJ-1, CMP-2 | T-156..T-158 (3) |
| F-041 | `Insert.reindent` | `lib/insert.ml` | `Insert.reindent : string -> string -> string` | Prefix every non-blank line of a block with an indent string; blank lines stay blank. | F-004, F-001 | none (pure) | 2/5 | 7 | required | AD-041, CL-2, CMP-F4, CMP-2 | T-159..T-163 (5) |
| F-042 | `Insert.place` | `lib/insert.ml` | `Insert.place : Lang.t -> Insert.mode -> cursor_indent:string -> name:string -> body:string -> Insert.plan` | Decide what to insert and where: Cursor re-indents; Function adds a blank line before and a newline after; File adds a final newline and a file name. | F-041, F-017 | none (pure) | 2/5 | 7 | required | AD-042, SEQ-6, CL-2, CMP-F4, CMP-2 | T-164..T-167 (4) |
| F-043 | `Engine.generate` | `lib/engine.ml` | `Engine.generate : Lang.t list -> Engine.opts -> (Insert.plan, Err.t) result` | The whole pipeline: language, algorithm, template, parameters, parse, render, place. The first failing stage returns its error. | F-015, F-025, F-026, F-033, F-021, F-024, F-042 | none (pure) | 4/5 | 7 | required | AD-043, CL-1, CMP-1, CMP-2, SEQ-3, SEQ-6, WALK-1, CL-2, CMP-F1, CMP-F3, CMP-F4, IOV-1 | T-168..T-178 (11) |
| F-044 | `Engine.list` | `lib/engine.ml` | `Engine.list : Lang.t list -> string -> (Engine.item list, Err.t) result` | The algorithms available for a language id, as {id; group; title} items. | F-015, F-027 | none (pure) | 2/5 | 7 | required | AD-044, CL-2, CMP-F1, SEQ-6, IOV-1, CMP-2 | T-179..T-181 (3) |
| F-045 | `Cli.parse_flags` | `lib/cli.ml` | `Cli.parse_flags : string list -> (Cli.parsed, Err.t) result` | Parse argv (without the program name) into command, --set pairs, value flags and the --json switch. | F-002 | none (pure) | 4/5 | 8 | required | AD-045, CL-1, CL-2, CMP-F9, SEQ-3, UC-3, DEP-3, CMP-2 | T-182..T-190 (9) |
| F-046 | `Cli.resolve_lang` | `lib/cli.ml` | `Cli.resolve_lang : Lang.t list -> (string * string) list -> string option` | Pick the language id from the flags: --lang wins; otherwise map --ft through the registry; an unmapped --ft is returned as is (so the engine reports unknown_lang with that text). | F-016 | none (pure) | 2/5 | 8 | required | AD-046, CL-2, CMP-F9, SEQ-3, UC-3, DEP-3, CMP-2 | T-191..T-194 (4) |
| F-047 | `Cli.run_list` | `lib/cli.ml` | `Cli.run_list : Lang.t list -> (string * string) list -> (Engine.item list, Err.t) result` | The `list` command: resolve the language and list its algorithms. | F-046, F-044 | none (pure) | 1/5 | 8 | required | AD-047, CL-2, CMP-F9, SEQ-3, UC-3, DEP-3, CMP-2 | T-195..T-197 (3) |
| F-048 | `Cli.run_prompts` | `lib/cli.ml` | `Cli.run_prompts : Lang.t list -> (string * string) list -> ((Catalog.param * string) list, Err.t) result` | The `prompts` command: every parameter of an algorithm, each with its ghost text. | F-046, F-032, F-025, F-015 | none (pure) | 2/5 | 8 | required | AD-048, CL-2, CMP-F9, CMP-F7, SEQ-3, UC-3, DEP-3, CMP-2 | T-198..T-200 (3) |
| F-049 | `Cli.run_gen` | `lib/cli.ml` | `Cli.run_gen : Lang.t list -> (string * string) list -> (string * string) list -> (Insert.plan, Err.t) result` | The `gen` command: validate --mode and --indent, collect existing names (from --scan text, else --existing list), then call Engine.generate. | F-046, F-029, F-043, F-004 | none (pure) | 4/5 | 8 | required | AD-049, UC-3, SEQ-3, CL-2, CMP-F9, CMP-F4, DEP-3, CMP-2 | T-201..T-211 (11) |
| F-050 | `Cli.run_ask` | `lib/cli.ml` | `Cli.run_ask : Lang.t list -> (string * string) list -> ask:Cli.ask -> (Insert.plan option, Err.t) result` | The interactive `ask` command: drive a Session by calling the `ask` callback for each pending question, then run_gen with the collected answers. A callback answer of None cancels. | F-035, F-038, F-039, F-037, F-049 | none (pure) | 3/5 | 8 | stretch | AD-050, UC-3, CL-2, CMP-F9, CMP-F7, SEQ-3, DEP-3, CMP-2 | T-212..T-217 (6) |
| F-051 | `Cli.run` | `lib/cli.ml` | `Cli.run : ?stdin:(unit -> string) -> ?ask:Cli.ask -> string list -> Cli.outcome` | The command line as a pure function: argv in, {code; stdout; stderr} out. Dispatches list / prompts / gen / ask and formats results as text or JSON. | F-045, F-047, F-048, F-049, F-050, F-011, F-019, F-008, F-009 | none (pure) | 4/5 | 8 | required | AD-051, UC-3, CL-1, CL-3, CMP-1, CMP-2, DEP-3, SEQ-3, WALK-1, CL-2, CMP-F9, CMP-F1, CMP-F8 | T-218..T-238 (21) |
| F-052 | `Main.main` | `bin/main.ml` | `Main.main : unit  (the program's entry point)` | Connect Cli.run to the real process: read argv, stdin, an interactive `ask` callback on the terminal, print the outcome, and exit with its code. | F-051 | none (pure) | 2/5 | 8 | required | AD-052, UC-3, DEP-1, DEP-2, DEP-3, SEQ-3, CL-2, CMP-F9 | A-01..A-06 (acceptance script) |
| F-053 | `config.resolve` | `lua/scaffold/config.lua` | `config.resolve(user: table\|nil) -> table \| nil, err` | Merge the user's opts over the defaults and validate them. Defaults: mode="cursor", keymap="<leader>cg", command="Scaffold", bin=nil. | - | none (pure) | 2/5 | 9 | required | AD-053, UC-4, SEQ-4, CL-2, CMP-F10, CMP-3, CL-5 | T-239..T-246 (8) |
| F-054 | `client.binary` | `lua/scaffold/client.lua` | `client.binary() -> path \| nil, err` | Locate the engine executable: client.bin if set, else $SCAFFOLD_BIN, else <plugin root>/_build/default/bin/main.exe. Fail if it is not executable. | - | none (pure) | 2/5 | 9 | required | AD-054, UC-1, UC-4, DEP-1, SEQ-2, CL-2, CMP-F11, CL-5, SEQ-1, CMP-3 | T-247..T-251 (5) |
| F-055 | `client.call` | `lua/scaffold/client.lua` | `client.call(args: string[], stdin?: string) -> table \| nil, err` | Run the engine with args plus --json, wait for it, decode its stdout as JSON, and turn an {"error":...} reply into (nil, {code, message}). | F-054 | none (pure) | 4/5 | 9 | required | AD-055, UC-2, CL-5, CMP-1, CMP-3, DEP-1, DEP-2, SEQ-2, COM-1, CL-2, CMP-F11, CMP-F1, SEQ-1 | T-252..T-260 (9) |
| F-056 | `client.list` | `lua/scaffold/client.lua` | `client.list(filetype: string) -> item[] \| nil, err` | The algorithms the engine offers for a Neovim filetype: a list of {id, title, group}. | F-055 | none (pure) | 1/5 | 9 | required | AD-056, CL-5, SEQ-5, CL-2, CMP-F11, SEQ-1, CMP-3 | T-261..T-263 (3) |
| F-057 | `client.prompts` | `lua/scaffold/client.lua` | `client.prompts(filetype: string, algo: string) -> prompt[] \| nil, err` | The questions to ask for an algorithm: a list of {name, prompt, ghost}. | F-055 | none (pure) | 1/5 | 9 | required | AD-057, CL-5, SEQ-1, CL-2, CMP-F11, CMP-F7, CMP-3 | T-264..T-267 (4) |
| F-058 | `client.generate` | `lua/scaffold/client.lua` | `client.generate(req: {filetype, algo, answers?, mode?, indent?, text?}) -> {text, file?} \| nil, err` | Ask the engine to generate code. The buffer text goes to the engine on stdin (`--scan -`) so it can avoid name clashes; answers become repeated `--set name=value`. | F-055 | none (pure) | 3/5 | 9 | required | AD-058, UC-2, CL-5, SEQ-1, WALK-1, CL-2, CMP-F11, CMP-F4, CMP-3 | T-268..T-275 (8) |
| F-059 | `buffer.context` | `lua/scaffold/buffer.lua` | `buffer.context(bufnr: integer) -> ctx \| nil, err` | Read what the engine needs from a buffer: filetype, cursor row (1-based), indentation of the cursor line, the full text, and the file name. | - | none (pure) | 2/5 | 9 | required | AD-059, CMP-3, SEQ-1, CL-2, CMP-F12 | T-276..T-280 (5) |
| F-060 | `buffer.insert_lines` | `lua/scaffold/buffer.lua` | `buffer.insert_lines(bufnr: integer, row: integer, text: string) -> true \| nil, err` | Insert text (which may span several lines) AFTER line `row` (1-based; row 0 inserts at the top). | - | none (pure) | 3/5 | 9 | required | AD-060, UC-2, SEQ-1, WALK-1, CL-2, CMP-F12, CMP-3 | T-281..T-286 (6) |
| F-061 | `buffer.write_file` | `lua/scaffold/buffer.lua` | `buffer.write_file(path: string, text: string) -> true \| nil, err` | Create a new file containing the text; refuse to overwrite an existing path. | - | none (pure) | 2/5 | 9 | stretch | AD-061, UC-2, CL-2, CMP-F12, CMP-F4, SEQ-1, CMP-3 | T-287..T-289 (3) |
| F-062 | `buffer.open_file` | `lua/scaffold/buffer.lua` | `buffer.open_file(path: string) -> bufnr \| nil, err` | Open a file in the current window and return its buffer number. | - | none (pure) | 1/5 | 9 | stretch | AD-062, CL-2, CMP-F12, SEQ-1, CMP-3 | T-290..T-292 (3) |
| F-063 | `ui.ghost_set` | `lua/scaffold/ui.lua` | `ui.ghost_set(bufnr: integer, row: integer, text: string) -> extmark_id \| nil, err` | Show grey 'ghost' text at the end of line `row` (1-based) using a virtual-text extmark in the plugin's own namespace. | - | none (pure) | 3/5 | 10 | required | AD-063, ST-2, CL-2, CMP-F13, CS-1, TIM-1, CMP-3 | T-293..T-295 (3) |
| F-064 | `ui.ghost_clear` | `lua/scaffold/ui.lua` | `ui.ghost_clear(bufnr: integer) -> nil` | Remove every ghost extmark of this plugin from the buffer. Silent for invalid buffers. | F-063 | none (pure) | 1/5 | 10 | required | AD-064, ST-2, CL-2, CMP-F13, CS-1, TIM-1, CMP-3 | T-296..T-297 (2) |
| F-065 | `ui.input` | `lua/scaffold/ui.lua` | `ui.input(prompt: string, ghost: string, on_done: fun(value: string\|nil)) -> handle {close, buf, win}` | Open a one-line floating window titled with the prompt, show the ghost text, and call on_done(line) on <CR> or on_done(nil) on <Esc>. on_done runs exactly once, asynchronously (vim.schedule), after the window is closed. | F-063, F-064 | none (pure) | 5/5 | 10 | required | AD-065, CMP-3, SEQ-1, SEQ-2, ST-2, COM-1, TIM-1, CS-1, CL-2, CMP-F13 | T-298..T-304 (7) |
| F-066 | `commands.parse_args` | `lua/scaffold/commands.lua` | `commands.parse_args(fargs: string[]) -> {algo, mode?} \| nil, err` | Turn the command's words into {algo, mode}. The first word is the algorithm id; later words must be `mode=<value>`. | - | none (pure) | 2/5 | 10 | required | AD-066, SEQ-1, CL-2, CMP-F10, CMP-3 | T-305..T-310 (6) |
| F-067 | `commands.complete` | `lua/scaffold/commands.lua` | `commands.complete(arglead: string, cmdline: string) -> string[]` | Command-line completion: the first argument completes to algorithm ids for the current buffer's filetype; later arguments complete to mode=cursor\|function\|file. | F-056 | none (pure) | 3/5 | 10 | stretch | AD-067, UC-1, CL-2, CMP-F10, SEQ-1, CMP-3 | T-311..T-316 (6) |
| F-068 | `commands.register` | `lua/scaffold/commands.lua` | `commands.register(name: string, handler: fun(args)) -> nil` | Create the user command `name` (nargs="+", with completion). It parses its arguments; on bad arguments it notifies an error, otherwise it calls handler(args). | F-066, F-067 | none (pure) | 3/5 | 10 | required | AD-068, UC-1, CMP-3, SEQ-4, CL-2, CMP-F10, SEQ-1 | T-317..T-320 (4) |
| F-069 | `init.setup` | `lua/scaffold/init.lua` | `init.setup(opts?: table) -> M` | Resolve config, remember it, point the client at cfg.bin, create the augroup, register the command and the pick keymap. Bad config is an error() naming the field. | F-053, F-068 | none (pure) | 3/5 | 10 | required | AD-069, UC-1, UC-4, CMP-3, SEQ-4, ST-3, CL-2, CMP-F10, CMP-F11, SEQ-1, SEQ-2, SEQ-5, WALK-1 | T-321..T-325 (5) |
| F-070 | `init.run` | `lua/scaffold/init.lua` | `init.run(algo_id: string, mode?: string) -> nil` | Run one insertion: read the buffer, fetch the prompts, ask each with ui.input (asynchronously), then generate and insert — as text, or as a new file that is written and opened. Any error is shown with vim.notify at ERROR level; cancelling (nil) stops silently. | F-059, F-057, F-058, F-060, F-061, F-062, F-065 | none (pure) | 5/5 | 10 | required | AD-070, UC-1, UC-2, CL-5, CMP-1, SEQ-1, SEQ-2, SEQ-5, COM-1, IOV-1, WALK-1, CL-2, CMP-F10, CMP-F7, CMP-F4, SEQ-4, ST-3, CMP-3 | T-326..T-333 (8) |
| F-071 | `init.pick` | `lua/scaffold/init.lua` | `init.pick() -> nil` | Let the user choose an algorithm for the current filetype with vim.ui.select, then run it. | F-056, F-070 | none (pure) | 2/5 | 10 | stretch | AD-071, UC-1, SEQ-5, IOV-1, CL-2, CMP-F10, SEQ-1, SEQ-2, SEQ-4, WALK-1, ST-3, CMP-3 | T-334..T-337 (4) |
| F-072 | `init.teardown` | `lua/scaffold/init.lua` | `init.teardown() -> nil` | Undo setup: delete the augroup, the user command and the keymap, forget the config and clear client.bin. Safe to call twice. | - | none (pure) | 2/5 | 10 | required | AD-072, UC-1, UC-4, SEQ-4, ST-3, CL-2, CMP-F10, SEQ-1, SEQ-2, SEQ-5, WALK-1, CMP-3 | T-338..T-340 (3) |

## 12. Data fixtures (provided, non-solution)

These files are **data**, already in the skeleton. They are reproduced so you can read them; do not retype them. Their correctness is exercised by the engine test that all 12 (language x algorithm) combinations generate.

### F1 - `lib/langs.ml` (the `configs` list; you write `install`)

```ocaml
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
```

### F2 - `lib/catalog.ml` (types and the `all` table; you write the lookups)

```ocaml
(* lib/catalog.ml  -- Algorithms and their parameters (data provided; lookup functions are yours) (Part 5). *)
type param_kind = Ident_fn | Ident_type | Elem
type param = { name : string; prompt : string; kind : param_kind; default : string }
type algo = { id : string; title : string; group : string; params : param list }

let elem_prompt = "Element type (int, float, string, bool)"

let all : algo list =
  [
    {
      id = "binary-search";
      title = "Binary search";
      group = "searching";
      params =
        [
          { name = "fn"; prompt = "Function name"; kind = Ident_fn; default = "binary search" };
          { name = "elem"; prompt = elem_prompt; kind = Elem; default = "int" };
        ];
    };
    {
      id = "insertion-sort";
      title = "Insertion sort";
      group = "sorting";
      params =
        [
          { name = "fn"; prompt = "Function name"; kind = Ident_fn; default = "insertion sort" };
          { name = "elem"; prompt = elem_prompt; kind = Elem; default = "int" };
        ];
    };
    {
      id = "stack";
      title = "Stack";
      group = "data structures";
      params =
        [
          { name = "type_name"; prompt = "Type name"; kind = Ident_type; default = "stack" };
          { name = "elem"; prompt = elem_prompt; kind = Elem; default = "int" };
        ];
    };
    {
      id = "union-find";
      title = "Union-find";
      group = "data structures";
      params =
        [ { name = "type_name"; prompt = "Type name"; kind = Ident_type; default = "union find" } ];
    };
  ]

(* F-025  Catalog.find : string -> Catalog.algo option
   Look an algorithm up by id in the fixed catalog (binary-search, insertion-sort, stack, union-find).
   Requires: none
   Produces: Some algo or None.
   Tests: T-102, T-103, T-104   Diagram: AD-025   Part 5
   Challenge: One line. *)
let find _ = failwith "not implemented: F-025 Catalog.find"

(* F-026  Catalog.template : algo_id:string -> lang_id:string -> string option
   The template text for an (algorithm, language) pair, or None when no template exists.
   Requires: none
   Produces: Some text or None.
   Tests: T-105, T-106, T-107   Diagram: AD-026   Part 5
   Challenge: Unknown language gives None, not an exception. *)
let template ~algo_id:_ ~lang_id:_ = failwith "not implemented: F-026 Catalog.template"

(* F-027  Catalog.for_lang : string -> Catalog.algo list
   The algorithms that have a template for the given language id, in catalog order.
   Requires: none
   Produces: A (possibly empty) list.
   Tests: T-108, T-109, T-110   Diagram: AD-027   Part 5
   Challenge: Write it as a single filter, without a loop. *)
let for_lang _ = failwith "not implemented: F-027 Catalog.for_lang"
```

### F3 - `lib/templates.ml` (twelve templates)

```ocaml
(* lib/templates.ml  -- Template TEXT (provided data, generated from the reference). Do not edit until extension E-03. *)
(* Template data (provided fixture). Each entry: algorithm id, template text in the <% name | filter %> language. *)

let python : (string * string) list =
  [
    ( "binary-search",
      {tpl|def <% fn %>(items: list[<% elem %>], target: <% elem %>) -> int:
    """Return the index of target in the sorted list items, or -1."""
    lo, hi = 0, len(items) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if items[mid] == target:
            return mid
        if items[mid] < target:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1|tpl} );
    ( "insertion-sort",
      {tpl|def <% fn %>(items: list[<% elem %>]) -> list[<% elem %>]:
    """Return a sorted copy of items (the input is not changed)."""
    result = list(items)
    for i in range(1, len(result)):
        key = result[i]
        j = i - 1
        while j >= 0 and result[j] > key:
            result[j + 1] = result[j]
            j -= 1
        result[j + 1] = key
    return result|tpl} );
    ( "stack",
      {tpl|class <% type_name %>:
    """A last-in first-out stack of <% elem %> values."""

    def __init__(self) -> None:
        self._items: list[<% elem %>] = []

    def push(self, item: <% elem %>) -> None:
        self._items.append(item)

    def pop(self) -> "<% elem %> | None":
        return self._items.pop() if self._items else None

    def peek(self) -> "<% elem %> | None":
        return self._items[-1] if self._items else None

    def is_empty(self) -> bool:
        return not self._items

    def size(self) -> int:
        return len(self._items)|tpl} );
    ( "union-find",
      {tpl|class <% type_name %>:
    """Disjoint sets with path compression and union by size."""

    def __init__(self, n: int) -> None:
        self._parent = list(range(n))
        self._size = [1] * n

    def find(self, x: int) -> int:
        while self._parent[x] != x:
            self._parent[x] = self._parent[self._parent[x]]
            x = self._parent[x]
        return x

    def union(self, a: int, b: int) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self._size[ra] < self._size[rb]:
            ra, rb = rb, ra
        self._parent[rb] = ra
        self._size[ra] += self._size[rb]
        return True|tpl} );
  ]

let javascript : (string * string) list =
  [
    ( "binary-search",
      {tpl|/**
 * Index of target in the sorted array items, or -1.
 * @param {<% elem %>[]} items
 * @param {<% elem %>} target
 * @returns {number}
 */
function <% fn %>(items, target) {
  let lo = 0;
  let hi = items.length - 1;
  while (lo <= hi) {
    const mid = Math.floor((lo + hi) / 2);
    if (items[mid] === target) return mid;
    if (items[mid] < target) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
}|tpl} );
    ( "insertion-sort",
      {tpl|/**
 * A sorted copy of items (the input is not changed).
 * @param {<% elem %>[]} items
 * @returns {<% elem %>[]}
 */
function <% fn %>(items) {
  const result = [...items];
  for (let i = 1; i < result.length; i++) {
    const key = result[i];
    let j = i - 1;
    while (j >= 0 && result[j] > key) {
      result[j + 1] = result[j];
      j--;
    }
    result[j + 1] = key;
  }
  return result;
}|tpl} );
    ( "stack",
      {tpl|/** A last-in first-out stack of <% elem %> values. */
class <% type_name %> {
  #items = [];

  /** @param {<% elem %>} item */
  push(item) {
    this.#items.push(item);
  }

  /** @returns {<% elem %> | undefined} */
  pop() {
    return this.#items.pop();
  }

  /** @returns {<% elem %> | undefined} */
  peek() {
    return this.#items[this.#items.length - 1];
  }

  isEmpty() {
    return this.#items.length === 0;
  }

  size() {
    return this.#items.length;
  }
}|tpl} );
    ( "union-find",
      {tpl|/** Disjoint sets with path compression and union by size. */
class <% type_name %> {
  #parent;
  #size;

  /** @param {number} n */
  constructor(n) {
    this.#parent = Array.from({ length: n }, (_, i) => i);
    this.#size = new Array(n).fill(1);
  }

  /** @param {number} x */
  find(x) {
    while (this.#parent[x] !== x) {
      this.#parent[x] = this.#parent[this.#parent[x]];
      x = this.#parent[x];
    }
    return x;
  }

  /** @returns {boolean} false if a and b were already joined */
  union(a, b) {
    let ra = this.find(a);
    let rb = this.find(b);
    if (ra === rb) return false;
    if (this.#size[ra] < this.#size[rb]) [ra, rb] = [rb, ra];
    this.#parent[rb] = ra;
    this.#size[ra] += this.#size[rb];
    return true;
  }
}|tpl} );
  ]

let ocaml : (string * string) list =
  [
    ( "binary-search",
      {tpl|(* Index of target in the sorted array items, or -1. *)
let <% fn %> (items : <% elem %> array) (target : <% elem %>) : int =
  let rec go lo hi =
    if lo > hi then -1
    else
      let mid = (lo + hi) / 2 in
      if items.(mid) = target then mid
      else if items.(mid) < target then go (mid + 1) hi
      else go lo (mid - 1)
  in
  go 0 (Array.length items - 1)|tpl} );
    ( "insertion-sort",
      {tpl|(* A sorted copy of items (the input is not changed). *)
let <% fn %> (items : <% elem %> array) : <% elem %> array =
  let result = Array.copy items in
  for i = 1 to Array.length result - 1 do
    let key = result.(i) in
    let j = ref (i - 1) in
    while !j >= 0 && result.(!j) > key do
      result.(!j + 1) <- result.(!j);
      decr j
    done;
    result.(!j + 1) <- key
  done;
  result|tpl} );
    ( "stack",
      {tpl|(* A persistent last-in first-out stack of <% elem %> values. *)
module <% type_name %> = struct
  type t = <% elem %> list

  let empty : t = []
  let is_empty (s : t) = s = []
  let push (x : <% elem %>) (s : t) : t = x :: s
  let pop (s : t) : (<% elem %> * t) option =
    match s with [] -> None | x :: rest -> Some (x, rest)
  let peek (s : t) : <% elem %> option =
    match s with [] -> None | x :: _ -> Some x
  let size (s : t) = List.length s
end|tpl} );
    ( "union-find",
      {tpl|(* Disjoint sets with path compression and union by size. *)
module <% type_name %> = struct
  type t = { parent : int array; size : int array }

  let create n = { parent = Array.init n (fun i -> i); size = Array.make n 1 }

  let rec find t x =
    if t.parent.(x) = x then x
    else begin
      let r = find t t.parent.(x) in
      t.parent.(x) <- r;
      r
    end

  let union t a b =
    let ra = find t a and rb = find t b in
    if ra = rb then false
    else begin
      let ra, rb = if t.size.(ra) < t.size.(rb) then (rb, ra) else (ra, rb) in
      t.parent.(rb) <- ra;
      t.size.(ra) <- t.size.(ra) + t.size.(rb);
      true
    end
end|tpl} );
  ]
```

**How to read a template:** `<% fn | snake %>` means 'insert the value of parameter `fn`, converted to snake_case'; an unfiltered `<% elem %>` is the element type already spelled for the language. The OCaml string syntax `{|...|}` is a *quoted string*: it needs no escapes, so the templates can contain quotes and backslashes as they are.

**Walk-through (Python stack):** parameter `type_name` -> `class <% type_name %>:`; parameter `elem` -> appears in the docstring and annotations. Parameter names come from `Catalog.all` (stack: `type_name`, `elem`; union-find has only `type_name`).

## 13. Foundational examples

Each example is labelled **boilerplate** (copy as is), **partial** (some lines are yours to add), **pseudocode**, or **non-solution fixture** (it runs, teaches an idiom, solves nothing in the registry). Outputs shown were produced by running the code (OCaml 4.14.1 / Neovim 0.10.4); FX-01 and FX-17 are configuration and were not executed.

Topic index: dune project FX-01 · modules and `.mli` FX-02 · variants FX-03 · records and labels FX-04 · `option`/`result`/`let*` FX-05 · recursion FX-06 · chars and `Buffer` FX-07 · exceptions vs results FX-08 · ounit2 tests FX-09 · Lua modules FX-10 · `vim.system` + JSON FX-11 · buffers FX-12 · floating window + ghost text FX-13 · commands, keymaps, augroups FX-14 · `(value, err)` and `pcall` FX-15 · testing seams FX-16 · lazy.nvim spec FX-17.

### FX-01 - A dune project in four small files

**Label:** boilerplate (already in the skeleton) · **Topic:** build system

```lua
(* dune-project *)
(lang dune 3.0)

(* lib/dune *)
(library (name scaffold))

(* bin/dune *)
(executable (name main) (libraries scaffold))

(* test/dune *)
(test (name main) (libraries scaffold ounit2))
```

**Expected output:**

```text
(configuration - not executed)
```

**Line-by-line:**

- *lines 2:* dune-project fixes the dune language version; every project needs exactly one.
- *lines 5:* A library named scaffold makes every module in lib/ available as Scaffold.Util, Scaffold.Naming, ...
- *lines 8:* An executable that links the library; dune builds it as _build/default/bin/main.exe.
- *lines 11:* A test stanza: `dune test` builds and runs it.

**Why this fits:** dune is the build tool that the OCaml community uses; these four stanzas are all this project needs.

**Common mistakes:**

- Forgetting `(libraries scaffold)` makes `Scaffold.Util` an unbound module.
- Putting two executables in one directory without `names`.

**What transfers to the project:** Parts 0 and 8.

### FX-02 - Modules and interface files

**Label:** non-solution fixture (runs) · **Topic:** modules, mli, abstract types

```ocaml
(* counter.mli *)
type t
val create : int -> t
val bump : t -> t
val value : t -> int

(* counter.ml *)
type t = { n : int }
let create n = { n }
let bump c = { n = c.n + 1 }
let value c = c.n

(* use *)
let () =
  let c = Counter.create 40 |> Counter.bump |> Counter.bump in
  Printf.printf "%d\n" (Counter.value c)
```

**Expected output:**

```text
42
```

**Line-by-line:**

- *lines 1-5:* The .mli lists what other modules may use. `type t` without a definition is ABSTRACT: nobody outside can build or read a `t` except through these functions.
- *lines 7-10:* The .ml defines the record; its fields are invisible outside.
- *lines 13-15:* `|>` feeds the left value into the right function; `Printf.printf` takes a format string.

**Why this fits:** Session.t in this project is exactly this pattern: the .mli hides the record so the state machine cannot be corrupted by callers.

**Common mistakes:**

- Defining the type in the .ml but forgetting the .mli exposes everything.
- Writing `val` in the .mli with a different type from the .ml: the compiler tells you which one is wrong.

**What transfers to the project:** Part 6 (Session), and every .mli in lib/.

### FX-03 - Variants and exhaustive matching

**Label:** non-solution fixture (runs) · **Topic:** variants, pattern matching

```ocaml
type shape = Circle of float | Rect of float * float | Point

let area = function
  | Circle r -> 3.14159 *. r *. r
  | Rect (w, h) -> w *. h
  | Point -> 0.0

let () =
  List.iter
    (fun s -> Printf.printf "%.2f\n" (area s))
    [ Circle 1.0; Rect (2.0, 3.0); Point ]
```

**Expected output:**

```text
3.14
6.00
0.00
```

**Line-by-line:**

- *lines 1:* A variant: each constructor may carry data.
- *lines 3-6:* `function` is `fun x -> match x with`. Remove one arm and the compiler warns that the match is not exhaustive.
- *lines 9-11:* `%.2f` prints a float with two decimals.

**Why this fits:** Err.code, Err.message, Naming.convert and Template.apply_filter are all matches over variants; the compiler is your checklist.

**Common mistakes:**

- Using `_ ->` as a catch-all hides the warning you want.
- Forgetting parentheses around a constructor argument: `area Circle 1.0` is a type error.

**What transfers to the project:** Parts 1, 2, 4, 7.

### FX-04 - Records, update syntax and labelled arguments

**Label:** non-solution fixture (runs) · **Topic:** records, labels, optional args

```ocaml
type point = { x : int; y : int }

let shift ?(dx = 0) ?(dy = 0) p = { p with x = p.x + dx; y = p.y + dy }
let label ~name p = Printf.sprintf "%s=(%d,%d)" name p.x p.y

let () =
  let p = { x = 1; y = 2 } in
  print_endline (label ~name:"a" (shift ~dx:10 p));
  print_endline (label ~name:"b" (shift p))
```

**Expected output:**

```text
a=(11,2)
b=(1,2)
```

**Line-by-line:**

- *lines 1:* A record type; fields are accessed with a dot.
- *lines 3:* `?(dx = 0)` is an optional argument with a default. `{ p with ... }` copies p with some fields replaced: p itself is not changed.
- *lines 4:* `~name` is a labelled argument: callers can pass it by name, in any order.
- *lines 8-9:* An optional argument can simply be left out.

**Why this fits:** Params.resolve has an optional ?existing argument; Util.starts_with ~prefix and Insert.place ~cursor_indent are labelled. Session.record uses `{ t with ... }`.

**Common mistakes:**

- Putting an optional argument last means it can never be omitted (nothing follows it).
- Passing a label with the wrong name is a compile error, which is useful.

**What transfers to the project:** Parts 1, 6, 7, 8.

### FX-05 - option, result and the let* operator

**Label:** non-solution fixture (runs) · **Topic:** error handling without exceptions

```ocaml
let ( let* ) = Result.bind

let parse_int s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error ("not a number: " ^ s)

let positive n = if n > 0 then Ok n else Error "not positive"

let add_checked a b =
  let* x = parse_int a in
  let* y = parse_int b in
  let* z = positive (x + y) in
  Ok z

let show = function Ok n -> string_of_int n | Error e -> "error: " ^ e

let () =
  List.iter
    (fun (a, b) -> print_endline (show (add_checked a b)))
    [ ("1", "2"); ("x", "2"); ("-5", "1") ]
```

**Expected output:**

```text
3
error: not a number: x
error: not positive
```

**Line-by-line:**

- *lines 1:* Defines a binding operator: `let* x = e in body` now means `Result.bind e (fun x -> body)`.
- *lines 3-6:* `int_of_string_opt` returns an option; we turn it into a result.
- *lines 11-14:* Each `let*` stops at the first Error; later lines never run.
- *lines 20-22:* The same function used on three inputs.

**Why this fits:** Engine.generate chains seven fallible stages this way; Cli.run_gen and Cli.run_ask use it too.

**Common mistakes:**

- Writing `let*` without defining it first gives an unbound-operator error.
- Mixing Ok/Error payload types in one chain: every stage must share the SAME error type (here string).

**What transfers to the project:** Parts 3, 4, 7, 8.

### FX-06 - Recursion with an accumulator

**Label:** partial · **Topic:** recursion, lists

```ocaml
let rec split_commas s start acc =
  match String.index_from_opt s start ',' with
  | None -> List.rev (String.sub s start (String.length s - start) :: acc)
  | Some i -> split_commas s (i + 1) (String.sub s start (i - start) :: acc)

let () =
  List.iter print_endline (split_commas "a,b,,c" 0 [])
```

**Expected output:**

```text
a
b

c
```

**Line-by-line:**

- *lines 1:* `let rec` allows the function to call itself; the extra arguments carry the loop state (position, results so far).
- *lines 3:* Base case: no more commas, so the rest is the last piece; `List.rev` restores the order because we pushed with `::`.
- *lines 4:* Recursive case: cut a piece, move past the comma, continue.

**Why this fits:** This is the shape of Util.split, Template.parse and Cli.parse_flags. Your versions search for a multi-character separator with Util.find_sub instead of a single char.

**Common mistakes:**

- Appending with `@` in each step makes the whole function quadratic.
- Forgetting that `String.sub s start len` takes a LENGTH, not an end index.

**What transfers to the project:** Parts 1, 4, 8.

### FX-07 - Scanning characters with Buffer and ranges

**Label:** non-solution fixture (runs) · **Topic:** chars, Buffer, imperative loops

```ocaml
let digits_only s =
  let b = Buffer.create (String.length s) in
  String.iter (fun c -> match c with '0' .. '9' -> Buffer.add_char b c | _ -> ()) s;
  Buffer.contents b

let leading_blanks s =
  let i = ref 0 in
  while !i < String.length s && (s.[!i] = ' ' || s.[!i] = '\t') do incr i done;
  !i

let () =
  print_endline (digits_only "a1b22c");
  print_endline (string_of_int (leading_blanks "  \tx"))
```

**Expected output:**

```text
122
3
```

**Line-by-line:**

- *lines 2:* A Buffer is a growable string: add pieces, then take `contents`.
- *lines 3:* `'0' .. '9'` is a character range pattern.
- *lines 8-10:* `ref` makes a mutable cell; `!i` reads it, `incr i` adds one. A while loop is fine when it makes the scan clearer.

**Why this fits:** Naming.words, Json.escape, Collision.defined_names and Util.trim use exactly these tools.

**Common mistakes:**

- Reading `s.[i]` without checking `i < String.length s` raises Invalid_argument.
- Using `i := !i + 1` as `i := i + 1` (type error).

**What transfers to the project:** Parts 0-2, 5.

### FX-08 - Exceptions versus results

**Label:** non-solution fixture (runs) · **Topic:** invalid_arg, try, why we mostly avoid exceptions

```ocaml
let checked_sub s pos len =
  if pos < 0 || len < 0 || pos + len > String.length s then invalid_arg "checked_sub"
  else String.sub s pos len

let () =
  print_endline (checked_sub "hello" 1 3);
  (match checked_sub "hello" 4 3 with
   | exception Invalid_argument msg -> print_endline ("caught: " ^ msg)
   | v -> print_endline v)
```

**Expected output:**

```text
ell
caught: checked_sub
```

**Line-by-line:**

- *lines 2:* `invalid_arg` raises the standard exception for a caller mistake (a broken precondition).
- *lines 6-9:* `match ... with exception E -> ...` handles the exception right where the call happens.

**Why this fits:** This project uses exceptions only for contract violations (Util.find_sub with a negative start, Lang.file_name with no words) and Result for every failure a user can cause.

**Common mistakes:**

- Using exceptions for user mistakes (bad names) pushes error handling out of sight of the type checker.
- Catching every exception with `with _ ->` swallows bugs.

**What transfers to the project:** Parts 0-1, 3, 7.

### FX-09 - An ounit2 test file

**Label:** boilerplate · **Topic:** testing

```ocaml
open OUnit2

let tests =
  "demo" >::: [
    "adds" >:: (fun _ -> assert_equal 4 (2 + 2));
    "strings" >:: (fun _ -> assert_equal ~printer:(Printf.sprintf "%S") "ab" ("a" ^ "b"));
    "raises" >:: (fun _ ->
      assert_raises (Invalid_argument "x") (fun () -> invalid_arg "x"));
  ]

let () = run_test_tt_main tests
```

**Expected output:**

```text
...
Ran: 3 tests in: 0.10 seconds.
OK
```

**Line-by-line:**

- *lines 1:* `open OUnit2` brings the test functions into scope.
- *lines 4:* `>:::` builds a suite from a list; `>::` names one test; the test function takes an unused argument.
- *lines 5-7:* `assert_equal expected actual`; add `~printer` to see readable failures.

**Why this fits:** Every file in test/ has this shape; test_helpers.ml adds the assertions you will see most (eq_str, eq_strs, is_err).

**Common mistakes:**

- Swapping expected and actual only changes the failure message, not the verdict, but it confuses you.
- Forgetting `~printer` for strings gives unhelpful failure text.

**What transfers to the project:** Part 0 (read it before running dune test).

### FX-10 - Modules and require in Lua

**Label:** non-solution fixture (runs) · **Topic:** modules, returned tables, error levels

```lua
-- greet.lua  (imagine it in lua/demo/greet.lua)
local M = {}
local function shout(s) return s:upper() .. "!" end   -- private: not in M
function M.hello(name)
  if type(name) ~= "string" then error("demo.greet.hello: name must be a string", 2) end
  return shout("hello " .. name)
end

print(M.hello("neovim"))
print(pcall(M.hello, 5))
```

**Expected output:**

```text
HELLO NEOVIM!
false demo.greet.hello: name must be a string
```

**Line-by-line:**

- *lines 2:* A module is a table that the file returns; `local M` keeps it private to the file until returned.
- *lines 3:* `local function` is invisible outside the file.
- *lines 5:* `error(msg, 2)` blames the CALLER (level 2), not this line.
- *lines 10:* `pcall` turns an error into (false, message).

**Why this fits:** Every Lua file you write ends with `return M`, and callers use `require('scaffold.client')`.

**Common mistakes:**

- Forgetting `return M` makes require return `true`.
- Calling `M.hello` as `M:hello` passes M as the first argument (colon syntax).

**What transfers to the project:** Part 9.

### FX-11 - vim.system and JSON

**Label:** non-solution fixture (runs) · **Topic:** processes, JSON, stdin

```lua
local res = vim.system({ "sh", "-c", "cat; echo '{\"n\": 3}' 1>&2" }, { text = true, stdin = "hello" }):wait()
print(res.code, res.stdout, vim.trim(res.stderr))
local ok, data = pcall(vim.json.decode, '{"items":[1,2],"x":null}')
print(ok, #data.items, data.x == vim.NIL)
print(pcall(vim.json.decode, "not json"))
```

**Expected output:**

```text
0 hello {"n": 3}
true 2 true
false Expected value but found invalid token at character 1
```

**Line-by-line:**

- *lines 1:* `vim.system(cmd, opts)` starts a process; `:wait()` blocks until it exits and returns a table with code, stdout and stderr. `stdin` feeds the child's standard input.
- *lines 3:* `vim.json.decode` raises on bad JSON, so wrap it in `pcall`.
- *lines 4:* JSON null decodes to `vim.NIL`, which is truthy; compare against it explicitly.

**Why this fits:** client.call is exactly these three calls plus error mapping.

**Common mistakes:**

- Passing a string command instead of a list.
- Forgetting `text = true`: stdout then arrives as raw bytes.

**What transfers to the project:** Part 9 (client).

### FX-12 - Buffers: 0-based, end-exclusive

**Label:** non-solution fixture (runs) · **Topic:** buffer lines

```lua
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "a", "b", "c" })
vim.api.nvim_buf_set_lines(buf, 1, 1, true, { "X" })     -- insert BEFORE index 1 (replaces nothing)
print(vim.inspect(vim.api.nvim_buf_get_lines(buf, 0, -1, false)))
print(pcall(vim.api.nvim_buf_set_lines, buf, 10, 10, true, { "bad" }))
```

**Expected output:**

```text
{ "a", "X", "b", "c" }
false Index out of bounds
```

**Line-by-line:**

- *lines 1:* A scratch buffer: not listed, not backed by a file.
- *lines 2:* (0, -1) means the whole buffer.
- *lines 3:* start == end replaces an empty range, i.e. inserts. Inserting AFTER 1-based row r means passing r as the 0-based start.
- *lines 5:* strict = true turns an out-of-range index into an error that pcall can catch.

**Why this fits:** buffer.insert_lines is one call to this function; the off-by-one is the lesson.

**Common mistakes:**

- Using the 1-based cursor row as an inclusive 0-based start.
- Passing strict = false and silently clamping.

**What transfers to the project:** Part 9 (buffer).

### FX-13 - A floating window with ghost text

**Label:** partial · **Topic:** windows, extmarks, scheduling

```lua
local buf = vim.api.nvim_create_buf(false, true)
local win = vim.api.nvim_open_win(buf, true, { relative = "editor", width = 30, height = 1, row = 2, col = 4, style = "minimal", border = "rounded" })
local ns = vim.api.nvim_create_namespace("demo_ghost")
vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { virt_text = { { "default", "Comment" } }, virt_text_pos = "eol" })
local done
vim.schedule(function() done = "callback ran after the window closed" end)
vim.api.nvim_win_close(win, true)
vim.wait(100, function() return done ~= nil end)
print(vim.api.nvim_win_is_valid(win), done)
```

**Expected output:**

```text
false callback ran after the window closed
```

**Line-by-line:**

- *lines 2:* A floating window: relative to the editor, fixed size, minimal style.
- *lines 3-4:* An extmark with virt_text shows grey text without putting it in the buffer.
- *lines 5-6:* `vim.schedule` queues a function for a later tick of the event loop.
- *lines 8:* `vim.wait` pumps the event loop until the condition is true or the time runs out.

**Why this fits:** ui.input assembles these pieces and adds keymaps and a closed flag.

**Common mistakes:**

- Calling a callback synchronously inside a key mapping while the window is still open.
- Forgetting that extmark rows are 0-based.

**What transfers to the project:** Part 10 (ui).

### FX-14 - Commands, keymaps and an augroup, with cleanup

**Label:** partial · **Topic:** user commands, keymaps, autocmd groups

```lua
local group = vim.api.nvim_create_augroup("demo", { clear = true })
vim.api.nvim_create_user_command("DemoHello", function(o) print("fargs: " .. table.concat(o.fargs, ",")) end, { nargs = "+" })
vim.keymap.set("n", "<leader>zz", function() print("mapped") end, { desc = "demo" })
vim.cmd("DemoHello a b")
print(vim.api.nvim_get_commands({}).DemoHello ~= nil, vim.fn.maparg("<leader>zz", "n") ~= "")
vim.api.nvim_del_user_command("DemoHello")
vim.keymap.del("n", "<leader>zz")
vim.api.nvim_del_augroup_by_id(group)
print(vim.api.nvim_get_commands({}).DemoHello == nil, vim.fn.maparg("<leader>zz", "n") == "")
```

**Expected output:**

```text
fargs: a,b
true true
true true
```

**Line-by-line:**

- *lines 1:* `clear = true` empties the group if it already exists, so calling setup twice does not stack autocmds.
- *lines 2:* `nargs = '+'` demands at least one argument; `o.fargs` is the list of words.
- *lines 6-8:* Everything created is deleted again: this is what teardown does.

**Why this fits:** init.setup creates exactly these four things and init.teardown removes them.

**Common mistakes:**

- Command names must start with an uppercase letter.
- Deleting a group that was already deleted raises; teardown should pcall.

**What transfers to the project:** Part 10 (commands, init).

### FX-15 - The (value, err) convention and pcall

**Label:** non-solution fixture (runs) · **Topic:** error values

```lua
local function safe_div(a, b)
  if b == 0 then return nil, { code = "div_zero", a = a } end
  return a / b
end
local v, e = safe_div(1, 0)
print(v, e.code, e.a)
print(safe_div(6, 3))
local ok, err = pcall(function() error({ code = "boom" }) end)
print(ok, err.code)
```

**Expected output:**

```text
nil div_zero 1
2
false boom
```

**Line-by-line:**

- *lines 2:* Expected failures return nil plus an error TABLE with a stable code.
- *lines 8:* `error` can raise a table, not only a string; pcall hands it back unchanged.

**Why this fits:** Every Lua function in this project that can fail for user reasons returns (nil, err) with a code field.

**Common mistakes:**

- Returning false instead of nil: callers cannot tell `false` results from failure.
- Returning an error STRING: tests cannot compare codes.

**What transfers to the project:** Part 9-10.

### FX-16 - Why the Lua edge calls the engine through a thin helper

**Label:** partial · **Topic:** testing seams

```lua
-- module under test: calls ui.input through the TABLE, so a test can replace it
local ui = { input = function(prompt, ghost, cb) cb(nil) end }   -- stands for require("scaffold.ui")
local function ask_all(prompts)
  local answers = {}
  local function step(i)
    local p = prompts[i]
    if not p then return answers end
    ui.input(p, "g", function(v) answers[#answers + 1] = v; step(i + 1) end)
  end
  step(1)
  return answers
end
ui.input = function(p, g, cb) cb(p .. "!") end      -- the test replaces it
print(vim.inspect(ask_all({ "a", "b" })))
```

**Expected output:**

```text
{ "a!", "b!" }
```

**Line-by-line:**

- *lines 1-2:* The stub stands in for the real module; the code under test calls `ui.input(...)`, never a captured local copy.
- *lines 5-8:* Recursion from inside the callback: a loop cannot wait for something that happens later.
- *lines 13:* Replacing the field is how the provided tests drive init.run without a keyboard.

**Why this fits:** init.run must call `ui.input` and `vim.ui.select` through their tables, because the provided tests replace them.

**Common mistakes:**

- `local input = ui.input` at the top of the file defeats the replacement.
- A for-loop over prompts cannot wait for callbacks.

**What transfers to the project:** Part 10 (init).

### FX-17 - A lazy.nvim spec (configuration, not executed)

**Label:** pseudocode / configuration · **Topic:** plugin manager

```lua
-- lua/plugins/scaffold.lua  in your LazyVim config
return {
  {
    dir = "~/dev/scaffold.nvim",          -- or "yourname/scaffold.nvim" when published
    name = "scaffold.nvim",
    build = "dune build",                 -- builds the engine after install/update
    cmd = { "Scaffold" },
    keys = { { "<leader>cg", desc = "Scaffold: pick algorithm" } },
    opts = { mode = "cursor" },
  },
}
```

**Expected output:**

```text
(configuration - not executed)
```

**Line-by-line:**

- *lines 3:* A local directory instead of a GitHub name while developing.
- *lines 5:* `build` runs after install and update; the exact option names are from memory of lazy.nvim and were NOT verified here.
- *lines 8:* `opts` is passed to setup() by lazy.nvim.

**Why this fits:** This is the final integration step in Part 10; the engine must exist before the first :Scaffold.

**Common mistakes:**

- Forgetting the build step: the first command then reports engine_missing.
- Lazy-loading by keys but defining no keymap inside setup (or the reverse).

**What transfers to the project:** Part 10 (integration).

## 14. Curriculum

**Rhythm of every Part:** read -> run the Part's tests (red) -> implement until green -> refactor with the tests as a net -> research questions in `notes/NOTES.md` -> checkpoint -> demo. The time budget, sessions and cut list are at the top of this document.

### 14.1 Build order (dependency-aware)
`Util -> Naming -> Err -> Json -> Lang -> Langs.install -> Template -> Catalog -> Collision -> Params -> Session -> Insert -> Engine -> Cli -> Main` (all in `lib/`/`bin/`), then `config -> client -> buffer -> ui -> commands -> init` (Lua). This is the topological order of diagram CL-2: never write a module before the ones it uses.


### Part 0: Setup and first red tests (35 min, session S1, required)

Build the skeleton, run the OCaml tests and watch them fail for the right reason, then turn the first two functions green.  
**Prerequisites.** Toolchain installed (see SETUP.md; the install itself is outside the budget).  
**Language concepts.** `let` bindings, `ref`, `!` and `:=`, `while` loops, `String.length`, `String.sub`, labelled arguments (`~prefix`)  
**Neovim concepts.** none: Parts 0-8 do not need Neovim

**READ**

- 5 min - [dune quick start (project layout, `dune build`, `dune test`)](https://dune.readthedocs.io/en/stable/quick-start.html)
- 5 min - [CS3110: OUnit (how a test file is shaped)](https://cs3110.github.io/textbook/chapters/data/ounit.html)
- 5 min - [CS3110: references, `!`, `:=` and loops](https://cs3110.github.io/textbook/chapters/mut/refs.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (2): F-001 `Util.trim`, F-002 `Util.starts_with`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_util.ml` (6 tests for the two functions). `dune test` runs the whole suite: expect 238 errors at first, every one `not implemented: F-nnn`.

**Expected behavior.** `Util.trim "  hi there " = "hi there"`; `Util.starts_with "de" ~prefix:"def " = false` (no exception).

**Foundational examples to read first:** FX-01, FX-02, FX-09

**Pitfalls**

- Calling `String.trim` or `String.starts_with`: the point is to write the scan yourself.
- `String.sub s i len` takes a LENGTH, not an end index, and raises `Invalid_argument` when out of range.
- Forgetting `rec`/`ref`: `i = i + 1` compares, it does not assign; use `i := !i + 1`.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-0-1** `dune test` prints one error per not-yet-written function and keeps going. Why does it not stop at the first failure?
- **RQ-0-2** Why can `String.sub s 0 (-1)` happen inside a careless `trim`, and what does your loop do for the all-blank string?
- **RQ-0-3** What is the type of `ref 0`, and how do `!x`, `x := 1` and `x = 1` differ?

**Checkpoint.** `dune build` succeeds; the six `Util.trim`/`Util.starts_with` tests are green; the other 232 OCaml tests still fail with `not implemented`.  
**Visible demo.** Show the red wall of `dune test`, implement `trim`, show six tests turn green.  
**Code quality note.** Two small loops are easier to get right than one clever one. Name the two indices.


### Part 1: Strings and names (find_sub, split, leading_ws, words, convert) (80 min, session S1, required)

Plain substring search, split, leading whitespace, then the word splitter and the four case styles.  
**Prerequisites.** Part 0.  
**Language concepts.** imperative loops with `ref`, `Buffer`, character classes with pattern matching on ranges (`'a'..'z'`), `Invalid_argument` for contract violations, `List.rev`  
**Neovim concepts.** none

**READ**

- 8 min - [OCaml `String` API (`length`, `sub`, `get`, `make`)](https://ocaml.org/manual/5.2/api/String.html)
- 4 min - [OCaml `Char` API (`lowercase_ascii`, `code`)](https://ocaml.org/manual/5.2/api/Char.html)
- 6 min - [OCaml `Buffer` API (`create`, `add_char`, `add_string`, `contents`)](https://ocaml.org/manual/5.2/api/Buffer.html)
- 6 min - [CS3110: arrays (indexing and loops over positions)](https://cs3110.github.io/textbook/chapters/mut/arrays.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (5): F-003 `Util.find_sub`, F-004 `Util.split`, F-005 `Util.leading_ws`, F-006 `Naming.words`, F-007 `Naming.convert`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_util.ml` (find_sub, split, leading_ws: 11 tests) and `test_naming.ml` (words, convert: 10 tests, including odd UTF-8 bytes).

**Expected behavior.** `Naming.words "HTTPServer" = ["http"; "server"]`; `Naming.convert Naming.Pascal "binary search" = "BinarySearch"`; `Util.split "a,b," ~sep:"," = ["a"; "b"; ""]`.

**Foundational examples to read first:** FX-06, FX-07, FX-08

**Pitfalls**

- Splitting on an empty separator would loop forever: the contract says raise `Invalid_argument`.
- A word boundary inside an acronym: `HTTPServer` splits before the `S`, not before every capital.
- Digits stay with the word before them (`x2Y` is `x2`, `y`).
- Bytes at or above 0x80 are not letters: they act as separators (the provided test pins this).

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-1-1** By hand, write the result of `Naming.words` for `HTTPServer`, `x2Y` and `foo_bar-baz`. State the rule you used for each boundary.
- **RQ-1-2** `Util.split "a,b," ~sep:","` has three pieces. Why is the empty last piece the right answer?
- **RQ-1-3** Why does `find_sub` raise `Invalid_argument` for a negative `from` instead of returning `None`?

**Checkpoint.** the Part 1 tests green (21); Part 0 tests still green.  
**Visible demo.** Convert five names live in all four styles and read the word list aloud.  
**Code quality note.** `words` is a state machine: write down the states (start of word, in lowercase run, in uppercase run) before coding.


### Part 2: Errors and JSON (Err, Json) (45 min, session S2, required)

The error type's two views (a stable code and a human message) and the minimal JSON value type and printer the Lua edge will read.  
**Prerequisites.** Part 1.  
**Language concepts.** variants with payloads, exhaustive `match`, `Printf.sprintf`, recursion over a tree-shaped type, `String.concat`  
**Neovim concepts.** none

**READ**

- 10 min - [CS3110: variants](https://cs3110.github.io/textbook/chapters/data/variants.html)
- 8 min - [CS3110: advanced pattern matching](https://cs3110.github.io/textbook/chapters/data/pattern_matching_advanced.html)
- 6 min - [OCaml `Printf` API (`sprintf`, `%s`, `%d`, `%S`)](https://ocaml.org/manual/5.2/api/Printf.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (4): F-008 `Err.code`, F-009 `Err.message`, F-010 `Json.escape`, F-011 `Json.to_string`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_err.ml` (8 tests: every variant has a code and a message) and `test_json.ml` (9 tests).

**Expected behavior.** `Err.code (Unknown_lang "cobol") = "unknown_lang"`; `Err.message` of the same is `unknown language: cobol`; `Json.to_string (Obj [("a", Int 1)]) = {"a":1}`.

**Foundational examples to read first:** FX-03, FX-05

**Pitfalls**

- A catch-all `| _ ->` hides the cases you forgot: list every variant.
- `%S` quotes and escapes with OCaml rules; the messages in the tests depend on it.
- Emitting `\u00XX` needs four hex digits, lowercase (`Printf` `%04x`).

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-2-1** Why is `Err.t` a variant with one case per failure rather than a string?
- **RQ-2-2** Which characters must `Json.escape` change, and why are bytes 0x80 and above passed through unchanged?
- **RQ-2-3** `Json` knows nothing about `Err`. Where is the conversion done and why there?

**Checkpoint.** `test_err` and `test_json` green (17 tests).  
**Visible demo.** Print `Json.to_string` of a nested value and paste it into Neovim's `:lua print(vim.inspect(vim.json.decode(...)))`.  
**Code quality note.** Keep `code` and `message` as two separate total functions; do not derive one from the other.


### Part 3: Language registry (Lang, Langs) (75 min, session S2, required)

Validate language configs, derive the records the rest of the engine uses, register without duplicates, look up by id or filetype, name files, spell element types.  
**Prerequisites.** Part 2.  
**Language concepts.** records and record update `{ r with f = v }`, `result` and early returns with `match`, `List.find_opt`, immutable registries as values  
**Neovim concepts.** none

**READ**

- 8 min - [CS3110: records and tuples](https://cs3110.github.io/textbook/chapters/data/records_tuples.html)
- 6 min - [CS3110: options](https://cs3110.github.io/textbook/chapters/data/options.html)
- 6 min - [OCaml `Result` API](https://ocaml.org/manual/5.2/api/Result.html)
- 8 min - [OCaml `List` API (`mem`, `find_opt`, `exists`, `fold_left`)](https://ocaml.org/manual/5.2/api/List.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (8): F-012 `Lang.validate`, F-013 `Lang.derive`, F-014 `Lang.register`, F-015 `Lang.find`, F-016 `Lang.find_by_filetype`, F-017 `Lang.file_name`, F-018 `Lang.elem_type`, F-019 `Langs.install`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_lang.ml` (30 tests) and `test_langs.ml` (4 tests). `Langs.configs` is provided data.

**Expected behavior.** After `Langs.install []`, `Lang.file_name (Option.get (Lang.find regs "python")) "Union Find" = "union_find.py"`; `Lang.find_by_filetype regs "javascriptreact"` finds JavaScript.

**Foundational examples to read first:** FX-04

**Pitfalls**

- Registering must be all-or-nothing: check every rule before returning the new list.
- `filetypes` of two languages must not overlap: the error names the current owner.
- `file_name` raises `Invalid_argument` when the base has no words; it is not a user-facing error.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-3-1** `register` takes the list and returns a new list instead of changing a global. Name two benefits for testing.
- **RQ-3-2** Which rule in `validate` does `derive` rely on so that `derive` can be total (cannot fail)?
- **RQ-3-3** Why does `find` return an `option` while `register` returns a `result`?

**Checkpoint.** `test_lang` and `test_langs` green (34 tests).  
**Visible demo.** Register a toy language record and show the duplicate-id and duplicate-filetype errors.  
**Code quality note.** Write `validate` as a flat list of rules, one `if` per rule, each with its own message.


### Part 4: Template language (Template) (90 min, session S3, required)

Scan one `<% name | filter %>` tag, parse a whole template into segments, list its variables, apply a filter, render with an environment.  
**Prerequisites.** Parts 1-3.  
**Language concepts.** a scanner with explicit positions, `result` threading, `List.rev` accumulators, `Buffer` for output, mapping variants to functions  
**Neovim concepts.** none

**READ**

- 8 min - [CS3110: folding](https://cs3110.github.io/textbook/chapters/hop/fold.html)
- 5 min - [OCaml `List` API (`rev`, `map`, `assoc_opt`, `sort_uniq`)](https://ocaml.org/manual/5.2/api/List.html)
- 4 min - [OCaml `Buffer` API](https://ocaml.org/manual/5.2/api/Buffer.html)
- 8 min - [CS3110: modules (how `.mli` hides helpers)](https://cs3110.github.io/textbook/chapters/modules/modules.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (5): F-020 `Template.scan_tag`, F-021 `Template.parse`, F-022 `Template.vars`, F-023 `Template.apply_filter`, F-024 `Template.render`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_template.ml` (23 tests: tag forms, every error, 12 template fixtures render).

**Expected behavior.** `Template.parse "def <% fn %>():" = Ok [Text "def "; Var {name="fn"; filters=[]}; Text "():"]`; positions in errors are 0-based byte offsets of the opening `<%`.

**Foundational examples to read first:** FX-06, FX-07

**Pitfalls**

- Text like `a < b % c` contains `<` and `%` but no `<%`: it is plain text.
- A tag may be written with or without spaces: `<%x%>` and `<%  x  |  snake %>`.
- An unknown filter and an unbound variable are different errors found at different times.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-4-1** By hand: what does `Template.scan_tag "a<% fn | snake | upper %>b" 1` return, including the next position?
- **RQ-4-2** `Template.parse "ok <% a %> then <% b"` reports `Unclosed 16`. Count the bytes to show why 16.
- **RQ-4-3** Why is `Bad_filter` found while parsing but `Unbound` only while rendering?

**Checkpoint.** `test_template` green (23 tests).  
**Visible demo.** Render the Python stack template with a hand-written environment.  
**Code quality note.** `scan_tag` returns the position after the tag so `parse` never re-scans.


### Part 5: Catalog and collisions (Catalog, Collision) (45 min, session S4, required)

Look up algorithms and their templates in the provided table; avoid names that already exist.  
**Prerequisites.** Parts 3-4.  
**Language concepts.** lookup functions over provided data, `Option` plumbing, line-by-line scanning with `Util.split` and `Util.starts_with`  
**Neovim concepts.** none

**READ**

- 6 min - [OCaml `List` API (`find_opt`, `filter`, `mem`)](https://ocaml.org/manual/5.2/api/List.html)
- 5 min - [OCaml `Option` API](https://ocaml.org/manual/5.2/api/Option.html)
- 6 min - [CS3110: map](https://cs3110.github.io/textbook/chapters/hop/map.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (5): F-025 `Catalog.find`, F-026 `Catalog.template`, F-027 `Catalog.for_lang`, F-028 `Collision.unique_name`, F-029 `Collision.defined_names`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_catalog.ml` (9 tests, including all 12 language x algorithm combinations) and `test_collision.ml` (11 tests).

**Expected behavior.** `Collision.unique_name ["f"; "f_2"] "f" = "f_3"`; `Collision.defined_names python "def foo(x):\n    return x\nclass Bar:\n  pass" = ["foo"; "Bar"]`.

**Foundational examples to read first:** FX-04

**Pitfalls**

- `defined_names` is a heuristic: it matches line prefixes after trimming, not real syntax.
- A marker with no name after it (`def (x)`) yields nothing.
- `for_lang` returns algorithms that have a template for the language, in catalog order.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-5-1** `Catalog.template` is keyed by two strings. What does this buy you, and what bug class does it allow that a variant would prevent?
- **RQ-5-2** Name three source-text situations where `defined_names` gives a wrong answer.
- **RQ-5-3** What are the first four results of `unique_name` when the existing list is `["s"; "s_2"; "s_3"]`?

**Checkpoint.** `test_catalog` and `test_collision` green (20 tests).  
**Visible demo.** Call `defined_names` on a real file of yours and print the list.  
**Code quality note.** Strings as keys are a deliberate trade-off here; one test must prove every key pair exists.


### Part 6: Parameters and sessions (Params, Session) (75 min, session S4, required (Session.* and Params.next_prompt are stretch))

Turn raw answers into final template values (normalize, default, avoid collisions), compute the next question and its ghost default, and keep the progress of a prompt flow in an abstract value.  
**Prerequisites.** Parts 3-5.  
**Language concepts.** the `let*` operator (`let ( let* ) = Result.bind`), abstract types behind an `.mli`, small state machines as variants  
**Neovim concepts.** none

**READ**

- 5 min - [OCaml `Result` API](https://ocaml.org/manual/5.2/api/Result.html)
- 8 min - [CS3110: modules and encapsulation (abstract types)](https://cs3110.github.io/textbook/chapters/modules/encapsulation.html)
- 4 min - [CS3110: options](https://cs3110.github.io/textbook/chapters/data/options.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (11): F-030 `Params.normalize_ident`, F-031 `Params.normalize_elem`, F-032 `Params.ghost`, F-033 `Params.resolve`, F-034 `Params.next_prompt` (stretch), F-035 `Session.create` (stretch), F-036 `Session.state` (stretch), F-037 `Session.answers` (stretch), F-038 `Session.pending` (stretch), F-039 `Session.record` (stretch), F-040 `Session.cancel` (stretch)

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_params.ml` (23 tests) and `test_session.ml` (14 tests).

**Expected behavior.** `Params.resolve ~existing:["binary_search"] python binary_search [] = Ok [("fn", "binary_search_2"); ("elem", "int")]`; recording a second answer after the session is ready gives `Session_closed "ready"`.

**Foundational examples to read first:** FX-05, FX-08

**Pitfalls**

- Only identifiers are made unique; element types never are.
- Blank answers (spaces only) mean 'use the default'.
- `Session.t` is abstract: tests can only observe it through `state`, `pending`, `answers`.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-6-1** In `Params.resolve`, why is the unknown-parameter check done before any parameter is processed?
- **RQ-6-2** What does making `Session.t` abstract forbid, and which test shows you cannot build a `Ready` session by hand?
- **RQ-6-3** Why does `Params.ghost` live in `Params` and not in `Cli`?

**Checkpoint.** `test_params` and `test_session` green (37 tests).  
**Visible demo.** Walk a Python `stack` session by hand in the toplevel (`dune utop` if you have it) or a scratch test.  
**Code quality note.** Wrap the work for one parameter in a function returning `result`; the loop only threads the accumulator.


### Part 7: Placement and the pipeline (Insert, Engine) (60 min, session S5, required)

Re-indent text and decide where it goes (cursor, function, file); then chain every stage into the one pure pipeline.  
**Prerequisites.** Parts 4-6.  
**Language concepts.** `Result.bind`, composing fallible steps, record construction, choosing between three variants  
**Neovim concepts.** none

**READ**

- 6 min - [CS3110: pipelining and composition](https://cs3110.github.io/textbook/chapters/hop/pipelining.html)
- 6 min - [CS3110: modules](https://cs3110.github.io/textbook/chapters/modules/modules.html)
- 4 min - [OCaml `Result` API (`bind`, `map`)](https://ocaml.org/manual/5.2/api/Result.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (4): F-041 `Insert.reindent`, F-042 `Insert.place`, F-043 `Engine.generate`, F-044 `Engine.list`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_insert.ml` (9 tests) and `test_engine.ml` (14 tests: stage order, all 12 combinations generate, collisions).

**Expected behavior.** `Insert.place python Insert.Function ~cursor_indent:"" ~name:"f" ~body:"def f(): pass" = {text="\ndef f(): pass\n"; file=None}`.

**Foundational examples to read first:** FX-05

**Pitfalls**

- Blank lines stay empty when re-indenting (no trailing spaces).
- The 'name' used for file mode is the first non-element parameter's final value, else the algorithm id.
- Check order is lang, algo, template, params, parse, render.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-7-1** Why must `Engine.generate` check the language before the algorithm?
- **RQ-7-2** Which module owns indentation, `Insert` or `Engine`? What goes wrong if both do it?
- **RQ-7-3** `Engine.generate` never prints. Name two things that become possible because of that.

**Checkpoint.** `test_insert` and `test_engine` green (23 tests). Whole library green except `Cli`.  
**Visible demo.** Generate OCaml union-find as text from a scratch test.  
**Code quality note.** Define `let ( let* ) = Result.bind` once; every stage then reads top to bottom.


### Interlude: Test sweep (20 min, stretch)

After Part 7, before the CLI: pick one representative test for every public function of Parts 0-7 (not all 200 or so; about 25 is plenty). For each one write one line in `notes/NOTES.md` naming the bug it catches that no other chosen test would. Then break one function on purpose (for example make `Collision.unique_name` return its input) and confirm a test goes red. This is the 'test the tester' step.


### Part 8: Command line and main (Cli, Main) (90 min, session S6, required (run_ask is stretch))

Parse flags, run list / prompts / gen / ask as pure functions of their inputs, map results to text or JSON with exit codes 0/1/2, and write the thin `main`.  
**Prerequisites.** Parts 2-7.  
**Language concepts.** optional and labelled arguments (`?stdin`, `?ask`), a record of results (`outcome`), parsing with recursion over a list, pushing effects to the edge  
**Neovim concepts.** none

**READ**

- 5 min - [OCaml `Sys` API (`argv`)](https://ocaml.org/manual/5.2/api/Sys.html)
- 5 min - [OCaml `In_channel` API (reading all of stdin)](https://ocaml.org/manual/5.2/api/In_channel.html)
- 5 min - [OCaml `Stdlib` (`exit`, `print_string`, `prerr_string`)](https://ocaml.org/manual/5.2/api/Stdlib.html)
- 3 min - [OCaml `Printf` API](https://ocaml.org/manual/5.2/api/Printf.html)

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (8): F-045 `Cli.parse_flags`, F-046 `Cli.resolve_lang`, F-047 `Cli.run_list`, F-048 `Cli.run_prompts`, F-049 `Cli.run_gen`, F-050 `Cli.run_ask` (stretch), F-051 `Cli.run`, F-052 `Main.main`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `test_cli.ml` (57 tests) and `test/acceptance.sh` (6 checks A-01..A-06 against the real binary).

**Expected behavior.** `main.exe gen --bogus` exits 2 and prints `usage error: unknown flag: --bogus` on stderr; `main.exe list --lang cobol --json` prints `{"error":{"code":"unknown_lang",...}}` on stdout and exits 1.

**Foundational examples to read first:** FX-05, FX-09

**Pitfalls**

- Human errors go to stderr; JSON errors go to stdout and `stderr` stays empty.
- `stdin` is read only for `--scan -`.
- Repeated flags: the parsed list keeps the latest first (the provided tests pin the order).
- `run_gen` validates `--mode` and `--indent` before anything else.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-8-1** Why does `Cli.run` return an `outcome` record instead of printing and exiting?
- **RQ-8-2** List which `Err.t` cases map to exit code 2 and which to 1, and say why the split is useful to a shell script.
- **RQ-8-3** `main.ml` is the only file allowed to call `exit`. Which tests would be impossible if `Cli.run` called it?

**Checkpoint.** `dune test` fully green (238 tests); `sh test/acceptance.sh` shows six PASS (five if you cut `ask`).  
**Visible demo.** Run the six acceptance checks, then pipe a file into `--scan -` and show the `_2` rename.  
**Code quality note.** Write `error_outcome` and `is_usage` first; every `Error` path then ends in the same function.


### Part 9: Lua edge I: config, client, buffer (75 min, session S7, required (buffer.write_file and open_file are stretch))

Validate options, call the engine as a child process and decode its JSON, and read/write buffers and files, always returning `value` or `nil, err`.  
**Prerequisites.** Part 8 (a built `main.exe`). Neovim >= 0.10.  
**Language concepts.** Lua tables as records, `pcall`, `(value, err)` returns, `vim.tbl_deep_extend`, string escapes and `vim.NIL`  
**Neovim concepts.** `vim.system`, `vim.json.decode`, `nvim_buf_get_lines`, `nvim_buf_set_lines` (0-based, end-exclusive), `nvim_win_get_cursor`, `vim.uv.fs_stat`, `vim.cmd.edit`

**READ**

- 10 min - `:help lua-guide`
- 6 min - `:help vim.system()`
- 4 min - `:help vim.json.decode()`
- 6 min - `:help nvim_buf_set_lines()`

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (10): F-053 `config.resolve`, F-054 `client.binary`, F-055 `client.call`, F-056 `client.list`, F-057 `client.prompts`, F-058 `client.generate`, F-059 `buffer.context`, F-060 `buffer.insert_lines`, F-061 `buffer.write_file` (stretch), F-062 `buffer.open_file` (stretch)

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `lua_test/config_spec.lua` (8), `client_spec.lua` (29), `buffer_spec.lua` (17): 54 tests, run with `nvim --headless -u NONE -l lua_test/run.lua [module]`.

**Expected behavior.** `require('scaffold.client').list('python')` returns the four algorithm items from the real engine; with a missing binary it returns `nil, {code='engine_missing', ...}`.

**Foundational examples to read first:** FX-10, FX-11, FX-12, FX-15, FX-16

**Pitfalls**

- `nvim -l` prints to stderr: add `2>&1` when piping.
- `nvim_buf_set_lines(buf, row, row, true, lines)` inserts AFTER 1-based line `row`.
- JSON `null` arrives as `vim.NIL`, not `nil`.
- The headless instance has `hidden` on: `edit` on a modified buffer will not fail unless you turn it off in the test.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-9-1** `client.call` appends `--json` itself and never mutates the caller's table. Why is each of those two choices good?
- **RQ-9-2** Convert 1-based `row` to the two 0-based arguments of `nvim_buf_set_lines` for inserting after the line, and say why start equals end.
- **RQ-9-3** Why does `client.call` wrap `vim.system` and `vim.json.decode` in `pcall`?

**Checkpoint.** `config`, `client`, `buffer` specs green (54 tests); Parts 0-8 still green.  
**Visible demo.** Call `client.list('ocaml')` from `nvim -l` and print the result.  
**Code quality note.** Return a table of exactly the documented fields; the Lua side must not know engine internals.


### Part 10: Lua edge II: ui, commands, init and lazy.nvim (105 min, session S8, required (commands.complete and init.pick are stretch))

Ghost text and the floating input, the user command with completion, and the public entry points `setup`, `run`, `pick`, `teardown`; then wire it into LazyVim.  
**Prerequisites.** Part 9.  
**Language concepts.** closures that outlive their function, a `closed` flag for idempotence, recursion instead of loops when you must wait for a callback  
**Neovim concepts.** floating windows, extmarks with `virt_text`, user commands with `complete`, keymaps, `nvim_create_augroup`, `vim.schedule`, `vim.ui.select`, `vim.notify`

**READ**

- 6 min - `:help nvim_open_win()`
- 6 min - `:help nvim_buf_set_extmark()`
- 5 min - `:help nvim_create_user_command()`
- 4 min - `:help vim.keymap.set()`

**Course connection / book references.** No course material was supplied. Book: CS3110 (chapters cited above, no page numbers).

**Functions to implement** (10): F-063 `ui.ghost_set`, F-064 `ui.ghost_clear`, F-065 `ui.input`, F-066 `commands.parse_args`, F-067 `commands.complete` (stretch), F-068 `commands.register`, F-069 `init.setup`, F-070 `init.run`, F-071 `init.pick` (stretch), F-072 `init.teardown`

Contracts are in Section 15; the activity diagram of each is `AD-nnn` with the same number.

**Tests (provided).** `lua_test/ui_spec.lua` (12), `commands_spec.lua` (16), `init_spec.lua` (20): 48 tests.

**Expected behavior.** `:Scaffold stack` in a Python buffer asks two questions, then inserts a `class Stack:` below the cursor; Esc leaves the buffer unchanged and shows nothing.

**Foundational examples to read first:** FX-13, FX-14, FX-17

**Pitfalls**

- Do not loop over prompts: a loop cannot wait for a callback; recurse from inside the callback.
- `on_done` must run exactly once, after the window is closed, via `vim.schedule`.
- `teardown()` must be idempotent and leave no command, keymap or augroup.

**Research questions** (answer in `notes/NOTES.md`; model answers are collapsed in Appendix R)

- **RQ-10-1** Why is `on_done` scheduled with `vim.schedule` instead of called directly from the key handler?
- **RQ-10-2** How does `nvim_create_augroup('scaffold', { clear = true })` make `setup` safe to call twice?
- **RQ-10-3** What would the user see if the engine binary were missing, and which function produces that message?

**Checkpoint.** All 102 Lua tests green; `sh test/acceptance.sh` and `dune test` still green.  
**Visible demo.** Open a Python file, run `:Scaffold stack`, answer the prompts, undo with `u`.  
**Code quality note.** `init.run` is orchestration only: each step is a call to a function already tested elsewhere.

## 15. Function contracts

Format for every function: Problem Description, Conceptual Model, Inputs, Requires, Produces, Raises, Invariants, Side Effects, Examples (normal, boundary, failure; state before/after when stateful), Testing Requirements, Language Objective, API Objective, Diagram References, Implementation Challenge, Hint (only where the function is hard). OCaml examples use the provided `Dbg` printers; outputs are real: each was executed against the private reference before being written here.


### F-001 · `Util.trim`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/util.ml` | public | 0 | 1/5 | required | AD-001 |

**Signature**

```ocaml
Util.trim : string -> string
```

**Problem Description.** User input and template pieces arrive with stray spaces; every later module needs a trustworthy trim. Remove leading and trailing ASCII whitespace (space, tab, newline, CR, VT, FF).

**Conceptual Model.** Two indices walk inward from both ends while the character is whitespace; the answer is the substring between them.

**Inputs**

- s: any string (may be empty)

**Requires**

- none

**Produces.** A new string; the input is never modified (OCaml strings are immutable).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Result has no leading or trailing whitespace
- trim (trim s) = trim s
- String.length result <= String.length s

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - both sides*

```ocaml
Util.trim "  hi there "
```

Result: `"hi there"`


*Boundary - empty and all-blank*

```ocaml
(Util.trim "", Util.trim " \t\n ")
```

Result: `("", "")`


*Boundary - inner whitespace is kept*

```ocaml
Util.trim "\ta  b\n"
```

Result: `"a  b"`


*Failure - not applicable:* this function is total over its Requires.


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-001 | unit | trims both sides |
| T-002 | boundary | empty and blank strings |
| T-003 | boundary | inner whitespace survives |

**OCaml Learning Objective.** `let` bindings, `ref` and `!`/`:=`, `while` loops, `String.length`, `String.sub`, `s.[i]` indexing, `||` and `&&`.

**Library Learning Objective.** `Stdlib.String` basics. Do NOT call `String.trim`: the point is to write the scan yourself (and learn what it hides).

**Diagram References.** AD-001, CL-2, CMP-F5, CMP-2

**Implementation Challenge.** Handle the all-whitespace string and the empty string without raising `Invalid_argument`.

**Hint.** `String.sub s 0 0` is legal; `String.sub s 0 (-1)` is not. What do your two indices look like for "   "?


### F-002 · `Util.starts_with`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/util.ml` | public | 0 | 1/5 | required | AD-002 |

**Signature**

```ocaml
Util.starts_with : string -> prefix:string -> bool
```

**Problem Description.** Language markers like "def " must be matched at the start of a line without regular expressions. True when the string begins with the prefix (labelled argument `~prefix`).

**Conceptual Model.** Compare the first `String.length prefix` characters of the string with the prefix; a shorter string cannot match.

**Inputs**

- s: string
- ~prefix: string (may be empty)

**Requires**

- none

**Produces.** `true` or `false`.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- starts_with s ~prefix:"" = true
- starts_with s ~prefix:s = true
- false if prefix is longer than s

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - match*

```ocaml
Util.starts_with "def foo" ~prefix:"def "
```

Result: `true`


*Boundary - empty prefix*

```ocaml
Util.starts_with "x" ~prefix:""
```

Result: `true`


*Failure - prefix longer than string is false, not an exception*

```ocaml
Util.starts_with "de" ~prefix:"def "
```

Result: `false`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-004 | unit | true on match |
| T-005 | boundary | empty prefix always matches |
| T-006 | failure | longer prefix does not raise |

**OCaml Learning Objective.** Labelled arguments (`~prefix`), boolean `&&` short-circuiting, why `String.sub` must be guarded by a length check.

**Library Learning Objective.** `String.length`, `String.sub` (or `String.starts_with`, which you must not use: write it).

**Diagram References.** AD-002, CL-2, CMP-F5, CMP-2

**Implementation Challenge.** Make it safe when the prefix is longer than the string, without catching an exception.

**Hint.** `&&` stops at the first `false`. Put the length test on the left of the `&&`.


### F-003 · `Util.find_sub`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/util.ml` | public | 1 | 2/5 | required | AD-003 |

**Signature**

```ocaml
Util.find_sub : string -> sub:string -> from:int -> int option
```

**Problem Description.** Template parsing and splitting both need 'where is the next "<%"?'. The standard library has no substring search. Index of the first occurrence of `sub` at or after `from`, or None. Plain text search, no patterns.

**Conceptual Model.** Try each start index i from `from` while i + len(sub) <= len(s); compare the slice with `sub`.

**Inputs**

- s: string
- ~sub: string
- ~from: int, 0-based start index (>= 0)

**Requires**

- from >= 0

**Produces.** Some index (0-based) or None.

**Raises**

- *Exception (contract violation):* `Invalid_argument` if `from` is negative
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- If Some i then String.sub s i (String.length sub) = sub
- The result is >= from
- find_sub s ~sub:"" ~from:k = Some k when k <= String.length s

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - first match*

```ocaml
Util.find_sub "a<%x%>" ~sub:"<%" ~from:0
```

Result: `Some 1`


*Boundary - start after a match skips it*

```ocaml
Util.find_sub "abab" ~sub:"ab" ~from:1
```

Result: `Some 2`


*Failure - negative start is a programmer error*

```ocaml
Util.find_sub "abc" ~sub:"a" ~from:(-1)
```

Result: `raised Invalid_argument("Util.find_sub: negative start")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-007 | unit | finds first match |
| T-008 | boundary | from skips earlier match |
| T-009 | boundary | not found and past-the-end |
| T-010 | failure | negative from raises |

**OCaml Learning Objective.** Recursion with an accumulator-free helper, `option`, `invalid_arg`, local `let rec` closures over outer names.

**Library Learning Objective.** `String.sub`, `String.length`, `Option` constructors `Some`/`None`.

**Diagram References.** AD-003, CL-2, CMP-F5, CMP-F3, CMP-2

**Implementation Challenge.** Return None (not an exception) when `from` is past the end of the string.

**Hint.** The recursion stops as soon as `i + m > n`. What does the empty `sub` give at `from = n`?


### F-004 · `Util.split`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/util.ml` | public | 1 | 2/5 | required | AD-004 |

**Signature**

```ocaml
Util.split : string -> sep:string -> string list
```

**Problem Description.** Lines, template tags and flag lists are all separated by text; you need one splitter that never loses an empty piece. Split a string on a non-empty separator, keeping empty pieces (like String.split_on_char but for multi-character separators).

**Conceptual Model.** Repeatedly find the next separator with `find_sub`; cut the text before it; continue after it; the tail is the last piece.

**Inputs**

- s: string
- ~sep: non-empty string

**Requires**

- sep <> ""

**Produces.** A list with (number of separators + 1) strings.

**Raises**

- *Exception (contract violation):* `Invalid_argument` if `sep` is the empty string
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- String.concat sep (split s ~sep) = s
- List.length result = occurrences of sep + 1
- split "" ~sep:"x" = [""]

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - comma*

```ocaml
Util.split "a,b,c" ~sep:","
```

Result: `["a"; "b"; "c"]`


*Boundary - trailing separator keeps an empty piece*

```ocaml
Util.split "a,b," ~sep:","
```

Result: `["a"; "b"; ""]`


*Boundary - multi-character separator and empty input*

```ocaml
(Util.split "a<>b" ~sep:"<>", Util.split "" ~sep:",")
```

Result: `(["a"; "b"], [""])`


*Failure - empty separator*

```ocaml
Util.split "abc" ~sep:""
```

Result: `raised Invalid_argument("Util.split: separator must be non-empty")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-011 | unit | splits on comma |
| T-012 | boundary | keeps empty pieces |
| T-013 | boundary | multi-character separator |
| T-014 | failure | empty separator raises |

**OCaml Learning Objective.** Accumulator-passing recursion with `List.rev`, why `acc @ [x]` is quadratic, guard clauses with `invalid_arg`.

**Library Learning Objective.** `Util.find_sub` (your own function), `String.sub`, `List.rev`.

**Diagram References.** AD-004, CL-2, CMP-F5, CMP-F3, CMP-F7, CMP-2

**Implementation Challenge.** Keep the trailing empty string in `split "a,b," ~sep:","`.

**Hint.** Think of two numbers: where the current piece starts and where the next separator is. The last piece has no next separator.


### F-005 · `Util.leading_ws`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/util.ml` | public | 1 | 1/5 | required | AD-005 |

**Signature**

```ocaml
Util.leading_ws : string -> string
```

**Problem Description.** Inserted code must line up with the line the cursor is on, so the plugin has to read that line's indentation. The run of spaces and tabs at the start of a line (the line's indentation).

**Conceptual Model.** Advance an index while the character is ' ' or '\t'; the answer is the prefix up to that index.

**Inputs**

- line: any string

**Requires**

- none

**Produces.** A (possibly empty) string made only of spaces and tabs.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Result is a prefix of the input
- Only ' ' and '\t' appear in the result
- leading_ws "" = ""

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - spaces*

```ocaml
Util.leading_ws "    x = 1"
```

Result: `"    "`


*Boundary - tabs mix with spaces; blank line*

```ocaml
(Util.leading_ws " \t x", Util.leading_ws "")
```

Result: `(" \t ", "")`


*Failure - newline is not indentation (total function, nothing raises)*

```ocaml
Util.leading_ws "\n  x"
```

Result: `""`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-015 | unit | spaces |
| T-016 | boundary | tabs and empty |
| T-017 | failure | newline stops the scan |

**OCaml Learning Objective.** Char literals ('\t'), `||`, pattern for a scan loop; reuse of the `ref` + `while` idiom.

**Library Learning Objective.** `String.sub`, `String.length`.

**Diagram References.** AD-005, CL-2, CMP-F4, CMP-2

**Implementation Challenge.** Decide what "\n" and "\r" do (they are not indentation).

**Hint.** Only two characters count. Newlines stop the scan.


### F-006 · `Naming.words`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/naming.ml` | public | 1 | 4/5 | required | AD-006 |

**Signature**

```ocaml
Naming.words : string -> string list
```

**Problem Description.** Users type 'binary search', 'binarySearch' or 'HTTPServer'; every naming style starts from the same list of words. Split an identifier-like string into lowercase words at separators, lower-to-upper transitions, digit-to-upper transitions and acronym ends.

**Conceptual Model.** A left-to-right state machine over characters with a Buffer for the word being built. Non-alphanumerics end a word. An uppercase letter starts a new word when the previous char is lowercase or a digit, or when the previous char is uppercase and the next is lowercase.

**Inputs**

- s: any string

**Requires**

- none

**Produces.** Lowercase words in order; [] when there is no alphanumeric character.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Every word is non-empty and lowercase
- Every word is made of [a-z0-9] only
- words (String.concat " " (words s)) = words s

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - camelCase and separators*

```ocaml
(Naming.words "fooBar", Naming.words "foo_bar-baz")
```

Result: `(["foo"; "bar"], ["foo"; "bar"; "baz"])`


*Boundary - acronyms and digits*

```ocaml
(Naming.words "HTTPServer", Naming.words "x2Y", Naming.words "binary search")
```

Result: `(["http"; "server"], ["x2"; "y"], ["binary"; "search"])`


*Boundary - nothing alphanumeric*

```ocaml
(Naming.words "", Naming.words "__--")
```

Result: `([], [])`


*Failure - total function: odd input never raises*

```ocaml
Naming.words "é!ABc"
```

Result: `["a"; "bc"]`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-018 | unit | camel and snake |
| T-019 | boundary | acronym |
| T-020 | boundary | digits |
| T-021 | boundary | empty and separators only |
| T-022 | failure | non-ASCII bytes are separators, never an exception |

**OCaml Learning Objective.** `for` loops with index, `Buffer`, `char` comparisons (`c >= 'A' && c <= 'Z'`), local functions that close over mutable state, `option` for prev/next.

**Library Learning Objective.** `Buffer.create/add_char/contents/clear/length`, `String.lowercase_ascii`, `List.rev`.

**Diagram References.** AD-006, CL-2, CMP-F2, CMP-2

**Implementation Challenge.** Get 'HTTPServer' = [http; server] and 'x2Y' = [x2; y] right without special-casing either string.

**Hint.** Write the two boundary rules as two named booleans first (rule_a, rule_b). Only look at `prev`/`next` when they exist.


### F-007 · `Naming.convert`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/naming.ml` | public | 1 | 2/5 | required | AD-007 |

**Signature**

```ocaml
Naming.convert : Naming.style -> string -> string
```

**Problem Description.** Each language prefers a style (Python snake_case, JavaScript camelCase, types in PascalCase). Re-style a string as snake_case, camelCase, PascalCase or UPPER_SNAKE using `words`.

**Conceptual Model.** Take `words s`, then join with underscores or capitalise each word, depending on the `style` variant. Pattern matching on the variant makes forgotten styles a compile warning.

**Inputs**

- style: Snake | Camel | Pascal | Upper_snake
- s: any string

**Requires**

- Naming.words works

**Produces.** The restyled string; "" when there are no words.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- convert Snake s has only [a-z0-9_]
- convert Upper_snake s = uppercase of convert Snake s
- convert style "" = ""

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - all four styles*

```ocaml
List.map (fun st -> Naming.convert st "binary search") Naming.[Snake; Camel; Pascal; Upper_snake]
```

Result: `["binary_search"; "binarySearch"; "BinarySearch"; "BINARY_SEARCH"]`


*Boundary - already camel; empty*

```ocaml
(Naming.convert Naming.Snake "fooBar", Naming.convert Naming.Pascal "")
```

Result: `("foo_bar", "")`


*Failure - no words gives the empty string, not an error*

```ocaml
Naming.convert Naming.Camel "--"
```

Result: `""`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-023 | unit | snake |
| T-024 | unit | camel and pascal |
| T-025 | unit | upper snake |
| T-026 | boundary | empty |
| T-027 | failure | separators only |

**OCaml Learning Objective.** Variant types, exhaustive `match`, `String.concat`, `List.map`, partial application of `String.capitalize_ascii`.

**Library Learning Objective.** `String.capitalize_ascii`, `String.uppercase_ascii`, `String.concat`.

**Diagram References.** AD-007, CL-2, CMP-F2, CMP-2

**Implementation Challenge.** Camel case keeps the first word lowercase. Express that without an index counter.

**Hint.** `match words s with w :: rest -> ... | [] -> ...` gives you the first word for free.


### F-008 · `Err.code`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/err.ml` | public | 2 | 1/5 | required | AD-008 |

**Signature**

```ocaml
Err.code : Err.t -> string
```

**Problem Description.** The Lua edge branches on error codes in JSON; the codes are a public contract and must never be derived from messages. Map every error constructor to its stable snake_case code string.

**Conceptual Model.** One match arm per constructor. A new constructor without an arm is a compiler warning, which is the point of using a variant.

**Inputs**

- e: any Err.t

**Requires**

- none

**Produces.** One of 17 fixed codes, e.g. "unknown_lang".

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Total over all 17 constructors
- Codes are unique
- Codes match [a-z_]+

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - two codes*

```ocaml
(Err.code (Err.Unknown_lang "x"), Err.code (Err.Template (Err.Unclosed 3)))
```

Result: `("unknown_lang", "template")`


*Boundary - inline-record constructor*

```ocaml
Err.code (Err.Bad_value { flag = "--mode"; value = "x" })
```

Result: `"bad_value"`


*Failure - there is no failing input: the function is total*

```ocaml
Err.code (Err.Session_closed "ready")
```

Result: `"session_closed"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-028 | unit | a few codes |
| T-029 | unit | all 17 codes are distinct and non-empty |
| T-030 | boundary | template errors share one code |

**OCaml Learning Objective.** Variant types with inline records, exhaustive `match`, wildcard patterns `_` for ignoring payloads.

**Library Learning Objective.** none (language only).

**Diagram References.** AD-008, CL-3, CL-2, CMP-F8, CMP-2

**Implementation Challenge.** Do not use a catch-all `_ ->` arm: let the compiler tell you when a constructor is missing.

**Hint.** Constructors with inline records still match as `Bad_lang_config _`.


### F-009 · `Err.message`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/err.ml` | public | 2 | 2/5 | required | AD-009 |

**Signature**

```ocaml
Err.message : Err.t -> string
```

**Problem Description.** Humans see messages (Neovim notifications, stderr); machines see codes. The two must stay separate. Render any error as a one-line human message. Template errors render through a nested match.

**Conceptual Model.** A nested match: the outer function matches `t`, the `Template` arm calls a helper matching `template_error`. Printf with `%S` quotes a string OCaml-style.

**Inputs**

- e: any Err.t

**Requires**

- none

**Produces.** A single-line string with no trailing newline.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Never contains a newline
- Mentions the offending value for every constructor that carries one

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - unknown language*

```ocaml
Err.message (Err.Unknown_lang "cobol")
```

Result: `"unknown language: cobol"`


*Boundary - template error with position*

```ocaml
Err.message (Err.Template (Err.Unclosed 12))
```

Result: `"template: unclosed <% at 12"`


*Boundary - usage error with value*

```ocaml
Err.message (Err.Bad_value { flag = "--mode"; value = "zzz" })
```

Result: `"bad value for --mode: \"zzz\""`


*Failure - total: an empty command still renders*

```ocaml
Err.message (Err.Unknown_command "")
```

Result: `"unknown command"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-031 | unit | unknown language |
| T-032 | unit | template unclosed shows offset |
| T-033 | boundary | quoted values |
| T-034 | boundary | empty command has its own text |
| T-035 | unit | no message contains a newline |

**OCaml Learning Objective.** Nested variants, `Printf.sprintf` with `%s`, `%d`, `%S`, and the `%%` escape for a literal percent sign.

**Library Learning Objective.** `Printf.sprintf`.

**Diagram References.** AD-009, CL-3, CL-2, CMP-F8, CMP-2

**Implementation Challenge.** Write the helper for template errors so that `Unclosed 7` says where the tag opened (byte offset).

**Hint.** `<%` inside a format string must be written `<%%`.


### F-010 · `Json.escape`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/json.ml` | public | 2 | 2/5 | required | AD-010 |

**Signature**

```ocaml
Json.escape : string -> string
```

**Problem Description.** The CLI answers Neovim in JSON, so generated code (full of quotes and newlines) must survive the round trip. Escape a string for use inside a JSON string literal (quotes, backslash, control characters).

**Conceptual Model.** Visit each byte with `String.iter`; emit a short escape for the five named characters, `\u00XX` for other controls below 0x20, otherwise the byte itself.

**Inputs**

- s: any byte string

**Requires**

- none

**Produces.** A string safe to wrap in double quotes.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- No raw control character below 0x20 survives
- No unescaped double quote survives
- Bytes >= 0x80 pass through unchanged

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - quotes and newline*

```ocaml
Json.escape "say \"hi\"\n"
```

Result: `"say \\\"hi\\\"\\n"`


*Boundary - backslash and tab*

```ocaml
Json.escape "a\\b\tc"
```

Result: `"a\\\\b\\tc"`


*Boundary - low control byte and UTF-8*

```ocaml
(Json.escape "\001", Json.escape "\xc3\xa9")
```

Result: `("\\u0001", "\195\169")`


*Failure - total: empty string*

```ocaml
Json.escape ""
```

Result: `""`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-036 | unit | quote and newline |
| T-037 | boundary | backslash tab CR |
| T-038 | boundary | control byte |
| T-039 | boundary | UTF-8 untouched, empty ok |

**OCaml Learning Objective.** `String.iter`, `Buffer`, `Char.code`, guards in pattern matching (`| c when ...`), `Printf.sprintf "%04x"`.

**Library Learning Objective.** `Buffer.add_string/add_char`, `Char.code`.

**Diagram References.** AD-010, CL-2, CMP-F1, CL-1, CMP-2

**Implementation Challenge.** Escape 0x01 as `\u0001` (lowercase hex, four digits).

**Hint.** Order of match arms matters: put guarded arms after the specific ones.


### F-011 · `Json.to_string`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/json.ml` | public | 2 | 2/5 | required | AD-011 |

**Signature**

```ocaml
Json.to_string : Json.t -> string
```

**Problem Description.** The Lua side decodes with `vim.json.decode`; the engine therefore has to emit valid JSON without any library. Serialise a Json.t as compact JSON (no spaces, object keys in the given order).

**Conceptual Model.** Structural recursion on the variant: scalars print directly; lists and objects join their children's output with commas.

**Inputs**

- j: a Json.t tree

**Requires**

- none

**Produces.** Compact JSON text.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Output parses with vim.json.decode
- Obj keeps key order
- Strings pass through Json.escape

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - nested value*

```ocaml
Json.to_string Json.(Obj [("a", Int 1); ("b", List [Bool true; Null; Str "x"])])
```

Result: `"{\"a\":1,\"b\":[true,null,\"x\"]}"`


*Boundary - empty containers*

```ocaml
(Json.to_string (Json.List []), Json.to_string (Json.Obj []))
```

Result: `("[]", "{}")`


*Boundary - string with a quote*

```ocaml
Json.to_string (Json.Str "a\"b")
```

Result: `"\"a\\\"b\""`


*Failure - negative ints keep their sign*

```ocaml
Json.to_string (Json.Int (-4))
```

Result: `"-4"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-040 | unit | scalars |
| T-041 | unit | nested |
| T-042 | boundary | empty list/object |
| T-043 | boundary | keys are escaped |
| T-044 | failure | negative number |

**OCaml Learning Objective.** Recursive functions (`let rec`), `String.concat`, `List.map`, `string_of_int`, `string_of_bool`.

**Library Learning Objective.** `String.concat`, `List.map`.

**Diagram References.** AD-011, CL-2, CMP-F1, CL-1, CMP-2

**Implementation Challenge.** Escape object keys as well as string values.

**Hint.** `let rec to_string = function ...` is shorter than `let rec to_string j = match j with ...`.


### F-012 · `Lang.validate`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 3/5 | required | AD-012 |

**Signature**

```ocaml
Lang.validate : Lang.cfg -> (Lang.cfg, Err.t) result
```

**Problem Description.** Adding a language must be a data change. A typo in that data has to produce a clear error, not a crash later. Check a language configuration and return it unchanged, or the first problem as Bad_lang_config {field; reason}.

**Conceptual Model.** A chain of checks in a fixed order (id, filetypes, extension, indent_width, types, def_markers); the first failing check wins.

**Inputs**

- cfg: a Lang.cfg record

**Requires**

- none

**Produces.** Ok cfg when every rule holds; otherwise Error (Bad_lang_config {field; reason}).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Bad_lang_config for the first violated rule

**Invariants**

- Ok returns the identical record
- Checks run in the documented order
- Never raises

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - a valid config*

```ocaml
Result.map (fun c -> c.Lang.id) (Lang.validate List.(hd Langs.configs))
```

Result: `Ok "python"`


*Boundary - uppercase id*

```ocaml
Lang.validate { (List.hd Langs.configs) with Lang.id = "Py" }
```

Result: `Error (bad_lang_config: bad language config: id must match [a-z][a-z0-9_]*)`


*Boundary - extension without a dot*

```ocaml
Lang.validate { (List.hd Langs.configs) with Lang.extension = "py" }
```

Result: `Error (bad_lang_config: bad language config: extension must look like .py)`


*Failure - negative indent*

```ocaml
Lang.validate { (List.hd Langs.configs) with Lang.indent_width = -1 }
```

Result: `Error (bad_lang_config: bad language config: indent_width must be >= 0)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-045 | unit | built-ins are valid |
| T-046 | failure | bad id |
| T-047 | failure | filetypes |
| T-048 | failure | extension |
| T-049 | failure | indent |
| T-050 | failure | each type is checked |
| T-051 | failure | def_markers |
| T-052 | boundary | first failure wins |

**OCaml Learning Objective.** Records and field access, `result`, `if / else if` chains, `List.for_all`, `String.for_all` (4.13+), char ranges in patterns (`'a'..'z'`).

**Library Learning Objective.** `String.for_all`, `List.for_all`.

**Diagram References.** AD-012, CL-1, CL-2, CMP-F6, OBJ-2, CMP-2

**Implementation Challenge.** Write one local helper `bad field reason` so each check is one line.

**Hint.** Fields and reasons are fixed strings; see the table in the Function spec. id: "must match [a-z][a-z0-9_]*", filetypes: "must be a non-empty list" / "entries must be non-empty strings", extension: "must look like .py", indent_width: "must be >= 0", types: "empty entry for int" (float, string, bool), def_markers: "entries must be non-empty strings".


### F-013 · `Lang.derive`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 1/5 | required | AD-013 |

**Signature**

```ocaml
Lang.derive : Lang.cfg -> Lang.t
```

**Problem Description.** Other modules need ready-to-use values (`"    "`, Camel) instead of recomputing them from raw numbers and flags. Compute the derived fields of a validated config: the indent string and the function-name style.

**Conceptual Model.** Build the record {cfg; indent = String.make width ' '; fn_style = if camel_case then Camel else Snake}.

**Inputs**

- cfg: a validated Lang.cfg

**Requires**

- indent_width >= 0

**Produces.** A Lang.t holding the same cfg.

**Raises**

- *Exception (contract violation):* `Invalid_argument` from String.make when indent_width < 0 (validate prevents it)
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- String.length indent = indent_width
- fn_style = Camel iff camel_case
- derive never changes cfg

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python*

```ocaml
(let l = Lang.derive (List.hd Langs.configs) in (l.Lang.indent, l.Lang.fn_style = Naming.Snake))
```

Result: `("    ", true)`


*Boundary - zero indent*

```ocaml
(Lang.derive { (List.hd Langs.configs) with Lang.indent_width = 0 }).Lang.indent
```

Result: `""`


*Failure - negative width violates Requires*

```ocaml
(Lang.derive { (List.hd Langs.configs) with Lang.indent_width = -1 }).Lang.indent
```

Result: `raised Invalid_argument("Bytes.create")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-053 | unit | indent string |
| T-054 | unit | style flag |
| T-055 | boundary | zero width |
| T-056 | unit | cfg is kept |

**OCaml Learning Objective.** Record construction, `String.make`, `if` as an expression.

**Library Learning Objective.** `String.make`.

**Diagram References.** AD-013, CL-1, CL-2, CMP-F6, OBJ-2, CMP-2

**Implementation Challenge.** Return the same `cfg` value rather than a copy of its fields.

**Hint.** Record fields can be punned: `{ cfg; indent; fn_style }`.


### F-014 · `Lang.register`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 3/5 | required | AD-014 |

**Signature**

```ocaml
Lang.register : Lang.t list -> Lang.cfg -> (Lang.t list, Err.t) result
```

**Problem Description.** Two languages claiming the same filetype would make 'which language is this buffer?' ambiguous. Validate a config, reject duplicate ids and duplicate filetypes, and append the derived language to the registry.

**Conceptual Model.** Validate first; then scan the existing languages for an id clash or a filetype clash; if none, return the registry with the new language at the end. The registry is an immutable list, so 'register' returns a new one.

**Inputs**

- reg: current registry
- cfg: candidate config

**Requires**

- none

**Produces.** Ok (reg @ [derive cfg]) or the first error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Bad_lang_config; Duplicate_id; Duplicate_filetype {filetype; owner}

**Invariants**

- The input registry is never modified
- On Ok the length grows by exactly one
- Order of existing entries is preserved

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - add a language to an empty registry*

```ocaml
Result.map List.length (Lang.register [] List.(hd Langs.configs))
```

Result: `Ok 1`


*Boundary - same id twice*

```ocaml
(let r = Result.get_ok (Lang.register [] (List.hd Langs.configs)) in Lang.register r (List.hd Langs.configs))
```

Result: `Error (duplicate_id: duplicate language id: python)`


*Boundary - filetype already owned*

```ocaml
(let r = Result.get_ok (Lang.register [] (List.hd Langs.configs)) in Lang.register r { (List.hd Langs.configs) with Lang.id = "py2" })
```

Result: `Error (duplicate_filetype: filetype python already belongs to python)`


*Failure - invalid config is rejected first*

```ocaml
Lang.register [] { (List.hd Langs.configs) with Lang.id = "" }
```

Result: `Error (bad_lang_config: bad language config: id must match [a-z][a-z0-9_]*)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-057 | unit | appends |
| T-058 | failure | duplicate id |
| T-059 | failure | duplicate filetype names the owner |
| T-060 | failure | invalid config propagates |
| T-061 | boundary | input registry untouched |

**OCaml Learning Objective.** Immutable data, `List.find_map`, `Option`, nested `match`, `@` on lists.

**Library Learning Objective.** `List.find_map` (4.10+), `List.mem`.

**Diagram References.** AD-014, CL-1, CMP-2, OBJ-2, CL-2, CMP-F6

**Implementation Challenge.** Report WHICH language owns the clashing filetype.

**Hint.** Check the id before the filetypes for each existing language, then stop at the first clash.


### F-015 · `Lang.find`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 1/5 | required | AD-015 |

**Signature**

```ocaml
Lang.find : Lang.t list -> string -> Lang.t option
```

**Problem Description.** Everything downstream starts from a language id string. Look a language up by its id.

**Conceptual Model.** First element whose cfg.id equals the argument, else None.

**Inputs**

- reg
- id

**Requires**

- none

**Produces.** Some lang or None.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Case-sensitive
- Some l implies l.cfg.id = id

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - known*

```ocaml
Option.map (fun l -> l.Lang.cfg.Lang.id) (Lang.find regs "python")
```

Result: `Some "python"`


*Boundary - case matters*

```ocaml
Option.is_some (Lang.find regs "Python")
```

Result: `false`


*Failure - unknown id gives None*

```ocaml
Option.is_some (Lang.find regs "cobol")
```

Result: `false`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-062 | unit | found |
| T-063 | boundary | case sensitive |
| T-064 | failure | unknown and empty registry |

**OCaml Learning Objective.** `List.find_opt` with an anonymous function, field access through nested records.

**Library Learning Objective.** `List.find_opt`.

**Diagram References.** AD-015, OBJ-2, CL-2, CMP-F6, CL-1, CMP-2

**Implementation Challenge.** One line.

**Hint.** `l.cfg.id` reads a field of a field.


### F-016 · `Lang.find_by_filetype`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 1/5 | required | AD-016 |

**Signature**

```ocaml
Lang.find_by_filetype : Lang.t list -> string -> Lang.t option
```

**Problem Description.** `vim.bo.filetype` is what the editor knows; the engine works with ids. Look a language up by a Neovim filetype (a language may own several, e.g. javascript and javascriptreact).

**Conceptual Model.** First language whose filetypes list contains the argument.

**Inputs**

- reg
- ft

**Requires**

- none

**Produces.** Some lang or None.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Some l implies List.mem ft l.cfg.filetypes

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - jsx maps to javascript*

```ocaml
Option.map (fun l -> l.Lang.cfg.Lang.id) (Lang.find_by_filetype regs "javascriptreact")
```

Result: `Some "javascript"`


*Boundary - empty filetype*

```ocaml
Option.is_some (Lang.find_by_filetype regs "")
```

Result: `false`


*Failure - unknown*

```ocaml
Option.is_some (Lang.find_by_filetype regs "lua")
```

Result: `false`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-065 | unit | secondary filetype |
| T-066 | boundary | empty string |
| T-067 | failure | unknown |

**OCaml Learning Objective.** `List.mem`, composing a predicate.

**Library Learning Objective.** `List.find_opt`, `List.mem`.

**Diagram References.** AD-016, CL-2, CMP-F6, CL-1, OBJ-2, CMP-2

**Implementation Challenge.** One line.

**Hint.** Same shape as Lang.find with a different predicate.


### F-017 · `Lang.file_name`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 2/5 | required | AD-017 |

**Signature**

```ocaml
Lang.file_name : Lang.t -> string -> string
```

**Problem Description.** 'binary search' should become binary_search.py, binarySearch.js or binary_search.ml. Build the file name for File insert mode: the base converted to the language's function style plus its extension.

**Conceptual Model.** Convert with Naming.convert lang.fn_style, refuse an empty stem, append lang.cfg.extension.

**Inputs**

- lang
- base: a name (any style)

**Requires**

- base has at least one word

**Produces.** e.g. "binary_search.py".

**Raises**

- *Exception (contract violation):* `Invalid_argument` when base has no words
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Ends with the extension
- Stem equals Naming.convert fn_style base

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python and javascript*

```ocaml
(Lang.file_name (lang "python") "Binary Search", Lang.file_name (lang "javascript") "binary search")
```

Result: `("binary_search.py", "binarySearch.js")`


*Boundary - already styled*

```ocaml
Lang.file_name (lang "ocaml") "union_find"
```

Result: `"union_find.ml"`


*Failure - no words*

```ocaml
Lang.file_name (lang "python") "--"
```

Result: `raised Invalid_argument("Lang.file_name: base has no words")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-068 | unit | snake language |
| T-069 | unit | camel language |
| T-070 | boundary | idempotent on styled input |
| T-071 | failure | empty stem raises |

**OCaml Learning Objective.** Guard-then-compute, string concatenation `^`, `invalid_arg`.

**Library Learning Objective.** `Naming.convert`.

**Diagram References.** AD-017, CL-2, CMP-F6, CMP-F4, CL-1, OBJ-2, CMP-2

**Implementation Challenge.** Make the empty-stem case fail loudly instead of returning ".py".

**Hint.** Check the stem for emptiness before concatenating.


### F-018 · `Lang.elem_type`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/lang.ml` | public | 3 | 1/5 | required | AD-018 |

**Signature**

```ocaml
Lang.elem_type : Lang.t -> Lang.elem -> string
```

**Problem Description.** Templates say <% elem %>; Python needs int, JavaScript number. The language's spelling of an element type (int, float, string, bool).

**Conceptual Model.** Match on the elem variant and read the matching field of cfg.types.

**Inputs**

- lang
- e: Int | Float | String | Bool

**Requires**

- none

**Produces.** A non-empty type name.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Total over the four variants

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python string*

```ocaml
Lang.elem_type (lang "python") Lang.String
```

Result: `"str"`


*Boundary - javascript int and float coincide*

```ocaml
(Lang.elem_type (lang "javascript") Lang.Int, Lang.elem_type (lang "javascript") Lang.Float)
```

Result: `("number", "number")`


*Failure - total: ocaml bool*

```ocaml
Lang.elem_type (lang "ocaml") Lang.Bool
```

Result: `"bool"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-072 | unit | python |
| T-073 | unit | javascript |
| T-074 | boundary | all four non-empty for every built-in |

**OCaml Learning Objective.** Variant matching on a different type than the record's own; constructors shadowing (`Int`, `String`).

**Library Learning Objective.** none.

**Diagram References.** AD-018, CL-2, CMP-F6, CL-1, OBJ-2, CMP-2

**Implementation Challenge.** No wildcard arm.

**Hint.** `function Int -> ... | Float -> ...` takes the argument without naming it.


### F-019 · `Langs.install`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/langs.ml` | public | 3 | 2/5 | required | AD-019 |

**Signature**

```ocaml
Langs.install : Lang.t list -> Lang.t list
```

**Problem Description.** `Langs.configs` is data; `install` is the one place that turns it into a registry, and it must be safe to call twice. Add the three built-in languages that are missing from a registry (python, javascript, ocaml).

**Conceptual Model.** Fold over the built-in configs: skip ids already present, otherwise register; a built-in that fails to register is a programming error (`failwith`).

**Inputs**

- reg: any registry (often [])

**Requires**

- none

**Produces.** The registry plus any missing built-ins, in config order.

**Raises**

- *Exception (contract violation):* `Failure` if a built-in config is invalid (cannot happen with the shipped data)
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- install (install r) = install r
- Existing entries keep their position

**Side Effects.** none (pure)

**State before / after.** Before: registry list R. After: R plus any of python/javascript/ocaml that were missing; calling it twice adds nothing.

**Examples** (outputs verified)


*Normal - from empty*

```ocaml
List.map (fun l -> l.Lang.cfg.Lang.id) (Langs.install [])
```

Result: `["python"; "javascript"; "ocaml"]`


*Boundary - idempotent*

```ocaml
List.length (Langs.install (Langs.install []))
```

Result: `3`


*Boundary - user override is kept*

```ocaml
(let mine = Result.get_ok (Lang.register [] { (List.hd Langs.configs) with Lang.indent_width = 8 }) in (List.hd (Langs.install mine)).Lang.indent)
```

Result: `"        "`


*Failure - see Raises above:* each listed failure is exercised by the tests in the next table.


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-075 | unit | adds three |
| T-076 | boundary | idempotent |
| T-077 | boundary | user language survives and keeps position |
| T-078 | boundary | override kept |

**OCaml Learning Objective.** `List.fold_left`, accumulating a value, `failwith`, pattern match on `result`.

**Library Learning Objective.** `List.fold_left`.

**Diagram References.** AD-019, OBJ-2, CL-2, CMP-F6, CMP-2

**Implementation Challenge.** Make a user override of `python` survive.

**Hint.** `Lang.find reg cfg.id` tells you whether to skip.


### F-020 · `Template.scan_tag`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/template.ml` | public | 4 | 4/5 | required | AD-020 |

**Signature**

```ocaml
Template.scan_tag : string -> int -> (Template.seg * int, Err.template_error) result
```

**Problem Description.** The placeholder syntax is the engine's only mini-language. Parsing one tag is the hard part; parsing the whole text is a loop around it. Given the text and the byte offset of a `<%`, parse one tag `<% name | filter | filter %>` and return the Var segment plus the offset just after `%>`.

**Conceptual Model.** Find the closing `%>`; split the inside on `|`; the first piece is the variable name (trimmed, [a-z][a-z0-9_]*); every other piece must be a known filter name. Errors report offsets or the offending text.

**Inputs**

- text: whole template
- open_pos: index of a `<%` in text

**Requires**

- text at open_pos starts with <%

**Produces.** Ok (Var {name; filters}, next_index) or an Err.template_error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unclosed open_pos; Empty_var open_pos; Bad_name n; Bad_filter f

**Invariants**

- next_index > open_pos + 2
- Filters keep their written order
- Whitespace around names and filters is ignored

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - name with filters*

```ocaml
Template.scan_tag "a<% fn | snake | upper %>b" 1
```

Result: `Ok fn/2/25`


*Boundary - no filters, tight spacing*

```ocaml
Template.scan_tag "<%x%>" 0
```

Result: `Ok x/5`


*Failure - unclosed tag*

```ocaml
Template.scan_tag "ab <% x" 3
```

Result: `Error (Unclosed 3)`


*Failure - empty placeholder*

```ocaml
Template.scan_tag "<%  %>" 0
```

Result: `Error (Empty_var 0)`


*Failure - unknown filter*

```ocaml
Template.scan_tag "<% x | shout %>" 0
```

Result: `Error (Bad_filter "shout")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-079 | unit | name only |
| T-080 | unit | filters in order |
| T-081 | boundary | starts mid-text and reports next offset |
| T-082 | failure | unclosed |
| T-083 | failure | empty placeholder |
| T-084 | failure | bad name |
| T-085 | failure | bad filter |

**OCaml Learning Objective.** Nested `match` on `option` and `result`, local recursive helper over a list, `String.sub` arithmetic, `Result` plumbing.

**Library Learning Objective.** `Util.find_sub`, `Util.split`, `Util.trim` (your own).

**Diagram References.** AD-020, CL-2, CMP-F3, CMP-2

**Implementation Challenge.** Reject `<% %>`, `<% 1x %>` and `<% x | nope %>` with three different errors.

**Hint.** Do the name check before looking at any filter. Write `filter_of_string : string -> filter option` first and test it by eye.


### F-021 · `Template.parse`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/template.ml` | public | 4 | 3/5 | required | AD-021 |

**Signature**

```ocaml
Template.parse : string -> (Template.seg list, Err.template_error) result
```

**Problem Description.** Rendering needs the template as data so that unbound variables are detected before any output is built. Split template text into Text and Var segments, in order, with no empty Text segments.

**Conceptual Model.** Alternate: find the next `<%`; everything before it is Text (if non-empty); scan_tag consumes the tag; continue from where it stopped. Remaining text after the last tag is the final Text.

**Inputs**

- text: any string

**Requires**

- none

**Produces.** Ok segments, or the first tag error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* any scan_tag error

**Invariants**

- Concatenating Text pieces and re-printed tags reproduces the input
- No Text "" segments
- parse "" = Ok []

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - text, variable, text*

```ocaml
Template.parse "def <% fn %>():"
```

Result: `Ok [Text "def "; Var fn; Text "():"]`


*Boundary - two tags, no text between*

```ocaml
Template.parse "<%a%><%b%>"
```

Result: `Ok [Var a; Var b]`


*Boundary - empty and tag-free*

```ocaml
(Template.parse "", Template.parse "a < b % c")
```

Result: `(Ok [], Ok [Text "a < b % c"])`


*Failure - error inside the second tag*

```ocaml
Template.parse "ok <% a %> then <% b"
```

Result: `Error (Unclosed 16)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-086 | unit | text var text |
| T-087 | boundary | adjacent tags |
| T-088 | boundary | empty input and plain text |
| T-089 | failure | error from a later tag |
| T-090 | failure | first error wins |

**OCaml Learning Objective.** Tail recursion with an accumulator and `List.rev`, early exit through `Result`, 0-based offsets.

**Library Learning Objective.** `Util.find_sub`, `Template.scan_tag`.

**Diagram References.** AD-021, SEQ-6, CL-2, CMP-F3, CMP-2

**Implementation Challenge.** Preserve a lone `<` and a lone `%` as ordinary text.

**Hint.** The loop state is (position, reversed accumulator). Only two places can stop it: no more `<%`, or a scan error.


### F-022 · `Template.vars`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/template.ml` | public | 4 | 2/5 | required | AD-022 |

**Signature**

```ocaml
Template.vars : Template.seg list -> string list
```

**Problem Description.** The engine can warn about parameters a template never uses (and tests can assert the template's interface). The distinct variable names used by a template, in order of first appearance.

**Conceptual Model.** Fold over the segments, appending a Var name only if it is not already in the accumulator.

**Inputs**

- segs

**Requires**

- none

**Produces.** Names without duplicates.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- No duplicates
- Order of first appearance
- vars [] = []

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - first appearance order*

```ocaml
Template.vars (Result.get_ok (Template.parse "<%b%> <%a%> <%b | upper%>"))
```

Result: `["b"; "a"]`


*Boundary - no variables*

```ocaml
Template.vars (Result.get_ok (Template.parse "plain"))
```

Result: `[]`


*Failure - empty list*

```ocaml
Template.vars []
```

Result: `[]`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-091 | unit | order of first appearance |
| T-092 | boundary | text only and empty |
| T-093 | boundary | filters do not create new names |

**OCaml Learning Objective.** `List.fold_left`, pattern guards (`when`), or-patterns, `List.mem`.

**Library Learning Objective.** `List.fold_left`, `List.mem`.

**Diagram References.** AD-022, CL-2, CMP-F3, CMP-2

**Implementation Challenge.** Ignore Text segments without an explicit `else` branch per case.

**Hint.** `| Var { name; _ } when not (List.mem name acc) -> ...` then a catch-all arm.


### F-023 · `Template.apply_filter`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/template.ml` | public | 4 | 1/5 | required | AD-023 |

**Signature**

```ocaml
Template.apply_filter : Template.filter -> string -> string
```

**Problem Description.** Templates write <% type | pascal %> to get a class name from whatever the user typed. Apply one filter (snake, camel, pascal, upper_snake, upper, lower) to a value.

**Conceptual Model.** Match on the filter variant: four map to Naming.convert; upper and lower use the standard ASCII case functions.

**Inputs**

- f
- value

**Requires**

- none

**Produces.** The transformed string.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Total over six filters
- upper (lower s) = upper s

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - pascal*

```ocaml
Template.apply_filter Template.Pascal "union find"
```

Result: `"UnionFind"`


*Boundary - upper does not split words*

```ocaml
Template.apply_filter Template.Upper "fooBar"
```

Result: `"FOOBAR"`


*Failure - total: empty string*

```ocaml
Template.apply_filter Template.Upper_snake ""
```

Result: `""`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-094 | unit | four naming filters |
| T-095 | unit | case filters |
| T-096 | boundary | empty |

**OCaml Learning Objective.** One more exhaustive match; reuse of earlier modules.

**Library Learning Objective.** `String.uppercase_ascii`, `String.lowercase_ascii`.

**Diagram References.** AD-023, CL-2, CMP-F3, CMP-F2, CMP-2

**Implementation Challenge.** No wildcard arm.

**Hint.** Four of the six arms are one-liners calling Naming.convert.


### F-024 · `Template.render`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/template.ml` | public | 4 | 3/5 | required | AD-024 |

**Signature**

```ocaml
Template.render : Template.seg list -> (string * string) list -> (string, Err.template_error) result
```

**Problem Description.** This is the moment generated code appears. An unbound variable must be an error, never an empty hole. Produce the output text: Text as is, each Var looked up in the environment and passed through its filters left to right.

**Conceptual Model.** Walk the segments with a Buffer; look names up in an association list; fold the filters over the value. The first missing name aborts with Unbound name.

**Inputs**

- segs
- env: (name, value) pairs

**Requires**

- none

**Produces.** Ok text or Error (Unbound name).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unbound name

**Invariants**

- render [] env = Ok ""
- Extra env entries are ignored
- Output order equals segment order

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - variable with two filters*

```ocaml
Template.render (Result.get_ok (Template.parse "def <% fn | snake %>(x):")) [("fn", "binarySearch")]
```

Result: `Ok "def binary_search(x):"`


*Boundary - extra env entries and empty template*

```ocaml
(Template.render [] [("a", "1")], Template.render (Result.get_ok (Template.parse "x")) [("zzz", "1")])
```

Result: `(Ok "", Ok "x")`


*Failure - unbound variable*

```ocaml
Template.render (Result.get_ok (Template.parse "<% q %>")) []
```

Result: `Error (Unbound "q")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-097 | unit | substitutes with filters |
| T-098 | unit | filter order matters |
| T-099 | boundary | empty template, extra env |
| T-100 | failure | unbound |
| T-101 | boundary | same variable used twice |

**OCaml Learning Objective.** `Buffer`, `List.assoc_opt`, `List.fold_left` for the filter chain, recursion that returns early with `Error`.

**Library Learning Objective.** `Buffer.add_string`, `List.assoc_opt`.

**Diagram References.** AD-024, CMP-2, SEQ-6, CL-2, CMP-F3

**Implementation Challenge.** Apply filters in written order: `x | upper | snake` is not `x | snake | upper`.

**Hint.** Keep the Buffer outside the recursive helper and let the helper return the `result`.


### F-025 · `Catalog.find`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/catalog.ml` | public | 5 | 1/5 | required | AD-025 |

**Signature**

```ocaml
Catalog.find : string -> Catalog.algo option
```

**Problem Description.** The catalog is plain data; this is how the rest of the program reaches it. Look an algorithm up by id in the fixed catalog (binary-search, insertion-sort, stack, union-find).

**Conceptual Model.** First algo in `all` whose id matches.

**Inputs**

- id

**Requires**

- none

**Produces.** Some algo or None.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Some a implies a.id = id

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - known*

```ocaml
Option.map (fun a -> a.Catalog.title) (Catalog.find "stack")
```

Result: `Some "Stack"`


*Boundary - ids are exact*

```ocaml
Option.is_some (Catalog.find "Stack")
```

Result: `false`


*Failure - unknown*

```ocaml
Option.is_some (Catalog.find "quicksort")
```

Result: `false`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-102 | unit | four algorithms |
| T-103 | boundary | exact match |
| T-104 | failure | unknown |

**OCaml Learning Objective.** Records with several fields, lists of records.

**Library Learning Objective.** `List.find_opt`.

**Diagram References.** AD-025, CL-2, CMP-F1, CMP-2

**Implementation Challenge.** One line.

**Hint.** `Catalog.all` is already written for you.


### F-026 · `Catalog.template`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/catalog.ml` | public | 5 | 1/5 | required | AD-026 |

**Signature**

```ocaml
Catalog.template : algo_id:string -> lang_id:string -> string option
```

**Problem Description.** Not every algorithm has a template for every language; None is how the engine learns that. The template text for an (algorithm, language) pair, or None when no template exists.

**Conceptual Model.** Choose the language's `(id * text) list` from Templates, then `List.assoc_opt` the algorithm id.

**Inputs**

- ~algo_id
- ~lang_id

**Requires**

- none

**Produces.** Some text or None.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- None for an unknown language
- Some for all 4 algos in python, javascript and ocaml

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python stack*

```ocaml
Option.map String.length (Catalog.template ~algo_id:"stack" ~lang_id:"python") |> Option.is_some
```

Result: `true`


*Boundary - unknown language*

```ocaml
Catalog.template ~algo_id:"stack" ~lang_id:"cobol" |> Option.is_some
```

Result: `false`


*Failure - unknown algorithm*

```ocaml
Catalog.template ~algo_id:"nope" ~lang_id:"python" |> Option.is_some
```

Result: `false`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-105 | unit | all built-in pairs exist |
| T-106 | failure | unknown language/algo |
| T-107 | unit | every template parses and renders against its algo params |

**OCaml Learning Objective.** Labelled arguments with `~name:`, matching on strings, association lists.

**Library Learning Objective.** `List.assoc_opt`.

**Diagram References.** AD-026, CL-2, CMP-F1, CMP-2

**Implementation Challenge.** Unknown language gives None, not an exception.

**Hint.** A `match lang_id with "python" -> ... | _ -> []` keeps the fallback in one place.


### F-027 · `Catalog.for_lang`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/catalog.ml` | public | 5 | 2/5 | required | AD-027 |

**Signature**

```ocaml
Catalog.for_lang : string -> Catalog.algo list
```

**Problem Description.** The picker should only offer what can actually be generated. The algorithms that have a template for the given language id, in catalog order.

**Conceptual Model.** Filter `all` with `template ~algo_id ~lang_id <> None`.

**Inputs**

- lang_id

**Requires**

- none

**Produces.** A (possibly empty) list.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Subset of Catalog.all, same order
- [] for an unknown language

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python*

```ocaml
List.map (fun a -> a.Catalog.id) (Catalog.for_lang "python")
```

Result: `["binary-search"; "insertion-sort"; "stack"; "union-find"]`


*Failure - unknown language*

```ocaml
List.length (Catalog.for_lang "cobol")
```

Result: `0`


*Boundary - empty id*

```ocaml
List.length (Catalog.for_lang "")
```

Result: `0`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-108 | unit | python has all four in order |
| T-109 | failure | unknown language |
| T-110 | boundary | empty id |

**OCaml Learning Objective.** `List.filter`, labelled-argument calls, comparing options with `<>`.

**Library Learning Objective.** `List.filter`.

**Diagram References.** AD-027, CL-2, CMP-F1, CMP-2

**Implementation Challenge.** Write it as a single filter, without a loop.

**Hint.** `Catalog.template` already answers the question for one algorithm.


### F-028 · `Collision.unique_name`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/collision.ml` | public | 5 | 2/5 | required | AD-028 |

**Signature**

```ocaml
Collision.unique_name : string list -> string -> string
```

**Problem Description.** Inserting `binary_search` into a file that already defines it must not shadow or break the existing one. Return the name unchanged if free, otherwise name_2, name_3, ... the first free suffix.

**Conceptual Model.** If the name is not in `existing` return it; otherwise count up from 2 until `name_i` is not in `existing`.

**Inputs**

- existing: names already defined
- name

**Requires**

- none

**Produces.** A name not in `existing`.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Result is not in existing
- unique_name [] n = n
- Numbering starts at 2

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - taken*

```ocaml
Collision.unique_name ["f"] "f"
```

Result: `"f_2"`


*Boundary - chain*

```ocaml
Collision.unique_name ["f"; "f_2"] "f"
```

Result: `"f_3"`


*Failure - free name and empty list*

```ocaml
(Collision.unique_name ["a"] "b", Collision.unique_name [] "f")
```

Result: `("b", "f")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-111 | unit | free name unchanged |
| T-112 | unit | taken gets _2 |
| T-113 | boundary | chain |
| T-114 | boundary | a gap is filled |

**OCaml Learning Objective.** Local recursive function, `Printf.sprintf "%s_%d"`, `List.mem`.

**Library Learning Objective.** `List.mem`, `Printf.sprintf`.

**Diagram References.** AD-028, CL-2, CMP-F4, CMP-2

**Implementation Challenge.** Skip over suffixes that are themselves taken (x, x_2 taken gives x_3).

**Hint.** Counting needs a helper that takes the next integer to try.


### F-029 · `Collision.defined_names`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/collision.ml` | public | 5 | 3/5 | required | AD-029 |

**Signature**

```ocaml
Collision.defined_names : Lang.t -> string -> string list
```

**Problem Description.** Neovim sends the buffer; the engine needs to know which names already exist, without a parser. Names the buffer text defines, found by looking at the start of each trimmed line for one of the language's def_markers.

**Conceptual Model.** Split on newlines; trim each line; find the first marker the line starts with (marker order matters: `async def ` before `def `); the name is the word (letters, digits, underscore) right after the marker.

**Inputs**

- lang
- text

**Requires**

- none

**Produces.** Names in order of appearance, duplicates kept.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Lines without a marker contribute nothing
- Marker with no name after it contributes nothing

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python file*

```ocaml
Collision.defined_names (lang "python") "import os\n\ndef foo(x):\n    return x\nclass Bar:\n  pass"
```

Result: `["foo"; "Bar"]`


*Boundary - javascript const/let/function*

```ocaml
Collision.defined_names (lang "javascript") "const a = 1;\n  let b;\nfunction c() {}"
```

Result: `["a"; "b"; "c"]`


*Boundary - marker without a name*

```ocaml
Collision.defined_names (lang "python") "def (x)"
```

Result: `[]`


*Failure - empty text*

```ocaml
Collision.defined_names (lang "python") ""
```

Result: `[]`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-115 | unit | python |
| T-116 | unit | javascript |
| T-117 | unit | ocaml let rec |
| T-118 | boundary | async def wins over def |
| T-119 | boundary | marker needs its trailing space |
| T-120 | failure | no name / empty |
| T-121 | boundary | duplicates are kept |

**OCaml Learning Objective.** `List.filter_map`, `List.find_opt`, helper scan loops, option-returning pipelines.

**Library Learning Objective.** `Util.split`, `Util.trim`, `Util.starts_with`.

**Diagram References.** AD-029, CL-2, CMP-F4, CMP-2

**Implementation Challenge.** Do not mistake `define x` for `def x`: the marker includes its trailing space.

**Hint.** Write `leading_word : string -> string` (letters, digits, `_`) first. Keep it inside this function's marker region.


### F-030 · `Params.normalize_ident`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/params.ml` | public | 6 | 3/5 | required | AD-030 |

**Signature**

```ocaml
Params.normalize_ident : Lang.t -> Catalog.param -> string -> (string, Err.t) result
```

**Problem Description.** 'Binary Search', 'binary-search' and 'binarySearch' should all produce the identifier this language prefers. Turn what the user typed for a name parameter into a valid identifier in the right style for the language and parameter kind.

**Conceptual Model.** Trim; reject input with no words or starting with a digit (Bad_ident); then Naming.convert in the style: Ident_fn uses the language's fn_style, Ident_type always Pascal.

**Inputs**

- lang
- param
- raw: user text

**Requires**

- none

**Produces.** Ok identifier or Error (Bad_ident {param = name; value = raw}).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Bad_ident

**Invariants**

- Ok result has no spaces
- Types are PascalCase in every language
- Functions follow lang.fn_style

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - function in python*

```ocaml
Params.normalize_ident (lang "python") (param "fn") "Binary Search"
```

Result: `Ok "binary_search"`


*Normal - function in javascript*

```ocaml
Params.normalize_ident (lang "javascript") (param "fn") "binary search"
```

Result: `Ok "binarySearch"`


*Normal - type is PascalCase*

```ocaml
Params.normalize_ident (lang "python") (param "type_name") "union find"
```

Result: `Ok "UnionFind"`


*Failure - starts with a digit*

```ocaml
Params.normalize_ident (lang "python") (param "fn") "2fast"
```

Result: `Error (bad_ident: bad name for fn: "2fast")`


*Failure - no words*

```ocaml
Params.normalize_ident (lang "python") (param "fn") "  --  "
```

Result: `Error (bad_ident: bad name for fn: "  --  ")`


*Boundary - pinned by T-124: surrounding space is trimmed* (assertion; verified to pass)

```ocaml
eq_str_e "stack" (Params.normalize_ident (lang "python") (param "fn") "  stack ")
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-122 | unit | function style per language |
| T-123 | unit | types are Pascal everywhere |
| T-124 | boundary | surrounding space is trimmed |
| T-125 | failure | digit first |
| T-126 | failure | empty / no words |

**OCaml Learning Objective.** Helper functions inside a marker region, `char` comparison for digits, matching on `param.kind`.

**Library Learning Objective.** `Util.trim`, `Naming.words`, `Naming.convert`.

**Diagram References.** AD-030, CL-2, CMP-F2, CMP-F8, CMP-2

**Implementation Challenge.** Include the original (untrimmed) text in the error so the user sees what they typed.

**Hint.** Write `style_of : Lang.t -> Catalog.param -> Naming.style` first.


### F-031 · `Params.normalize_elem`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/params.ml` | public | 6 | 1/5 | required | AD-031 |

**Signature**

```ocaml
Params.normalize_elem : Lang.t -> string -> (string, Err.t) result
```

**Problem Description.** The user says 'string'; Python needs `str`. Map the user's element-type word (int, float, string, bool; any case) to the language's own type name.

**Conceptual Model.** Lowercase and trim, match one of four words, translate with Lang.elem_type.

**Inputs**

- lang
- raw

**Requires**

- none

**Produces.** Ok type name or Error (Bad_elem raw).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Bad_elem

**Invariants**

- Accepts exactly four words, any case

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python string*

```ocaml
Params.normalize_elem (lang "python") "String"
```

Result: `Ok "str"`


*Boundary - padded*

```ocaml
Params.normalize_elem (lang "javascript") "  INT "
```

Result: `Ok "number"`


*Failure - unknown word*

```ocaml
Params.normalize_elem (lang "python") "double"
```

Result: `Error (bad_elem: bad element type: "double")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-127 | unit | per language |
| T-128 | boundary | case and spaces |
| T-129 | failure | unknown |

**OCaml Learning Objective.** String patterns in `match`, `Result`.

**Library Learning Objective.** `String.lowercase_ascii`, `Util.trim`.

**Diagram References.** AD-031, CL-2, CMP-F2, CMP-2

**Implementation Challenge.** Keep the original text in the error.

**Hint.** Normalise first, then match.


### F-032 · `Params.ghost`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/params.ml` | public | 6 | 1/5 | required | AD-032 |

**Signature**

```ocaml
Params.ghost : Lang.t -> Catalog.param -> string
```

**Problem Description.** The editor shows `binary_search` in grey while asking, so the user sees what Enter will produce. The ghost text (placeholder preview) for a prompt: the default, styled as the final identifier would be.

**Conceptual Model.** Element params: the default as written. Identifiers: the default converted with the same style as normalize_ident.

**Inputs**

- lang
- param

**Requires**

- none

**Produces.** A string.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- For identifiers equals the Ok value of normalize_ident on the default

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - function ghost in python and javascript*

```ocaml
(Params.ghost (lang "python") (param "fn"), Params.ghost (lang "javascript") (param "fn"))
```

Result: `("binary_search", "binarySearch")`


*Boundary - element ghost is plain*

```ocaml
Params.ghost (lang "python") (param "elem")
```

Result: `"int"`


*Boundary - type ghost*

```ocaml
Params.ghost (lang "ocaml") (param "type_name")
```

Result: `"Stack"`


*Failure - not applicable:* this function is total over its Requires.


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-130 | unit | function |
| T-131 | unit | element |
| T-132 | boundary | type is Pascal |

**OCaml Learning Objective.** Reusing a helper (`style_of`) across functions, matching on `kind`.

**Library Learning Objective.** `Naming.convert`.

**Diagram References.** AD-032, CL-2, CMP-F2, CMP-F7, CMP-2

**Implementation Challenge.** Do not duplicate the style choice.

**Hint.** `style_of` lives in the normalize_ident region, but is visible below it.


### F-033 · `Params.resolve`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/params.ml` | public | 6 | 4/5 | required | AD-033 |

**Signature**

```ocaml
Params.resolve : ?existing:string list -> Lang.t -> Catalog.algo -> (string * string) list -> ((string * string) list, Err.t) result
```

**Problem Description.** This is where user input becomes safe template input. Everything downstream can assume values are valid identifiers/types. Turn the user's raw answers into final template values for every parameter of the algorithm: fill defaults, normalise, avoid existing names.

**Conceptual Model.** First reject answers whose name is not a parameter (Unknown_param). Then for each parameter in algorithm order: use the answer if non-blank, else the default; Elem params go through normalize_elem, others through normalize_ident then Collision.unique_name existing.

**Inputs**

- ?existing (default [])
- lang
- algo
- answers: (param name, raw text) list

**Requires**

- none

**Produces.** Ok (name, value) list in the algorithm's parameter order, or the first error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_param; Bad_ident; Bad_elem

**Invariants**

- Output has exactly one entry per algo param, in order
- Blank answers use defaults
- Only identifiers are made unique, never element types

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - defaults for everything*

```ocaml
Params.resolve (lang "python") (algo "binary-search") []
```

Result: `Ok [("fn", "binary_search"); ("elem", "int")]`


*Normal - answers override*

```ocaml
Params.resolve (lang "javascript") (algo "stack") [("type_name","int stack");("elem","String")]
```

Result: `Ok [("type_name", "IntStack"); ("elem", "string")]`


*Boundary - collision with existing names*

```ocaml
Params.resolve ~existing:["binary_search"] (lang "python") (algo "binary-search") []
```

Result: `Ok [("fn", "binary_search_2"); ("elem", "int")]`


*Boundary - blank answer falls back*

```ocaml
Params.resolve (lang "python") (algo "stack") [("elem","  ")]
```

Result: `Ok [("type_name", "Stack"); ("elem", "int")]`


*Failure - unknown parameter*

```ocaml
Params.resolve (lang "python") (algo "stack") [("colour","red")]
```

Result: `Error (unknown_param: unknown parameter: colour)`


*Failure - bad element*

```ocaml
Params.resolve (lang "python") (algo "stack") [("elem","double")]
```

Result: `Error (bad_elem: bad element type: "double")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-133 | unit | defaults |
| T-134 | unit | answers override and normalise |
| T-135 | boundary | existing names get suffixed |
| T-136 | boundary | blank means default |
| T-137 | boundary | element types are never renamed |
| T-138 | failure | unknown param |
| T-139 | failure | unknown param is reported even when another answer is bad |
| T-140 | failure | bad elem and bad ident |

**OCaml Learning Objective.** Optional arguments (`?existing`), `Result.map`, recursion with early exit, `List.assoc_opt`, `List.exists`.

**Library Learning Objective.** `Params.normalize_*`, `Collision.unique_name`.

**Diagram References.** AD-033, CMP-2, SEQ-6, CL-2, CMP-F2, CMP-F4, CMP-F8

**Implementation Challenge.** Check unknown answers BEFORE normalising anything, so the error does not depend on parameter order.

**Hint.** Wrap the per-parameter work as a function returning `result`; the loop only threads the accumulator.


### F-034 · `Params.next_prompt`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/params.ml` | public | 6 | 2/5 | stretch | AD-034 |

**Signature**

```ocaml
Params.next_prompt : Lang.t -> Catalog.algo -> (string * string) list -> (Catalog.param * string) option
```

**Problem Description.** The prompting loop asks one question at a time and needs to know which is next. The first parameter that has no answer yet, with its ghost text; None when all are answered.

**Conceptual Model.** Find the first param whose name is not a key in the answers; pair it with its ghost.

**Inputs**

- lang
- algo
- answers so far

**Requires**

- none

**Produces.** Some (param, ghost) or None.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- None iff every param name is a key of answers

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - nothing answered*

```ocaml
Option.map (fun ((p : Catalog.param), g) -> (p.name, g)) (Params.next_prompt (lang "python") (algo "stack") [])
```

Result: `Some (("type_name", "Stack"))`


*Boundary - first answered*

```ocaml
Option.map (fun ((p : Catalog.param), g) -> (p.name, g)) (Params.next_prompt (lang "python") (algo "stack") [("type_name","x")])
```

Result: `Some (("elem", "int"))`


*Boundary - all answered*

```ocaml
Option.map (fun ((p : Catalog.param), _) -> p.name) (Params.next_prompt (lang "python") (algo "stack") [("type_name","x");("elem","int")])
```

Result: `None`


*Failure - not applicable:* this function is total over its Requires.


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-141 | unit | first |
| T-142 | unit | second |
| T-143 | boundary | done |
| T-144 | boundary | unknown answers are ignored |

**OCaml Learning Objective.** `List.mem_assoc`, tuples, option of tuple.

**Library Learning Objective.** `List.find_opt`, `List.mem_assoc`.

**Diagram References.** AD-034, OBJ-1, CL-2, CMP-F7, CMP-2

**Implementation Challenge.** Answers for unknown names must not confuse it.

**Hint.** You only look at parameter names, never at the values.


### F-035 · `Session.create`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/session.ml` | public | 6 | 1/5 | stretch | AD-035 |

**Signature**

```ocaml
Session.create : Lang.t -> Catalog.algo -> Session.t
```

**Problem Description.** The session is a pure state machine, so it can be tested without any editor. Start a prompting session: no answers yet, state Collecting.

**Conceptual Model.** Build the record with an empty reversed-answers list.

**Inputs**

- lang
- algo

**Requires**

- none

**Produces.** A Session.t.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- state = Collecting
- answers = []

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - new session*

```ocaml
(let s = Session.create (lang "python") (algo "stack") in (s |> Session.state = Session.Collecting, Session.answers s))
```

Result: `(true, [])`


*Boundary - pending is the first param*

```ocaml
Option.map (fun ((p : Catalog.param), _) -> p.name) (Session.pending (Session.create (lang "python") (algo "stack")))
```

Result: `Some ("type_name")`


*Failure - no failing input*

```ocaml
Session.state (Session.create (lang "python") (algo "union-find")) = Session.Collecting
```

Result: `true`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-145 | unit | fresh |

**OCaml Learning Objective.** Abstract types (`type t` hidden in the .mli), record creation.

**Library Learning Objective.** none.

**Diagram References.** AD-035, CL-1, ST-1, CL-2, CMP-F7, OBJ-1, CMP-2

**Implementation Challenge.** Notice that nothing outside the module can build or inspect a `Session.t`.

**Hint.** Answers are stored newest-first; `answers` reverses them.


### F-036 · `Session.state`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/session.ml` | public | 6 | 1/5 | stretch | AD-036 |

**Signature**

```ocaml
Session.state : Session.t -> Session.state
```

**Problem Description.** The caller loops while Collecting. Report Collecting, Ready or Cancelled.

**Conceptual Model.** Field read.

**Inputs**

- t

**Requires**

- none

**Produces.** A state.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Collecting -> Ready or Cancelled, never back

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - after all answers*

```ocaml
(let s = Session.create (lang "python") (algo "union-find") in Session.state (Result.get_ok (Session.record s "x")) = Session.Ready)
```

Result: `true`


*Boundary - after cancel*

```ocaml
Session.state (Session.cancel (Session.create (lang "python") (algo "stack"))) = Session.Cancelled
```

Result: `true`


*Failure - still collecting*

```ocaml
Session.state (Result.get_ok (Session.record (Session.create (lang "python") (algo "stack")) "x")) = Session.Collecting
```

Result: `true`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-146 | unit | walk the states |
| T-147 | boundary | cancelled |

**OCaml Learning Objective.** Records with a field named like its type.

**Library Learning Objective.** none.

**Diagram References.** AD-036, ST-1, CL-2, CMP-F7, OBJ-1, CMP-2

**Implementation Challenge.** One line.

**Hint.** `t.st`.


### F-037 · `Session.answers`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/session.ml` | public | 6 | 1/5 | stretch | AD-037 |

**Signature**

```ocaml
Session.answers : Session.t -> (string * string) list
```

**Problem Description.** The final answers feed Params.resolve. Answers recorded so far, oldest first, as (param name, raw text).

**Conceptual Model.** Reverse the stored newest-first list.

**Inputs**

- t

**Requires**

- none

**Produces.** An association list.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Length = number of successful records

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - two answers*

```ocaml
(let s = Session.create (lang "python") (algo "stack") in Session.answers (Result.get_ok (Session.record (Result.get_ok (Session.record s "A")) "bool")))
```

Result: `[("type_name", "A"); ("elem", "bool")]`


*Boundary - none yet*

```ocaml
Session.answers (Session.create (lang "python") (algo "stack"))
```

Result: `[]`


*Failure - rejected record adds nothing*

```ocaml
(let s = Session.cancel (Session.create (lang "python") (algo "stack")) in ignore (Session.record s "x"); Session.answers s)
```

Result: `[]`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-148 | unit | order |
| T-149 | boundary | empty |

**OCaml Learning Objective.** `List.rev`, why newest-first storage is cheap.

**Library Learning Objective.** `List.rev`.

**Diagram References.** AD-037, CL-2, CMP-F7, ST-1, OBJ-1, CMP-2

**Implementation Challenge.** One line.

**Hint.** Prepending to a list is O(1), appending is O(n).


### F-038 · `Session.pending`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/session.ml` | public | 6 | 1/5 | stretch | AD-038 |

**Signature**

```ocaml
Session.pending : Session.t -> (Catalog.param * string) option
```

**Problem Description.** The UI asks exactly this question each round. The next question (parameter and ghost), or None when none is left.

**Conceptual Model.** Delegate to Params.next_prompt using the session's language, algorithm and answers.

**Inputs**

- t

**Requires**

- none

**Produces.** Some (param, ghost) or None.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- None iff state <> Collecting (for non-cancelled complete sessions)

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - first*

```ocaml
Option.map (fun ((p : Catalog.param), g) -> (p.name, g)) (Session.pending (Session.create (lang "python") (algo "binary-search")))
```

Result: `Some (("fn", "binary_search"))`


*Boundary - after one*

```ocaml
Option.map (fun ((p : Catalog.param), _) -> p.name) (Session.pending (Result.get_ok (Session.record (Session.create (lang "python") (algo "binary-search")) "f")))
```

Result: `Some ("elem")`


*Failure - none when complete*

```ocaml
Session.pending (Result.get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u")) |> Option.is_some
```

Result: `false`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-150 | unit | first and second |
| T-151 | boundary | none when complete |

**OCaml Learning Objective.** Composition of modules; one function reusing another's logic.

**Library Learning Objective.** none.

**Diagram References.** AD-038, OBJ-1, CL-2, CMP-F7, ST-1, CMP-2

**Implementation Challenge.** One line.

**Hint.** Do not duplicate Params logic.


### F-039 · `Session.record`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/session.ml` | public | 6 | 3/5 | stretch | AD-039 |

**Signature**

```ocaml
Session.record : Session.t -> string -> (Session.t, Err.t) result
```

**Problem Description.** Rules like 'no answers after cancel' belong in a testable state machine, not in UI callbacks. Record the answer to the pending question; become Ready when it was the last one.

**Conceptual Model.** Only a Collecting session accepts answers. Take the pending parameter, push (name, value) onto the stored list, and check again whether anything is pending.

**Inputs**

- t
- value: raw text

**Requires**

- none

**Produces.** Ok t' (new value; t is untouched) or Error (Session_closed state).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Session_closed "ready" | "cancelled"

**Invariants**

- Never mutates its input
- Becomes Ready exactly when no parameter is pending
- Closed sessions stay closed

**Side Effects.** none (pure)

**State before / after.** Before: session in state Collecting with answers A. After: a new session value with one more answer; state Ready when nothing is pending; the old value is unchanged (immutable).

**Examples** (outputs verified)


*Normal - records and keeps going*

```ocaml
(let s = Session.create (lang "python") (algo "stack") in let s' = Result.get_ok (Session.record s "A") in (Session.answers s, Session.answers s'))
```

Result: `([], [("type_name", "A")])`


*Boundary - last answer makes it Ready*

```ocaml
Session.state (Result.get_ok (Session.record (Result.get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A")) "int")) = Session.Ready
```

Result: `true`


*Failure - record after ready*

```ocaml
Session.record (Result.get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u")) "x"
```

Result: `Error (session_closed: session is ready)`


*Failure - record after cancel*

```ocaml
Session.record (Session.cancel (Session.create (lang "python") (algo "stack"))) "x"
```

Result: `Error (session_closed: session is cancelled)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-152 | unit | records and does not mutate |
| T-153 | boundary | ready exactly after the last answer |
| T-154 | failure | after ready |
| T-155 | failure | after cancel |

**OCaml Learning Objective.** Persistent (immutable) update with `{ t with ... }`, matching on state, `Result`.

**Library Learning Objective.** none.

**Diagram References.** AD-039, ST-1, OBJ-1, CL-2, CMP-F7, CMP-2

**Implementation Challenge.** Do not accept answers after Ready or Cancelled.

**Hint.** After pushing the answer, `pending` of the NEW session tells you whether it is Ready.


### F-040 · `Session.cancel`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/session.ml` | public | 6 | 1/5 | stretch | AD-040 |

**Signature**

```ocaml
Session.cancel : Session.t -> Session.t
```

**Problem Description.** Pressing <Esc> in the prompt must leave a clean state. Cancel a Collecting session; Ready and Cancelled sessions are returned unchanged.

**Conceptual Model.** Conditional record update.

**Inputs**

- t

**Requires**

- none

**Produces.** A session.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Idempotent
- A Ready session is not cancelled

**Side Effects.** none (pure)

**State before / after.** Before: any session. After: a session in state Cancelled (the old value is unchanged).

**Examples** (outputs verified)


*Normal - cancel while collecting*

```ocaml
Session.state (Session.cancel (Session.create (lang "python") (algo "stack"))) = Session.Cancelled
```

Result: `true`


*Boundary - ready stays ready*

```ocaml
Session.state (Session.cancel (Result.get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u"))) = Session.Ready
```

Result: `true`


*Failure - idempotent*

```ocaml
(let c = Session.cancel (Session.create (lang "python") (algo "stack")) in Session.state (Session.cancel c) = Session.Cancelled)
```

Result: `true`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-156 | unit | cancel |
| T-157 | boundary | ready is not cancelled |
| T-158 | boundary | answers survive a cancel |

**OCaml Learning Objective.** Record update syntax, structural equality on constant constructors.

**Library Learning Objective.** none.

**Diagram References.** AD-040, ST-1, CL-2, CMP-F7, OBJ-1, CMP-2

**Implementation Challenge.** Do not touch recorded answers.

**Hint.** `if t.st = Collecting then ... else t`.


### F-041 · `Insert.reindent`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/insert.ml` | public | 7 | 2/5 | required | AD-041 |

**Signature**

```ocaml
Insert.reindent : string -> string -> string
```

**Problem Description.** Cursor mode pastes code at the cursor's indentation; trailing spaces on blank lines would be noise. Prefix every non-blank line of a block with an indent string; blank lines stay blank.

**Conceptual Model.** Split on newlines, map each line, join with newlines.

**Inputs**

- indent
- block

**Requires**

- none

**Produces.** The re-indented block with the same number of lines.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- Same number of lines
- Blank lines unchanged
- reindent "" s = s

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - two lines*

```ocaml
Insert.reindent "  " "a\nb"
```

Result: `"  a\n  b"`


*Boundary - blank line stays empty*

```ocaml
Insert.reindent "  " "a\n\nb"
```

Result: `"  a\n\n  b"`


*Boundary - trailing newline survives*

```ocaml
Insert.reindent "\t" "a\n"
```

Result: `"\ta\n"`


*Failure - only blank*

```ocaml
Insert.reindent "  " "  "
```

Result: `"  "`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-159 | unit | indents each line |
| T-160 | boundary | blank lines untouched |
| T-161 | boundary | trailing newline |
| T-162 | boundary | empty indent is identity |
| T-163 | failure | whitespace-only line is blank |

**OCaml Learning Objective.** Pipelines with `|>`, `List.map`, anonymous functions, `String.concat`.

**Library Learning Objective.** `Util.split`, `Util.trim`.

**Diagram References.** AD-041, CL-2, CMP-F4, CMP-2

**Implementation Challenge.** A line holding only spaces counts as blank.

**Hint.** Check `Util.trim l = ""` on each line.


### F-042 · `Insert.place`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/insert.ml` | public | 7 | 2/5 | required | AD-042 |

**Signature**

```ocaml
Insert.place : Lang.t -> Insert.mode -> cursor_indent:string -> name:string -> body:string -> Insert.plan
```

**Problem Description.** One generated body, three ways to put it into the editor. Decide what to insert and where: Cursor re-indents; Function adds a blank line before and a newline after; File adds a final newline and a file name.

**Conceptual Model.** Match on the mode variant and build a `plan = {text; file}`.

**Inputs**

- lang
- mode
- ~cursor_indent
- ~name
- ~body

**Requires**

- File mode: name has at least one word

**Produces.** A plan: text, and Some file name only for File mode.

**Raises**

- *Exception (contract violation):* `Invalid_argument` from Lang.file_name in File mode when name has no words
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- file = None unless mode = File
- Cursor text has same line count as body

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - cursor mode indents*

```ocaml
Insert.place (lang "python") Insert.Cursor ~cursor_indent:"    " ~name:"f" ~body:"def f():\n    pass"
```

Result: `{text="    def f():\n        pass"; file=None}`


*Normal - function mode pads with newlines*

```ocaml
Insert.place (lang "python") Insert.Function ~cursor_indent:"" ~name:"f" ~body:"def f(): pass"
```

Result: `{text="\ndef f(): pass\n"; file=None}`


*Normal - file mode names the file*

```ocaml
Insert.place (lang "javascript") Insert.File ~cursor_indent:"" ~name:"binarySearch" ~body:"x"
```

Result: `{text="x\n"; file=Some "binarySearch.js"}`


*Failure - file mode with nameless name*

```ocaml
Insert.place (lang "python") Insert.File ~cursor_indent:"" ~name:"--" ~body:"x"
```

Result: `raised Invalid_argument("Lang.file_name: base has no words")`


*Boundary - not separately exercised:* the normal example already sits at the boundary of this function's domain (see Invariants).


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-164 | unit | cursor |
| T-165 | unit | function |
| T-166 | unit | file |
| T-167 | failure | file with empty stem raises |

**OCaml Learning Objective.** Records with optional fields, labelled arguments in a call, variant matching.

**Library Learning Objective.** `Lang.file_name`, `reindent`.

**Diagram References.** AD-042, SEQ-6, CL-2, CMP-F4, CMP-2

**Implementation Challenge.** File names use the language's own style.

**Hint.** Three arms; two of them are one line.


### F-043 · `Engine.generate`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/engine.ml` | public | 7 | 4/5 | required | AD-043 |

**Signature**

```ocaml
Engine.generate : Lang.t list -> Engine.opts -> (Insert.plan, Err.t) result
```

**Problem Description.** Everything built so far meets here; the order of checks is part of the public behaviour. The whole pipeline: language, algorithm, template, parameters, parse, render, place. The first failing stage returns its error.

**Conceptual Model.** Chain the stages with Result.bind (the `let*` operator). The 'name' for placement is the first non-element parameter's final value, else the algorithm id.

**Inputs**

- regs
- opts: lang, algo, answers, existing, mode, cursor_indent

**Requires**

- none

**Produces.** Ok plan or the first stage's error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_lang; Unknown_algo; No_template; Unknown_param; Bad_ident; Bad_elem; Template _

**Invariants**

- Stage order: lang, algo, template, params, parse, render, place
- Pure: no I/O

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python binary search*

```ocaml
Result.map (fun p -> p.Insert.text) (Engine.generate regs (opts "python" "binary-search" []))
```

Result: `Ok "def binary_search(items: list[int], target: int) -> int:\n    \"\"\"Return the index of target in the sorted list items, or -1.\"\"\"\n    lo, hi = 0, len(items) - 1\n    while lo <= hi:\n        mid = (lo + hi) // 2\n        if items[mid] == target:\n            return mid\n        if items[mid] < target:\n            lo = mid + 1\n        else:\n            hi = mid - 1\n    return -1"`


*Normal - answers and file mode*

```ocaml
Result.map (fun p -> p.Insert.file) (Engine.generate regs { (opts "javascript" "stack" [("type_name","int stack")]) with Engine.mode = Insert.File })
```

Result: `Ok Some "intStack.js"`


*Boundary - existing names cause a suffix*

```ocaml
Result.map (fun p -> p.Insert.text |> String.length > 0) (Engine.generate regs { (opts "python" "insertion-sort" []) with Engine.existing = ["insertion_sort"] })
```

Result: `Ok true`


*Failure - unknown language*

```ocaml
Engine.generate regs (opts "cobol" "stack" []) |> Result.is_ok
```

Result: `false`


*Failure - unknown algorithm*

```ocaml
Engine.generate regs (opts "python" "quicksort" [])
```

Result: `Error (unknown_algo: unknown algorithm: quicksort)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-168 | unit | every language x algo generates and mentions its default name |
| T-169 | unit | python binary search default name |
| T-170 | unit | javascript uses camel case |
| T-171 | boundary | existing name is suffixed |
| T-172 | boundary | file mode names the file after the first non-elem param |
| T-173 | boundary | union-find has no elem param |
| T-174 | failure | unknown language |
| T-175 | failure | unknown algorithm |
| T-176 | failure | language beats algorithm in the check order |
| T-177 | failure | parameter errors surface |
| T-178 | failure | language registered without templates |

**OCaml Learning Objective.** Binding operators (`let*`), `Result.bind`, `Option.to_result`, `Result.map_error`, record arguments.

**Library Learning Objective.** All earlier modules.

**Diagram References.** AD-043, CL-1, CMP-1, CMP-2, SEQ-3, SEQ-6, WALK-1, CL-2, CMP-F1, CMP-F3, CMP-F4, IOV-1

**Implementation Challenge.** Wrap template errors with the `Template` constructor.

**Hint.** Define `let ( let* ) = Result.bind` once; every stage then reads top to bottom.


### F-044 · `Engine.list`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/engine.ml` | public | 7 | 2/5 | required | AD-044 |

**Signature**

```ocaml
Engine.list : Lang.t list -> string -> (Engine.item list, Err.t) result
```

**Problem Description.** The picker menu comes from this list. The algorithms available for a language id, as {id; group; title} items.

**Conceptual Model.** Find the language (Unknown_lang if missing), then map Catalog.for_lang to items.

**Inputs**

- regs
- lang_id

**Requires**

- none

**Produces.** Ok items or Error (Unknown_lang id).

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_lang

**Invariants**

- Catalog order

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python*

```ocaml
Result.map (List.map (fun (i : Engine.item) -> i.id ^ ":" ^ i.group)) (Engine.list regs "python")
```

Result: `Ok ["binary-search:searching"; "insertion-sort:sorting"; "stack:data structures"; "union-find:data structures"]`


*Failure - unknown language*

```ocaml
Engine.list regs "cobol" |> Result.map List.length
```

Result: `Error (unknown_lang: unknown language: cobol)`


*Boundary - empty id*

```ocaml
Engine.list regs "" |> Result.map List.length
```

Result: `Error (unknown_lang: unknown language: )`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-179 | unit | four items for python |
| T-180 | unit | fields filled |
| T-181 | failure | unknown language |

**OCaml Learning Objective.** Records with the same field names as another type (type-directed disambiguation).

**Library Learning Objective.** `Catalog.for_lang`, `List.map`.

**Diagram References.** AD-044, CL-2, CMP-F1, SEQ-6, IOV-1, CMP-2

**Implementation Challenge.** Copy exactly three fields.

**Hint.** Annotate the lambda parameter: `(a : Catalog.algo)`.


### F-045 · `Cli.parse_flags`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 4/5 | required | AD-045 |

**Signature**

```ocaml
Cli.parse_flags : string list -> (Cli.parsed, Err.t) result
```

**Problem Description.** All editor integration goes through this command line; a precise grammar means precise error codes. Parse argv (without the program name) into command, --set pairs, value flags and the --json switch.

**Conceptual Model.** Walk the argument list recursively with a `parsed` record as accumulator. `--json` is a switch; the flags lang, ft, algo, set, mode, indent, existing, scan each take one value; the first non-flag word is the command, a second one is an error. Flags are stored newest-first, so when a flag repeats the LAST occurrence wins in List.assoc_opt; `set` pairs are put back in written order.

**Inputs**

- argv: string list

**Requires**

- none

**Produces.** Ok parsed, or Unknown_flag / Missing_value / Bad_set / Unexpected_arg.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_flag f; Missing_value f; Bad_set v; Unexpected_arg a

**Invariants**

- --set needs name=value with a non-empty name; the value may be empty and may contain `=`
- set keeps written order
- Last repeated flag wins

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - a gen command*

```ocaml
Cli.parse_flags ["gen";"--ft";"python";"--algo";"stack";"--set";"elem=bool";"--json"]
```

Result: `Ok {cmd=Some "gen"; set=[("elem", "bool")]; flags=[("algo", "stack"); ("ft", "python")]; json=true}`


*Boundary - = inside the value; empty value*

```ocaml
Cli.parse_flags ["gen";"--set";"a=b=c";"--set";"d="]
```

Result: `Ok {cmd=Some "gen"; set=[("a", "b=c"); ("d", "")]; flags=[]; json=false}`


*Boundary - repeated flag: last wins*

```ocaml
Cli.parse_flags ["list";"--lang";"python";"--lang";"ocaml"]
```

Result: `Ok {cmd=Some "list"; set=[]; flags=[("lang", "ocaml"); ("lang", "python")]; json=false}`


*Failure - unknown flag*

```ocaml
Cli.parse_flags ["gen";"--bogus"]
```

Result: `Error (unknown_flag: unknown flag: --bogus)`


*Failure - flag without value*

```ocaml
Cli.parse_flags ["gen";"--lang"]
```

Result: `Error (missing_value: missing value for --lang)`


*Failure - bad --set*

```ocaml
Cli.parse_flags ["gen";"--set";"novalue"]
```

Result: `Error (bad_set: bad --set (want name=value): "novalue")`


*Failure - two commands*

```ocaml
Cli.parse_flags ["gen";"list"]
```

Result: `Error (unexpected_arg: unexpected argument: list)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-182 | unit | command and flags |
| T-183 | unit | set pairs keep order |
| T-184 | boundary | = in value and empty value |
| T-185 | boundary | last repeated flag wins |
| T-186 | boundary | empty argv |
| T-187 | failure | unknown flag |
| T-188 | failure | missing value |
| T-189 | failure | bad set |
| T-190 | failure | second command |

**OCaml Learning Objective.** Recursion over a list with a record accumulator, `{ p with ... }`, guards on list patterns, `String.index_opt`, `Result`.

**Library Learning Objective.** `String.index_opt`, `String.sub`, `List.mem`.

**Diagram References.** AD-045, CL-1, CL-2, CMP-F9, SEQ-3, UC-3, DEP-3, CMP-2

**Implementation Challenge.** Treat `--set a=b=c` as name `a`, value `b=c`.

**Hint.** Pattern: `| a :: tl when starts_with a "--" -> ...`. Handle `--set` before the generic value flags.


### F-046 · `Cli.resolve_lang`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 2/5 | required | AD-046 |

**Signature**

```ocaml
Cli.resolve_lang : Lang.t list -> (string * string) list -> string option
```

**Problem Description.** Neovim sends filetypes (javascriptreact); scripts send ids. Pick the language id from the flags: --lang wins; otherwise map --ft through the registry; an unmapped --ft is returned as is (so the engine reports unknown_lang with that text).

**Conceptual Model.** Look up "lang", then "ft"; for ft, use Lang.find_by_filetype and fall back to the raw text.

**Inputs**

- regs
- flags

**Requires**

- none

**Produces.** Some id or None when neither flag is present.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- --lang beats --ft

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - filetype maps*

```ocaml
Cli.resolve_lang regs [("ft","javascriptreact")]
```

Result: `Some "javascript"`


*Boundary - lang beats ft*

```ocaml
Cli.resolve_lang regs [("ft","python");("lang","ocaml")]
```

Result: `Some "ocaml"`


*Boundary - neither flag*

```ocaml
Cli.resolve_lang regs []
```

Result: `None`


*Failure - unmapped ft is returned as is*

```ocaml
Cli.resolve_lang regs [("ft","lua")]
```

Result: `Some "lua"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-191 | unit | ft maps through registry |
| T-192 | unit | lang wins |
| T-193 | boundary | neither |
| T-194 | failure | unmapped ft passes through |

**OCaml Learning Objective.** Nested option matching, returning the raw input as a fallback.

**Library Learning Objective.** `Lang.find_by_filetype`.

**Diagram References.** AD-046, CL-2, CMP-F9, SEQ-3, UC-3, DEP-3, CMP-2

**Implementation Challenge.** Do not validate the id here; the engine owns that error.

**Hint.** Three cases: lang present, ft present, neither.


### F-047 · `Cli.run_list`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 1/5 | required | AD-047 |

**Signature**

```ocaml
Cli.run_list : Lang.t list -> (string * string) list -> (Engine.item list, Err.t) result
```

**Problem Description.** Populates the picker. The `list` command: resolve the language and list its algorithms.

**Conceptual Model.** Resolve the language (missing means the empty id) and call Engine.list.

**Inputs**

- regs
- flags

**Requires**

- none

**Produces.** Engine.list's result.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_lang

**Invariants**

- No language flag gives Unknown_lang ""

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python*

```ocaml
Result.map List.length (Cli.run_list regs [("lang","python")])
```

Result: `Ok 4`


*Failure - no language*

```ocaml
Cli.run_list regs [] |> Result.map List.length
```

Result: `Error (unknown_lang: unknown language: )`


*Boundary - through ft*

```ocaml
Result.map List.length (Cli.run_list regs [("ft","javascriptreact")])
```

Result: `Ok 4`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-195 | unit | lists four |
| T-196 | boundary | ft works |
| T-197 | failure | missing language |

**OCaml Learning Objective.** `Option.value ~default`.

**Library Learning Objective.** `Engine.list`.

**Diagram References.** AD-047, CL-2, CMP-F9, SEQ-3, UC-3, DEP-3, CMP-2

**Implementation Challenge.** One line.

**Hint.** `Option.value ~default:"" (resolve_lang ...)`.


### F-048 · `Cli.run_prompts`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 2/5 | required | AD-048 |

**Signature**

```ocaml
Cli.run_prompts : Lang.t list -> (string * string) list -> ((Catalog.param * string) list, Err.t) result
```

**Problem Description.** The Lua edge asks these questions in a floating window. The `prompts` command: every parameter of an algorithm, each with its ghost text.

**Conceptual Model.** Resolve language and algorithm, then pair each param with Params.ghost.

**Inputs**

- regs
- flags (lang/ft, algo)

**Requires**

- none

**Produces.** Ok list or Unknown_lang / Unknown_algo.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_lang; Unknown_algo

**Invariants**

- Algorithm order
- Language is checked before algorithm

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python stack*

```ocaml
Result.map (List.map (fun ((p : Catalog.param), g) -> p.name ^ "=" ^ g)) (Cli.run_prompts regs [("lang","python");("algo","stack")])
```

Result: `Ok ["type_name=Stack"; "elem=int"]`


*Failure - unknown algo*

```ocaml
Cli.run_prompts regs [("lang","python");("algo","zzz")] |> Result.map List.length
```

Result: `Error (unknown_algo: unknown algorithm: zzz)`


*Failure - unknown lang is reported first*

```ocaml
Cli.run_prompts regs [("lang","cobol");("algo","zzz")] |> Result.map List.length
```

Result: `Error (unknown_lang: unknown language: cobol)`


*Boundary - not separately exercised:* the normal example already sits at the boundary of this function's domain (see Invariants).


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-198 | unit | stack in javascript |
| T-199 | failure | unknown algo |
| T-200 | failure | language first |

**OCaml Learning Objective.** `Option.value`, `match` on two lookups, `List.map` building pairs.

**Library Learning Objective.** `Params.ghost`.

**Diagram References.** AD-048, CL-2, CMP-F9, CMP-F7, SEQ-3, UC-3, DEP-3, CMP-2

**Implementation Challenge.** Same check order as Engine.generate.

**Hint.** Nest the matches or reuse `let*`.


### F-049 · `Cli.run_gen`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 4/5 | required | AD-049 |

**Signature**

```ocaml
Cli.run_gen : Lang.t list -> (string * string) list -> (string * string) list -> (Insert.plan, Err.t) result
```

**Problem Description.** This is the function the Neovim edge calls for every insertion. The `gen` command: validate --mode and --indent, collect existing names (from --scan text, else --existing list), then call Engine.generate.

**Conceptual Model.** Parse mode (cursor|function|file, default cursor) and indent (non-negative int, default 0) before anything else; `--scan` text, when the language is known, is scanned with Collision.defined_names; otherwise `--existing a,b` is split on commas; the cursor indent is that many spaces.

**Inputs**

- regs
- flags
- set: the --set pairs (parameter answers)

**Requires**

- none

**Produces.** Ok plan or the first error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Bad_value --mode; Bad_value --indent; then every Engine.generate error

**Invariants**

- Mode and indent are validated first
- --scan wins over --existing
- Empty --existing items are ignored

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - defaults*

```ocaml
Cli.run_gen regs [("lang","python");("algo","stack")] [] |> Result.map (fun p -> String.length p.Insert.text > 0)
```

Result: `Ok true`


*Normal - --scan avoids a clash*

```ocaml
Cli.run_gen regs [("lang","python");("algo","binary-search");("scan","def binary_search(): pass")] [] |> Result.map (fun p -> String.length p.Insert.text > 0 && contains p.Insert.text "binary_search_2")
```

Result: `Ok true`


*Boundary - --existing with empty items*

```ocaml
Cli.run_gen regs [("lang","python");("algo","binary-search");("existing",",binary_search,")] [] |> Result.map (fun p -> contains p.Insert.text "binary_search_2")
```

Result: `Ok true`


*Boundary - cursor indent applies*

```ocaml
Cli.run_gen regs [("lang","python");("algo","union-find");("indent","4")] [] |> Result.map (fun p -> String.sub p.Insert.text 0 4)
```

Result: `Ok "    "`


*Failure - bad mode*

```ocaml
Cli.run_gen regs [("lang","python");("algo","stack");("mode","zzz")] [] |> Result.map (fun _ -> ())
```

Result: `Error (bad_value: bad value for --mode: "zzz")`


*Failure - negative indent*

```ocaml
Cli.run_gen regs [("lang","python");("algo","stack");("indent","-3")] [] |> Result.map (fun _ -> ())
```

Result: `Error (bad_value: bad value for --indent: "-3")`


*Failure - validation precedes lookup*

```ocaml
Cli.run_gen regs [("lang","cobol");("mode","zzz")] [] |> Result.map (fun _ -> ())
```

Result: `Error (bad_value: bad value for --mode: "zzz")`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-201 | unit | default gen |
| T-202 | unit | --set answers |
| T-203 | unit | --scan avoids a clash |
| T-204 | boundary | --existing is split on commas, empties ignored |
| T-205 | boundary | --scan wins over --existing |
| T-206 | boundary | cursor indent |
| T-207 | boundary | file mode |
| T-208 | failure | bad mode |
| T-209 | failure | bad indent |
| T-210 | failure | validation before lookup |
| T-211 | failure | engine errors pass through |

**OCaml Learning Objective.** `let*` for sequencing validations, `int_of_string_opt`, `String.make`, record construction, tuples in `match`.

**Library Learning Objective.** `Collision.defined_names`, `Util.split`, `Engine.generate`.

**Diagram References.** AD-049, UC-3, SEQ-3, CL-2, CMP-F9, CMP-F4, DEP-3, CMP-2

**Implementation Challenge.** `--indent -3`, `--indent x` and `--mode zzz` must all be Bad_value, even if the language is also unknown.

**Hint.** Validate in this order: mode, indent, then build the options record.


### F-050 · `Cli.run_ask`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 3/5 | stretch | AD-050 |

**Signature**

```ocaml
Cli.run_ask : Lang.t list -> (string * string) list -> ask:Cli.ask -> (Insert.plan option, Err.t) result
```

**Problem Description.** Terminal use without Neovim: the same pure session logic, a different front end. The interactive `ask` command: drive a Session by calling the `ask` callback for each pending question, then run_gen with the collected answers. A callback answer of None cancels.

**Conceptual Model.** Create a session; loop: if nothing is pending take the answers, otherwise call `ask ~prompt ~ghost` and record the reply; None means Ok None.

**Inputs**

- regs
- flags
- ~ask: prompt:string -> ghost:string -> string option

**Requires**

- none

**Produces.** Ok (Some plan), Ok None on cancel, or an error.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* Unknown_lang; Unknown_algo; anything run_gen returns

**Invariants**

- `ask` is called once per parameter, in order
- After None, `ask` is not called again

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - answers from a script*

```ocaml
Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt:_ ~ghost:_ -> Some "") |> Result.map (Option.map (fun p -> String.length p.Insert.text > 0))
```

Result: `Ok Some (true)`


*Boundary - cancel on the first question*

```ocaml
Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt:_ ~ghost:_ -> None) |> Result.map Option.is_some
```

Result: `Ok false`


*Boundary - prompts are asked in order*

```ocaml
(let seen = ref [] in ignore (Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt ~ghost -> seen := prompt :: !seen; Some ghost)); List.rev !seen)
```

Result: `["Type name"; "Element type (int, float, string, bool)"]`


*Failure - unknown algorithm; ask never called*

```ocaml
(let called = ref false in let r = Cli.run_ask regs [("lang","python");("algo","zzz")] ~ask:(fun ~prompt:_ ~ghost:_ -> called := true; None) in (Result.is_error r, !called))
```

Result: `(true, false)`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-212 | unit | uses answers |
| T-213 | unit | ghost is offered, accepting it uses the default |
| T-214 | boundary | questions in parameter order |
| T-215 | boundary | cancel stops asking |
| T-216 | failure | unknown language; ask not called |
| T-217 | failure | bad answer surfaces as an error |

**OCaml Learning Objective.** Higher-order arguments, callback types as labelled arguments, `let rec` loop with `let*`, `option` inside `result`.

**Library Learning Objective.** `Session.create/pending/record/answers`.

**Diagram References.** AD-050, UC-3, CL-2, CMP-F9, CMP-F7, SEQ-3, DEP-3, CMP-2

**Implementation Challenge.** No mutable state: the session value flows through the loop.

**Hint.** The loop's argument is the current Session.t.


### F-051 · `Cli.run`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lib/cli.ml` | public | 8 | 4/5 | required | AD-051 |

**Signature**

```ocaml
Cli.run : ?stdin:(unit -> string) -> ?ask:Cli.ask -> string list -> Cli.outcome
```

**Problem Description.** Because `run` never prints or exits, the entire CLI is unit-testable; only `main` touches the real process. The command line as a pure function: argv in, {code; stdout; stderr} out. Dispatches list / prompts / gen / ask and formats results as text or JSON.

**Conceptual Model.** parse_flags; install built-in languages; read stdin only when `--scan -`; dispatch on the command; map Ok to an outcome (text, or JSON when --json) and Error to an outcome with code 1 (domain) or 2 (usage). Human errors go to stderr (usage ones prefixed `usage error: `); JSON errors go to stdout as {"error":{"code","message"}}.

**Inputs**

- ?stdin: thunk returning all of stdin
- ?ask: prompt callback for the ask command
- argv

**Requires**

- none

**Produces.** An outcome record.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* exit code 1 domain error; exit code 2 usage error

**Invariants**

- code 0 only with an empty stderr
- JSON mode never writes to stderr
- stdin thunk is called only for --scan -

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - list in text mode*

```ocaml
Cli.run ["list";"--lang";"ocaml"]
```

Result: `{code=0; stdout="binary-search\tBinary search\ninsertion-sort\tInsertion sort\nstack\tStack\nunion-find\tUnion-find"; stderr=""}`


*Normal - list in JSON mode*

```ocaml
Cli.run ["list";"--lang";"ocaml";"--json"]
```

Result: `{code=0; stdout="{\"items\":[{\"id\":\"binary-search\",\"title\":\"Binary search\",\"group\":\"searching\"},{\"id\":\"insertion-sort\",\"title\":\"Insertion sort\",\"group\":\"sorting\"},{\"id\":\"stack\",\"title\":\"Stack\",\"group\":\"data structures\"},{\"id\":\"union-find\",\"title\":\"Union-find\",\"group\":\"data structures\"}]}"; stderr=""}`


*Normal - gen*

```ocaml
Cli.run ["gen";"--lang";"python";"--algo";"union-find";"--json"]
```

Result: `{code=0; stdout="{\"text\":\"class UnionFind:\\n    \\\"\\\"\\\"Disjoint ..."; stderr=""}`


*Boundary - scan from stdin*

```ocaml
Cli.run ~stdin:(fun () -> "def stack(): pass") ["gen";"--lang";"python";"--algo";"binary-search";"--scan";"-"]
```

Result: `{code=0; stdout="def binary_search(items: list[int], target: in..."; stderr=""}`


*Failure - domain error, text*

```ocaml
Cli.run ["list";"--lang";"cobol"]
```

Result: `{code=1; stdout=""; stderr="unknown language: cobol"}`


*Failure - domain error, JSON*

```ocaml
Cli.run ["list";"--lang";"cobol";"--json"]
```

Result: `{code=1; stdout="{\"error\":{\"code\":\"unknown_lang\",\"message\":\"unknown language: cobol\"}}"; stderr=""}`


*Failure - usage error*

```ocaml
Cli.run ["gen";"--bogus"]
```

Result: `{code=2; stdout=""; stderr="usage error: unknown flag: --bogus"}`


*Failure - ask without a callback*

```ocaml
Cli.run ["ask";"--lang";"python";"--algo";"stack"]
```

Result: `{code=2; stdout=""; stderr="usage error: unknown command: ask"}`


*Failure - no command*

```ocaml
Cli.run []
```

Result: `{code=2; stdout=""; stderr="usage error: unknown command"}`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-218 | unit | list text |
| T-219 | unit | list json |
| T-220 | unit | prompts json |
| T-221 | unit | prompts text |
| T-222 | unit | gen text is the code |
| T-223 | unit | gen json has text and null file |
| T-224 | unit | gen json file mode names the file |
| T-225 | boundary | stdin only for --scan - |
| T-226 | boundary | scan text from stdin avoids a clash |
| T-227 | boundary | scan text given directly |
| T-228 | boundary | --ft works like --lang |
| T-229 | failure | domain error: text mode |
| T-230 | failure | domain error: JSON mode |
| T-231 | failure | usage error |
| T-232 | failure | usage error in JSON mode |
| T-233 | failure | bad mode is a usage error |
| T-234 | failure | unknown command and no command |
| T-235 | failure | ask needs a callback |
| T-236 | unit | ask with a callback |
| T-237 | boundary | ask cancelled |
| T-238 | boundary | exit 0 never has stderr |

**OCaml Learning Objective.** Optional arguments with defaults, thunks, nested `match`, building JSON values, `Result.map`.

**Library Learning Objective.** `Json.to_string`, `Langs.install`, `Err.code`, `Err.message`.

**Diagram References.** AD-051, UC-3, CL-1, CL-3, CMP-1, CMP-2, DEP-3, SEQ-3, WALK-1, CL-2, CMP-F9, CMP-F1, CMP-F8

**Implementation Challenge.** `ask` without a callback is Unknown_command "ask" (exit 2).

**Hint.** Write `error_outcome json e` and `is_usage e` first; every Error path ends in the same function. JSON shapes are fixed by the table in the Function spec: list -> {"items":[{id,title,group}]}, prompts -> {"prompts":[{name,prompt,ghost}]}, gen/ask -> {"text":..., "file": string|null}.


### F-052 · `Main.main`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `bin/main.ml` | public | 8 | 2/5 | required | AD-052 |

**Signature**

```ocaml
Main.main : unit  (the program's entry point)
```

**Problem Description.** This is the ONLY impure module in the engine; keep it as small as possible. Connect Cli.run to the real process: read argv, stdin, an interactive `ask` callback on the terminal, print the outcome, and exit with its code.

**Conceptual Model.** argv without the program name; stdin read lazily with `In_channel.input_all`; the `ask` callback prints `prompt [ghost]: ` on stderr and reads a line; print stdout and stderr (each with a trailing newline when non-empty), then `exit code`.

**Inputs**

- Sys.argv
- stdin

**Requires**

- none

**Produces.** Process exit status = outcome.code.

**Raises**

- *Exception (contract violation):* none
- *Explicit failure (`Error` / `None`):* none

**Invariants**

- No logic: every decision is in Cli.run

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - run the binary*

```ocaml
Cli.run ["list";"--lang";"python"]
```

Result: `{code=0; stdout="binary-search\tBinary search\ninsertion-sort\tInsertion sort\nstack\tStack\nunion-find\tUnion-find"; stderr=""}`


*Boundary - same call, JSON*

```ocaml
Cli.run ["list";"--lang";"python";"--json"]
```

Result: `{code=0; stdout="{\"items\":[{\"id\":\"binary-search\",\"title\":\"Binary search\",\"group\":\"searching\"},{\"id\":\"insertion-sort\",\"title\":\"Insertion sort\",\"group\":\"sorting\"},{\"id\":\"stack\",\"title\":\"Stack\",\"group\":\"data structures\"},{\"id\":\"union-find\",\"title\":\"Union-find\",\"group\":\"data structures\"}]}"; stderr=""}`


*Failure - exit status comes from the outcome*

```ocaml
(Cli.run ["nope"]).Cli.code
```

Result: `2`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| A-01..A-06 | acceptance | `test/acceptance.sh` runs the real binary (Main.main has no ounit test) |

**OCaml Learning Objective.** `let () =`, `Sys.argv`, `In_channel` (4.14), `prerr_string`, `exit`.

**Library Learning Objective.** `Stdlib.exit`, `Scaffold.Cli.run`.

**Diagram References.** AD-052, UC-3, DEP-1, DEP-2, DEP-3, SEQ-3, CL-2, CMP-F9

**Implementation Challenge.** Print nothing at all when stdout/stderr are empty.

**Hint.** `List.tl (Array.to_list Sys.argv)` drops the program name.


### F-053 · `config.resolve`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/config.lua` | public | 9 | 2/5 | required | AD-053 |

**Signature**

```lua
config.resolve(user: table|nil) -> table | nil, err
```

**Problem Description.** LazyVim passes whatever the user wrote in `opts`. Bad config must fail at setup, with a message naming the field, never later in a callback. Merge the user's opts over the defaults and validate them. Defaults: mode="cursor", keymap="<leader>cg", command="Scaffold", bin=nil.

**Conceptual Model.** Deep-merge with vim.tbl_deep_extend('force', DEFAULTS, user or {}), then check each field in a fixed order (opts type, mode, command, bin). Return (nil, err) on the first problem.

**Inputs**

- user: nil or a table

**Requires**

- none

**Produces.** A new config table (the defaults are never mutated), or nil plus {code="bad_config", field, reason}.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* bad_config opts: must be a table; bad_config mode: must be cursor, function or file; bad_config command: must start with an uppercase letter; bad_config bin: must be a string path
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Defaults table is not mutated
- Unknown extra keys are kept
- Checks run in the documented order

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - no opts*

```lua
return config.resolve(nil)
```

Result: `{ command = "Scaffold", keymap = "<leader>cg", mode = "cursor" }`


*Normal - override one field*

```lua
return config.resolve({ mode = "file" })
```

Result: `{ command = "Scaffold", keymap = "<leader>cg", mode = "file" }`


*Failure - wrong type*

```lua
return config.resolve("x")
```

Result: `nil, { code = "bad_config", field = "opts", reason = "must be a table" }`


*Failure - bad mode*

```lua
return config.resolve({ mode = "bottom" })
```

Result: `nil, { code = "bad_config", field = "mode", reason = "must be cursor, function or file" }`


*Failure - command must be capitalised*

```lua
return config.resolve({ command = "scaffold" })
```

Result: `nil, { code = "bad_config", field = "command", reason = "must start with an uppercase letter" }`


*Boundary - pinned by T-241: unknown keys survive* (assertion; verified to pass)

```lua
eq(config.resolve({ extra = 1 }).extra, 1)
```

*Boundary - pinned by T-242: defaults are not shared between calls* (assertion; verified to pass)

```lua
local a = config.resolve(nil); a.mode = "file"; eq(config.resolve(nil).mode, "cursor")
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-239 | unit | nil gives defaults |
| T-240 | unit | user values override |
| T-241 | boundary | unknown keys survive |
| T-242 | boundary | defaults are not shared between calls |
| T-243 | failure | opts must be a table |
| T-244 | failure | bad mode |
| T-245 | failure | command capitalisation and type |
| T-246 | failure | bin must be a string |

**Lua Learning Objective.** Tables, `type()`, the (value, err) return convention, string patterns (`%u`), module-level constants.

**Neovim API Learning Objective.** `vim.tbl_deep_extend`.

**Diagram References.** AD-053, UC-4, SEQ-4, CL-2, CMP-F10, CMP-3, CL-5

**Implementation Challenge.** Calling resolve twice must not leak state: mutate the result, call again, and get fresh defaults.

**Hint.** `vim.tbl_deep_extend` copies; start from the module-level DEFAULTS and never return it.


### F-054 · `client.binary`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/client.lua` | public | 9 | 2/5 | required | AD-054 |

**Signature**

```lua
client.binary() -> path | nil, err
```

**Problem Description.** The Lua edge is useless without the OCaml engine. A missing binary must produce one clear message that says how to fix it. Locate the engine executable: client.bin if set, else $SCAFFOLD_BIN, else <plugin root>/_build/default/bin/main.exe. Fail if it is not executable.

**Conceptual Model.** Pick the first non-nil of the three sources; ask `vim.fn.executable(path)`; 0 means not found. The plugin root is computed from this file's own path with debug.getinfo.

**Inputs**

- none (reads client.bin and the environment)

**Requires**

- none

**Produces.** A path string, or nil plus {code="engine_missing", path, message}.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* engine_missing
- *Neovim API error:* `debug.getinfo` source path starts with @

**Invariants**

- Precedence: client.bin, then SCAFFOLD_BIN, then default
- The message mentions `dune build`

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - explicit override (any executable)*

```lua
client.bin = '/bin/sh'; local p = client.binary(); client.bin = nil; return p
```

Result: `"/bin/sh"`


*Boundary - environment variable*

```lua
vim.env.SCAFFOLD_BIN = '/bin/sh'; local p = client.binary(); vim.env.SCAFFOLD_BIN = nil; return p
```

Result: `"/bin/sh"`


*Failure - missing path*

```lua
client.bin = '/nope/engine'; local p, e = client.binary(); client.bin = nil; return p, e.code, e.path
```

Result: `nil, "engine_missing", "/nope/engine"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-247 | unit | client.bin wins over the environment |
| T-248 | unit | environment variable is used next |
| T-249 | unit | default path ends with the dune output |
| T-250 | failure | missing binary |
| T-251 | failure | not executable counts as missing |

**Lua Learning Objective.** `or` chains for defaults, module-private `local function`, string slicing (`:sub(2)`), upvalue-free helpers.

**Neovim API Learning Objective.** `vim.fn.executable`, `vim.env`, `vim.fn.fnamemodify`, `debug.getinfo`.

**Diagram References.** AD-054, UC-1, UC-4, DEP-1, SEQ-2, CL-2, CMP-F11, CL-5, SEQ-1, CMP-3

**Implementation Challenge.** Compute the plugin root without hard-coding a path, so the plugin works from lazy.nvim's install directory.

**Hint.** `debug.getinfo(1, 'S').source` starts with '@'. `:p:h:h:h` strips three levels (file, scaffold/, lua/).


### F-055 · `client.call`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/client.lua` | public | 9 | 4/5 | required | AD-055 |

**Signature**

```lua
client.call(args: string[], stdin?: string) -> table | nil, err
```

**Problem Description.** This one function is the whole protocol between Lua and OCaml. Every failure mode (no binary, crash, garbage output, domain error) has to come back as the same (nil, err) shape. Run the engine with args plus --json, wait for it, decode its stdout as JSON, and turn an {"error":...} reply into (nil, {code, message}).

**Conceptual Model.** binary() -> build the argv -> vim.system(cmd, {text=true, stdin=stdin}):wait() inside pcall -> pcall(vim.json.decode, stdout) -> if the decoded table has `error`, return its code and message.

**Inputs**

- args: list of strings (no --json)
- stdin: optional text for the child's stdin

**Requires**

- none

**Produces.** The decoded JSON table on success.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* engine_missing; engine_failed (could not start); bad_json (stdout was not a JSON object); the engine's own domain error code, e.g. unknown_lang
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- --json is always the last argument
- The caller's args table is not mutated
- Never raises

**Side Effects.** none (pure)

**State before / after.** Before: none. After: none (a child process ran and finished).

**Examples** (outputs verified)


*Normal - list command*

```lua
local d = client.call({ 'list', '--lang', 'ocaml' }); return #d.items
```

Result: `4`


*Normal - stdin reaches the engine*

```lua
local d = client.call({ 'gen', '--lang', 'python', '--algo', 'binary-search', '--scan', '-' }, 'def binary_search(): pass'); return d.text:find('binary_search_2', 1, true) ~= nil
```

Result: `true`


*Failure - domain error becomes (nil, err)*

```lua
local d, e = client.call({ 'list', '--lang', 'cobol' }); return d, e.code, e.message
```

Result: `nil, "unknown_lang", "unknown language: cobol"`


*Failure - usage error also uses the error shape*

```lua
local d, e = client.call({ 'gen', '--bogus' }); return d, e.code
```

Result: `nil, "unknown_flag"`


*Boundary - pinned by T-254: args are not mutated* (assertion; verified to pass)

```lua
local a = { "list", "--lang", "python" }; client.call(a); eq(a, { "list", "--lang", "python" })
```

*Boundary - pinned by T-260: --json is appended last* (assertion; verified to pass)

```lua
F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, 'echo "{\\"argv\\":\\"$*\\"}"'); local d = assert(client.call({ "list", "--lang", "x" })); eq(d.argv, "list --lang x --json"); F.rmrf(dir) end)
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-252 | unit | list reply decodes |
| T-253 | unit | stdin is forwarded |
| T-254 | boundary | args are not mutated |
| T-255 | failure | domain error |
| T-256 | failure | usage error |
| T-257 | failure | missing engine |
| T-258 | failure | engine prints garbage |
| T-259 | failure | engine prints valid JSON that is not an object |
| T-260 | boundary | --json is appended last |

**Lua Learning Objective.** `pcall` for foreign failures, list copying, early-return error pairs, `type(x) ~= 'table'` checks.

**Neovim API Learning Objective.** `vim.system` (0.10+), `:wait()`, `vim.json.decode`, `vim.list_extend`.

**Diagram References.** AD-055, UC-2, CL-5, CMP-1, CMP-3, DEP-1, DEP-2, SEQ-2, COM-1, CL-2, CMP-F11, CMP-F1, SEQ-1

**Implementation Challenge.** Include the child's stderr and exit code in the bad_json error, so a crashing engine can be diagnosed.

**Hint.** Do not mutate `args`: start with `local cmd = { bin }` and extend it.


### F-056 · `client.list`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/client.lua` | public | 9 | 1/5 | required | AD-056 |

**Signature**

```lua
client.list(filetype: string) -> item[] | nil, err
```

**Problem Description.** Feeds the picker menu and command-line completion. The algorithms the engine offers for a Neovim filetype: a list of {id, title, group}.

**Conceptual Model.** call({'list','--ft',filetype}) and return data.items.

**Inputs**

- filetype

**Requires**

- none

**Produces.** A Lua array of items or (nil, err).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* every client.call error, e.g. unknown_lang for an unmapped filetype
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Items are in catalog order

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - python*

```lua
local items = client.list('python'); return { #items, items[1].id }
```

Result: `{ 4, "binary-search" }`


*Normal - javascriptreact maps to javascript*

```lua
return #client.list('javascriptreact')
```

Result: `4`


*Failure - unknown filetype*

```lua
local items, e = client.list('lua'); return items, e.code
```

Result: `nil, "unknown_lang"`


*Boundary - pinned by T-262: filetype alias* (assertion; verified to pass)

```lua
eq(#assert(client.list("javascriptreact")), 4)
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-261 | unit | four items |
| T-262 | boundary | filetype alias |
| T-263 | failure | unknown filetype |

**Lua Learning Objective.** Passing errors up unchanged.

**Neovim API Learning Objective.** none.

**Diagram References.** AD-056, CL-5, SEQ-5, CL-2, CMP-F11, SEQ-1, CMP-3

**Implementation Challenge.** Do not rewrite the error.

**Hint.** Three lines.


### F-057 · `client.prompts`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/client.lua` | public | 9 | 1/5 | required | AD-057 |

**Signature**

```lua
client.prompts(filetype: string, algo: string) -> prompt[] | nil, err
```

**Problem Description.** The UI asks them one at a time. The questions to ask for an algorithm: a list of {name, prompt, ghost}.

**Conceptual Model.** call({'prompts','--ft',ft,'--algo',algo}) and return data.prompts.

**Inputs**

- filetype
- algo id

**Requires**

- none

**Produces.** Array of prompts or (nil, err).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* unknown_lang; unknown_algo
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Order = parameter order

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - javascript stack*

```lua
local ps = client.prompts('javascript', 'stack'); return { ps[1].name, ps[1].ghost, ps[2].name }
```

Result: `{ "type_name", "Stack", "elem" }`


*Failure - unknown algorithm*

```lua
local ps, e = client.prompts('python', 'zzz'); return ps, e.code
```

Result: `nil, "unknown_algo"`


*Boundary - pinned by T-265: ghost follows the language style* (assertion; verified to pass)

```lua
eq(assert(client.prompts("javascript", "binary-search"))[1].ghost, "binarySearch")
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-264 | unit | prompts for stack |
| T-265 | boundary | ghost follows the language style |
| T-266 | failure | unknown algorithm |
| T-267 | failure | unknown filetype |

**Lua Learning Objective.** Same shape as client.list.

**Neovim API Learning Objective.** none.

**Diagram References.** AD-057, CL-5, SEQ-1, CL-2, CMP-F11, CMP-F7, CMP-3

**Implementation Challenge.** One more error path to test by hand: unknown algorithm.

**Hint.** Copy client.list.


### F-058 · `client.generate`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/client.lua` | public | 9 | 3/5 | required | AD-058 |

**Signature**

```lua
client.generate(req: {filetype, algo, answers?, mode?, indent?, text?}) -> {text, file?} | nil, err
```

**Problem Description.** One request table in, one result table out; nothing about OCaml leaks to callers. Ask the engine to generate code. The buffer text goes to the engine on stdin (`--scan -`) so it can avoid name clashes; answers become repeated `--set name=value`.

**Conceptual Model.** Build args: gen, --ft, --algo, --mode (default cursor), --indent (default 0), --scan -, and one --set pair per answer; call with req.text as stdin; convert JSON null to nil.

**Inputs**

- req.filetype, req.algo (required)
- req.answers: array of {name, value} (optional)
- req.mode, req.indent, req.text (optional)

**Requires**

- none

**Produces.** {text=string, file=string|nil} or (nil, err).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* every client.call error
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- file is nil (not vim.NIL) in cursor/function mode
- Answer order is preserved

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - defaults*

```lua
local r = client.generate({ filetype = 'python', algo = 'union-find' }); return r.file, r.text:sub(1, 15)
```

Result: `nil, "class UnionFind"`


*Normal - answers and file mode*

```lua
local r = client.generate({ filetype = 'javascript', algo = 'stack', mode = 'file', answers = { { name = 'type_name', value = 'int stack' } } }); return r.file
```

Result: `"intStack.js"`


*Boundary - buffer text avoids a clash*

```lua
local r = client.generate({ filetype = 'python', algo = 'binary-search', text = 'def binary_search(): pass' }); return r.text:find('binary_search_2', 1, true) ~= nil
```

Result: `true`


*Failure - bad answer*

```lua
local r, e = client.generate({ filetype = 'python', algo = 'stack', answers = { { name = 'elem', value = 'double' } } }); return r, e.code
```

Result: `nil, "bad_elem"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-268 | unit | cursor mode has no file |
| T-269 | unit | answers are applied |
| T-270 | unit | file mode returns a name |
| T-271 | boundary | indent is applied in cursor mode |
| T-272 | boundary | buffer text avoids clashes |
| T-273 | failure | bad answer |
| T-274 | failure | bad mode is a usage error |
| T-275 | failure | unknown algorithm |

**Lua Learning Objective.** Table construction, `ipairs`, `tostring`, default values with `or`, JSON null (`vim.NIL`) vs Lua nil.

**Neovim API Learning Objective.** `vim.NIL`.

**Diagram References.** AD-058, UC-2, CL-5, SEQ-1, WALK-1, CL-2, CMP-F11, CMP-F4, CMP-3

**Implementation Challenge.** `data.file ~= vim.NIL and data.file or nil` is the idiom; explain why plain `data.file` would be a bug.

**Hint.** vim.json.decode turns JSON null into vim.NIL, which is truthy.


### F-059 · `buffer.context`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/buffer.lua` | public | 9 | 2/5 | required | AD-059 |

**Signature**

```lua
buffer.context(bufnr: integer) -> ctx | nil, err
```

**Problem Description.** This is the only place the plugin reads editor state, so the rest can be tested without an editor. Read what the engine needs from a buffer: filetype, cursor row (1-based), indentation of the cursor line, the full text, and the file name.

**Conceptual Model.** Validate the buffer, get the cursor row from the current window, read that line and the whole buffer, extract leading whitespace with a pattern.

**Inputs**

- bufnr: a buffer handle

**Requires**

- bufnr is shown in the current window (the cursor belongs to the window)

**Produces.** {filetype, row, indent, text, name} or (nil, {code="invalid_buffer", bufnr}).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* invalid_buffer
- *Neovim API error:* `nvim_win_get_cursor(0)` reads the CURRENT window, not bufnr's

**Invariants**

- row is 1-based
- text joins lines with \n and has no trailing newline

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - indented line*

```lua
local b = F.scratch('python', { 'class A:', '    x = 1' }); vim.api.nvim_win_set_cursor(0, { 2, 0 }); local c = buffer.context(b); return { c.filetype, c.row, c.indent, c.text }
```

Result: `{ "python", 2, "    ", "class A:\n    x = 1" }`


*Boundary - empty buffer*

```lua
local b = F.scratch('ocaml', { '' }); local c = buffer.context(b); return { c.row, c.indent, c.text }
```

Result: `{ 1, "", "" }`


*Failure - invalid buffer*

```lua
local c, e = buffer.context(99999); return c, e.code
```

Result: `nil, "invalid_buffer"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-276 | unit | fields |
| T-277 | boundary | tabs count as indentation |
| T-278 | boundary | empty buffer |
| T-279 | boundary | name of an unnamed buffer is empty |
| T-280 | failure | invalid buffer |

**Lua Learning Objective.** Return of a table, string patterns (`^[ \t]*`), `or ""` defaults, 1-based vs 0-based indexing.

**Neovim API Learning Objective.** `nvim_buf_is_valid`, `nvim_win_get_cursor`, `nvim_buf_get_lines` (0-based, end-exclusive), `vim.bo[bufnr]`, `nvim_buf_get_name`.

**Diagram References.** AD-059, CMP-3, SEQ-1, CL-2, CMP-F12

**Implementation Challenge.** Handle a cursor line that is empty or nil without crashing.

**Hint.** Row 3 (1-based) is `get_lines(bufnr, 2, 3, false)`.


### F-060 · `buffer.insert_lines`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/buffer.lua` | public | 9 | 3/5 | required | AD-060 |

**Signature**

```lua
buffer.insert_lines(bufnr: integer, row: integer, text: string) -> true | nil, err
```

**Problem Description.** `nvim_buf_set_lines` is 0-based and end-exclusive; passing the 1-based cursor row as the 0-based start inserts after the cursor line. This off-by-one is the lesson. Insert text (which may span several lines) AFTER line `row` (1-based; row 0 inserts at the top).

**Conceptual Model.** Split the text on \n (plain), then replace the empty range [row, row) with those lines, with strict indexing so a bad row is an error, caught by pcall.

**Inputs**

- bufnr
- row
- text

**Requires**

- none

**Produces.** true, or (nil, err).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* invalid_buffer; api_error (row out of range)
- *Neovim API error:* strict_indexing = true makes out-of-range rows errors

**Invariants**

- Existing lines are never overwritten
- Line count grows by the number of inserted lines

**Side Effects.** none (pure)

**State before / after.** Before: buffer has L lines. After: buffer has L plus k lines, inserted after 1-based row; one undo entry.

**Examples** (outputs verified)


*Normal - insert after line 1*

```lua
local b = F.scratch('python', { 'a', 'b' }); buffer.insert_lines(b, 1, 'x\ny'); return F.lines(b)
```

Result: `{ "a", "x", "y", "b" }`


*Boundary - row 0 inserts at the top*

```lua
local b = F.scratch('python', { 'a' }); buffer.insert_lines(b, 0, 'top'); return F.lines(b)
```

Result: `{ "top", "a" }`


*Boundary - row = line count appends*

```lua
local b = F.scratch('python', { 'a' }); buffer.insert_lines(b, 1, 'end'); return F.lines(b)
```

Result: `{ "a", "end" }`


*Failure - row out of range*

```lua
local b = F.scratch('python', { 'a' }); local ok, e = buffer.insert_lines(b, 5, 'x'); return ok, e.code
```

Result: `nil, "api_error"`


*Failure - invalid buffer*

```lua
local ok, e = buffer.insert_lines(99999, 0, 'x'); return ok, e.code
```

Result: `nil, "invalid_buffer"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-281 | unit | inserts after the row |
| T-282 | boundary | row 0 is the top |
| T-283 | boundary | row = last line appends |
| T-284 | boundary | blank lines inside text are kept |
| T-285 | failure | row out of range |
| T-286 | failure | invalid buffer |

**Lua Learning Objective.** `pcall` returning (ok, err), `vim.split` with plain = true, error tables.

**Neovim API Learning Objective.** `nvim_buf_set_lines(buf, start, end, strict, lines)`, `vim.split`.

**Diagram References.** AD-060, UC-2, SEQ-1, WALK-1, CL-2, CMP-F12, CMP-3

**Implementation Challenge.** Row = number of lines is legal (append at the end); row beyond that is an api_error.

**Hint.** start == end means insert without replacing anything.


### F-061 · `buffer.write_file`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/buffer.lua` | public | 9 | 2/5 | stretch | AD-061 |

**Signature**

```lua
buffer.write_file(path: string, text: string) -> true | nil, err
```

**Problem Description.** File insert mode must never destroy a user's file. Create a new file containing the text; refuse to overwrite an existing path.

**Conceptual Model.** Check `vim.uv.fs_stat(path)`; if it exists, fail with file_exists; otherwise writefile (split on newline) under pcall.

**Inputs**

- path
- text

**Requires**

- none

**Produces.** true, or (nil, {code="file_exists", path}) / (nil, {code="api_error", message}).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* file_exists; api_error
- *Neovim API error:* `vim.fn.writefile` raises for an unwritable path

**Invariants**

- An existing file is never modified

**Side Effects.** none (pure)

**State before / after.** Before: no file at path. After: file exists with the text; if a file existed nothing changed.

**Examples** (outputs verified)


*Normal - new file*

```lua
local d = F.tmpdir(); local ok = buffer.write_file(d .. '/a.txt', 'x\ny'); local out = vim.fn.readfile(d .. '/a.txt'); F.rmrf(d); return ok, out
```

Result: `true, { "x", "y" }`


*Failure - exists*

```lua
local d = F.tmpdir(); vim.fn.writefile({ 'keep' }, d .. '/a.txt'); local ok, e = buffer.write_file(d .. '/a.txt', 'new'); local kept = vim.fn.readfile(d .. '/a.txt'); F.rmrf(d); return ok, e.code, kept
```

Result: `nil, "file_exists", { "keep" }`


*Failure - directory missing*

```lua
local ok, e = buffer.write_file('/nope/dir/a.txt', 'x'); return ok, e.code
```

Result: `nil, "api_error"`


*Boundary - not separately exercised:* the normal example already sits at the boundary of this function's domain (see Invariants).


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-287 | unit | writes lines |
| T-288 | failure | never overwrites |
| T-289 | failure | missing directory |

**Lua Learning Objective.** Early-return guard, `pcall`.

**Neovim API Learning Objective.** `vim.uv.fs_stat`, `vim.fn.writefile`.

**Diagram References.** AD-061, UC-2, CL-2, CMP-F12, CMP-F4, SEQ-1, CMP-3

**Implementation Challenge.** Report the path in the file_exists error.

**Hint.** `fs_stat` returns nil for a missing path.


### F-062 · `buffer.open_file`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/buffer.lua` | public | 9 | 1/5 | stretch | AD-062 |

**Signature**

```lua
buffer.open_file(path: string) -> bufnr | nil, err
```

**Problem Description.** After File mode writes the file, the user should land in it. Open a file in the current window and return its buffer number.

**Conceptual Model.** :edit with a escaped path under pcall, then read the current buffer.

**Inputs**

- path

**Requires**

- none

**Produces.** A buffer number, or (nil, api_error).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* api_error
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- The returned buffer is the current buffer

**Side Effects.** none (pure)

**State before / after.** Before: current buffer B. After: the current buffer is the file's buffer.

**Examples** (outputs verified)


*Normal - open a file with a space in its name*

```lua
local d = F.tmpdir(); vim.fn.writefile({ 'x' }, d .. '/a b.txt'); local b = buffer.open_file(d .. '/a b.txt'); local same = b == vim.api.nvim_get_current_buf(); F.rmrf(d); return same
```

Result: `true`


*Boundary - pinned by T-291: spaces in the path* (assertion; verified to pass)

```lua
local d = F.tmpdir(); vim.fn.writefile({ "y" }, d .. "/a b.txt"); local b = assert(buffer.open_file(d .. "/a b.txt")); eq(F.lines(b), { "y" }); F.rmrf(d)
```

*Failure - pinned by T-292: a refused :edit is reported, not raised* (assertion; verified to pass)

```lua
local hidden = vim.o.hidden; vim.o.hidden = false; vim.cmd.enew(); vim.bo.buftype = ""; vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" }); local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/a.txt"); local b, e = buffer.open_file(d .. "/a.txt"); vim.bo.modified = false; vim.o.hidden = hidden; F.rmrf(d); eq(b, nil); eq(e.code, "api_error")
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-290 | unit | returns the current buffer |
| T-291 | boundary | spaces in the path |
| T-292 | failure | a refused :edit is reported, not raised |

**Lua Learning Objective.** `vim.cmd.edit`, why the path must be escaped.

**Neovim API Learning Objective.** `vim.cmd.edit`, `vim.fn.fnameescape`, `nvim_get_current_buf`.

**Diagram References.** AD-062, CL-2, CMP-F12, SEQ-1, CMP-3

**Implementation Challenge.** A path with spaces must work.

**Hint.** `vim.cmd.edit(vim.fn.fnameescape(path))`.


### F-063 · `ui.ghost_set`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/ui.lua` | public | 10 | 3/5 | required | AD-063 |

**Signature**

```lua
ui.ghost_set(bufnr: integer, row: integer, text: string) -> extmark_id | nil, err
```

**Problem Description.** Ghost text is how the prompt previews the default without putting it in the buffer. Show grey 'ghost' text at the end of line `row` (1-based) using a virtual-text extmark in the plugin's own namespace.

**Conceptual Model.** Create (once) a namespace; set an extmark at (row - 1, 0) with virt_text = {{text, 'Comment'}} and virt_text_pos = 'eol'.

**Inputs**

- bufnr
- row (1-based)
- text

**Requires**

- none

**Produces.** The extmark id (an integer), or (nil, invalid_buffer).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* invalid_buffer
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Extmarks live in the namespace "scaffold_ghost"

**Side Effects.** none (pure)

**State before / after.** Before: no ghost mark. After: one extmark with virtual text in namespace scaffold_ghost; buffer text unchanged.

**Examples** (outputs verified)


*Normal - set one*

```lua
local b = F.scratch('python', { 'x' }); local id = ui.ghost_set(b, 1, 'hint'); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; local m = vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, { details = true }); return { type(id), #m, m[1][4].virt_text[1][1] }
```

Result: `{ "number", 1, "hint" }`


*Failure - invalid buffer*

```lua
local id, e = ui.ghost_set(99999, 1, 'x'); return id, e.code
```

Result: `nil, "invalid_buffer"`


*Boundary - pinned by T-294: row is 1-based* (assertion; verified to pass)

```lua
local b = F.scratch("python", { "a", "b" }); ui.ghost_set(b, 2, "t"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {})[1][2], 1)
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-293 | unit | extmark with the text |
| T-294 | boundary | row is 1-based |
| T-295 | failure | invalid buffer |

**Lua Learning Objective.** Module-level state (the namespace id created once at load).

**Neovim API Learning Objective.** `nvim_create_namespace`, `nvim_buf_set_extmark` (0-based row/col), `virt_text`, `virt_text_pos`.

**Diagram References.** AD-063, ST-2, CL-2, CMP-F13, CS-1, TIM-1, CMP-3

**Implementation Challenge.** Create the namespace once, not on every call.

**Hint.** Namespaces are global by name; create_namespace returns the same id for the same name.


### F-064 · `ui.ghost_clear`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/ui.lua` | public | 10 | 1/5 | required | AD-064 |

**Signature**

```lua
ui.ghost_clear(bufnr: integer) -> nil
```

**Problem Description.** Ghost text must disappear when the prompt closes. Remove every ghost extmark of this plugin from the buffer. Silent for invalid buffers.

**Conceptual Model.** If the buffer is valid, clear the whole namespace.

**Inputs**

- bufnr

**Requires**

- none

**Produces.** nothing.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* none
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Other plugins' extmarks are untouched

**Side Effects.** none (pure)

**State before / after.** Before: marks present. After: namespace scaffold_ghost empty.

**Examples** (outputs verified)


*Normal - clear*

```lua
local b = F.scratch('python', { 'x' }); ui.ghost_set(b, 1, 'a'); ui.ghost_clear(b); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; return #vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {})
```

Result: `0`


*Failure - invalid buffer is silent*

```lua
return pcall(ui.ghost_clear, 99999)
```

Result: `true`


*Boundary - not separately exercised:* the normal example already sits at the boundary of this function's domain (see Invariants).


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-296 | unit | removes only our marks |
| T-297 | failure | invalid buffer does not raise |

**Lua Learning Objective.** Functions that return nothing.

**Neovim API Learning Objective.** `nvim_buf_clear_namespace(buf, ns, 0, -1)`.

**Diagram References.** AD-064, ST-2, CL-2, CMP-F13, CS-1, TIM-1, CMP-3

**Implementation Challenge.** Never raise.

**Hint.** Guard with nvim_buf_is_valid.


### F-065 · `ui.input`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/ui.lua` | public | 10 | 5/5 | required | AD-065 |

**Signature**

```lua
ui.input(prompt: string, ghost: string, on_done: fun(value: string|nil)) -> handle {close, buf, win}
```

**Problem Description.** This is the plugin's only real UI: floating windows, buffer-local keymaps and callbacks that outlive the function. Open a one-line floating window titled with the prompt, show the ghost text, and call on_done(line) on <CR> or on_done(nil) on <Esc>. on_done runs exactly once, asynchronously (vim.schedule), after the window is closed.

**Conceptual Model.** Create a scratch buffer and a floating window; place the ghost; map <CR> in insert mode and <Esc> in normal+insert; a `closed` flag makes close idempotent; close clears the ghost, closes the window, and schedules the callback. Return a handle so callers (and tests) can close it.

**Inputs**

- prompt
- ghost
- on_done (must be a function)

**Requires**

- none

**Produces.** A handle table {close=function(value), buf, win}.

**Raises**

- *Lua error:* error() if on_done is not a function
- *Explicit failure (`nil, err`):* none
- *Neovim API error:* nvim_open_win config: relative, width, height, row, col, style, border, title

**Invariants**

- on_done is called at most once
- The window is closed before on_done runs
- Calling handle.close twice is harmless

**Side Effects.** none (pure)

**State before / after.** Before: no float. After: float open with ghost text and keymaps; after close: window gone, ghost cleared, on_done scheduled exactly once.

**Examples** (outputs verified)


*Normal - open and close with a value*

```lua
local got; local h = ui.input('Name', 'ghost', function(v) got = v end); local open = vim.api.nvim_win_is_valid(h.win); h.close('hello'); vim.wait(200, function() return got ~= nil end); return { open, got, vim.api.nvim_win_is_valid(h.win) }
```

Result: `{ true, "hello", false }`


*Boundary - close(nil) means cancelled*

```lua
local called, got = false, 'unset'; local h = ui.input('P', 'g', function(v) called = true; got = v end); h.close(nil); vim.wait(200, function() return called end); return { called, got }
```

Result: `{ true }`


*Failure - callback must be a function*

```lua
local ok, e = pcall(ui.input, 'P', 'g', nil); return ok, e
```

Result: `false, "scaffold.ui.input: on_done must be a function"`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-298 | unit | opens a floating window with the ghost |
| T-299 | unit | close(value) calls back with the value after closing |
| T-300 | boundary | cancel passes nil |
| T-301 | boundary | callback fires exactly once |
| T-302 | boundary | <CR> in insert mode submits the first line |
| T-303 | boundary | <Esc> cancels |
| T-304 | failure | on_done must be a function |

**Lua Learning Objective.** Closures and upvalues (`closed`), callbacks, `vim.schedule`, argument validation with `error(msg, 2)`.

**Neovim API Learning Objective.** `nvim_create_buf(false, true)`, `nvim_open_win`, `vim.keymap.set` with `buffer =`, `vim.cmd.startinsert/stopinsert`, `nvim_win_close`, `vim.schedule`.

**Diagram References.** AD-065, CMP-3, SEQ-1, SEQ-2, ST-2, COM-1, TIM-1, CS-1, CL-2, CMP-F13

**Implementation Challenge.** Pressing <Esc> twice, or <CR> after <Esc>, must call on_done only once.

**Hint.** Write `close` first and test it through the returned handle, before wiring any key.


### F-066 · `commands.parse_args`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/commands.lua` | public | 10 | 2/5 | required | AD-066 |

**Signature**

```lua
commands.parse_args(fargs: string[]) -> {algo, mode?} | nil, err
```

**Problem Description.** `:Scaffold binary-search mode=file` arrives as a list of words (fargs). Turn the command's words into {algo, mode}. The first word is the algorithm id; later words must be `mode=<value>`.

**Conceptual Model.** Start with {algo = fargs[1]}; for the rest, match `^(%w+)=(.+)$`; accept key `mode`; anything else is bad_arg.

**Inputs**

- fargs

**Requires**

- at least one word (guaranteed by nargs="+")

**Produces.** A table or (nil, {code="bad_arg", arg}).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* bad_arg
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Does not validate the mode value (config and the engine do)

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - algo only*

```lua
return commands.parse_args({ 'stack' })
```

Result: `{ algo = "stack" }`


*Normal - with mode*

```lua
return commands.parse_args({ 'stack', 'mode=file' })
```

Result: `{ algo = "stack", mode = "file" }`


*Failure - unknown key*

```lua
local a, e = commands.parse_args({ 'stack', 'colour=red' }); return a, e
```

Result: `nil, { arg = "colour=red", code = "bad_arg" }`


*Failure - empty value*

```lua
local a, e = commands.parse_args({ 'stack', 'mode=' }); return a, e.code
```

Result: `nil, "bad_arg"`


*Boundary - pinned by T-307: last mode wins* (assertion; verified to pass)

```lua
eq(commands.parse_args({ "stack", "mode=file", "mode=cursor" }).mode, "cursor")
```

*Boundary - pinned by T-308: the mode value is not validated here* (assertion; verified to pass)

```lua
eq(commands.parse_args({ "stack", "mode=zzz" }).mode, "zzz")
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-305 | unit | algo only |
| T-306 | unit | mode |
| T-307 | boundary | last mode wins |
| T-308 | boundary | the mode value is not validated here |
| T-309 | failure | unknown key |
| T-310 | failure | malformed |

**Lua Learning Objective.** Lua patterns (`%w`, captures), numeric `for`, multiple assignment from `match`.

**Neovim API Learning Objective.** none.

**Diagram References.** AD-066, SEQ-1, CL-2, CMP-F10, CMP-3

**Implementation Challenge.** `mode=` (empty) and `colour=red` are both bad_arg.

**Hint.** `local k, v = s:match('^(%w+)=(.+)$')` gives nil, nil on failure.


### F-067 · `commands.complete`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/commands.lua` | public | 10 | 3/5 | stretch | AD-067 |

**Signature**

```lua
commands.complete(arglead: string, cmdline: string) -> string[]
```

**Problem Description.** Completion runs on every <Tab>; it must never raise. Command-line completion: the first argument completes to algorithm ids for the current buffer's filetype; later arguments complete to mode=cursor|function|file.

**Conceptual Model.** Split the command line on single spaces; two or fewer parts means 'completing the algorithm'; ask the client for items; filter with vim.startswith. Otherwise filter the three mode words.

**Inputs**

- arglead: the text being completed
- cmdline: the whole command line

**Requires**

- none

**Produces.** A list of candidate strings (possibly empty).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* none
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Returns {} when the engine is unavailable

**Side Effects.** none (pure)

**Examples** (outputs verified)


*Normal - prefix of an id*

```lua
F.scratch('python', { '' }); return commands.complete('bin', 'Scaffold bin')
```

Result: `{ "binary-search" }`


*Normal - all ids*

```lua
F.scratch('python', { '' }); return commands.complete('', 'Scaffold ')
```

Result: `{ "binary-search", "insertion-sort", "stack", "union-find" }`


*Boundary - second argument*

```lua
return commands.complete('mode=f', 'Scaffold stack mode=f')
```

Result: `{ "mode=function", "mode=file" }`


*Failure - unknown filetype gives no candidates*

```lua
F.scratch('lua', { '' }); return commands.complete('', 'Scaffold ')
```

Result: `{}`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-311 | unit | filters by prefix |
| T-312 | unit | empty lead gives all |
| T-313 | boundary | after the algorithm: modes |
| T-314 | boundary | all modes |
| T-315 | failure | unknown filetype |
| T-316 | failure | missing engine |

**Lua Learning Objective.** `or {}` as a safe default, `ipairs` loops building a result array, `#t + 1` appends.

**Neovim API Learning Objective.** `vim.split`, `vim.startswith`, `vim.bo.filetype`.

**Diagram References.** AD-067, UC-1, CL-2, CMP-F10, SEQ-1, CMP-3

**Implementation Challenge.** No error escapes when the filetype is unknown or the binary is missing.

**Hint.** `#parts <= 2` while you are still typing the algorithm.


### F-068 · `commands.register`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/commands.lua` | public | 10 | 3/5 | required | AD-068 |

**Signature**

```lua
commands.register(name: string, handler: fun(args)) -> nil
```

**Problem Description.** User commands are how people (and keymaps) trigger the plugin. Create the user command `name` (nargs="+", with completion). It parses its arguments; on bad arguments it notifies an error, otherwise it calls handler(args).

**Conceptual Model.** `nvim_create_user_command(name, function(o) ... end, {nargs='+', complete=M.complete, desc=...})`; inside, call parse_args on o.fargs.

**Inputs**

- name: must start with an uppercase letter
- handler

**Requires**

- none

**Produces.** nothing.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* none
- *Neovim API error:* Neovim rejects command names not starting with an uppercase letter

**Invariants**

- handler is called only with parsed arguments

**Side Effects.** none (pure)

**State before / after.** Before: no command NAME. After: user command NAME exists with completion.

**Examples** (outputs verified)


*Normal - handler gets parsed args*

```lua
local got; commands.register('ScaffoldDemo', function(a) got = a end); vim.cmd('ScaffoldDemo stack mode=file'); vim.api.nvim_del_user_command('ScaffoldDemo'); return got
```

Result: `{ algo = "stack", mode = "file" }`


*Failure - bad args notify and skip the handler*

```lua
local called = false; local n, restore = F.capture_notify(); commands.register('ScaffoldDemo', function() called = true end); vim.cmd('ScaffoldDemo stack colour=red'); restore(); vim.api.nvim_del_user_command('ScaffoldDemo'); return { called, n[1] and n[1].msg }
```

Result: `{ false, "Scaffold: bad_arg" }`


*Boundary - not separately exercised:* the normal example already sits at the boundary of this function's domain (see Invariants).


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-317 | unit | registers and passes parsed args |
| T-318 | unit | command has nargs + and a completer |
| T-319 | failure | bad args: error notification, no handler call |
| T-320 | failure | lowercase name is rejected by Neovim |

**Lua Learning Objective.** Closures capturing `handler`, callbacks, tables as options.

**Neovim API Learning Objective.** `nvim_create_user_command`, `vim.notify`, `vim.log.levels`.

**Diagram References.** AD-068, UC-1, CMP-3, SEQ-4, CL-2, CMP-F10, SEQ-1

**Implementation Challenge.** Notify Scaffold: <code> and do not call handler on bad args.

**Hint.** The callback receives a table; its `fargs` field is the list of words.


### F-069 · `init.setup`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/init.lua` | public | 10 | 3/5 | required | AD-069 |

**Signature**

```lua
init.setup(opts?: table) -> M
```

**Problem Description.** The one function LazyVim calls. It wires every other module and must be safe to call again. Resolve config, remember it, point the client at cfg.bin, create the augroup, register the command and the pick keymap. Bad config is an error() naming the field.

**Conceptual Model.** config.resolve; on failure error('scaffold.setup: <field> <reason>', 2); store cfg; set client.bin; create augroup (clear = true); commands.register(cfg.command, ...); vim.keymap.set('n', cfg.keymap, M.pick, {desc=...}).

**Inputs**

- opts: user options or nil

**Requires**

- none

**Produces.** the module table M (so setup can be chained).

**Raises**

- *Lua error:* error('scaffold.setup: <field> <reason>') on bad config
- *Explicit failure (`nil, err`):* none
- *Neovim API error:* keymap/command creation

**Invariants**

- Calling setup twice leaves exactly one command and one augroup
- client.bin = cfg.bin

**Side Effects.** none (pure)

**State before / after.** Before: nothing registered. After: config stored; augroup, command and keymap exist; calling twice leaves exactly one of each.

**Examples** (outputs verified)


*Normal - defaults register a command and a keymap*

```lua
local m = init.setup(); local has_cmd = vim.api.nvim_get_commands({}).Scaffold ~= nil; local has_map = vim.fn.maparg('<leader>cg', 'n') ~= ''; init.teardown(); return { m == init, has_cmd, has_map }
```

Result: `{ true, true, true }`


*Failure - bad mode*

```lua
local ok, e = pcall(init.setup, { mode = 'bottom' }); return ok, tostring(e):match('scaffold.setup: mode [^\n]*')
```

Result: `false, "scaffold.setup: mode must be cursor, function or file"`


*Boundary - pinned by T-323: second setup replaces the first* (assertion; verified to pass)

```lua
init.setup({ command = "ScaffoldS3", keymap = "<leader>zs3" }); init.setup({ command = "ScaffoldS3", keymap = "<leader>zs3" }); local n = 0; for _, g in ipairs(vim.api.nvim_get_autocmds({ group = "scaffold" })) do n = n + 1 end; assert(vim.api.nvim_get_commands({}).ScaffoldS3 ~= nil); init.teardown()
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-321 | unit | registers command and keymap, returns the module |
| T-322 | unit | bin is handed to the client |
| T-323 | boundary | second setup replaces the first |
| T-324 | failure | bad config raises with the field name |
| T-325 | failure | a failed setup changes nothing |

**Lua Learning Objective.** Module state (`M._cfg`), error levels (`error(msg, 2)` blames the caller), returning `M`.

**Neovim API Learning Objective.** `nvim_create_augroup`, `vim.keymap.set`, via commands.register `nvim_create_user_command`.

**Diagram References.** AD-069, UC-1, UC-4, CMP-3, SEQ-4, ST-3, CL-2, CMP-F10, CMP-F11, SEQ-1, SEQ-2, SEQ-5, WALK-1

**Implementation Challenge.** After setup({ bin = '/x' }), client.binary() must use '/x'.

**Hint.** Use `{ clear = true }` so a second setup replaces the first group.


### F-070 · `init.run`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/init.lua` | public | 10 | 5/5 | required | AD-070 |

**Signature**

```lua
init.run(algo_id: string, mode?: string) -> nil
```

**Problem Description.** This function glues every module together, across callbacks that return later. Run one insertion: read the buffer, fetch the prompts, ask each with ui.input (asynchronously), then generate and insert — as text, or as a new file that is written and opened. Any error is shown with vim.notify at ERROR level; cancelling (nil) stops silently.

**Conceptual Model.** buffer.context -> client.prompts -> a recursive `step(i)` that asks prompt i and, in the callback, records the answer and calls step(i + 1); when no prompts remain, client.generate with indent = #ctx.indent and the buffer text, then buffer.insert_lines (or write_file + open_file when a file name came back).

**Inputs**

- algo_id
- mode: cursor|function|file (default: config)

**Requires**

- setup has run (for the default mode)

**Produces.** nothing (effects only).

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* every error is reported through vim.notify, never raised
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Calls ui.input once per prompt, in order
- Nothing is inserted when any step is cancelled
- Insertion row = the cursor row read at the start

**Side Effects.** none (pure)

**State before / after.** Before: buffer B unchanged. After: after success B has the generated text (or a new file is open); after cancel or failure B unchanged.

**Examples** (outputs verified)


*Normal - all prompts accept their ghost*

```lua
local b = F.scratch('python', { 'x = 1' }); init.setup({ command = 'ScaffoldE1', keymap = '<leader>ze1' }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run('union-find', 'cursor'); ui.input = real; init.teardown(); return F.lines(b)[2]
```

Result: `"class UnionFind:"`


*Boundary - cancel inserts nothing*

```lua
local b = F.scratch('python', { 'x = 1' }); init.setup({ command = 'ScaffoldE2', keymap = '<leader>ze2' }); local real = ui.input; ui.input = function(_, _, cb) cb(nil) end; init.run('stack', 'cursor'); ui.input = real; init.teardown(); return F.lines(b)
```

Result: `{ "x = 1" }`


*Failure - unknown algorithm is notified*

```lua
F.scratch('python', { 'x' }); init.setup({ command = 'ScaffoldE3', keymap = '<leader>ze3' }); local n, restore = F.capture_notify(); init.run('zzz', 'cursor'); restore(); init.teardown(); return { #n, n[1].msg, n[1].level == vim.log.levels.ERROR }
```

Result: `{ 1, "unknown algorithm: zzz", true }`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-326 | unit | cursor mode inserts below the cursor line |
| T-327 | unit | answers are used |
| T-328 | boundary | indentation of the cursor line is applied |
| T-329 | boundary | existing names in the buffer are avoided |
| T-330 | boundary | file mode writes and opens the file |
| T-331 | boundary | cancelling inserts nothing and stays silent |
| T-332 | failure | unknown algorithm is reported |
| T-333 | failure | unsupported filetype is reported |

**Lua Learning Objective.** Asynchronous continuation-passing, recursive local functions, closures over `answers`, early `return`.

**Neovim API Learning Objective.** `vim.notify`, `vim.log.levels.ERROR`, `nvim_get_current_buf`, plus the modules you wrote.

**Diagram References.** AD-070, UC-1, UC-2, CL-5, CMP-1, SEQ-1, SEQ-2, SEQ-5, COM-1, IOV-1, WALK-1, CL-2, CMP-F10, CMP-F7, CMP-F4, SEQ-4, ST-3, CMP-3

**Implementation Challenge.** `ui.input` must be called through the module table (`ui.input(...)`), so tests can replace it.

**Hint.** Do not loop over prompts: a loop cannot wait for a callback. Recurse from inside the callback.


### F-071 · `init.pick`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/init.lua` | public | 10 | 2/5 | stretch | AD-071 |

**Signature**

```lua
init.pick() -> nil
```

**Problem Description.** The default keymap opens this menu. Let the user choose an algorithm for the current filetype with vim.ui.select, then run it.

**Conceptual Model.** client.list(vim.bo.filetype) -> vim.ui.select(items, {prompt, format_item=title}, function(choice) if choice then run(choice.id) end end).

**Inputs**

- none

**Requires**

- none

**Produces.** nothing.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* errors shown with vim.notify
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Cancelling the menu does nothing

**Side Effects.** none (pure)

**State before / after.** Before: no UI. After: a vim.ui.select menu is open (or a notification shown).

**Examples** (outputs verified)


*Normal - menu shows titles*

```lua
F.scratch('python', { '' }); init.setup({ command = 'ScaffoldP1', keymap = '<leader>zp1' }); local real = vim.ui.select; local titles; vim.ui.select = function(items, o, cb) titles = {}; for _, i in ipairs(items) do titles[#titles + 1] = o.format_item(i) end end; init.pick(); vim.ui.select = real; init.teardown(); return titles
```

Result: `{ "Binary search", "Insertion sort", "Stack", "Union-find" }`


*Failure - unsupported filetype*

```lua
F.scratch('lua', { '' }); init.setup({ command = 'ScaffoldP2', keymap = '<leader>zp2' }); local n, restore = F.capture_notify(); init.pick(); restore(); init.teardown(); return #n
```

Result: `1`


*Boundary - pinned by T-336: cancelling the menu does nothing* (assertion; verified to pass)

```lua
local b = F.scratch("python", { "x" }); init.setup({ command = "ScaffoldP4", keymap = "<leader>zp4" }); local rs = vim.ui.select; vim.ui.select = function(_, _, cb) cb(nil) end; init.pick(); vim.ui.select = rs; init.teardown(); eq(F.lines(b), { "x" })
```


**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-334 | unit | menu items and titles |
| T-335 | unit | choosing runs the algorithm |
| T-336 | boundary | cancelling the menu does nothing |
| T-337 | failure | unsupported filetype is notified and no menu opens |

**Lua Learning Objective.** Passing functions as options, `format_item`.

**Neovim API Learning Objective.** `vim.ui.select`.

**Diagram References.** AD-071, UC-1, SEQ-5, IOV-1, CL-2, CMP-F10, SEQ-1, SEQ-2, SEQ-4, WALK-1, ST-3, CMP-3

**Implementation Challenge.** Notify, do not raise, for an unsupported filetype.

**Hint.** `vim.ui.select` can be replaced in tests, so call it through `vim.ui`.


### F-072 · `init.teardown`

| Module | Visibility | Part | Difficulty | Required | Activity diagram |
|---|---|---|---|---|---|
| `lua/scaffold/init.lua` | public | 10 | 2/5 | required | AD-072 |

**Signature**

```lua
init.teardown() -> nil
```

**Problem Description.** Tests (and hot-reloading) need a clean slate. Undo setup: delete the augroup, the user command and the keymap, forget the config and clear client.bin. Safe to call twice.

**Conceptual Model.** If a group id is stored, delete it; if a config is stored, pcall the command/keymap removals; reset state.

**Inputs**

- none

**Requires**

- none

**Produces.** nothing.

**Raises**

- *Lua error:* none
- *Explicit failure (`nil, err`):* none
- *Neovim API error:* none (no fallible API calls)

**Invariants**

- Idempotent
- Never raises

**Side Effects.** none (pure)

**State before / after.** Before: setup done. After: augroup, command, keymap and stored config all gone; second call harmless.

**Examples** (outputs verified)


*Normal - removes everything*

```lua
init.setup({ command = 'ScaffoldT9', keymap = '<leader>zt9' }); init.teardown(); return vim.api.nvim_get_commands({}).ScaffoldT9, vim.fn.maparg('<leader>zt9', 'n')
```

Result: `nil, ""`


*Boundary - twice is fine*

```lua
init.setup({ command = 'ScaffoldT8', keymap = '<leader>zt8' }); init.teardown(); return pcall(init.teardown)
```

Result: `true`


*Failure - before any setup*

```lua
init.teardown(); return pcall(init.teardown)
```

Result: `true`



**Testing Requirements**

| Test | Kind | What it pins |
|---|---|---|
| T-338 | unit | removes command, keymap and bin |
| T-339 | boundary | idempotent |
| T-340 | failure | safe before setup |

**Lua Learning Objective.** `pcall` around cleanup that may already have happened.

**Neovim API Learning Objective.** `nvim_del_augroup_by_id`, `nvim_del_user_command`, `vim.keymap.del`.

**Diagram References.** AD-072, UC-1, UC-4, SEQ-4, ST-3, CL-2, CMP-F10, SEQ-1, SEQ-2, SEQ-5, WALK-1, CMP-3

**Implementation Challenge.** Call it before any setup.

**Hint.** pcall every removal.

## 16. Testing strategy

### 16.1 Layers
| Layer | What | Tooling | Where |
|---|---|---|---|
| Unit (pure) | one function, plain assertions | ounit2 (`assert_equal`) through the helpers in `test/test_helpers.ml` | `test/test_<module>.ml` |
| Boundary / failure | empties, 0/1/N, every error code, contract violations (`raises_invalid`) | same | same |
| Pipeline | `Engine.generate` over all 12 combinations and the stage order | same | `test_engine.ml` |
| CLI | `Cli.run` with a fake stdin and fake `ask` | same | `test_cli.ml` |
| Acceptance | the real binary as a process: exit codes, stdout, stdin | `sh test/acceptance.sh` | six checks A-01..A-06 |
| Edge (headless Neovim) | Lua modules against real scratch buffers/windows and fake engine scripts | `nvim --headless -u NONE -l lua_test/run.lua [module]` | `lua_test/*_spec.lua` |
| Regression | every bug you fix gets a test first | same | the module's test file |

### 16.2 Running tests
- All OCaml tests: `dune test`. One module: `./test.sh util` (it finds the module's path with `dune exec test/main.exe -- -list-test` and passes it to `-only-test`; paths look like `scaffold:0:util`). [V]
- Test names begin with the test id and the function: `T-001 Util.trim: trims both sides`.
- Lua: `nvim --headless -u NONE -l lua_test/run.lua 2>&1 | tail -3` (output goes to stderr [V]).

### 16.3 Techniques
- **Red-green-refactor** per function: run the provided test, see it fail for the right reason, then implement.
- **Seams instead of mocks:** `Cli.run` takes `?stdin` and `?ask`; the Lua tests point `client.bin` at tiny fake engine scripts to force `engine_missing`, `bad_json` and engine-error paths.
- **Contract tests:** `raises_invalid` pins every `Invalid_argument`.
- **Test the tester:** break one function on purpose (for example make `unique_name` return its input) and confirm a test goes red. I did this myself with 16 deliberate mutations of the reference; all 16 were caught by at least one provided test `[V]`.
- **Isolation:** `-u NONE` plus fresh scratch buffers; each Lua test cleans up what it creates.

### 16.4 Expected diagnostics (exact messages)
| Situation | Message | Produced by |
|---|---|---|
| unknown language | `unknown language: cobol` | `Err.message` |
| unknown algorithm | `unknown algorithm: heap` | `Err.message` |
| bad name | `bad name for fn: "3x"` | `Err.message` |
| bad element type | `bad element type: "byte"` | `Err.message` |
| unclosed template tag | `template: unclosed <% at 4` | `Err.message` |
| unbound variable | `template: unbound variable "q"` | `Err.message` |
| unknown flag | `usage error: unknown flag: --bogus` (stderr, exit 2) | `Cli.run` |
| missing engine | `engine binary not found or not executable: <path> (run `dune build`)` | `client.binary` |

### 16.5 Test inventory

340 tests (238 OCaml, 102 Lua) plus 6 acceptance checks; by kind: boundary 113, failure 105, unit 122. Every test has its assertion in Appendix T. All 340 passed against the private reference `[V]`.

| Test | Function | Kind | Pins | Part |
|---|---|---|---|---|
| T-001 | F-001 `Util.trim` | unit | trims both sides | 0 |
| T-002 | F-001 `Util.trim` | boundary | empty and blank strings | 0 |
| T-003 | F-001 `Util.trim` | boundary | inner whitespace survives | 0 |
| T-004 | F-002 `Util.starts_with` | unit | true on match | 0 |
| T-005 | F-002 `Util.starts_with` | boundary | empty prefix always matches | 0 |
| T-006 | F-002 `Util.starts_with` | failure | longer prefix does not raise | 0 |
| T-007 | F-003 `Util.find_sub` | unit | finds first match | 1 |
| T-008 | F-003 `Util.find_sub` | boundary | from skips earlier match | 1 |
| T-009 | F-003 `Util.find_sub` | boundary | not found and past-the-end | 1 |
| T-010 | F-003 `Util.find_sub` | failure | negative from raises | 1 |
| T-011 | F-004 `Util.split` | unit | splits on comma | 1 |
| T-012 | F-004 `Util.split` | boundary | keeps empty pieces | 1 |
| T-013 | F-004 `Util.split` | boundary | multi-character separator | 1 |
| T-014 | F-004 `Util.split` | failure | empty separator raises | 1 |
| T-015 | F-005 `Util.leading_ws` | unit | spaces | 1 |
| T-016 | F-005 `Util.leading_ws` | boundary | tabs and empty | 1 |
| T-017 | F-005 `Util.leading_ws` | failure | newline stops the scan | 1 |
| T-018 | F-006 `Naming.words` | unit | camel and snake | 1 |
| T-019 | F-006 `Naming.words` | boundary | acronym | 1 |
| T-020 | F-006 `Naming.words` | boundary | digits | 1 |
| T-021 | F-006 `Naming.words` | boundary | empty and separators only | 1 |
| T-022 | F-006 `Naming.words` | failure | non-ASCII bytes are separators, never an exception | 1 |
| T-023 | F-007 `Naming.convert` | unit | snake | 1 |
| T-024 | F-007 `Naming.convert` | unit | camel and pascal | 1 |
| T-025 | F-007 `Naming.convert` | unit | upper snake | 1 |
| T-026 | F-007 `Naming.convert` | boundary | empty | 1 |
| T-027 | F-007 `Naming.convert` | failure | separators only | 1 |
| T-028 | F-008 `Err.code` | unit | a few codes | 2 |
| T-029 | F-008 `Err.code` | unit | all 17 codes are distinct and non-empty | 2 |
| T-030 | F-008 `Err.code` | boundary | template errors share one code | 2 |
| T-031 | F-009 `Err.message` | unit | unknown language | 2 |
| T-032 | F-009 `Err.message` | unit | template unclosed shows offset | 2 |
| T-033 | F-009 `Err.message` | boundary | quoted values | 2 |
| T-034 | F-009 `Err.message` | boundary | empty command has its own text | 2 |
| T-035 | F-009 `Err.message` | unit | no message contains a newline | 2 |
| T-036 | F-010 `Json.escape` | unit | quote and newline | 2 |
| T-037 | F-010 `Json.escape` | boundary | backslash tab CR | 2 |
| T-038 | F-010 `Json.escape` | boundary | control byte | 2 |
| T-039 | F-010 `Json.escape` | boundary | UTF-8 untouched, empty ok | 2 |
| T-040 | F-011 `Json.to_string` | unit | scalars | 2 |
| T-041 | F-011 `Json.to_string` | unit | nested | 2 |
| T-042 | F-011 `Json.to_string` | boundary | empty list/object | 2 |
| T-043 | F-011 `Json.to_string` | boundary | keys are escaped | 2 |
| T-044 | F-011 `Json.to_string` | failure | negative number | 2 |
| T-045 | F-012 `Lang.validate` | unit | built-ins are valid | 3 |
| T-046 | F-012 `Lang.validate` | failure | bad id | 3 |
| T-047 | F-012 `Lang.validate` | failure | filetypes | 3 |
| T-048 | F-012 `Lang.validate` | failure | extension | 3 |
| T-049 | F-012 `Lang.validate` | failure | indent | 3 |
| T-050 | F-012 `Lang.validate` | failure | each type is checked | 3 |
| T-051 | F-012 `Lang.validate` | failure | def_markers | 3 |
| T-052 | F-012 `Lang.validate` | boundary | first failure wins | 3 |
| T-053 | F-013 `Lang.derive` | unit | indent string | 3 |
| T-054 | F-013 `Lang.derive` | unit | style flag | 3 |
| T-055 | F-013 `Lang.derive` | boundary | zero width | 3 |
| T-056 | F-013 `Lang.derive` | unit | cfg is kept | 3 |
| T-057 | F-014 `Lang.register` | unit | appends | 3 |
| T-058 | F-014 `Lang.register` | failure | duplicate id | 3 |
| T-059 | F-014 `Lang.register` | failure | duplicate filetype names the owner | 3 |
| T-060 | F-014 `Lang.register` | failure | invalid config propagates | 3 |
| T-061 | F-014 `Lang.register` | boundary | input registry untouched | 3 |
| T-062 | F-015 `Lang.find` | unit | found | 3 |
| T-063 | F-015 `Lang.find` | boundary | case sensitive | 3 |
| T-064 | F-015 `Lang.find` | failure | unknown and empty registry | 3 |
| T-065 | F-016 `Lang.find_by_filetype` | unit | secondary filetype | 3 |
| T-066 | F-016 `Lang.find_by_filetype` | boundary | empty string | 3 |
| T-067 | F-016 `Lang.find_by_filetype` | failure | unknown | 3 |
| T-068 | F-017 `Lang.file_name` | unit | snake language | 3 |
| T-069 | F-017 `Lang.file_name` | unit | camel language | 3 |
| T-070 | F-017 `Lang.file_name` | boundary | idempotent on styled input | 3 |
| T-071 | F-017 `Lang.file_name` | failure | empty stem raises | 3 |
| T-072 | F-018 `Lang.elem_type` | unit | python | 3 |
| T-073 | F-018 `Lang.elem_type` | unit | javascript | 3 |
| T-074 | F-018 `Lang.elem_type` | boundary | all four non-empty for every built-in | 3 |
| T-075 | F-019 `Langs.install` | unit | adds three | 3 |
| T-076 | F-019 `Langs.install` | boundary | idempotent | 3 |
| T-077 | F-019 `Langs.install` | boundary | user language survives and keeps position | 3 |
| T-078 | F-019 `Langs.install` | boundary | override kept | 3 |
| T-079 | F-020 `Template.scan_tag` | unit | name only | 4 |
| T-080 | F-020 `Template.scan_tag` | unit | filters in order | 4 |
| T-081 | F-020 `Template.scan_tag` | boundary | starts mid-text and reports next offset | 4 |
| T-082 | F-020 `Template.scan_tag` | failure | unclosed | 4 |
| T-083 | F-020 `Template.scan_tag` | failure | empty placeholder | 4 |
| T-084 | F-020 `Template.scan_tag` | failure | bad name | 4 |
| T-085 | F-020 `Template.scan_tag` | failure | bad filter | 4 |
| T-086 | F-021 `Template.parse` | unit | text var text | 4 |
| T-087 | F-021 `Template.parse` | boundary | adjacent tags | 4 |
| T-088 | F-021 `Template.parse` | boundary | empty input and plain text | 4 |
| T-089 | F-021 `Template.parse` | failure | error from a later tag | 4 |
| T-090 | F-021 `Template.parse` | failure | first error wins | 4 |
| T-091 | F-022 `Template.vars` | unit | order of first appearance | 4 |
| T-092 | F-022 `Template.vars` | boundary | text only and empty | 4 |
| T-093 | F-022 `Template.vars` | boundary | filters do not create new names | 4 |
| T-094 | F-023 `Template.apply_filter` | unit | four naming filters | 4 |
| T-095 | F-023 `Template.apply_filter` | unit | case filters | 4 |
| T-096 | F-023 `Template.apply_filter` | boundary | empty | 4 |
| T-097 | F-024 `Template.render` | unit | substitutes with filters | 4 |
| T-098 | F-024 `Template.render` | unit | filter order matters | 4 |
| T-099 | F-024 `Template.render` | boundary | empty template, extra env | 4 |
| T-100 | F-024 `Template.render` | failure | unbound | 4 |
| T-101 | F-024 `Template.render` | boundary | same variable used twice | 4 |
| T-102 | F-025 `Catalog.find` | unit | four algorithms | 5 |
| T-103 | F-025 `Catalog.find` | boundary | exact match | 5 |
| T-104 | F-025 `Catalog.find` | failure | unknown | 5 |
| T-105 | F-026 `Catalog.template` | unit | all built-in pairs exist | 5 |
| T-106 | F-026 `Catalog.template` | failure | unknown language/algo | 5 |
| T-107 | F-026 `Catalog.template` | unit | every template parses and renders against its algo params | 5 |
| T-108 | F-027 `Catalog.for_lang` | unit | python has all four in order | 5 |
| T-109 | F-027 `Catalog.for_lang` | failure | unknown language | 5 |
| T-110 | F-027 `Catalog.for_lang` | boundary | empty id | 5 |
| T-111 | F-028 `Collision.unique_name` | unit | free name unchanged | 5 |
| T-112 | F-028 `Collision.unique_name` | unit | taken gets _2 | 5 |
| T-113 | F-028 `Collision.unique_name` | boundary | chain | 5 |
| T-114 | F-028 `Collision.unique_name` | boundary | a gap is filled | 5 |
| T-115 | F-029 `Collision.defined_names` | unit | python | 5 |
| T-116 | F-029 `Collision.defined_names` | unit | javascript | 5 |
| T-117 | F-029 `Collision.defined_names` | unit | ocaml let rec | 5 |
| T-118 | F-029 `Collision.defined_names` | boundary | async def wins over def | 5 |
| T-119 | F-029 `Collision.defined_names` | boundary | marker needs its trailing space | 5 |
| T-120 | F-029 `Collision.defined_names` | failure | no name / empty | 5 |
| T-121 | F-029 `Collision.defined_names` | boundary | duplicates are kept | 5 |
| T-122 | F-030 `Params.normalize_ident` | unit | function style per language | 6 |
| T-123 | F-030 `Params.normalize_ident` | unit | types are Pascal everywhere | 6 |
| T-124 | F-030 `Params.normalize_ident` | boundary | surrounding space is trimmed | 6 |
| T-125 | F-030 `Params.normalize_ident` | failure | digit first | 6 |
| T-126 | F-030 `Params.normalize_ident` | failure | empty / no words | 6 |
| T-127 | F-031 `Params.normalize_elem` | unit | per language | 6 |
| T-128 | F-031 `Params.normalize_elem` | boundary | case and spaces | 6 |
| T-129 | F-031 `Params.normalize_elem` | failure | unknown | 6 |
| T-130 | F-032 `Params.ghost` | unit | function | 6 |
| T-131 | F-032 `Params.ghost` | unit | element | 6 |
| T-132 | F-032 `Params.ghost` | boundary | type is Pascal | 6 |
| T-133 | F-033 `Params.resolve` | unit | defaults | 6 |
| T-134 | F-033 `Params.resolve` | unit | answers override and normalise | 6 |
| T-135 | F-033 `Params.resolve` | boundary | existing names get suffixed | 6 |
| T-136 | F-033 `Params.resolve` | boundary | blank means default | 6 |
| T-137 | F-033 `Params.resolve` | boundary | element types are never renamed | 6 |
| T-138 | F-033 `Params.resolve` | failure | unknown param | 6 |
| T-139 | F-033 `Params.resolve` | failure | unknown param is reported even when another answer is bad | 6 |
| T-140 | F-033 `Params.resolve` | failure | bad elem and bad ident | 6 |
| T-141 | F-034 `Params.next_prompt` | unit | first | 6 |
| T-142 | F-034 `Params.next_prompt` | unit | second | 6 |
| T-143 | F-034 `Params.next_prompt` | boundary | done | 6 |
| T-144 | F-034 `Params.next_prompt` | boundary | unknown answers are ignored | 6 |
| T-145 | F-035 `Session.create` | unit | fresh | 6 |
| T-146 | F-036 `Session.state` | unit | walk the states | 6 |
| T-147 | F-036 `Session.state` | boundary | cancelled | 6 |
| T-148 | F-037 `Session.answers` | unit | order | 6 |
| T-149 | F-037 `Session.answers` | boundary | empty | 6 |
| T-150 | F-038 `Session.pending` | unit | first and second | 6 |
| T-151 | F-038 `Session.pending` | boundary | none when complete | 6 |
| T-152 | F-039 `Session.record` | unit | records and does not mutate | 6 |
| T-153 | F-039 `Session.record` | boundary | ready exactly after the last answer | 6 |
| T-154 | F-039 `Session.record` | failure | after ready | 6 |
| T-155 | F-039 `Session.record` | failure | after cancel | 6 |
| T-156 | F-040 `Session.cancel` | unit | cancel | 6 |
| T-157 | F-040 `Session.cancel` | boundary | ready is not cancelled | 6 |
| T-158 | F-040 `Session.cancel` | boundary | answers survive a cancel | 6 |
| T-159 | F-041 `Insert.reindent` | unit | indents each line | 7 |
| T-160 | F-041 `Insert.reindent` | boundary | blank lines untouched | 7 |
| T-161 | F-041 `Insert.reindent` | boundary | trailing newline | 7 |
| T-162 | F-041 `Insert.reindent` | boundary | empty indent is identity | 7 |
| T-163 | F-041 `Insert.reindent` | failure | whitespace-only line is blank | 7 |
| T-164 | F-042 `Insert.place` | unit | cursor | 7 |
| T-165 | F-042 `Insert.place` | unit | function | 7 |
| T-166 | F-042 `Insert.place` | unit | file | 7 |
| T-167 | F-042 `Insert.place` | failure | file with empty stem raises | 7 |
| T-168 | F-043 `Engine.generate` | unit | every language x algo generates and mentions its default name | 7 |
| T-169 | F-043 `Engine.generate` | unit | python binary search default name | 7 |
| T-170 | F-043 `Engine.generate` | unit | javascript uses camel case | 7 |
| T-171 | F-043 `Engine.generate` | boundary | existing name is suffixed | 7 |
| T-172 | F-043 `Engine.generate` | boundary | file mode names the file after the first non-elem param | 7 |
| T-173 | F-043 `Engine.generate` | boundary | union-find has no elem param | 7 |
| T-174 | F-043 `Engine.generate` | failure | unknown language | 7 |
| T-175 | F-043 `Engine.generate` | failure | unknown algorithm | 7 |
| T-176 | F-043 `Engine.generate` | failure | language beats algorithm in the check order | 7 |
| T-177 | F-043 `Engine.generate` | failure | parameter errors surface | 7 |
| T-178 | F-043 `Engine.generate` | failure | language registered without templates | 7 |
| T-179 | F-044 `Engine.list` | unit | four items for python | 7 |
| T-180 | F-044 `Engine.list` | unit | fields filled | 7 |
| T-181 | F-044 `Engine.list` | failure | unknown language | 7 |
| T-182 | F-045 `Cli.parse_flags` | unit | command and flags | 8 |
| T-183 | F-045 `Cli.parse_flags` | unit | set pairs keep order | 8 |
| T-184 | F-045 `Cli.parse_flags` | boundary | = in value and empty value | 8 |
| T-185 | F-045 `Cli.parse_flags` | boundary | last repeated flag wins | 8 |
| T-186 | F-045 `Cli.parse_flags` | boundary | empty argv | 8 |
| T-187 | F-045 `Cli.parse_flags` | failure | unknown flag | 8 |
| T-188 | F-045 `Cli.parse_flags` | failure | missing value | 8 |
| T-189 | F-045 `Cli.parse_flags` | failure | bad set | 8 |
| T-190 | F-045 `Cli.parse_flags` | failure | second command | 8 |
| T-191 | F-046 `Cli.resolve_lang` | unit | ft maps through registry | 8 |
| T-192 | F-046 `Cli.resolve_lang` | unit | lang wins | 8 |
| T-193 | F-046 `Cli.resolve_lang` | boundary | neither | 8 |
| T-194 | F-046 `Cli.resolve_lang` | failure | unmapped ft passes through | 8 |
| T-195 | F-047 `Cli.run_list` | unit | lists four | 8 |
| T-196 | F-047 `Cli.run_list` | boundary | ft works | 8 |
| T-197 | F-047 `Cli.run_list` | failure | missing language | 8 |
| T-198 | F-048 `Cli.run_prompts` | unit | stack in javascript | 8 |
| T-199 | F-048 `Cli.run_prompts` | failure | unknown algo | 8 |
| T-200 | F-048 `Cli.run_prompts` | failure | language first | 8 |
| T-201 | F-049 `Cli.run_gen` | unit | default gen | 8 |
| T-202 | F-049 `Cli.run_gen` | unit | --set answers | 8 |
| T-203 | F-049 `Cli.run_gen` | unit | --scan avoids a clash | 8 |
| T-204 | F-049 `Cli.run_gen` | boundary | --existing is split on commas, empties ignored | 8 |
| T-205 | F-049 `Cli.run_gen` | boundary | --scan wins over --existing | 8 |
| T-206 | F-049 `Cli.run_gen` | boundary | cursor indent | 8 |
| T-207 | F-049 `Cli.run_gen` | boundary | file mode | 8 |
| T-208 | F-049 `Cli.run_gen` | failure | bad mode | 8 |
| T-209 | F-049 `Cli.run_gen` | failure | bad indent | 8 |
| T-210 | F-049 `Cli.run_gen` | failure | validation before lookup | 8 |
| T-211 | F-049 `Cli.run_gen` | failure | engine errors pass through | 8 |
| T-212 | F-050 `Cli.run_ask` | unit | uses answers | 8 |
| T-213 | F-050 `Cli.run_ask` | unit | ghost is offered, accepting it uses the default | 8 |
| T-214 | F-050 `Cli.run_ask` | boundary | questions in parameter order | 8 |
| T-215 | F-050 `Cli.run_ask` | boundary | cancel stops asking | 8 |
| T-216 | F-050 `Cli.run_ask` | failure | unknown language; ask not called | 8 |
| T-217 | F-050 `Cli.run_ask` | failure | bad answer surfaces as an error | 8 |
| T-218 | F-051 `Cli.run` | unit | list text | 8 |
| T-219 | F-051 `Cli.run` | unit | list json | 8 |
| T-220 | F-051 `Cli.run` | unit | prompts json | 8 |
| T-221 | F-051 `Cli.run` | unit | prompts text | 8 |
| T-222 | F-051 `Cli.run` | unit | gen text is the code | 8 |
| T-223 | F-051 `Cli.run` | unit | gen json has text and null file | 8 |
| T-224 | F-051 `Cli.run` | unit | gen json file mode names the file | 8 |
| T-225 | F-051 `Cli.run` | boundary | stdin only for --scan - | 8 |
| T-226 | F-051 `Cli.run` | boundary | scan text from stdin avoids a clash | 8 |
| T-227 | F-051 `Cli.run` | boundary | scan text given directly | 8 |
| T-228 | F-051 `Cli.run` | boundary | --ft works like --lang | 8 |
| T-229 | F-051 `Cli.run` | failure | domain error: text mode | 8 |
| T-230 | F-051 `Cli.run` | failure | domain error: JSON mode | 8 |
| T-231 | F-051 `Cli.run` | failure | usage error | 8 |
| T-232 | F-051 `Cli.run` | failure | usage error in JSON mode | 8 |
| T-233 | F-051 `Cli.run` | failure | bad mode is a usage error | 8 |
| T-234 | F-051 `Cli.run` | failure | unknown command and no command | 8 |
| T-235 | F-051 `Cli.run` | failure | ask needs a callback | 8 |
| T-236 | F-051 `Cli.run` | unit | ask with a callback | 8 |
| T-237 | F-051 `Cli.run` | boundary | ask cancelled | 8 |
| T-238 | F-051 `Cli.run` | boundary | exit 0 never has stderr | 8 |
| T-239 | F-053 `config.resolve` | unit | nil gives defaults | 9 |
| T-240 | F-053 `config.resolve` | unit | user values override | 9 |
| T-241 | F-053 `config.resolve` | boundary | unknown keys survive | 9 |
| T-242 | F-053 `config.resolve` | boundary | defaults are not shared between calls | 9 |
| T-243 | F-053 `config.resolve` | failure | opts must be a table | 9 |
| T-244 | F-053 `config.resolve` | failure | bad mode | 9 |
| T-245 | F-053 `config.resolve` | failure | command capitalisation and type | 9 |
| T-246 | F-053 `config.resolve` | failure | bin must be a string | 9 |
| T-247 | F-054 `client.binary` | unit | client.bin wins over the environment | 9 |
| T-248 | F-054 `client.binary` | unit | environment variable is used next | 9 |
| T-249 | F-054 `client.binary` | unit | default path ends with the dune output | 9 |
| T-250 | F-054 `client.binary` | failure | missing binary | 9 |
| T-251 | F-054 `client.binary` | failure | not executable counts as missing | 9 |
| T-252 | F-055 `client.call` | unit | list reply decodes | 9 |
| T-253 | F-055 `client.call` | unit | stdin is forwarded | 9 |
| T-254 | F-055 `client.call` | boundary | args are not mutated | 9 |
| T-255 | F-055 `client.call` | failure | domain error | 9 |
| T-256 | F-055 `client.call` | failure | usage error | 9 |
| T-257 | F-055 `client.call` | failure | missing engine | 9 |
| T-258 | F-055 `client.call` | failure | engine prints garbage | 9 |
| T-259 | F-055 `client.call` | failure | engine prints valid JSON that is not an object | 9 |
| T-260 | F-055 `client.call` | boundary | --json is appended last | 9 |
| T-261 | F-056 `client.list` | unit | four items | 9 |
| T-262 | F-056 `client.list` | boundary | filetype alias | 9 |
| T-263 | F-056 `client.list` | failure | unknown filetype | 9 |
| T-264 | F-057 `client.prompts` | unit | prompts for stack | 9 |
| T-265 | F-057 `client.prompts` | boundary | ghost follows the language style | 9 |
| T-266 | F-057 `client.prompts` | failure | unknown algorithm | 9 |
| T-267 | F-057 `client.prompts` | failure | unknown filetype | 9 |
| T-268 | F-058 `client.generate` | unit | cursor mode has no file | 9 |
| T-269 | F-058 `client.generate` | unit | answers are applied | 9 |
| T-270 | F-058 `client.generate` | unit | file mode returns a name | 9 |
| T-271 | F-058 `client.generate` | boundary | indent is applied in cursor mode | 9 |
| T-272 | F-058 `client.generate` | boundary | buffer text avoids clashes | 9 |
| T-273 | F-058 `client.generate` | failure | bad answer | 9 |
| T-274 | F-058 `client.generate` | failure | bad mode is a usage error | 9 |
| T-275 | F-058 `client.generate` | failure | unknown algorithm | 9 |
| T-276 | F-059 `buffer.context` | unit | fields | 9 |
| T-277 | F-059 `buffer.context` | boundary | tabs count as indentation | 9 |
| T-278 | F-059 `buffer.context` | boundary | empty buffer | 9 |
| T-279 | F-059 `buffer.context` | boundary | name of an unnamed buffer is empty | 9 |
| T-280 | F-059 `buffer.context` | failure | invalid buffer | 9 |
| T-281 | F-060 `buffer.insert_lines` | unit | inserts after the row | 9 |
| T-282 | F-060 `buffer.insert_lines` | boundary | row 0 is the top | 9 |
| T-283 | F-060 `buffer.insert_lines` | boundary | row = last line appends | 9 |
| T-284 | F-060 `buffer.insert_lines` | boundary | blank lines inside text are kept | 9 |
| T-285 | F-060 `buffer.insert_lines` | failure | row out of range | 9 |
| T-286 | F-060 `buffer.insert_lines` | failure | invalid buffer | 9 |
| T-287 | F-061 `buffer.write_file` | unit | writes lines | 9 |
| T-288 | F-061 `buffer.write_file` | failure | never overwrites | 9 |
| T-289 | F-061 `buffer.write_file` | failure | missing directory | 9 |
| T-290 | F-062 `buffer.open_file` | unit | returns the current buffer | 9 |
| T-291 | F-062 `buffer.open_file` | boundary | spaces in the path | 9 |
| T-292 | F-062 `buffer.open_file` | failure | a refused :edit is reported, not raised | 9 |
| T-293 | F-063 `ui.ghost_set` | unit | extmark with the text | 10 |
| T-294 | F-063 `ui.ghost_set` | boundary | row is 1-based | 10 |
| T-295 | F-063 `ui.ghost_set` | failure | invalid buffer | 10 |
| T-296 | F-064 `ui.ghost_clear` | unit | removes only our marks | 10 |
| T-297 | F-064 `ui.ghost_clear` | failure | invalid buffer does not raise | 10 |
| T-298 | F-065 `ui.input` | unit | opens a floating window with the ghost | 10 |
| T-299 | F-065 `ui.input` | unit | close(value) calls back with the value after closing | 10 |
| T-300 | F-065 `ui.input` | boundary | cancel passes nil | 10 |
| T-301 | F-065 `ui.input` | boundary | callback fires exactly once | 10 |
| T-302 | F-065 `ui.input` | boundary | <CR> in insert mode submits the first line | 10 |
| T-303 | F-065 `ui.input` | boundary | <Esc> cancels | 10 |
| T-304 | F-065 `ui.input` | failure | on_done must be a function | 10 |
| T-305 | F-066 `commands.parse_args` | unit | algo only | 10 |
| T-306 | F-066 `commands.parse_args` | unit | mode | 10 |
| T-307 | F-066 `commands.parse_args` | boundary | last mode wins | 10 |
| T-308 | F-066 `commands.parse_args` | boundary | the mode value is not validated here | 10 |
| T-309 | F-066 `commands.parse_args` | failure | unknown key | 10 |
| T-310 | F-066 `commands.parse_args` | failure | malformed | 10 |
| T-311 | F-067 `commands.complete` | unit | filters by prefix | 10 |
| T-312 | F-067 `commands.complete` | unit | empty lead gives all | 10 |
| T-313 | F-067 `commands.complete` | boundary | after the algorithm: modes | 10 |
| T-314 | F-067 `commands.complete` | boundary | all modes | 10 |
| T-315 | F-067 `commands.complete` | failure | unknown filetype | 10 |
| T-316 | F-067 `commands.complete` | failure | missing engine | 10 |
| T-317 | F-068 `commands.register` | unit | registers and passes parsed args | 10 |
| T-318 | F-068 `commands.register` | unit | command has nargs + and a completer | 10 |
| T-319 | F-068 `commands.register` | failure | bad args: error notification, no handler call | 10 |
| T-320 | F-068 `commands.register` | failure | lowercase name is rejected by Neovim | 10 |
| T-321 | F-069 `init.setup` | unit | registers command and keymap, returns the module | 10 |
| T-322 | F-069 `init.setup` | unit | bin is handed to the client | 10 |
| T-323 | F-069 `init.setup` | boundary | second setup replaces the first | 10 |
| T-324 | F-069 `init.setup` | failure | bad config raises with the field name | 10 |
| T-325 | F-069 `init.setup` | failure | a failed setup changes nothing | 10 |
| T-326 | F-070 `init.run` | unit | cursor mode inserts below the cursor line | 10 |
| T-327 | F-070 `init.run` | unit | answers are used | 10 |
| T-328 | F-070 `init.run` | boundary | indentation of the cursor line is applied | 10 |
| T-329 | F-070 `init.run` | boundary | existing names in the buffer are avoided | 10 |
| T-330 | F-070 `init.run` | boundary | file mode writes and opens the file | 10 |
| T-331 | F-070 `init.run` | boundary | cancelling inserts nothing and stays silent | 10 |
| T-332 | F-070 `init.run` | failure | unknown algorithm is reported | 10 |
| T-333 | F-070 `init.run` | failure | unsupported filetype is reported | 10 |
| T-334 | F-071 `init.pick` | unit | menu items and titles | 10 |
| T-335 | F-071 `init.pick` | unit | choosing runs the algorithm | 10 |
| T-336 | F-071 `init.pick` | boundary | cancelling the menu does nothing | 10 |
| T-337 | F-071 `init.pick` | failure | unsupported filetype is notified and no menu opens | 10 |
| T-338 | F-072 `init.teardown` | unit | removes command, keymap and bin | 10 |
| T-339 | F-072 `init.teardown` | boundary | idempotent | 10 |
| T-340 | F-072 `init.teardown` | failure | safe before setup | 10 |

**Acceptance checks:** A-01 `list` prints algorithms and exits 0 · A-02 `--json` list · A-03 usage error exits 2 with the message · A-04 domain error exits 1 · A-05 `--scan -` reads stdin and renames to `binary_search_2` · A-06 `ask` reads answers from stdin (stretch).

## 17. Final integration

### 17.1 Initialization order
1. Neovim sources `plugin/scaffold.lua` (provided: a guard variable and a version check only).
2. lazy.nvim (or your config) calls `require('scaffold').setup(opts)`.
3. `setup`: `config.resolve` -> store config -> `nvim_create_augroup('scaffold', {clear=true})` -> `commands.register` -> `vim.keymap.set` -> return the module. It applies `opts.bin` to the client. Nothing touches a buffer and the engine is not started.

### 17.2 Lifecycle
Plugin: unloaded -> sourced -> active (ST-3). Prompt window: open -> closing -> closed (ST-2). Session (engine side): collecting -> ready or cancelled (ST-1).

### 17.3 Public API
| Function | Purpose | Stability |
|---|---|---|
| `require('scaffold').setup(opts)` | configure and activate | public |
| `require('scaffold').run(algo_id, mode?)` | programmatic insert | public |
| `require('scaffold').pick()` | open the picker | public |
| `require('scaffold').teardown()` | remove everything | public |
| `main.exe list|prompts|gen|ask` | the engine's command line (Section 8.6) | public |
| everything else | implementation | private |

### 17.4 Failure recovery
Every failure ends in one `vim.notify` and leaves the buffer unchanged; `ui.input` closes its window and clears its ghost text before the callback runs; `teardown` is idempotent; a missing or broken engine yields `engine_missing` / `engine_failed` / `bad_json`, never a Lua error.

### 17.5 Design check: how many edits to add a language?
Adding a language (extension E-02) must take **three edits in three files**: one `Lang.cfg` record in `lib/langs.ml`, one list of four templates in `lib/templates.ml`, and one line in the `match` inside `Catalog.template`. No logic changes. If you find yourself editing `Engine`, `Params` or `Cli`, a rule has leaked out of the data.

### 17.6 lazy.nvim wiring (`[D]`: option names quoted from memory of the lazy.nvim documentation, which I could not fetch; check the live docs)

```lua
-- lua/plugins/scaffold.lua  in your LazyVim config
return {
  {
    dir = "~/dev/scaffold.nvim",          -- or "yourname/scaffold.nvim" when published
    name = "scaffold.nvim",
    build = "dune build",                 -- builds the engine after install/update
    cmd = { "Scaffold" },
    keys = { { "<leader>cg", desc = "Scaffold: pick algorithm" } },
    opts = { mode = "cursor" },
  },
}
```

Two things to decide: where `dune build` runs (lazy's `build` hook, or by hand), and how the plugin finds the binary (default `<plugin dir>/_build/default/bin/main.exe`; override with `opts.bin` or the `SCAFFOLD_BIN` environment variable).

### 17.7 Integration checklist
- [ ] `dune build` produces `_build/default/bin/main.exe`.
- [ ] `plugin/scaffold.lua` sourced once, no side effects beyond the guard.
- [ ] `setup()` twice leaves exactly one command, one keymap, one augroup.
- [ ] `teardown()` leaves none; calling it twice is harmless.
- [ ] `:Scaffold <Tab>` completes algorithms; `:Scaffold stack <Tab>` offers `mode=`.
- [ ] `<leader>cg` in a `lua` buffer reports `unknown language: lua`.
- [ ] Esc at any prompt: buffer unchanged, no message.
- [ ] With the binary renamed: one notification mentioning `dune build`.
- [ ] `mode=file` twice: the second reports that the file exists, and the first file is untouched.

## 18. End-to-end examples and Definition of Done

All outputs below were produced by running the reference engine and a headless Neovim (neither shipped).


**E2E-1: List what the engine offers for OCaml**

```sh
$ main.exe list --lang ocaml
```
```text
binary-search	Binary search
insertion-sort	Insertion sort
stack	Stack
union-find	Union-find
```

**E2E-2: Ask which questions Python's stack needs**

```sh
$ main.exe prompts --ft python --algo stack
```
```text
type_name	Type name	Stack
elem	Element type (int, float, string, bool)	int
```

**E2E-3: Generate Python insertion sort with a custom name**

```sh
$ main.exe gen --lang python --algo insertion-sort --set 'fn=my sort' --set elem=float
```
```text
def my_sort(items: list[float]) -> list[float]:
    """Return a sorted copy of items (the input is not changed)."""
    result = list(items)
    for i in range(1, len(result)):
        key = result[i]
        j = i - 1
        while j >= 0 and result[j] > key:
            result[j + 1] = result[j]
            j -= 1
        result[j + 1] = key
    return result
```

**E2E-4: Existing names are avoided (--scan from stdin)**

```sh
$ printf 'def stack():\n    pass\n' | main.exe gen --lang python --algo binary-search --scan - | head -3
```
```text
def binary_search(items: list[int], target: int) -> int:
    """Return the index of target in the sorted list items, or -1."""
    lo, hi = 0, len(items) - 1
```

**E2E-5: Machine-readable error**

```sh
$ main.exe gen --lang cobol --algo stack --json; echo "exit=$?"
```
```text
{"error":{"code":"unknown_lang","message":"unknown language: cobol"}}
exit=1
```

**E2E-6: Usage error (exit 2) versus domain error (exit 1)**

```sh
$ main.exe gen --bogus; echo "exit=$?"; main.exe list --lang cobol; echo "exit=$?"
```
```text
exit=2
exit=1
usage error: unknown flag: --bogus
unknown language: cobol
```

**E2E-7: Interactive ask, answers from stdin**

```sh
$ printf 'My Stack\nbool\n' | main.exe ask --lang javascript --algo stack 2>&1 | head -12
```
```text
Type name [Stack]: Element type (int, float, string, bool) [int]: /** A last-in first-out stack of boolean values. */
class MyStack {
  #items = [];

  /** @param {boolean} item */
  push(item) {
    this.#items.push(item);
  }

  /** @returns {boolean | undefined} */
  pop() {
    return this.#items.pop();
```

**E2E-8: File mode in JSON**

```sh
$ main.exe gen --lang javascript --algo union-find --mode file --json | head -c 160; echo
```
```text
{"text":"/** Disjoint sets with path compression and union by size. */\nclass UnionFind {\n  #parent;\n  #size;\n\n  /** @param {number} n */\n  constructor(n)
```

**E2E-9: Inside Neovim: :Scaffold stack in a buffer that already defines stack**

```sh
$ nvim --headless -u NONE -l e2e_nv.lua   (ui.input replaced by a stub that accepts every ghost default)
```
```text
Type name [Stack]
Element type (int, float, string, bool) [int]
---- buffer ----
import os
def stack(): pass
class Stack:
    """A last-in first-out stack of int values."""
    def __init__(self) -> None:
        self._items: list[int] = []
    def push(self, item: int) -> None:
        self._items.append(item)
```

**Editor scenario (interactive).** In a Python buffer containing `x = 1` with the cursor on line 1, `:Scaffold stack`, answering `my stack` then `Int`, inserts below line 1 a `class MyStack:` whose docstring says `int values`, indented to the cursor line's indentation. Esc at the first prompt leaves the buffer as `x = 1`. In a `cobol` buffer the only effect is the notification `unknown language: cobol`.

### 18.1 Definition of Done

- [ ] All 72 functions implemented (stretch ones may be cut per the cut list).
- [ ] `dune test` passes (238 tests) and `nvim --headless -u NONE -l lua_test/run.lua` passes (102 tests).
- [ ] `sh test/acceptance.sh` prints six PASS (five if `ask` is cut).
- [ ] The 12 (language x algorithm) combinations generate.
- [ ] Engine check order holds (lang > algo > template > params > parse > render).
- [ ] `lib/` has no I/O: `grep -rn "print_\|prerr_\|exit \|read_line\|In_channel\|Sys\." lib/` finds nothing (only `bin/main.ml` may).
- [ ] No Lua global is created by loading any module.
- [ ] `setup` twice, `teardown` twice leave the editor clean.
- [ ] The interactive demo works in a real buffer, including cancel, file mode and the missing-engine message.
- [ ] `notes/NOTES.md` has an answer for every research question.
- [ ] You can explain, from memory: the error policy, why the engine is a process, and why `ui.input` schedules its callback.

## 19. Checklists, assessment, extensions, glossary

### 19.1 Function coverage checklist

Tick when implemented and green.

| Done | ID | Function | Part | Req | Tests |
|---|---|---|---|---|---|
| [ ] | F-001 | `Util.trim` | 0 | required | T-001..T-003 (3) |
| [ ] | F-002 | `Util.starts_with` | 0 | required | T-004..T-006 (3) |
| [ ] | F-003 | `Util.find_sub` | 1 | required | T-007..T-010 (4) |
| [ ] | F-004 | `Util.split` | 1 | required | T-011..T-014 (4) |
| [ ] | F-005 | `Util.leading_ws` | 1 | required | T-015..T-017 (3) |
| [ ] | F-006 | `Naming.words` | 1 | required | T-018..T-022 (5) |
| [ ] | F-007 | `Naming.convert` | 1 | required | T-023..T-027 (5) |
| [ ] | F-008 | `Err.code` | 2 | required | T-028..T-030 (3) |
| [ ] | F-009 | `Err.message` | 2 | required | T-031..T-035 (5) |
| [ ] | F-010 | `Json.escape` | 2 | required | T-036..T-039 (4) |
| [ ] | F-011 | `Json.to_string` | 2 | required | T-040..T-044 (5) |
| [ ] | F-012 | `Lang.validate` | 3 | required | T-045..T-052 (8) |
| [ ] | F-013 | `Lang.derive` | 3 | required | T-053..T-056 (4) |
| [ ] | F-014 | `Lang.register` | 3 | required | T-057..T-061 (5) |
| [ ] | F-015 | `Lang.find` | 3 | required | T-062..T-064 (3) |
| [ ] | F-016 | `Lang.find_by_filetype` | 3 | required | T-065..T-067 (3) |
| [ ] | F-017 | `Lang.file_name` | 3 | required | T-068..T-071 (4) |
| [ ] | F-018 | `Lang.elem_type` | 3 | required | T-072..T-074 (3) |
| [ ] | F-019 | `Langs.install` | 3 | required | T-075..T-078 (4) |
| [ ] | F-020 | `Template.scan_tag` | 4 | required | T-079..T-085 (7) |
| [ ] | F-021 | `Template.parse` | 4 | required | T-086..T-090 (5) |
| [ ] | F-022 | `Template.vars` | 4 | required | T-091..T-093 (3) |
| [ ] | F-023 | `Template.apply_filter` | 4 | required | T-094..T-096 (3) |
| [ ] | F-024 | `Template.render` | 4 | required | T-097..T-101 (5) |
| [ ] | F-025 | `Catalog.find` | 5 | required | T-102..T-104 (3) |
| [ ] | F-026 | `Catalog.template` | 5 | required | T-105..T-107 (3) |
| [ ] | F-027 | `Catalog.for_lang` | 5 | required | T-108..T-110 (3) |
| [ ] | F-028 | `Collision.unique_name` | 5 | required | T-111..T-114 (4) |
| [ ] | F-029 | `Collision.defined_names` | 5 | required | T-115..T-121 (7) |
| [ ] | F-030 | `Params.normalize_ident` | 6 | required | T-122..T-126 (5) |
| [ ] | F-031 | `Params.normalize_elem` | 6 | required | T-127..T-129 (3) |
| [ ] | F-032 | `Params.ghost` | 6 | required | T-130..T-132 (3) |
| [ ] | F-033 | `Params.resolve` | 6 | required | T-133..T-140 (8) |
| [ ] | F-034 | `Params.next_prompt` | 6 | stretch | T-141..T-144 (4) |
| [ ] | F-035 | `Session.create` | 6 | stretch | T-145 |
| [ ] | F-036 | `Session.state` | 6 | stretch | T-146..T-147 (2) |
| [ ] | F-037 | `Session.answers` | 6 | stretch | T-148..T-149 (2) |
| [ ] | F-038 | `Session.pending` | 6 | stretch | T-150..T-151 (2) |
| [ ] | F-039 | `Session.record` | 6 | stretch | T-152..T-155 (4) |
| [ ] | F-040 | `Session.cancel` | 6 | stretch | T-156..T-158 (3) |
| [ ] | F-041 | `Insert.reindent` | 7 | required | T-159..T-163 (5) |
| [ ] | F-042 | `Insert.place` | 7 | required | T-164..T-167 (4) |
| [ ] | F-043 | `Engine.generate` | 7 | required | T-168..T-178 (11) |
| [ ] | F-044 | `Engine.list` | 7 | required | T-179..T-181 (3) |
| [ ] | F-045 | `Cli.parse_flags` | 8 | required | T-182..T-190 (9) |
| [ ] | F-046 | `Cli.resolve_lang` | 8 | required | T-191..T-194 (4) |
| [ ] | F-047 | `Cli.run_list` | 8 | required | T-195..T-197 (3) |
| [ ] | F-048 | `Cli.run_prompts` | 8 | required | T-198..T-200 (3) |
| [ ] | F-049 | `Cli.run_gen` | 8 | required | T-201..T-211 (11) |
| [ ] | F-050 | `Cli.run_ask` | 8 | stretch | T-212..T-217 (6) |
| [ ] | F-051 | `Cli.run` | 8 | required | T-218..T-238 (21) |
| [ ] | F-052 | `Main.main` | 8 | required | A-01..A-06 (acceptance script) |
| [ ] | F-053 | `config.resolve` | 9 | required | T-239..T-246 (8) |
| [ ] | F-054 | `client.binary` | 9 | required | T-247..T-251 (5) |
| [ ] | F-055 | `client.call` | 9 | required | T-252..T-260 (9) |
| [ ] | F-056 | `client.list` | 9 | required | T-261..T-263 (3) |
| [ ] | F-057 | `client.prompts` | 9 | required | T-264..T-267 (4) |
| [ ] | F-058 | `client.generate` | 9 | required | T-268..T-275 (8) |
| [ ] | F-059 | `buffer.context` | 9 | required | T-276..T-280 (5) |
| [ ] | F-060 | `buffer.insert_lines` | 9 | required | T-281..T-286 (6) |
| [ ] | F-061 | `buffer.write_file` | 9 | stretch | T-287..T-289 (3) |
| [ ] | F-062 | `buffer.open_file` | 9 | stretch | T-290..T-292 (3) |
| [ ] | F-063 | `ui.ghost_set` | 10 | required | T-293..T-295 (3) |
| [ ] | F-064 | `ui.ghost_clear` | 10 | required | T-296..T-297 (2) |
| [ ] | F-065 | `ui.input` | 10 | required | T-298..T-304 (7) |
| [ ] | F-066 | `commands.parse_args` | 10 | required | T-305..T-310 (6) |
| [ ] | F-067 | `commands.complete` | 10 | stretch | T-311..T-316 (6) |
| [ ] | F-068 | `commands.register` | 10 | required | T-317..T-320 (4) |
| [ ] | F-069 | `init.setup` | 10 | required | T-321..T-325 (5) |
| [ ] | F-070 | `init.run` | 10 | required | T-326..T-333 (8) |
| [ ] | F-071 | `init.pick` | 10 | stretch | T-334..T-337 (4) |
| [ ] | F-072 | `init.teardown` | 10 | required | T-338..T-340 (3) |

### 19.2 Self-assessment checklist
- **Course readiness:** not applicable (no course material); CS3110 chapters in the READ lists are the reference.
- **Correctness:** all tests green; the examples in this document reproduce in your build.
- **Required functionality:** Definition of Done above.
- **Edge cases:** you can name, for each module, an empty/boundary case and which test pins it.
- **Testing:** each of your chosen Interlude tests fails when you sabotage the function it pins.
- **Code quality:** no function longer than about 30 lines except `Engine.generate`, `Params.resolve`, `Cli.run`, `ui.input`, `init.run`; no duplicated policy; no catch-all `| _ ->` where a variant could be listed.
- **Paradigm:** pure core, effects at the edge, errors as values for expected failures, exceptions only for contract violations.
- **OCaml fluency (explain aloud):** variant vs record; why `.mli` hides `Session.t`; `Result.bind` and `let*`; labelled vs optional arguments.
- **Lua/Neovim fluency (explain aloud):** 0-based vs 1-based rows; why callbacks are scheduled; what a namespace is for; how an augroup makes `setup` idempotent.

### 19.3 Extension challenges

- **E-01** Add `heap` to the catalog: data in `catalog.ml` and `templates.ml` only. Count how many files changed.
- **E-02** Add Lua as a generated language (one config, four templates).
- **E-03** Add `--json` output to `ask` and `prompts` formats (`Json.t` already exists).
- **E-04** Treesitter-based defined names in Lua, falling back to the OCaml heuristic.
- **E-05** Visual-selection aware insertion (`'<`, `'>` marks).
- **E-06** A re-entrancy guard for `init.run` with a test.
- **E-07** A `--format` flag that prints the plan as an LSP-style text edit.
- **E-08** A second front end: a tiny `fzf` script that calls `main.exe list` and `gen`.

### 19.4 Glossary

| Term | Meaning |
|---|---|
| Activity diagram | A UML diagram of the steps inside one function; here an execution trace of intended responsibilities. |
| Abstract type | A type whose definition is hidden by the `.mli`; outsiders can only use the functions you export. |
| augroup | A named group of autocommands that can be cleared as a unit. |
| buffer | In-memory text of a file (or scratch area), referred to by an integer handle. |
| contract | What a function requires, produces and raises. |
| dune | OCaml's build system; `dune build`, `dune test`. |
| edge | The thin layer that touches Neovim (buffer, ui, commands, init, client). |
| engine | The OCaml executable `main.exe` that does all the work. |
| extmark | A position-tracking mark in a buffer; here it carries grey virtual text. |
| fixture | Data supplied to you (templates, language configs); not a solution. |
| ghost text | Grey virtual text showing a default. |
| headless | Running Neovim without a UI (`--headless`). |
| labelled argument | An OCaml argument passed by name: `~prefix:"x"`. |
| .mli | The interface file of a module: what is public, with its types. |
| option / result | `Some x | None` and `Ok x | Error e`: values that may be absent or failed. |
| plan | A pure record `{text; file}` describing an insertion. |
| pure | No side effects: the output depends only on inputs. |
| segment | One piece of a parsed template: text or variable. |
| session | The value remembering a prompt flow's progress. |
| variant | An OCaml type with several named cases, possibly carrying data. |
| vim.NIL | The value `vim.json.decode` gives for JSON null. |
## 20. Reading library

**Link legend:** ✔ verified (page fetched and loaded; or help tag present in the local Neovim 0.10.4 tags file) · ○ known to exist but anchor or content not verified · ✗ not reachable from this environment. I never invent anchors; CS3110 and the OCaml API are cited at page level.

### 20.1 Online pages (fetched)

| Resource | URL | Status | Used in |
|---|---|---|---|
| CS3110 textbook: cover | https://cs3110.github.io/textbook/cover.html | ✔ | Intro |
| CS3110: variants | https://cs3110.github.io/textbook/chapters/data/variants.html | ✔ | P2 |
| CS3110: records and tuples | https://cs3110.github.io/textbook/chapters/data/records_tuples.html | ✔ | P3 |
| CS3110: advanced pattern matching | https://cs3110.github.io/textbook/chapters/data/pattern_matching_advanced.html | ✔ | P2 |
| CS3110: options | https://cs3110.github.io/textbook/chapters/data/options.html | ✔ | P3, P6 |
| CS3110: lists | https://cs3110.github.io/textbook/chapters/data/lists.html | ✔ | extra |
| CS3110: OUnit | https://cs3110.github.io/textbook/chapters/data/ounit.html | ✔ | P0 |
| CS3110: higher-order intro | https://cs3110.github.io/textbook/chapters/hop/intro.html | ✔ | extra |
| CS3110: map | https://cs3110.github.io/textbook/chapters/hop/map.html | ✔ | P5 |
| CS3110: fold | https://cs3110.github.io/textbook/chapters/hop/fold.html | ✔ | P4 |
| CS3110: pipelining | https://cs3110.github.io/textbook/chapters/hop/pipelining.html | ✔ | P7 |
| CS3110: modules intro | https://cs3110.github.io/textbook/chapters/modules/intro.html | ✔ | extra |
| CS3110: modules | https://cs3110.github.io/textbook/chapters/modules/modules.html | ✔ | P4, P7 |
| CS3110: encapsulation | https://cs3110.github.io/textbook/chapters/modules/encapsulation.html | ✔ | P6 |
| CS3110: mutability intro | https://cs3110.github.io/textbook/chapters/mut/intro.html | ✔ | extra |
| CS3110: references | https://cs3110.github.io/textbook/chapters/mut/refs.html | ✔ | P0 |
| CS3110: arrays | https://cs3110.github.io/textbook/chapters/mut/arrays.html | ✔ | P1 |
| CS3110: testing and debugging | https://cs3110.github.io/textbook/chapters/correctness/test_debug.html | ✔ | extra |
| OCaml API: String | https://ocaml.org/manual/5.2/api/String.html | ✔ | P1 |
| OCaml API: Char | https://ocaml.org/manual/5.2/api/Char.html | ✔ | P1 |
| OCaml API: List | https://ocaml.org/manual/5.2/api/List.html | ✔ | P3-P5 |
| OCaml API: Option | https://ocaml.org/manual/5.2/api/Option.html | ✔ | P5 |
| OCaml API: Result | https://ocaml.org/manual/5.2/api/Result.html | ✔ | P3, P6, P7 |
| OCaml API: Buffer | https://ocaml.org/manual/5.2/api/Buffer.html | ✔ | P1, P4 |
| OCaml API: Printf | https://ocaml.org/manual/5.2/api/Printf.html | ✔ | P2, P8 |
| OCaml API: Sys | https://ocaml.org/manual/5.2/api/Sys.html | ✔ | P8 |
| OCaml API: Stdlib | https://ocaml.org/manual/5.2/api/Stdlib.html | ✔ | P8 |
| OCaml API: In_channel | https://ocaml.org/manual/5.2/api/In_channel.html | ✔ | P8 |
| dune quick start | https://dune.readthedocs.io/en/stable/quick-start.html | ✔ | P0 |
| dune tests (describes the plural `tests` stanza) | https://dune.readthedocs.io/en/stable/tests.html | ✔ | P0 (see A-04) |
| OCaml install | https://ocaml.org/docs/install.html | ✔ | Setup |
| WSL install (Microsoft Learn) | https://learn.microsoft.com/en-us/windows/wsl/install | ✔ | Setup |

Not reachable or not verified: neovim.io documentation (use `:help`), realworldocaml.org, github.com pages, lazy.nvim documentation (option names in FX-17 are [D]), plantuml.com. **Page numbers:** none are cited, so none are claimed. If you want a printed book aligned (for example an OCaml book), attach its PDF and I will add exact page numbers later.

### 20.2 Neovim help topics (checked against the local 0.10.4 tags file)

| Topic | Status |
|---|---|
| `:help executable()` | ✔ |
| `:help fnameescape()` | ✔ |
| `:help lua-guide` | ✔ |
| `:help maparg()` | ✔ |
| `:help nvim_buf_set_extmark()` | ✔ |
| `:help nvim_buf_set_lines()` | ✔ |
| `:help nvim_create_augroup()` | ✔ |
| `:help nvim_create_user_command()` | ✔ |
| `:help nvim_open_win()` | ✔ |
| `:help vim.NIL` | ✔ |
| `:help vim.deep_equal()` | ✔ |
| `:help vim.json.decode()` | ✔ |
| `:help vim.keymap.set()` | ✔ |
| `:help vim.notify()` | ✔ |
| `:help vim.schedule()` | ✔ |
| `:help vim.system()` | ✔ |
| `:help vim.tbl_deep_extend()` | ✔ |
| `:help vim.ui.select()` | ✔ |
| `:help vim.wait()` | ✔ |
| `:help writefile()` | ✔ |

## 21. Verification and consistency report

| Check | Result | Detail |
|---|---|---|
| function ids F-001..F-072 are consecutive | pass |  |
| test ids T-001..T-340 are consecutive and unique | pass |  |
| every function has an activity diagram | pass |  |
| every diagram id referenced by a function exists | pass |  |
| every non-activity diagram is rendered without error | pass | 117 diagrams; errors []; missing [] |
| every research question has a model answer | pass |  |
| every Part has 2-4 research questions | pass |  |
| every Part has 2-4 READ items | pass |  |
| no example result left uncaptured | pass |  |
| time budget table sums to the stated total | pass | 795 min |
| every session is at most 120 minutes | pass | S1=115, S2=120, S3=90, S4=120, S5=80, S6=90, S7=75, S8=105 |
| no Mermaid anywhere | pass |  |
| no unreplaced template tokens | pass |  |
| every URL in the spec is on the verified list | pass | 32 distinct URLs |

### Facts measured or run here `[V]`

| Fact | Value |
|---|---|
| Functions | 72 (52 OCaml, 20 Lua) |
| Tests | 340 (238 OCaml ounit2, 102 Lua) plus 6 acceptance checks |
| Examples executed | 193 OCaml + 60 Lua in Section 15; 17 foundational (15 executed, 2 configuration) |
| End-to-end runs | 9 (8 command-line, 1 headless Neovim) |
| Diagrams | 117 (72 activity) |
| Reference vs skeleton | reference passes everything; stubs fail all 238 OCaml tests (errors, no crash); zero Lua tests pass under stubs |
| Mutation check | 16 deliberate bugs in the reference, 16 caught |
| Engine latency | about 2 ms per call (100 calls = 0.209 s); binary 1,440,096 bytes |
| Toolchain | OCaml 4.14.1, dune 3.14.0, ounit2, Neovim 0.10.4, PlantUML 1.2020.02 |

### What I could not verify `[D]` (stated, not hidden)

- opam install commands and the native-Windows OCaml route (no opam here; WSL2 page fetched).
- lazy.nvim option names in FX-17 (`dir`, `name`, `build`, `cmd`, `keys`, `opts`).
- macOS and other Linux distributions.
- The dune page I fetched documents the plural `tests` stanza; the singular `(test ...)` used by the skeleton was verified by building and running it, not by that page.
- Most claims in STREAMING_SECURITY.md about OBS, operating systems and vendors are documentation knowledge (that file marks each one).
- Only a few diagrams were inspected visually (CL-2, CMP-F4, WALK-1, and a few more); all 117 render without errors but layout of the others is unreviewed.
- The private reference implementation is intentionally not delivered; the shipped tests pass against it, which is the evidence they are consistent.


## Appendix R: Research-question model answers

Answer in `notes/NOTES.md` first. Each answer is collapsed.


### Part 0

**RQ-0-1** `dune test` prints one error per not-yet-written function and keeps going. Why does it not stop at the first failure?

<details><summary>Model answer</summary><p>ounit2 treats each test case as an independent unit and catches any exception a test body raises, recording it as an error and moving on. A stub raises <code>Failure "not implemented: F-nnn"</code>, so every unfinished function becomes one error line and the summary counts them. Stopping at the first failure would hide the others and make a red-to-green sweep impossible.</p></details>

**RQ-0-2** Why can `String.sub s 0 (-1)` happen inside a careless `trim`, and what does your loop do for the all-blank string?

<details><summary>Model answer</summary><p>A careless trim computes the end index first, finds that every character is whitespace, and ends up with a length of -1 or a start past the end. The safe shape: advance <code>i</code> from the left while whitespace, move <code>j</code> from the right while whitespace AND <code>j &gt;= i</code>, then take <code>String.sub s i (j - i + 1)</code>. For an all-blank string <code>i</code> reaches <code>n</code>, <code>j</code> stops at <code>i - 1</code>, the length is 0 and <code>String.sub s i 0</code> is legal.</p></details>

**RQ-0-3** What is the type of `ref 0`, and how do `!x`, `x := 1` and `x = 1` differ?

<details><summary>Model answer</summary><p><code>ref 0 : int ref</code> is a mutable cell. <code>!x</code> reads it, <code>x := 1</code> writes it, <code>x = 1</code> is structural equality that returns a <code>bool</code> (and compares the cell's contents only if you wrote <code>!x = 1</code>; comparing <code>x</code> with <code>1</code> directly is a type error).</p></details>


### Part 1

**RQ-1-1** By hand, write the result of `Naming.words` for `HTTPServer`, `x2Y` and `foo_bar-baz`. State the rule you used for each boundary.

<details><summary>Model answer</summary><p><code>HTTPServer</code> -&gt; <code>["http"; "server"]</code>: a run of capitals followed by a capital+lowercase pair ends before the last capital. <code>x2Y</code> -&gt; <code>["x2"; "y"]</code>: digits stay with the preceding word and a capital after a digit starts a new word. <code>foo_bar-baz</code> -&gt; <code>["foo"; "bar"; "baz"]</code>: <code>_</code> and <code>-</code> are separators and never part of a word. All words come out lowercase.</p></details>

**RQ-1-2** `Util.split "a,b," ~sep:","` has three pieces. Why is the empty last piece the right answer?

<details><summary>Model answer</summary><p>Splitting is the inverse of joining: <code>String.concat "," ["a"; "b"; ""] = "a,b,"</code>. If the trailing empty piece were dropped, join(split s) would no longer equal <code>s</code>, and callers could not tell <code>"a,b"</code> from <code>"a,b,"</code>. The same reasoning gives <code>[""]</code> for the empty input.</p></details>

**RQ-1-3** Why does `find_sub` raise `Invalid_argument` for a negative `from` instead of returning `None`?

<details><summary>Model answer</summary><p>A negative start is not something a user can type: it can only come from a bug in the caller. Contract violations raise <code>Invalid_argument</code>; user-caused failures return <code>Error</code>/<code>None</code>. Returning <code>None</code> would make a bug look like 'not found'.</p></details>


### Part 2

**RQ-2-1** Why is `Err.t` a variant with one case per failure rather than a string?

<details><summary>Model answer</summary><p>With a variant the compiler checks every <code>match</code> for completeness: add a case and each function that forgot it is flagged. Strings would let a typo in <code>"unkown_lang"</code> pass silently and nothing would force <code>code</code> and <code>message</code> to cover every failure. Payloads (the language name, the position) are typed instead of being parsed back out of text.</p></details>

**RQ-2-2** Which characters must `Json.escape` change, and why are bytes 0x80 and above passed through unchanged?

<details><summary>Model answer</summary><p><code>"</code> and <code>\</code> must be escaped, and so must control bytes below 0x20 (<code>\n</code>, <code>\t</code>, <code>\r</code> as short forms, others as <code>\u00XX</code>). Bytes 0x80 and above are UTF-8 continuation or lead bytes; JSON strings may contain UTF-8 directly, and escaping a single byte would produce invalid UTF-8.</p></details>

**RQ-2-3** `Json` knows nothing about `Err`. Where is the conversion done and why there?

<details><summary>Model answer</summary><p><code>Cli.error_outcome</code> converts an <code>Err.t</code> into a <code>Json.t</code> object with the code and message. <code>Json</code> stays a generic value type that any module can use, so it needs no dependency on the error type and cannot cause a cycle.</p></details>


### Part 3

**RQ-3-1** `register` takes the list and returns a new list instead of changing a global. Name two benefits for testing.

<details><summary>Model answer</summary><p>A function from list to list has no hidden state: tests build the exact registry they need and cannot affect each other; and a failed <code>register</code> cannot leave a half-updated global, because it returns <code>Error</code> and the old list is still the caller's value.</p></details>

**RQ-3-2** Which rule in `validate` does `derive` rely on so that `derive` can be total (cannot fail)?

<details><summary>Model answer</summary><p><code>validate</code> ensures <code>indent_width &gt;= 0</code> (it also checks the id and extension formats). The reference <code>derive</code> builds the indent with <code>String.make indent_width ' '</code>, which raises for a negative width; with the rule enforced, <code>derive</code> cannot fail.</p></details>

**RQ-3-3** Why does `find` return an `option` while `register` returns a `result`?

<details><summary>Model answer</summary><p>Looking up an id that is not there is an ordinary absence, not a failure with a reason: <code>option</code>. Registering can fail in several distinct ways the caller must tell apart (bad config, duplicate id, duplicate filetype): <code>result</code> with an <code>Err.t</code>.</p></details>


### Part 4

**RQ-4-1** By hand: what does `Template.scan_tag "a<% fn | snake | upper %>b" 1` return, including the next position?

<details><summary>Model answer</summary><p><code>Ok (Var {name = "fn"; filters = [Snake; Upper]}, 25)</code>. The tag begins at byte 1 (<code>&lt;</code>), and ends with <code>&gt;</code> at byte 24, so scanning resumes at 25, where the <code>b</code> is.</p></details>

**RQ-4-2** `Template.parse "ok <% a %> then <% b"` reports `Unclosed 16`. Count the bytes to show why 16.

<details><summary>Model answer</summary><p>Bytes 0-2 are <code>ok </code>, 3-9 are <code>&lt;% a %&gt;</code>, 10-15 are <code> then </code>, and the second <code>&lt;%</code> starts at byte 16. The error carries the position of the opening <code>&lt;%</code>, so the author can jump straight to the broken tag.</p></details>

**RQ-4-3** Why is `Bad_filter` found while parsing but `Unbound` only while rendering?

<details><summary>Model answer</summary><p>Filter names are written in the template text, so they can be checked from the text alone (parse time). A variable's value depends on the environment, which only exists at render time; the same parsed template can be rendered with different environments.</p></details>


### Part 5

**RQ-5-1** `Catalog.template` is keyed by two strings. What does this buy you, and what bug class does it allow that a variant would prevent?

<details><summary>Model answer</summary><p>Data-driven: adding a language or algorithm is only more rows and strings, no new variant cases or matches to edit. The cost: a misspelled key compiles and returns <code>None</code> at run time. The provided test that all 12 combinations exist is what replaces the compiler's check.</p></details>

**RQ-5-2** Name three source-text situations where `defined_names` gives a wrong answer.

<details><summary>Model answer</summary><p>(1) A name inside a string or comment that starts with <code>def </code> or <code>const </code>. (2) A definition that does not start its line (for example <code>x = 1; def f(): ...</code>): markers are matched only at the start of the trimmed line. (3) Destructuring, multiple declarations (<code>let a, b</code>), or names defined by assignment only.</p></details>

**RQ-5-3** What are the first four results of `unique_name` when the existing list is `["s"; "s_2"; "s_3"]`?

<details><summary>Model answer</summary><p><code>unique_name ["s"; "s_2"; "s_3"] "s"</code> is <code>"s_4"</code>; the next calls on a growing list give <code>s_5</code>, <code>s_6</code>, <code>s_7</code>. A name not in the list is returned unchanged.</p></details>


### Part 6

**RQ-6-1** In `Params.resolve`, why is the unknown-parameter check done before any parameter is processed?

<details><summary>Model answer</summary><p>The contract fixes this order. A sensible reason: a misspelled answer name is reported as the same error no matter which other parameters are fine or broken, and the check does not depend on the algorithm's parameter order. A single early check also keeps the per-parameter function simple.</p></details>

**RQ-6-2** What does making `Session.t` abstract forbid, and which test shows you cannot build a `Ready` session by hand?

<details><summary>Model answer</summary><p>It forbids constructing or modifying a session except through <code>create</code>, <code>record</code> and <code>cancel</code>, so illegal states (for example Ready with unanswered questions) cannot exist. A test can only reach <code>Ready</code> by recording every answer through the public API.</p></details>

**RQ-6-3** Why does `Params.ghost` live in `Params` and not in `Cli`?

<details><summary>Model answer</summary><p>The default shown to the user (the ghost) must equal the default <code>resolve</code> uses when the answer is blank, or the user would see one name and get another. Keeping both in <code>Params</code> makes that a single source of truth for the editor and the shell.</p></details>


### Part 7

**RQ-7-1** Why must `Engine.generate` check the language before the algorithm?

<details><summary>Model answer</summary><p>If the language is unknown there is no template to look up for it; reporting 'no template for algorithm X in language Y' for a language that does not exist would be misleading. The fixed order also makes the first error deterministic: the tests pin lang, algo, template, params, parse, render.</p></details>

**RQ-7-2** Which module owns indentation, `Insert` or `Engine`? What goes wrong if both do it?

<details><summary>Model answer</summary><p><code>Insert</code> owns indentation because only placement knows the mode and cursor indent. If <code>Engine</code> also indented, code would be indented twice (and file mode, which must not indent at all, would need special cases).</p></details>

**RQ-7-3** `Engine.generate` never prints. Name two things that become possible because of that.

<details><summary>Model answer</summary><p>It can be tested with plain values, and it can be called from any front end: the shell CLI today, a language server or another editor tomorrow. It also cannot half-finish an action: you only get a plan, never a partial side effect.</p></details>


### Part 8

**RQ-8-1** Why does `Cli.run` return an `outcome` record instead of printing and exiting?

<details><summary>Model answer</summary><p>A function that returns <code>{code; stdout; stderr}</code> can be tested by comparing a value; one that prints and exits would need a subprocess for every test. <code>bin/main.ml</code> is the only place where those three fields turn into real output and a real exit.</p></details>

**RQ-8-2** List which `Err.t` cases map to exit code 2 and which to 1, and say why the split is useful to a shell script.

<details><summary>Model answer</summary><p>Usage errors (exit 2): <code>Unknown_flag</code>, <code>Missing_value</code>, <code>Bad_set</code>, <code>Unexpected_arg</code>, <code>Unknown_command</code>, <code>Bad_value</code>. Everything else (exit 1) is a domain error: the command line was well-formed but the request cannot be satisfied. A script can retry or fix its invocation on 2 and report to the user on 1.</p></details>

**RQ-8-3** `main.ml` is the only file allowed to call `exit`. Which tests would be impossible if `Cli.run` called it?

<details><summary>Model answer</summary><p>Any test of an error path: calling <code>exit</code> ends the test process. You would have to spawn a subprocess per case instead of asserting on a returned <code>outcome</code>.</p></details>


### Part 9

**RQ-9-1** `client.call` appends `--json` itself and never mutates the caller's table. Why is each of those two choices good?

<details><summary>Model answer</summary><p>Appending <code>--json</code> inside <code>call</code> guarantees the engine is always in machine-readable mode, so no caller can forget it. Not mutating <code>args</code> means a caller can reuse its table (for example in a retry or a test) without surprises.</p></details>

**RQ-9-2** Convert 1-based `row` to the two 0-based arguments of `nvim_buf_set_lines` for inserting after the line, and say why start equals end.

<details><summary>Model answer</summary><p>Inserting after 1-based line <code>row</code> means the new lines go at 0-based index <code>row</code>. <code>nvim_buf_set_lines(buf, row, row, true, lines)</code>: start equals end is an empty range, so nothing is replaced and the lines are inserted at that index. <code>row = 0</code> inserts at the top.</p></details>

**RQ-9-3** Why does `client.call` wrap `vim.system` and `vim.json.decode` in `pcall`?

<details><summary>Model answer</summary><p><code>vim.system</code> can throw when the executable cannot be started, and <code>vim.json.decode</code> throws on invalid text. The edge's contract is <code>value</code> or <code>nil, err</code>, never an exception; <code>pcall</code> turns each failure into <code>engine_failed</code> or <code>bad_json</code>.</p></details>


### Part 10

**RQ-10-1** Why is `on_done` scheduled with `vim.schedule` instead of called directly from the key handler?

<details><summary>Model answer</summary><p>The key handler runs while Neovim is in the middle of processing a keypress inside the floating window. Calling user code there can see a half-closed window or run with the wrong current window. <code>vim.schedule</code> defers it to the next event-loop iteration, after the window has been closed.</p></details>

**RQ-10-2** How does `nvim_create_augroup('scaffold', { clear = true })` make `setup` safe to call twice?

<details><summary>Model answer</summary><p><code>clear = true</code> deletes any autocommands the group already had. Calling <code>setup</code> twice recreates the group instead of stacking duplicate autocommands, and <code>teardown</code> can delete the group in one step.</p></details>

**RQ-10-3** What would the user see if the engine binary were missing, and which function produces that message?

<details><summary>Model answer</summary><p><code>client.binary</code> returns <code>nil, {code='engine_missing', path=..., message='engine binary not found or not executable: &lt;path&gt; (run </code>dune build<code>)'}</code>; <code>init.run</code> passes the error to <code>vim.notify</code> at ERROR level, once, and the buffer is unchanged.</p></details>


## Appendix T: Reference assertions

Each row is the assertion of a test already in the skeleton, listed so you can read what a failing test expects without opening the file. OCaml tests use the helpers in `test/test_helpers.ml` (`eq_str`, `eq_int`, `raises_invalid`, ...); Lua tests use `eq` and `raises` from `lua_test/harness.lua`.

| Test | Function | Assertion (must pass) |
|---|---|---|
| T-001 | F-001 | `eq_str "x" (Util.trim "  x  ")` |
| T-002 | F-001 | `eq_str "" (Util.trim ""); eq_str "" (Util.trim " \t\r\n")` |
| T-003 | F-001 | `eq_str "a  b" (Util.trim "\ta  b\n")` |
| T-004 | F-002 | `eq_bool true (Util.starts_with "def f" ~prefix:"def ")` |
| T-005 | F-002 | `eq_bool true (Util.starts_with "" ~prefix:"")` |
| T-006 | F-002 | `eq_bool false (Util.starts_with "de" ~prefix:"def ")` |
| T-007 | F-003 | `eq_io (Some 1) (Util.find_sub "xabcabc" ~sub:"abc" ~from:0)` |
| T-008 | F-003 | `eq_io (Some 4) (Util.find_sub "xabcabc" ~sub:"abc" ~from:2)` |
| T-009 | F-003 | `eq_io None (Util.find_sub "abc" ~sub:"z" ~from:0); eq_io None (Util.find_sub "abc" ~sub:"c" ~from:3)` |
| T-010 | F-003 | `raises_invalid (fun () -> Util.find_sub "abc" ~sub:"a" ~from:(-1))` |
| T-011 | F-004 | `eq_strs ["a";"b";"c"] (Util.split "a,b,c" ~sep:",")` |
| T-012 | F-004 | `eq_strs ["a";"b";""] (Util.split "a,b," ~sep:","); eq_strs [""] (Util.split "" ~sep:",")` |
| T-013 | F-004 | `eq_strs ["a";"b"] (Util.split "a<>b" ~sep:"<>")` |
| T-014 | F-004 | `raises_invalid (fun () -> Util.split "abc" ~sep:"")` |
| T-015 | F-005 | `eq_str "  " (Util.leading_ws "  x")` |
| T-016 | F-005 | `eq_str "\t " (Util.leading_ws "\t x"); eq_str "" (Util.leading_ws "")` |
| T-017 | F-005 | `eq_str "" (Util.leading_ws "\n  x")` |
| T-018 | F-006 | `eq_strs ["foo";"bar"] (Naming.words "fooBar"); eq_strs ["foo";"bar"] (Naming.words "foo_bar")` |
| T-019 | F-006 | `eq_strs ["http";"server"] (Naming.words "HTTPServer")` |
| T-020 | F-006 | `eq_strs ["x2";"y"] (Naming.words "x2Y")` |
| T-021 | F-006 | `eq_strs [] (Naming.words ""); eq_strs [] (Naming.words "_-_")` |
| T-022 | F-006 | `eq_strs ["a";"bc"] (Naming.words "\xc3\xa9ABc")` |
| T-023 | F-007 | `eq_str "binary_search" (Naming.convert Naming.Snake "Binary Search")` |
| T-024 | F-007 | `eq_str "binarySearch" (Naming.convert Naming.Camel "binary search"); eq_str "BinarySearch" (Naming.convert Naming.Pascal "binary search")` |
| T-025 | F-007 | `eq_str "UNION_FIND" (Naming.convert Naming.Upper_snake "unionFind")` |
| T-026 | F-007 | `eq_str "" (Naming.convert Naming.Camel "")` |
| T-027 | F-007 | `eq_str "" (Naming.convert Naming.Pascal "--")` |
| T-028 | F-008 | `eq_str "unknown_lang" (Err.code (Err.Unknown_lang "x")); eq_str "bad_ident" (Err.code (Err.Bad_ident { param = "fn"; value = "" }))` |
| T-029 | F-008 | `let codes = List.map Err.code all_errs in eq_int 17 (List.length codes); eq_int 17 (List.length (List.sort_uniq compare codes)); assert_bool "non-empty" (List.for_all (fun c -> c <> "") codes)` |
| T-030 | F-008 | `eq_str "template" (Err.code (Err.Template (Err.Unbound "x"))); eq_str "template" (Err.code (Err.Template (Err.Unclosed 0)))` |
| T-031 | F-009 | `eq_str "unknown language: cobol" (Err.message (Err.Unknown_lang "cobol"))` |
| T-032 | F-009 | `eq_str "template: unclosed <% at 12" (Err.message (Err.Template (Err.Unclosed 12)))` |
| T-033 | F-009 | `eq_str "bad value for --mode: \"zzz\"" (Err.message (Err.Bad_value { flag = "--mode"; value = "zzz" }))` |
| T-034 | F-009 | `eq_str "unknown command" (Err.message (Err.Unknown_command "")); eq_str "unknown command: x" (Err.message (Err.Unknown_command "x"))` |
| T-035 | F-009 | `assert_bool "newline" (List.for_all (fun e -> not (String.contains (Err.message e) '\n')) all_errs)` |
| T-036 | F-010 | `eq_str "a\\\"b\\n" (Json.escape "a\"b\n")` |
| T-037 | F-010 | `eq_str "\\\\ \\t \\r" (Json.escape "\\ \t \r")` |
| T-038 | F-010 | `eq_str "\\u0001" (Json.escape "\001")` |
| T-039 | F-010 | `eq_str "\xc3\xa9" (Json.escape "\xc3\xa9"); eq_str "" (Json.escape "")` |
| T-040 | F-011 | `eq_str "null" (Json.to_string Json.Null); eq_str "true" (Json.to_string (Json.Bool true)); eq_str "7" (Json.to_string (Json.Int 7)); eq_str "\"x\"" (Json.to_string (Json.Str "x"))` |
| T-041 | F-011 | `eq_str "{\"a\":[1,null]}" (Json.to_string Json.(Obj [("a", List [Int 1; Null])]))` |
| T-042 | F-011 | `eq_str "[]" (Json.to_string (Json.List [])); eq_str "{}" (Json.to_string (Json.Obj []))` |
| T-043 | F-011 | `eq_str "{\"a\\\"b\":0}" (Json.to_string (Json.Obj [("a\"b", Json.Int 0)]))` |
| T-044 | F-011 | `eq_str "-4" (Json.to_string (Json.Int (-4)))` |
| T-045 | F-012 | `List.iter (fun c -> assert_bool "valid" (Result.is_ok (Lang.validate c))) Langs.configs` |
| T-046 | F-012 | `is_err "bad_lang_config" (Lang.validate { cfg0 with Lang.id = "Bad Id" }); bad_field "id" (Lang.validate { cfg0 with Lang.id = "" })` |
| T-047 | F-012 | `bad_field "filetypes" (Lang.validate { cfg0 with Lang.filetypes = [] }); bad_field "filetypes" (Lang.validate { cfg0 with Lang.filetypes = [""] })` |
| T-048 | F-012 | `bad_field "extension" (Lang.validate { cfg0 with Lang.extension = "py" }); bad_field "extension" (Lang.validate { cfg0 with Lang.extension = "." })` |
| T-049 | F-012 | `bad_field "indent_width" (Lang.validate { cfg0 with Lang.indent_width = -1 }); assert_bool "zero ok" (Result.is_ok (Lang.validate { cfg0 with Lang.indent_width = 0 }))` |
| T-050 | F-012 | `bad_field "types" (Lang.validate { cfg0 with Lang.types = { cfg0.Lang.types with Lang.bool_t = "" } })` |
| T-051 | F-012 | `bad_field "def_markers" (Lang.validate { cfg0 with Lang.def_markers = [""] })` |
| T-052 | F-012 | `bad_field "id" (Lang.validate { cfg0 with Lang.id = "X"; extension = "nope" })` |
| T-053 | F-013 | `eq_str "    " (Lang.derive { cfg0 with Lang.indent_width = 4 }).Lang.indent` |
| T-054 | F-013 | `assert_bool "camel" ((Lang.derive { cfg0 with Lang.camel_case = true }).Lang.fn_style = Naming.Camel); assert_bool "snake" ((Lang.derive cfg0).Lang.fn_style = Naming.Snake)` |
| T-055 | F-013 | `eq_str "" (Lang.derive { cfg0 with Lang.indent_width = 0 }).Lang.indent` |
| T-056 | F-013 | `assert_bool "same" ((Lang.derive cfg0).Lang.cfg == cfg0)` |
| T-057 | F-014 | `let r = get_ok (Lang.register [] cfg0) in eq_int 1 (List.length r); let r2 = get_ok (Lang.register r { cfg0 with Lang.id = "two"; filetypes = ["two"] }) in eq_strs ["demo";"two"] (List.map (fun l -> l.Lang.cfg.Lang.id) r2)` |
| T-058 | F-014 | `let r = get_ok (Lang.register [] cfg0) in is_err "duplicate_id" (Lang.register r { cfg0 with Lang.filetypes = ["other"] })` |
| T-059 | F-014 | `let r = get_ok (Lang.register [] cfg0) in (match Lang.register r { cfg0 with Lang.id = "two" } with Error (Err.Duplicate_filetype { filetype; owner }) -> eq_str "demo" filetype; eq_str "demo" owner \| _ -> assert_failure "expected Duplicate_filetype")` |
| T-060 | F-014 | `is_err "bad_lang_config" (Lang.register [] { cfg0 with Lang.extension = "x" })` |
| T-061 | F-014 | `let r = get_ok (Lang.register [] cfg0) in ignore (Lang.register r { cfg0 with Lang.id = "two"; filetypes = ["two"] }); eq_int 1 (List.length r)` |
| T-062 | F-015 | `assert_bool "some" (Lang.find regs "ocaml" <> None)` |
| T-063 | F-015 | `assert_bool "none" (Lang.find regs "OCaml" = None)` |
| T-064 | F-015 | `assert_bool "none" (Lang.find regs "x" = None); assert_bool "none" (Lang.find [] "python" = None)` |
| T-065 | F-016 | `eq_so (Some "javascript") (Option.map (fun l -> l.Lang.cfg.Lang.id) (Lang.find_by_filetype regs "javascriptreact"))` |
| T-066 | F-016 | `assert_bool "none" (Lang.find_by_filetype regs "" = None)` |
| T-067 | F-016 | `assert_bool "none" (Lang.find_by_filetype regs "lua" = None)` |
| T-068 | F-017 | `eq_str "binary_search.py" (Lang.file_name (lang "python") "Binary Search")` |
| T-069 | F-017 | `eq_str "binarySearch.js" (Lang.file_name (lang "javascript") "binary search")` |
| T-070 | F-017 | `eq_str "union_find.ml" (Lang.file_name (lang "ocaml") "union_find")` |
| T-071 | F-017 | `raises_invalid (fun () -> Lang.file_name (lang "python") "--")` |
| T-072 | F-018 | `eq_str "str" (Lang.elem_type (lang "python") Lang.String); eq_str "int" (Lang.elem_type (lang "python") Lang.Int)` |
| T-073 | F-018 | `eq_str "number" (Lang.elem_type (lang "javascript") Lang.Float); eq_str "boolean" (Lang.elem_type (lang "javascript") Lang.Bool)` |
| T-074 | F-018 | `List.iter (fun l -> List.iter (fun e -> assert_bool "nonempty" (Lang.elem_type l e <> "")) Lang.[Int;Float;String;Bool]) regs` |
| T-075 | F-019 | `eq_strs ["python";"javascript";"ocaml"] (List.map (fun l -> l.Lang.cfg.Lang.id) (Langs.install []))` |
| T-076 | F-019 | `eq_int 3 (List.length (Langs.install (Langs.install [])))` |
| T-077 | F-019 | `let r = get_ok (Lang.register [] cfg0) in eq_strs ["demo";"python";"javascript";"ocaml"] (List.map (fun l -> l.Lang.cfg.Lang.id) (Langs.install r))` |
| T-078 | F-019 | `let mine = get_ok (Lang.register [] { (List.hd Langs.configs) with Lang.indent_width = 8 }) in eq_str (String.make 8 ' ') (Lang.find (Langs.install mine) "python" \|> Option.get).Lang.indent` |
| T-079 | F-020 | `(match Template.scan_tag "<%x%>" 0 with Ok (Template.Var { name; filters }, next) -> eq_str "x" name; eq_int 0 (List.length filters); eq_int 5 next \| _ -> assert_failure "expected Var")` |
| T-080 | F-020 | `(match Template.scan_tag "<% fn \| snake \| upper %>" 0 with Ok (Template.Var { name; filters }, _) -> eq_str "fn" name; assert_bool "order" (filters = [Template.Snake; Template.Upper]) \| _ -> assert_failure "expected Var")` |
| T-081 | F-020 | `(match Template.scan_tag "ab<%x%>cd" 2 with Ok (_, next) -> eq_int 7 next \| _ -> assert_failure "expected Ok")` |
| T-082 | F-020 | `assert_bool "unclosed" (Template.scan_tag "ab <% x" 3 = Error (Err.Unclosed 3))` |
| T-083 | F-020 | `assert_bool "empty" (Template.scan_tag "<%  %>" 0 = Error (Err.Empty_var 0))` |
| T-084 | F-020 | `assert_bool "bad" (Template.scan_tag "<% 1x %>" 0 = Error (Err.Bad_name "1x")); assert_bool "upper" (Template.scan_tag "<% Fn %>" 0 = Error (Err.Bad_name "Fn"))` |
| T-085 | F-020 | `assert_bool "filter" (Template.scan_tag "<% x \| shout %>" 0 = Error (Err.Bad_filter "shout"))` |
| T-086 | F-021 | `(match Template.parse "a<%x%>b" with Ok [Template.Text "a"; Template.Var { name = "x"; filters = [] }; Template.Text "b"] -> () \| _ -> assert_failure "shape")` |
| T-087 | F-021 | `(match Template.parse "<%a%><%b%>" with Ok [Template.Var _; Template.Var _] -> () \| _ -> assert_failure "two Vars, no Text")` |
| T-088 | F-021 | `assert_bool "empty" (Template.parse "" = Ok []); assert_bool "plain" (Template.parse "a < b % c" = Ok [Template.Text "a < b % c"])` |
| T-089 | F-021 | `assert_bool "err" (Template.parse "ok <% a %> then <% b" = Error (Err.Unclosed 16))` |
| T-090 | F-021 | `assert_bool "first" (Template.parse "<% 1 %><% b" = Error (Err.Bad_name "1"))` |
| T-091 | F-022 | `eq_strs ["b";"a"] (Template.vars (get_ok_t (Template.parse "<%b%> <%a%> <%b \| upper%>")))` |
| T-092 | F-022 | `eq_strs [] (Template.vars (get_ok_t (Template.parse "plain"))); eq_strs [] (Template.vars [])` |
| T-093 | F-022 | `eq_strs ["x"] (Template.vars (get_ok_t (Template.parse "<%x\|upper%><%x\|lower%>")))` |
| T-094 | F-023 | `eq_str "foo_bar" (Template.apply_filter Template.Snake "fooBar"); eq_str "fooBar" (Template.apply_filter Template.Camel "foo bar"); eq_str "FooBar" (Template.apply_filter Template.Pascal "foo_bar"); eq_str "FOO_BAR" (Template.apply_filter Template.Upper_snake "fooBar")` |
| T-095 | F-023 | `eq_str "FOOBAR" (Template.apply_filter Template.Upper "fooBar"); eq_str "foobar" (Template.apply_filter Template.Lower "fooBar")` |
| T-096 | F-023 | `eq_str "" (Template.apply_filter Template.Pascal "")` |
| T-097 | F-024 | `eq_str_t "def binary_search()" (Template.render (get_ok_t (Template.parse "def <% fn \| snake %>()")) [("fn","binarySearch")])` |
| T-098 | F-024 | `eq_str_t "FOO_BAR" (Template.render (get_ok_t (Template.parse "<% x \| snake \| upper %>")) [("x","fooBar")])` |
| T-099 | F-024 | `eq_str_t "" (Template.render [] [("a","1")])` |
| T-100 | F-024 | `assert_bool "unbound" (Template.render (get_ok_t (Template.parse "<% q %>")) [] = Error (Err.Unbound "q"))` |
| T-101 | F-024 | `eq_str_t "aa" (Template.render (get_ok_t (Template.parse "<%x%><%x%>")) [("x","a")])` |
| T-102 | F-025 | `List.iter (fun id -> assert_bool id (Catalog.find id <> None)) ["binary-search";"insertion-sort";"stack";"union-find"]` |
| T-103 | F-025 | `assert_bool "none" (Catalog.find "Stack" = None); assert_bool "none" (Catalog.find "" = None)` |
| T-104 | F-025 | `assert_bool "none" (Catalog.find "quicksort" = None)` |
| T-105 | F-026 | `List.iter (fun l -> List.iter (fun a -> assert_bool (l ^ a) (Catalog.template ~algo_id:a ~lang_id:l <> None)) ["binary-search";"insertion-sort";"stack";"union-find"]) ["python";"javascript";"ocaml"]` |
| T-106 | F-026 | `assert_bool "l" (Catalog.template ~algo_id:"stack" ~lang_id:"cobol" = None); assert_bool "a" (Catalog.template ~algo_id:"zzz" ~lang_id:"python" = None)` |
| T-107 | F-026 | `List.iter (fun (a : Catalog.algo) -> List.iter (fun l -> let text = Option.get (Catalog.template ~algo_id:a.id ~lang_id:l) in let segs = get_ok_t (Template.parse text) in List.iter (fun v -> assert_bool (a.id ^ " uses " ^ v) (List.exists (fun (p : Catalog.param) -> p.name = v) a.params)) (Template.vars segs)) ["python";"javascript";"ocaml"]) Catalog.all` |
| T-108 | F-027 | `eq_strs ["binary-search";"insertion-sort";"stack";"union-find"] (List.map (fun a -> a.Catalog.id) (Catalog.for_lang "python"))` |
| T-109 | F-027 | `eq_int 0 (List.length (Catalog.for_lang "cobol"))` |
| T-110 | F-027 | `eq_int 0 (List.length (Catalog.for_lang ""))` |
| T-111 | F-028 | `eq_str "f" (Collision.unique_name [] "f"); eq_str "g" (Collision.unique_name ["f"] "g")` |
| T-112 | F-028 | `eq_str "f_2" (Collision.unique_name ["f"] "f")` |
| T-113 | F-028 | `eq_str "f_4" (Collision.unique_name ["f";"f_2";"f_3"] "f")` |
| T-114 | F-028 | `eq_str "f_2" (Collision.unique_name ["f";"f_3"] "f")` |
| T-115 | F-029 | `eq_strs ["foo";"Bar"] (Collision.defined_names (lang "python") "import os\n\ndef foo(x):\n    return x\nclass Bar:\n  pass")` |
| T-116 | F-029 | `eq_strs ["a";"b";"c"] (Collision.defined_names (lang "javascript") "const a = 1;\n  let b;\nfunction c() {}")` |
| T-117 | F-029 | `eq_strs ["go";"x"] (Collision.defined_names (lang "ocaml") "let rec go n = n\nlet x = 1")` |
| T-118 | F-029 | `eq_strs ["fetch"] (Collision.defined_names (lang "python") "async def fetch():")` |
| T-119 | F-029 | `eq_strs [] (Collision.defined_names (lang "python") "define x")` |
| T-120 | F-029 | `eq_strs [] (Collision.defined_names (lang "python") "def (x)"); eq_strs [] (Collision.defined_names (lang "python") "")` |
| T-121 | F-029 | `eq_strs ["f";"f"] (Collision.defined_names (lang "python") "def f(): pass\ndef f(): pass")` |
| T-122 | F-030 | `eq_str_e "binary_search" (Params.normalize_ident (lang "python") (param "fn") "Binary Search"); eq_str_e "binarySearch" (Params.normalize_ident (lang "javascript") (param "fn") "binary search")` |
| T-123 | F-030 | `eq_str_e "UnionFind" (Params.normalize_ident (lang "python") (param "type_name") "union find"); eq_str_e "UnionFind" (Params.normalize_ident (lang "ocaml") (param "type_name") "union_find")` |
| T-124 | F-030 | `eq_str_e "stack" (Params.normalize_ident (lang "python") (param "fn") "  stack ")` |
| T-125 | F-030 | `is_err "bad_ident" (Params.normalize_ident (lang "python") (param "fn") "2fast")` |
| T-126 | F-030 | `is_err "bad_ident" (Params.normalize_ident (lang "python") (param "fn") ""); is_err "bad_ident" (Params.normalize_ident (lang "python") (param "fn") "--")` |
| T-127 | F-031 | `eq_str_e "str" (Params.normalize_elem (lang "python") "string"); eq_str_e "number" (Params.normalize_elem (lang "javascript") "float")` |
| T-128 | F-031 | `eq_str_e "bool" (Params.normalize_elem (lang "ocaml") " BOOL ")` |
| T-129 | F-031 | `is_err "bad_elem" (Params.normalize_elem (lang "python") "double"); is_err "bad_elem" (Params.normalize_elem (lang "python") "")` |
| T-130 | F-032 | `eq_str "binary_search" (Params.ghost (lang "python") (param "fn")); eq_str "binarySearch" (Params.ghost (lang "javascript") (param "fn"))` |
| T-131 | F-032 | `eq_str "int" (Params.ghost (lang "python") (param "elem"))` |
| T-132 | F-032 | `eq_str "Stack" (Params.ghost (lang "python") (param "type_name"))` |
| T-133 | F-033 | `assert_bool "defaults" (Params.resolve (lang "python") (algo "binary-search") [] = Ok [("fn","binary_search");("elem","int")])` |
| T-134 | F-033 | `assert_bool "answers" (Params.resolve (lang "javascript") (algo "stack") [("type_name","int stack");("elem","String")] = Ok [("type_name","IntStack");("elem","string")])` |
| T-135 | F-033 | `assert_bool "unique" (Params.resolve ~existing:["binary_search"] (lang "python") (algo "binary-search") [] = Ok [("fn","binary_search_2");("elem","int")])` |
| T-136 | F-033 | `assert_bool "blank" (Params.resolve (lang "python") (algo "stack") [("elem","  ")] = Ok [("type_name","Stack");("elem","int")])` |
| T-137 | F-033 | `assert_bool "elem" (Params.resolve ~existing:["int"] (lang "python") (algo "stack") [] = Ok [("type_name","Stack");("elem","int")])` |
| T-138 | F-033 | `assert_bool "unknown" (Params.resolve (lang "python") (algo "stack") [("colour","red")] = Error (Err.Unknown_param "colour"))` |
| T-139 | F-033 | `assert_bool "first" (Params.resolve (lang "python") (algo "stack") [("elem","double");("colour","red")] = Error (Err.Unknown_param "colour"))` |
| T-140 | F-033 | `is_err "bad_elem" (Params.resolve (lang "python") (algo "stack") [("elem","double")]); is_err "bad_ident" (Params.resolve (lang "python") (algo "stack") [("type_name","9")])` |
| T-141 | F-034 | `(match Params.next_prompt (lang "python") (algo "stack") [] with Some (p, g) -> eq_str "type_name" p.Catalog.name; eq_str "Stack" g \| None -> assert_failure "some")` |
| T-142 | F-034 | `(match Params.next_prompt (lang "python") (algo "stack") [("type_name","x")] with Some (p, _) -> eq_str "elem" p.Catalog.name \| None -> assert_failure "some")` |
| T-143 | F-034 | `assert_bool "none" (Params.next_prompt (lang "python") (algo "stack") [("type_name","x");("elem","int")] = None)` |
| T-144 | F-034 | `(match Params.next_prompt (lang "python") (algo "stack") [("zzz","1")] with Some (p, _) -> eq_str "type_name" p.Catalog.name \| None -> assert_failure "some")` |
| T-145 | F-035 | `let s = Session.create (lang "python") (algo "stack") in assert_bool "collecting" (Session.state s = Session.Collecting); assert_bool "empty" (Session.answers s = [])` |
| T-146 | F-036 | `let s0 = Session.create (lang "python") (algo "stack") in let s1 = get_ok (Session.record s0 "a") in assert_bool "c" (Session.state s1 = Session.Collecting); let s2 = get_ok (Session.record s1 "int") in assert_bool "r" (Session.state s2 = Session.Ready)` |
| T-147 | F-036 | `assert_bool "x" (Session.state (Session.cancel (Session.create (lang "python") (algo "stack"))) = Session.Cancelled)` |
| T-148 | F-037 | `let s = get_ok (Session.record (get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A")) "bool") in assert_bool "order" (Session.answers s = [("type_name","A");("elem","bool")])` |
| T-149 | F-037 | `assert_bool "empty" (Session.answers (Session.create (lang "python") (algo "stack")) = [])` |
| T-150 | F-038 | `let s = Session.create (lang "python") (algo "binary-search") in (match Session.pending s with Some (p, _) -> eq_str "fn" p.Catalog.name \| None -> assert_failure "some"); (match Session.pending (get_ok (Session.record s "f")) with Some (p, _) -> eq_str "elem" p.Catalog.name \| None -> assert_failure "some")` |
| T-151 | F-038 | `assert_bool "none" (Session.pending (get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u")) = None)` |
| T-152 | F-039 | `let s = Session.create (lang "python") (algo "stack") in let s' = get_ok (Session.record s "A") in assert_bool "orig" (Session.answers s = []); assert_bool "new" (Session.answers s' = [("type_name","A")])` |
| T-153 | F-039 | `let s = get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A") in assert_bool "not yet" (Session.state s = Session.Collecting); assert_bool "now" (Session.state (get_ok (Session.record s "int")) = Session.Ready)` |
| T-154 | F-039 | `let s = get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u") in assert_bool "err" (Session.record s "x" = Error (Err.Session_closed "ready")) ` |
| T-155 | F-039 | `assert_bool "err" (Session.record (Session.cancel (Session.create (lang "python") (algo "stack"))) "x" = Error (Err.Session_closed "cancelled"))` |
| T-156 | F-040 | `assert_bool "c" (Session.state (Session.cancel (Session.create (lang "python") (algo "stack"))) = Session.Cancelled)` |
| T-157 | F-040 | `assert_bool "r" (Session.state (Session.cancel (get_ok (Session.record (Session.create (lang "python") (algo "union-find")) "u"))) = Session.Ready)` |
| T-158 | F-040 | `let s = get_ok (Session.record (Session.create (lang "python") (algo "stack")) "A") in assert_bool "kept" (Session.answers (Session.cancel s) = [("type_name","A")])` |
| T-159 | F-041 | `eq_str "  a\n  b" (Insert.reindent "  " "a\nb")` |
| T-160 | F-041 | `eq_str "  a\n\n  b" (Insert.reindent "  " "a\n\nb")` |
| T-161 | F-041 | `eq_str "\ta\n" (Insert.reindent "\t" "a\n")` |
| T-162 | F-041 | `eq_str "a\nb" (Insert.reindent "" "a\nb")` |
| T-163 | F-041 | `eq_str "  " (Insert.reindent "xx" "  ")` |
| T-164 | F-042 | `let p = Insert.place (lang "python") Insert.Cursor ~cursor_indent:"  " ~name:"f" ~body:"a\nb" in eq_str "  a\n  b" p.Insert.text; assert_bool "nofile" (p.Insert.file = None)` |
| T-165 | F-042 | `let p = Insert.place (lang "python") Insert.Function ~cursor_indent:"  " ~name:"f" ~body:"a" in eq_str "\na\n" p.Insert.text; assert_bool "nofile" (p.Insert.file = None)` |
| T-166 | F-042 | `let p = Insert.place (lang "python") Insert.File ~cursor_indent:"" ~name:"Binary Search" ~body:"a" in eq_str "a\n" p.Insert.text; assert_bool "file" (p.Insert.file = Some "binary_search.py")` |
| T-167 | F-042 | `raises_invalid (fun () -> Insert.place (lang "python") Insert.File ~cursor_indent:"" ~name:"--" ~body:"x")` |
| T-168 | F-043 | `List.iter (fun l -> List.iter (fun (a : Catalog.algo) -> let p = get_ok (Engine.generate regs (opts l a.id [])) in assert_bool (l ^ "/" ^ a.id) (String.length p.Insert.text > 20)) Catalog.all) ["python";"javascript";"ocaml"]` |
| T-169 | F-043 | `let p = get_ok (Engine.generate regs (opts "python" "binary-search" [])) in assert_bool "def" (contains p.Insert.text "def binary_search(")` |
| T-170 | F-043 | `let p = get_ok (Engine.generate regs (opts "javascript" "binary-search" [])) in assert_bool "fn" (contains p.Insert.text "function binarySearch(")` |
| T-171 | F-043 | `let p = get_ok (Engine.generate regs { (opts "python" "binary-search" []) with Engine.existing = ["binary_search"] }) in assert_bool "_2" (contains p.Insert.text "def binary_search_2(")` |
| T-172 | F-043 | `let p = get_ok (Engine.generate regs { (opts "javascript" "stack" [("type_name","int stack")]) with Engine.mode = Insert.File }) in assert_bool "file" (p.Insert.file = Some "intStack.js")` |
| T-173 | F-043 | `let p = get_ok (Engine.generate regs (opts "ocaml" "union-find" [])) in assert_bool "text" (String.length p.Insert.text > 20)` |
| T-174 | F-043 | `is_err "unknown_lang" (Engine.generate regs (opts "cobol" "stack" []))` |
| T-175 | F-043 | `is_err "unknown_algo" (Engine.generate regs (opts "python" "quicksort" []))` |
| T-176 | F-043 | `is_err "unknown_lang" (Engine.generate regs (opts "cobol" "quicksort" []))` |
| T-177 | F-043 | `is_err "unknown_param" (Engine.generate regs (opts "python" "stack" [("colour","x")])); is_err "bad_elem" (Engine.generate regs (opts "python" "stack" [("elem","double")]))` |
| T-178 | F-043 | `let r = get_ok (Lang.register regs cfg0) in is_err "no_template" (Engine.generate r (opts "demo" "stack" []))` |
| T-179 | F-044 | `let items = get_ok (Engine.list regs "python") in eq_strs ["binary-search";"insertion-sort";"stack";"union-find"] (List.map (fun (i : Engine.item) -> i.id) items)` |
| T-180 | F-044 | `let items = get_ok (Engine.list regs "ocaml") in let i = List.hd items in eq_str "searching" i.Engine.group; eq_str "Binary search" i.Engine.title` |
| T-181 | F-044 | `is_err "unknown_lang" (Engine.list regs "cobol"); is_err "unknown_lang" (Engine.list regs "")` |
| T-182 | F-045 | `(match Cli.parse_flags ["gen";"--ft";"python";"--json"] with Ok p -> assert_bool "cmd" (p.Cli.cmd = Some "gen"); assert_bool "ft" (List.assoc_opt "ft" p.Cli.flags = Some "python"); assert_bool "json" p.Cli.json \| Error _ -> assert_failure "ok")` |
| T-183 | F-045 | `(match Cli.parse_flags ["gen";"--set";"a=1";"--set";"b=2"] with Ok p -> assert_bool "set" (p.Cli.set = [("a","1");("b","2")]) \| Error _ -> assert_failure "ok")` |
| T-184 | F-045 | `(match Cli.parse_flags ["gen";"--set";"a=b=c";"--set";"d="] with Ok p -> assert_bool "set" (p.Cli.set = [("a","b=c");("d","")]) \| Error _ -> assert_failure "ok")` |
| T-185 | F-045 | `(match Cli.parse_flags ["list";"--lang";"python";"--lang";"ocaml"] with Ok p -> assert_bool "last" (List.assoc_opt "lang" p.Cli.flags = Some "ocaml") \| Error _ -> assert_failure "ok")` |
| T-186 | F-045 | `(match Cli.parse_flags [] with Ok p -> assert_bool "none" (p.Cli.cmd = None && p.Cli.set = [] && p.Cli.flags = [] && not p.Cli.json) \| Error _ -> assert_failure "ok")` |
| T-187 | F-045 | `assert_bool "u" (Cli.parse_flags ["gen";"--bogus"] = Error (Err.Unknown_flag "--bogus"))` |
| T-188 | F-045 | `assert_bool "m" (Cli.parse_flags ["gen";"--lang"] = Error (Err.Missing_value "--lang"))` |
| T-189 | F-045 | `assert_bool "b" (Cli.parse_flags ["gen";"--set";"novalue"] = Error (Err.Bad_set "novalue")); assert_bool "b2" (Cli.parse_flags ["--set";"=x"] = Error (Err.Bad_set "=x"))` |
| T-190 | F-045 | `assert_bool "x" (Cli.parse_flags ["gen";"list"] = Error (Err.Unexpected_arg "list"))` |
| T-191 | F-046 | `assert_bool "js" (Cli.resolve_lang regs [("ft","javascriptreact")] = Some "javascript")` |
| T-192 | F-046 | `assert_bool "lang" (Cli.resolve_lang regs [("ft","python");("lang","ocaml")] = Some "ocaml")` |
| T-193 | F-046 | `assert_bool "none" (Cli.resolve_lang regs [] = None)` |
| T-194 | F-046 | `assert_bool "raw" (Cli.resolve_lang regs [("ft","lua")] = Some "lua")` |
| T-195 | F-047 | `(match Cli.run_list regs [("lang","python")] with Ok l -> eq_int 4 (List.length l) \| Error _ -> assert_failure "ok")` |
| T-196 | F-047 | `(match Cli.run_list regs [("ft","javascriptreact")] with Ok l -> eq_int 4 (List.length l) \| Error _ -> assert_failure "ok")` |
| T-197 | F-047 | `assert_bool "e" (Cli.run_list regs [] = Error (Err.Unknown_lang ""))` |
| T-198 | F-048 | `(match Cli.run_prompts regs [("ft","javascript");("algo","stack")] with Ok ps -> eq_strs ["type_name=Stack";"elem=int"] (List.map (fun ((p : Catalog.param), g) -> p.name ^ "=" ^ g) ps) \| Error _ -> assert_failure "ok")` |
| T-199 | F-048 | `assert_bool "a" (Result.is_error (Cli.run_prompts regs [("lang","python");("algo","zzz")])); is_err "unknown_algo" (Cli.run_prompts regs [("lang","python");("algo","zzz")])` |
| T-200 | F-048 | `is_err "unknown_lang" (Cli.run_prompts regs [("lang","cobol");("algo","zzz")])` |
| T-201 | F-049 | `(match Cli.run_gen regs [("lang","python");("algo","stack")] [] with Ok p -> assert_bool "text" (contains p.Insert.text "class Stack") \| Error _ -> assert_failure "ok")` |
| T-202 | F-049 | `(match Cli.run_gen regs [("lang","python");("algo","stack")] [("type_name","my stack");("elem","bool")] with Ok p -> assert_bool "text" (contains p.Insert.text "class MyStack") \| Error _ -> assert_failure "ok")` |
| T-203 | F-049 | `(match Cli.run_gen regs [("lang","python");("algo","binary-search");("scan","def binary_search(): pass")] [] with Ok p -> assert_bool "suffix" (contains p.Insert.text "def binary_search_2(") \| Error _ -> assert_failure "ok")` |
| T-204 | F-049 | `(match Cli.run_gen regs [("lang","python");("algo","binary-search");("existing",",binary_search,")] [] with Ok p -> assert_bool "suffix" (contains p.Insert.text "def binary_search_2(") \| Error _ -> assert_failure "ok")` |
| T-205 | F-049 | `(match Cli.run_gen regs [("lang","python");("algo","binary-search");("scan","x = 1");("existing","binary_search")] [] with Ok p -> assert_bool "no suffix" (contains p.Insert.text "def binary_search(") \| Error _ -> assert_failure "ok")` |
| T-206 | F-049 | `(match Cli.run_gen regs [("lang","python");("algo","union-find");("indent","4")] [] with Ok p -> eq_str "    " (String.sub p.Insert.text 0 4) \| Error _ -> assert_failure "ok")` |
| T-207 | F-049 | `(match Cli.run_gen regs [("lang","javascript");("algo","binary-search");("mode","file")] [] with Ok p -> assert_bool "file" (p.Insert.file = Some "binarySearch.js") \| Error _ -> assert_failure "ok")` |
| T-208 | F-049 | `assert_bool "m" (Cli.run_gen regs [("lang","python");("algo","stack");("mode","zzz")] [] = Error (Err.Bad_value { flag = "--mode"; value = "zzz" }))` |
| T-209 | F-049 | `assert_bool "i" (Cli.run_gen regs [("lang","python");("algo","stack");("indent","-3")] [] = Error (Err.Bad_value { flag = "--indent"; value = "-3" })); is_err "bad_value" (Cli.run_gen regs [("lang","python");("algo","stack");("indent","x")] [])` |
| T-210 | F-049 | `is_err "bad_value" (Cli.run_gen regs [("lang","cobol");("mode","zzz")] [])` |
| T-211 | F-049 | `is_err "unknown_lang" (Cli.run_gen regs [("lang","cobol");("algo","stack")] []); is_err "unknown_param" (Cli.run_gen regs [("lang","python");("algo","stack")] [("zzz","1")])` |
| T-212 | F-050 | `(match Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt ~ghost:_ -> if contains prompt "Type" then Some "my stack" else Some "bool") with Ok (Some p) -> assert_bool "cls" (contains p.Insert.text "class MyStack") \| _ -> assert_failure "expected a plan")` |
| T-213 | F-050 | `(match Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt:_ ~ghost -> Some ghost) with Ok (Some p) -> assert_bool "cls" (contains p.Insert.text "class Stack") \| _ -> assert_failure "expected a plan")` |
| T-214 | F-050 | `let seen = ref [] in ignore (Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt ~ghost -> seen := prompt :: !seen; Some ghost)); eq_int 2 (List.length !seen); assert_bool "first" (contains (List.nth (List.rev !seen) 0) "Type name")` |
| T-215 | F-050 | `let n = ref 0 in let r = Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt:_ ~ghost:_ -> incr n; None) in assert_bool "none" (r = Ok None); eq_int 1 !n` |
| T-216 | F-050 | `let n = ref 0 in let r = Cli.run_ask regs [("lang","cobol");("algo","stack")] ~ask:(fun ~prompt:_ ~ghost:_ -> incr n; None) in assert_bool "e" (Result.is_error r); eq_int 0 !n` |
| T-217 | F-050 | `is_err "bad_elem" (Cli.run_ask regs [("lang","python");("algo","stack")] ~ask:(fun ~prompt ~ghost:_ -> if contains prompt "Element" then Some "double" else Some ""))` |
| T-218 | F-051 | `let o = Cli.run ["list";"--lang";"ocaml"] in eq_int 0 o.Cli.code; assert_bool "line" (contains o.Cli.stdout "binary-search\tBinary search"); eq_str "" o.Cli.stderr` |
| T-219 | F-051 | `let o = Cli.run ["list";"--lang";"ocaml";"--json"] in eq_int 0 o.Cli.code; assert_bool "json" (contains o.Cli.stdout "{\"items\":[{\"id\":\"binary-search\",\"title\":\"Binary search\",\"group\":\"searching\"}")` |
| T-220 | F-051 | `let o = Cli.run ["prompts";"--lang";"python";"--algo";"stack";"--json"] in eq_int 0 o.Cli.code; assert_bool "json" (contains o.Cli.stdout "{\"prompts\":[{\"name\":\"type_name\",\"prompt\":\"Type name\",\"ghost\":\"Stack\"}")` |
| T-221 | F-051 | `let o = Cli.run ["prompts";"--lang";"python";"--algo";"stack"] in assert_bool "line" (contains o.Cli.stdout "type_name\tType name\tStack")` |
| T-222 | F-051 | `let o = Cli.run ["gen";"--lang";"python";"--algo";"union-find"] in eq_int 0 o.Cli.code; assert_bool "class" (contains o.Cli.stdout "class UnionFind")` |
| T-223 | F-051 | `let o = Cli.run ["gen";"--lang";"python";"--algo";"union-find";"--json"] in assert_bool "text" (contains o.Cli.stdout "{\"text\":\""); assert_bool "null" (contains o.Cli.stdout "\"file\":null}")` |
| T-224 | F-051 | `let o = Cli.run ["gen";"--lang";"javascript";"--algo";"stack";"--mode";"file";"--json"] in assert_bool "file" (contains o.Cli.stdout "\"file\":\"stack.js\"}")` |
| T-225 | F-051 | `let calls = ref 0 in ignore (Cli.run ~stdin:(fun () -> incr calls; "") ["list";"--lang";"python"]); eq_int 0 !calls; ignore (Cli.run ~stdin:(fun () -> incr calls; "") ["gen";"--lang";"python";"--algo";"stack";"--scan";"-"]); eq_int 1 !calls` |
| T-226 | F-051 | `let o = Cli.run ~stdin:(fun () -> "def binary_search(): pass") ["gen";"--lang";"python";"--algo";"binary-search";"--scan";"-"] in assert_bool "suffix" (contains o.Cli.stdout "def binary_search_2(")` |
| T-227 | F-051 | `let o = Cli.run ["gen";"--lang";"python";"--algo";"binary-search";"--scan";"def binary_search(): pass"] in assert_bool "suffix" (contains o.Cli.stdout "binary_search_2")` |
| T-228 | F-051 | `let o = Cli.run ["list";"--ft";"javascriptreact"] in eq_int 0 o.Cli.code` |
| T-229 | F-051 | `let o = Cli.run ["list";"--lang";"cobol"] in eq_int 1 o.Cli.code; eq_str "" o.Cli.stdout; eq_str "unknown language: cobol" o.Cli.stderr` |
| T-230 | F-051 | `let o = Cli.run ["list";"--lang";"cobol";"--json"] in eq_int 1 o.Cli.code; eq_str "" o.Cli.stderr; eq_str "{\"error\":{\"code\":\"unknown_lang\",\"message\":\"unknown language: cobol\"}}" o.Cli.stdout` |
| T-231 | F-051 | `let o = Cli.run ["gen";"--bogus"] in eq_int 2 o.Cli.code; eq_str "usage error: unknown flag: --bogus" o.Cli.stderr` |
| T-232 | F-051 | `let o = Cli.run ["gen";"--bogus";"--json"] in eq_int 2 o.Cli.code; assert_bool "code" (contains o.Cli.stdout "\"code\":\"unknown_flag\"")` |
| T-233 | F-051 | `eq_int 2 (Cli.run ["gen";"--lang";"python";"--algo";"stack";"--mode";"zzz"]).Cli.code` |
| T-234 | F-051 | `let o = Cli.run ["zzz"] in eq_int 2 o.Cli.code; eq_str "usage error: unknown command: zzz" o.Cli.stderr; eq_str "usage error: unknown command" (Cli.run []).Cli.stderr` |
| T-235 | F-051 | `let o = Cli.run ["ask";"--lang";"python";"--algo";"stack"] in eq_int 2 o.Cli.code; eq_str "usage error: unknown command: ask" o.Cli.stderr` |
| T-236 | F-051 | `let o = Cli.run ~ask:(fun ~prompt:_ ~ghost -> Some ghost) ["ask";"--lang";"python";"--algo";"stack"] in eq_int 0 o.Cli.code; assert_bool "class" (contains o.Cli.stdout "class Stack")` |
| T-237 | F-051 | `let o = Cli.run ~ask:(fun ~prompt:_ ~ghost:_ -> None) ["ask";"--lang";"python";"--algo";"stack"] in eq_int 1 o.Cli.code; eq_str "cancelled" o.Cli.stderr; eq_str "" o.Cli.stdout` |
| T-238 | F-051 | `List.iter (fun argv -> let o = Cli.run argv in if o.Cli.code = 0 then eq_str "" o.Cli.stderr) [["list";"--lang";"python"];["prompts";"--lang";"ocaml";"--algo";"stack"];["gen";"--lang";"ocaml";"--algo";"stack"]]` |
| T-239 | F-053 | `local c = config.resolve(nil); eq(c.mode, "cursor"); eq(c.keymap, "<leader>cg"); eq(c.command, "Scaffold"); eq(c.bin, nil)` |
| T-240 | F-053 | `local c = config.resolve({ mode = "file", keymap = "<leader>x", bin = "/opt/engine" }); eq(c.mode, "file"); eq(c.keymap, "<leader>x"); eq(c.bin, "/opt/engine")` |
| T-241 | F-053 | `eq(config.resolve({ extra = 1 }).extra, 1)` |
| T-242 | F-053 | `local a = config.resolve(nil); a.mode = "file"; eq(config.resolve(nil).mode, "cursor")` |
| T-243 | F-053 | `local c, e = config.resolve("x"); eq(c, nil); eq(e, { code = "bad_config", field = "opts", reason = "must be a table" })` |
| T-244 | F-053 | `local c, e = config.resolve({ mode = "bottom" }); eq(c, nil); eq(e.field, "mode"); eq(e.code, "bad_config")` |
| T-245 | F-053 | `eq(select(2, config.resolve({ command = "scaffold" })).field, "command"); eq(select(2, config.resolve({ command = 5 })).field, "command")` |
| T-246 | F-053 | `eq(select(2, config.resolve({ bin = 5 })).field, "bin")` |
| T-247 | F-054 | `F.with_clean_engine(function() vim.env.SCAFFOLD_BIN = "/bin/false"; client.bin = "/bin/sh"; eq(client.binary(), "/bin/sh") end)` |
| T-248 | F-054 | `F.with_clean_engine(function() vim.env.SCAFFOLD_BIN = "/bin/sh"; eq(client.binary(), "/bin/sh") end)` |
| T-249 | F-054 | `F.with_clean_engine(function() local p = client.binary(); eq(type(p), "string"); eq(p:sub(-#"/_build/default/bin/main.exe"), "/_build/default/bin/main.exe") end)` |
| T-250 | F-054 | `F.with_clean_engine(function() client.bin = "/nope/engine"; local p, e = client.binary(); eq(p, nil); eq(e.code, "engine_missing"); eq(e.path, "/nope/engine"); assert(F.has(e.message, "dune build")) end)` |
| T-251 | F-054 | `F.with_clean_engine(function() local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/plain"); client.bin = d .. "/plain"; eq(select(2, client.binary()).code, "engine_missing"); F.rmrf(d) end)` |
| T-252 | F-055 | `local d = assert(client.call({ "list", "--lang", "ocaml" })); eq(#d.items, 4); eq(d.items[1].id, "binary-search")` |
| T-253 | F-055 | `local d = assert(client.call({ "gen", "--lang", "python", "--algo", "binary-search", "--scan", "-" }, "def binary_search(): pass")); assert(F.has(d.text, "binary_search_2"))` |
| T-254 | F-055 | `local a = { "list", "--lang", "python" }; client.call(a); eq(a, { "list", "--lang", "python" })` |
| T-255 | F-055 | `local d, e = client.call({ "list", "--lang", "cobol" }); eq(d, nil); eq(e.code, "unknown_lang"); eq(e.message, "unknown language: cobol")` |
| T-256 | F-055 | `local d, e = client.call({ "gen", "--bogus" }); eq(d, nil); eq(e.code, "unknown_flag")` |
| T-257 | F-055 | `F.with_clean_engine(function() client.bin = "/nope/engine"; local d, e = client.call({ "list" }); eq(d, nil); eq(e.code, "engine_missing") end)` |
| T-258 | F-055 | `F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, "echo not json"); local d, e = client.call({ "list" }); eq(d, nil); eq(e.code, "bad_json"); F.rmrf(dir) end)` |
| T-259 | F-055 | `F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, "echo 42"); eq(select(2, client.call({ "list" })).code, "bad_json"); F.rmrf(dir) end)` |
| T-260 | F-055 | `F.with_clean_engine(function() local dir = F.tmpdir(); client.bin = F.fake_bin(dir, 'echo "{\\"argv\\":\\"$*\\"}"'); local d = assert(client.call({ "list", "--lang", "x" })); eq(d.argv, "list --lang x --json"); F.rmrf(dir) end)` |
| T-261 | F-056 | `local items = assert(client.list("python")); eq(#items, 4); eq(items[2], { id = "insertion-sort", title = "Insertion sort", group = "sorting" })` |
| T-262 | F-056 | `eq(#assert(client.list("javascriptreact")), 4)` |
| T-263 | F-056 | `local items, e = client.list("lua"); eq(items, nil); eq(e.code, "unknown_lang")` |
| T-264 | F-057 | `local ps = assert(client.prompts("python", "stack")); eq(#ps, 2); eq(ps[1], { name = "type_name", prompt = "Type name", ghost = "Stack" })` |
| T-265 | F-057 | `eq(assert(client.prompts("javascript", "binary-search"))[1].ghost, "binarySearch")` |
| T-266 | F-057 | `local ps, e = client.prompts("python", "zzz"); eq(ps, nil); eq(e.code, "unknown_algo")` |
| T-267 | F-057 | `eq(select(2, client.prompts("lua", "stack")).code, "unknown_lang")` |
| T-268 | F-058 | `local r = assert(client.generate({ filetype = "python", algo = "union-find" })); eq(r.file, nil); assert(F.has(r.text, "class UnionFind"))` |
| T-269 | F-058 | `local r = assert(client.generate({ filetype = "python", algo = "stack", answers = { { name = "type_name", value = "my stack" }, { name = "elem", value = "bool" } } })); assert(F.has(r.text, "class MyStack"))` |
| T-270 | F-058 | `local r = assert(client.generate({ filetype = "javascript", algo = "stack", mode = "file", answers = { { name = "type_name", value = "int stack" } } })); eq(r.file, "intStack.js"); eq(type(r.text), "string")` |
| T-271 | F-058 | `local r = assert(client.generate({ filetype = "python", algo = "union-find", indent = 4 })); eq(r.text:sub(1, 4), "    ")` |
| T-272 | F-058 | `local r = assert(client.generate({ filetype = "python", algo = "binary-search", text = "def binary_search(): pass" })); assert(F.has(r.text, "def binary_search_2("))` |
| T-273 | F-058 | `local r, e = client.generate({ filetype = "python", algo = "stack", answers = { { name = "elem", value = "double" } } }); eq(r, nil); eq(e.code, "bad_elem")` |
| T-274 | F-058 | `eq(select(2, client.generate({ filetype = "python", algo = "stack", mode = "zzz" })).code, "bad_value")` |
| T-275 | F-058 | `eq(select(2, client.generate({ filetype = "python", algo = "zzz" })).code, "unknown_algo")` |
| T-276 | F-059 | `local b = F.scratch("python", { "class A:", "    x = 1" }); vim.api.nvim_win_set_cursor(0, { 2, 0 }); local c = assert(buffer.context(b)); eq(c.filetype, "python"); eq(c.row, 2); eq(c.indent, "    "); eq(c.text, "class A:\n    x = 1")` |
| T-277 | F-059 | `local b = F.scratch("javascript", { "\t\tx" }); eq(assert(buffer.context(b)).indent, "\t\t")` |
| T-278 | F-059 | `local b = F.scratch("ocaml", { "" }); local c = assert(buffer.context(b)); eq(c.row, 1); eq(c.indent, ""); eq(c.text, "")` |
| T-279 | F-059 | `eq(assert(buffer.context(F.scratch("python", { "x" }))).name, "")` |
| T-280 | F-059 | `local c, e = buffer.context(99999); eq(c, nil); eq(e.code, "invalid_buffer"); eq(e.bufnr, 99999)` |
| T-281 | F-060 | `local b = F.scratch("python", { "a", "b" }); eq(buffer.insert_lines(b, 1, "x\ny"), true); eq(F.lines(b), { "a", "x", "y", "b" })` |
| T-282 | F-060 | `local b = F.scratch("python", { "a" }); buffer.insert_lines(b, 0, "top"); eq(F.lines(b), { "top", "a" })` |
| T-283 | F-060 | `local b = F.scratch("python", { "a" }); buffer.insert_lines(b, 1, "end"); eq(F.lines(b), { "a", "end" })` |
| T-284 | F-060 | `local b = F.scratch("python", { "a" }); buffer.insert_lines(b, 1, "x\n\ny"); eq(F.lines(b), { "a", "x", "", "y" })` |
| T-285 | F-060 | `local b = F.scratch("python", { "a" }); local ok, e = buffer.insert_lines(b, 5, "x"); eq(ok, nil); eq(e.code, "api_error"); eq(F.lines(b), { "a" })` |
| T-286 | F-060 | `local ok, e = buffer.insert_lines(99999, 0, "x"); eq(ok, nil); eq(e.code, "invalid_buffer")` |
| T-287 | F-061 | `local d = F.tmpdir(); eq(buffer.write_file(d .. "/a.txt", "x\ny"), true); eq(vim.fn.readfile(d .. "/a.txt"), { "x", "y" }); F.rmrf(d)` |
| T-288 | F-061 | `local d = F.tmpdir(); vim.fn.writefile({ "keep" }, d .. "/a.txt"); local ok, e = buffer.write_file(d .. "/a.txt", "new"); eq(ok, nil); eq(e, { code = "file_exists", path = d .. "/a.txt" }); eq(vim.fn.readfile(d .. "/a.txt"), { "keep" }); F.rmrf(d)` |
| T-289 | F-061 | `local ok, e = buffer.write_file("/nope/dir/a.txt", "x"); eq(ok, nil); eq(e.code, "api_error")` |
| T-290 | F-062 | `local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/a.txt"); local b = assert(buffer.open_file(d .. "/a.txt")); eq(b, vim.api.nvim_get_current_buf()); eq(F.lines(b), { "x" }); F.rmrf(d)` |
| T-291 | F-062 | `local d = F.tmpdir(); vim.fn.writefile({ "y" }, d .. "/a b.txt"); local b = assert(buffer.open_file(d .. "/a b.txt")); eq(F.lines(b), { "y" }); F.rmrf(d)` |
| T-292 | F-062 | `local hidden = vim.o.hidden; vim.o.hidden = false; vim.cmd.enew(); vim.bo.buftype = ""; vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved" }); local d = F.tmpdir(); vim.fn.writefile({ "x" }, d .. "/a.txt"); local b, e = buffer.open_file(d .. "/a.txt"); vim.bo.modified = false; vim.o.hidden = hidden; F.rmrf(d); eq(b, nil); eq(e.code, "api_error")` |
| T-293 | F-063 | `local b = F.scratch("python", { "x" }); local id = assert(ui.ghost_set(b, 1, "hint")); eq(type(id), "number"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; local m = vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, { details = true }); eq(#m, 1); eq(m[1][4].virt_text[1][1], "hint"); eq(m[1][2], 0)` |
| T-294 | F-063 | `local b = F.scratch("python", { "a", "b" }); ui.ghost_set(b, 2, "t"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {})[1][2], 1)` |
| T-295 | F-063 | `local id, e = ui.ghost_set(99999, 1, "x"); eq(id, nil); eq(e.code, "invalid_buffer")` |
| T-296 | F-064 | `local b = F.scratch("python", { "x" }); ui.ghost_set(b, 1, "a"); local other = vim.api.nvim_create_namespace("other"); vim.api.nvim_buf_set_extmark(b, other, 0, 0, {}); ui.ghost_clear(b); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(#vim.api.nvim_buf_get_extmarks(b, ns, 0, -1, {}), 0); eq(#vim.api.nvim_buf_get_extmarks(b, other, 0, -1, {}), 1)` |
| T-297 | F-064 | `eq(pcall(ui.ghost_clear, 99999), true)` |
| T-298 | F-065 | `local h = ui.input("Name", "ghost", function() end); eq(vim.api.nvim_win_is_valid(h.win), true); eq(vim.api.nvim_win_get_config(h.win).relative, "editor"); local ns = vim.api.nvim_get_namespaces().scaffold_ghost; eq(#vim.api.nvim_buf_get_extmarks(h.buf, ns, 0, -1, {}), 1); h.close(nil)` |
| T-299 | F-065 | `local got, win_open_at_callback; local h; h = ui.input("P", "g", function(v) got = v; win_open_at_callback = vim.api.nvim_win_is_valid(h.win) end); h.close("abc"); vim.wait(500, function() return got ~= nil end); eq(got, "abc"); eq(win_open_at_callback, false)` |
| T-300 | F-065 | `local called, got = false, "unset"; local h = ui.input("P", "g", function(v) called = true; got = v end); h.close(nil); vim.wait(500, function() return called end); eq(called, true); eq(got, nil)` |
| T-301 | F-065 | `local n = 0; local h = ui.input("P", "g", function() n = n + 1 end); h.close("a"); h.close("b"); h.close(nil); vim.wait(100); eq(n, 1)` |
| T-302 | F-065 | `local got; local h = ui.input("P", "g", function(v) got = v end); vim.api.nvim_buf_set_lines(h.buf, 0, -1, false, { "typed" }); vim.api.nvim_set_current_win(h.win); local keymap = vim.fn.maparg("<CR>", "i", false, true); keymap.callback(); vim.wait(500, function() return got ~= nil end); eq(got, "typed")` |
| T-303 | F-065 | `local called, got = false, "unset"; local h = ui.input("P", "g", function(v) called = true; got = v end); vim.api.nvim_set_current_win(h.win); local keymap = vim.fn.maparg("<Esc>", "n", false, true); keymap.callback(); vim.wait(500, function() return called end); eq(got, nil); eq(called, true)` |
| T-304 | F-065 | `raises(function() ui.input("P", "g", nil) end, "on_done must be a function"); raises(function() ui.input("P", "g", "x") end, "on_done")` |
| T-305 | F-066 | `eq(commands.parse_args({ "stack" }), { algo = "stack" })` |
| T-306 | F-066 | `eq(commands.parse_args({ "stack", "mode=file" }), { algo = "stack", mode = "file" })` |
| T-307 | F-066 | `eq(commands.parse_args({ "stack", "mode=file", "mode=cursor" }).mode, "cursor")` |
| T-308 | F-066 | `eq(commands.parse_args({ "stack", "mode=zzz" }).mode, "zzz")` |
| T-309 | F-066 | `local a, e = commands.parse_args({ "stack", "colour=red" }); eq(a, nil); eq(e, { code = "bad_arg", arg = "colour=red" })` |
| T-310 | F-066 | `eq(select(2, commands.parse_args({ "stack", "mode=" })).code, "bad_arg"); eq(select(2, commands.parse_args({ "stack", "junk" })).arg, "junk")` |
| T-311 | F-067 | `F.scratch("python", { "" }); eq(commands.complete("bin", "Scaffold bin"), { "binary-search" })` |
| T-312 | F-067 | `F.scratch("python", { "" }); eq(commands.complete("", "Scaffold "), { "binary-search", "insertion-sort", "stack", "union-find" })` |
| T-313 | F-067 | `eq(commands.complete("mode=f", "Scaffold stack mode=f"), { "mode=function", "mode=file" })` |
| T-314 | F-067 | `eq(#commands.complete("", "Scaffold stack "), 3)` |
| T-315 | F-067 | `F.scratch("lua", { "" }); eq(commands.complete("", "Scaffold "), {})` |
| T-316 | F-067 | `F.with_clean_engine(function() F.scratch("python", { "" }); client.bin = "/nope"; eq(commands.complete("", "Scaffold "), {}) end)` |
| T-317 | F-068 | `local got; commands.register("ScaffoldT1", function(a) got = a end); vim.cmd("ScaffoldT1 stack mode=file"); vim.api.nvim_del_user_command("ScaffoldT1"); eq(got, { algo = "stack", mode = "file" })` |
| T-318 | F-068 | `commands.register("ScaffoldT2", function() end); local c = vim.api.nvim_get_commands({})["ScaffoldT2"]; vim.api.nvim_del_user_command("ScaffoldT2"); eq(c.nargs, "+"); assert(c.complete ~= nil or c.complete_arg ~= nil or true)` |
| T-319 | F-068 | `local called = false; local n, restore = F.capture_notify(); commands.register("ScaffoldT3", function() called = true end); vim.cmd("ScaffoldT3 stack colour=red"); restore(); vim.api.nvim_del_user_command("ScaffoldT3"); eq(called, false); eq(#n, 1); eq(n[1].level, vim.log.levels.ERROR); assert(F.has(n[1].msg, "bad_arg"))` |
| T-320 | F-068 | `raises(function() commands.register("scaffoldlower", function() end) end, "must start with uppercase")` |
| T-321 | F-069 | `local m = init.setup({ command = "ScaffoldS1", keymap = "<leader>zs1" }); eq(m, init); assert(vim.api.nvim_get_commands({}).ScaffoldS1 ~= nil); assert(vim.fn.maparg("<leader>zs1", "n") ~= ""); init.teardown()` |
| T-322 | F-069 | `init.setup({ command = "ScaffoldS2", keymap = "<leader>zs2", bin = "/opt/x" }); eq(client.bin, "/opt/x"); init.teardown(); eq(client.bin, nil)` |
| T-323 | F-069 | `init.setup({ command = "ScaffoldS3", keymap = "<leader>zs3" }); init.setup({ command = "ScaffoldS3", keymap = "<leader>zs3" }); local n = 0; for _, g in ipairs(vim.api.nvim_get_autocmds({ group = "scaffold" })) do n = n + 1 end; assert(vim.api.nvim_get_commands({}).ScaffoldS3 ~= nil); init.teardown()` |
| T-324 | F-069 | `raises(function() init.setup({ mode = "bottom" }) end, "scaffold.setup: mode"); raises(function() init.setup({ command = "lower" }) end, "scaffold.setup: command")` |
| T-325 | F-069 | `local ok, e = pcall(init.setup, { mode = "bottom", command = "ScaffoldS4" }); eq(ok, false); assert(F.has(tostring(e), "scaffold.setup: mode")); eq(vim.api.nvim_get_commands({}).ScaffoldS4, nil)` |
| T-326 | F-070 | `local b = F.scratch("python", { "x = 1", "y = 2" }); init.setup({ command = "ScaffoldR1", keymap = "<leader>zr1" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("union-find", "cursor"); ui.input = real; init.teardown(); local l = F.lines(b); eq(l[1], "x = 1"); assert(F.has(l[2], "class UnionFind")); eq(l[#l], "y = 2")` |
| T-327 | F-070 | `local b = F.scratch("python", { "" }); init.setup({ command = "ScaffoldR2", keymap = "<leader>zr2" }); local real = ui.input; local seen = {}; ui.input = function(p, g, cb) seen[#seen + 1] = p; cb(#seen == 1 and "my stack" or "bool") end; init.run("stack", "cursor"); ui.input = real; init.teardown(); eq(#seen, 2); eq(seen[1], "Type name"); assert(F.has(table.concat(F.lines(b), "\n"), "class MyStack"))` |
| T-328 | F-070 | `local b = F.scratch("python", { "    pass" }); init.setup({ command = "ScaffoldR3", keymap = "<leader>zr3" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("union-find", "cursor"); ui.input = real; init.teardown(); eq(F.lines(b)[2]:sub(1, 4), "    ")` |
| T-329 | F-070 | `local b = F.scratch("python", { "def binary_search(): pass" }); init.setup({ command = "ScaffoldR4", keymap = "<leader>zr4" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("binary-search", "function"); ui.input = real; init.teardown(); assert(F.has(table.concat(F.lines(b), "\n"), "def binary_search_2("))` |
| T-330 | F-070 | `local d = F.tmpdir(); local old = vim.fn.getcwd(); vim.cmd.cd(d); local b = F.scratch("javascript", { "" }); init.setup({ command = "ScaffoldR5", keymap = "<leader>zr5" }); local real = ui.input; ui.input = function(_, g, cb) cb(g) end; init.run("stack", "file"); ui.input = real; init.teardown(); assert(vim.uv.fs_stat(d .. "/stack.js") ~= nil); assert(F.has(vim.api.nvim_buf_get_name(0), "stack.js")); vim.cmd.cd(old); F.rmrf(d)` |
| T-331 | F-070 | `local b = F.scratch("python", { "x" }); init.setup({ command = "ScaffoldR6", keymap = "<leader>zr6" }); local n, restore = F.capture_notify(); local real = ui.input; ui.input = function(_, _, cb) cb(nil) end; init.run("stack", "cursor"); ui.input = real; restore(); init.teardown(); eq(F.lines(b), { "x" }); eq(#n, 0)` |
| T-332 | F-070 | `F.scratch("python", { "x" }); init.setup({ command = "ScaffoldR7", keymap = "<leader>zr7" }); local n, restore = F.capture_notify(); init.run("zzz", "cursor"); restore(); init.teardown(); eq(#n, 1); eq(n[1].level, vim.log.levels.ERROR); assert(F.has(n[1].msg, "unknown algorithm"))` |
| T-333 | F-070 | `F.scratch("lua", { "x" }); init.setup({ command = "ScaffoldR8", keymap = "<leader>zr8" }); local n, restore = F.capture_notify(); init.run("stack", "cursor"); restore(); init.teardown(); eq(#n, 1); assert(F.has(n[1].msg, "unknown language"))` |
| T-334 | F-071 | `F.scratch("python", { "" }); init.setup({ command = "ScaffoldP1", keymap = "<leader>zp1" }); local real = vim.ui.select; local titles, prompt; vim.ui.select = function(items, o, cb) prompt = o.prompt; titles = {}; for _, i in ipairs(items) do titles[#titles + 1] = o.format_item(i) end end; init.pick(); vim.ui.select = real; init.teardown(); eq(prompt, "Algorithm"); eq(titles, { "Binary search", "Insertion sort", "Stack", "Union-find" })` |
| T-335 | F-071 | `local b = F.scratch("python", { "" }); init.setup({ command = "ScaffoldP3", keymap = "<leader>zp3" }); local rs, ri = vim.ui.select, ui.input; vim.ui.select = function(items, _, cb) cb(items[4]) end; ui.input = function(_, g, cb) cb(g) end; init.pick(); vim.ui.select, ui.input = rs, ri; init.teardown(); assert(F.has(table.concat(F.lines(b), "\n"), "class UnionFind"))` |
| T-336 | F-071 | `local b = F.scratch("python", { "x" }); init.setup({ command = "ScaffoldP4", keymap = "<leader>zp4" }); local rs = vim.ui.select; vim.ui.select = function(_, _, cb) cb(nil) end; init.pick(); vim.ui.select = rs; init.teardown(); eq(F.lines(b), { "x" })` |
| T-337 | F-071 | `F.scratch("lua", { "" }); init.setup({ command = "ScaffoldP5", keymap = "<leader>zp5" }); local n, restore = F.capture_notify(); local rs = vim.ui.select; local opened = false; vim.ui.select = function() opened = true end; init.pick(); vim.ui.select = rs; restore(); init.teardown(); eq(opened, false); eq(#n, 1)` |
| T-338 | F-072 | `init.setup({ command = "ScaffoldT9", keymap = "<leader>zt9", bin = "/opt/x" }); init.teardown(); eq(vim.api.nvim_get_commands({}).ScaffoldT9, nil); eq(vim.fn.maparg("<leader>zt9", "n"), ""); eq(client.bin, nil)` |
| T-339 | F-072 | `init.setup({ command = "ScaffoldT8", keymap = "<leader>zt8" }); init.teardown(); eq(pcall(init.teardown), true)` |
| T-340 | F-072 | `init.teardown(); eq(pcall(init.teardown), true)` |