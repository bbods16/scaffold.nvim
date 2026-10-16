# PROGRESS

Tick a function when its tests are green. `[R]` required, `[S]` stretch (see the cut list in the spec).

## Part 0: Setup and first red tests (35 min, session S1)

- [ ] [R] F-001 `Util.trim` (`lib/util.ml`) tests T-001..T-003
- [ ] [R] F-002 `Util.starts_with` (`lib/util.ml`) tests T-004..T-006
- [ ] research questions answered in notes/NOTES.md: RQ-0-1, RQ-0-2, RQ-0-3
- [ ] checkpoint: `dune build` succeeds; the six `Util.trim`/`Util.starts_with` tests are green; the other 232 OCaml tests still fail with `not implemented`.

## Part 1: Strings and names (find_sub, split, leading_ws, words, convert) (80 min, session S1)

- [ ] [R] F-003 `Util.find_sub` (`lib/util.ml`) tests T-007..T-010
- [ ] [R] F-004 `Util.split` (`lib/util.ml`) tests T-011..T-014
- [ ] [R] F-005 `Util.leading_ws` (`lib/util.ml`) tests T-015..T-017
- [ ] [R] F-006 `Naming.words` (`lib/naming.ml`) tests T-018..T-022
- [ ] [R] F-007 `Naming.convert` (`lib/naming.ml`) tests T-023..T-027
- [ ] research questions answered in notes/NOTES.md: RQ-1-1, RQ-1-2, RQ-1-3
- [ ] checkpoint: the Part 1 tests green (21); Part 0 tests still green.

## Part 2: Errors and JSON (Err, Json) (45 min, session S2)

- [ ] [R] F-008 `Err.code` (`lib/err.ml`) tests T-028..T-030
- [ ] [R] F-009 `Err.message` (`lib/err.ml`) tests T-031..T-035
- [ ] [R] F-010 `Json.escape` (`lib/json.ml`) tests T-036..T-039
- [ ] [R] F-011 `Json.to_string` (`lib/json.ml`) tests T-040..T-044
- [ ] research questions answered in notes/NOTES.md: RQ-2-1, RQ-2-2, RQ-2-3
- [ ] checkpoint: `test_err` and `test_json` green (17 tests).

## Part 3: Language registry (Lang, Langs) (75 min, session S2)

- [ ] [R] F-012 `Lang.validate` (`lib/lang.ml`) tests T-045..T-052
- [ ] [R] F-013 `Lang.derive` (`lib/lang.ml`) tests T-053..T-056
- [ ] [R] F-014 `Lang.register` (`lib/lang.ml`) tests T-057..T-061
- [ ] [R] F-015 `Lang.find` (`lib/lang.ml`) tests T-062..T-064
- [ ] [R] F-016 `Lang.find_by_filetype` (`lib/lang.ml`) tests T-065..T-067
- [ ] [R] F-017 `Lang.file_name` (`lib/lang.ml`) tests T-068..T-071
- [ ] [R] F-018 `Lang.elem_type` (`lib/lang.ml`) tests T-072..T-074
- [ ] [R] F-019 `Langs.install` (`lib/langs.ml`) tests T-075..T-078
- [ ] research questions answered in notes/NOTES.md: RQ-3-1, RQ-3-2, RQ-3-3
- [ ] checkpoint: `test_lang` and `test_langs` green (34 tests).

## Part 4: Template language (Template) (90 min, session S3)

- [ ] [R] F-020 `Template.scan_tag` (`lib/template.ml`) tests T-079..T-085
- [ ] [R] F-021 `Template.parse` (`lib/template.ml`) tests T-086..T-090
- [ ] [R] F-022 `Template.vars` (`lib/template.ml`) tests T-091..T-093
- [ ] [R] F-023 `Template.apply_filter` (`lib/template.ml`) tests T-094..T-096
- [ ] [R] F-024 `Template.render` (`lib/template.ml`) tests T-097..T-101
- [ ] research questions answered in notes/NOTES.md: RQ-4-1, RQ-4-2, RQ-4-3
- [ ] checkpoint: `test_template` green (23 tests).

## Part 5: Catalog and collisions (Catalog, Collision) (45 min, session S4)

- [ ] [R] F-025 `Catalog.find` (`lib/catalog.ml`) tests T-102..T-104
- [ ] [R] F-026 `Catalog.template` (`lib/catalog.ml`) tests T-105..T-107
- [ ] [R] F-027 `Catalog.for_lang` (`lib/catalog.ml`) tests T-108..T-110
- [ ] [R] F-028 `Collision.unique_name` (`lib/collision.ml`) tests T-111..T-114
- [ ] [R] F-029 `Collision.defined_names` (`lib/collision.ml`) tests T-115..T-121
- [ ] research questions answered in notes/NOTES.md: RQ-5-1, RQ-5-2, RQ-5-3
- [ ] checkpoint: `test_catalog` and `test_collision` green (20 tests).

## Part 6: Parameters and sessions (Params, Session) (75 min, session S4)

- [ ] [R] F-030 `Params.normalize_ident` (`lib/params.ml`) tests T-122..T-126
- [ ] [R] F-031 `Params.normalize_elem` (`lib/params.ml`) tests T-127..T-129
- [ ] [R] F-032 `Params.ghost` (`lib/params.ml`) tests T-130..T-132
- [ ] [R] F-033 `Params.resolve` (`lib/params.ml`) tests T-133..T-140
- [ ] [S] F-034 `Params.next_prompt` (`lib/params.ml`) tests T-141..T-144
- [ ] [S] F-035 `Session.create` (`lib/session.ml`) tests T-145
- [ ] [S] F-036 `Session.state` (`lib/session.ml`) tests T-146..T-147
- [ ] [S] F-037 `Session.answers` (`lib/session.ml`) tests T-148..T-149
- [ ] [S] F-038 `Session.pending` (`lib/session.ml`) tests T-150..T-151
- [ ] [S] F-039 `Session.record` (`lib/session.ml`) tests T-152..T-155
- [ ] [S] F-040 `Session.cancel` (`lib/session.ml`) tests T-156..T-158
- [ ] research questions answered in notes/NOTES.md: RQ-6-1, RQ-6-2, RQ-6-3
- [ ] checkpoint: `test_params` and `test_session` green (37 tests).

## Part 7: Placement and the pipeline (Insert, Engine) (60 min, session S5)

- [ ] [R] F-041 `Insert.reindent` (`lib/insert.ml`) tests T-159..T-163
- [ ] [R] F-042 `Insert.place` (`lib/insert.ml`) tests T-164..T-167
- [ ] [R] F-043 `Engine.generate` (`lib/engine.ml`) tests T-168..T-178
- [ ] [R] F-044 `Engine.list` (`lib/engine.ml`) tests T-179..T-181
- [ ] research questions answered in notes/NOTES.md: RQ-7-1, RQ-7-2, RQ-7-3
- [ ] checkpoint: `test_insert` and `test_engine` green (23 tests). Whole library green except `Cli`.

## Interlude: Test sweep (20 min, stretch)

- [ ] After Part 7, before the CLI: pick one representative test for every public function of Parts 0-7 (not all 200 or so; about 25 is plenty). For each one write one line in `notes/NOTES.md` naming the bug it catches that no other chosen test would. Then break one function on purpose (for example make `Collision.unique_name` return its input) and confirm a test goes red. This is the 'test the tester' step.

## Part 8: Command line and main (Cli, Main) (90 min, session S6)

- [ ] [R] F-045 `Cli.parse_flags` (`lib/cli.ml`) tests T-182..T-190
- [ ] [R] F-046 `Cli.resolve_lang` (`lib/cli.ml`) tests T-191..T-194
- [ ] [R] F-047 `Cli.run_list` (`lib/cli.ml`) tests T-195..T-197
- [ ] [R] F-048 `Cli.run_prompts` (`lib/cli.ml`) tests T-198..T-200
- [ ] [R] F-049 `Cli.run_gen` (`lib/cli.ml`) tests T-201..T-211
- [ ] [S] F-050 `Cli.run_ask` (`lib/cli.ml`) tests T-212..T-217
- [ ] [R] F-051 `Cli.run` (`lib/cli.ml`) tests T-218..T-238
- [ ] [R] F-052 `Main.main` (`bin/main.ml`) tests A-01..A-06
- [ ] research questions answered in notes/NOTES.md: RQ-8-1, RQ-8-2, RQ-8-3
- [ ] checkpoint: `dune test` fully green (238 tests); `sh test/acceptance.sh` shows six PASS (five if you cut `ask`).

## Part 9: Lua edge I: config, client, buffer (75 min, session S7)

- [ ] [R] F-053 `config.resolve` (`lua/scaffold/config.lua`) tests T-239..T-246
- [ ] [R] F-054 `client.binary` (`lua/scaffold/client.lua`) tests T-247..T-251
- [ ] [R] F-055 `client.call` (`lua/scaffold/client.lua`) tests T-252..T-260
- [ ] [R] F-056 `client.list` (`lua/scaffold/client.lua`) tests T-261..T-263
- [ ] [R] F-057 `client.prompts` (`lua/scaffold/client.lua`) tests T-264..T-267
- [ ] [R] F-058 `client.generate` (`lua/scaffold/client.lua`) tests T-268..T-275
- [ ] [R] F-059 `buffer.context` (`lua/scaffold/buffer.lua`) tests T-276..T-280
- [ ] [R] F-060 `buffer.insert_lines` (`lua/scaffold/buffer.lua`) tests T-281..T-286
- [ ] [S] F-061 `buffer.write_file` (`lua/scaffold/buffer.lua`) tests T-287..T-289
- [ ] [S] F-062 `buffer.open_file` (`lua/scaffold/buffer.lua`) tests T-290..T-292
- [ ] research questions answered in notes/NOTES.md: RQ-9-1, RQ-9-2, RQ-9-3
- [ ] checkpoint: `config`, `client`, `buffer` specs green (54 tests); Parts 0-8 still green.

## Part 10: Lua edge II: ui, commands, init and lazy.nvim (105 min, session S8)

- [ ] [R] F-063 `ui.ghost_set` (`lua/scaffold/ui.lua`) tests T-293..T-295
- [ ] [R] F-064 `ui.ghost_clear` (`lua/scaffold/ui.lua`) tests T-296..T-297
- [ ] [R] F-065 `ui.input` (`lua/scaffold/ui.lua`) tests T-298..T-304
- [ ] [R] F-066 `commands.parse_args` (`lua/scaffold/commands.lua`) tests T-305..T-310
- [ ] [S] F-067 `commands.complete` (`lua/scaffold/commands.lua`) tests T-311..T-316
- [ ] [R] F-068 `commands.register` (`lua/scaffold/commands.lua`) tests T-317..T-320
- [ ] [R] F-069 `init.setup` (`lua/scaffold/init.lua`) tests T-321..T-325
- [ ] [R] F-070 `init.run` (`lua/scaffold/init.lua`) tests T-326..T-333
- [ ] [S] F-071 `init.pick` (`lua/scaffold/init.lua`) tests T-334..T-337
- [ ] [R] F-072 `init.teardown` (`lua/scaffold/init.lua`) tests T-338..T-340
- [ ] research questions answered in notes/NOTES.md: RQ-10-1, RQ-10-2, RQ-10-3
- [ ] checkpoint: All 102 Lua tests green; `sh test/acceptance.sh` and `dune test` still green.
