# SETUP

Parts 0-8 need only OCaml, dune and ounit2. Parts 9-10 also need Neovim 0.10 or newer.

## 1. Toolchain
- **Linux / macOS:** install opam (see https://ocaml.org/docs/install.html), then something like:
  `opam init`, `opam switch create 4.14.1` (any OCaml 4.14 or newer works), `eval $(opam env)`, `opam install dune ounit2`.
  (The ocaml.org page was fetched and checked by the author; the exact opam commands were NOT run by the author, because the build machine had no opam. Follow the page if they differ.)
- **Windows:** use WSL2 (https://learn.microsoft.com/en-us/windows/wsl/install), then follow the Linux steps *inside* the WSL shell, including Neovim. Native Windows OCaml is described on ocaml.org but was not tested.
- Check: `ocaml -version`, `dune --version` (3.0 or newer), `ocamlfind list | grep ounit`.
- The skeleton was verified with OCaml 4.14.1, dune 3.14.0, Neovim 0.10.4.

## 2. First build and first red run
```sh
tar -xzf scaffold.nvim-skeleton.tgz     # outside the folder that holds the docs
cd scaffold.nvim
dune build            # stubs compile; warnings are shown, never fatal
dune test             # expect: Errors 238  (every one says "not implemented: F-nnn")
sh test/acceptance.sh # expect FAIL lines until Part 8
```

## 3. Working on one module
```sh
./test.sh util        # runs only test/test_util.ml (module names: util naming err json lang langs template catalog collision params session insert engine cli)
./test.sh             # everything
```
Read the stub's comment, the contract in the spec (Section 15) and the activity diagram `AD-nnn`, then make the tests pass.

## 4. Lua edge (Parts 9-10)
```sh
dune build                                   # the plugin needs _build/default/bin/main.exe
nvim --headless -u NONE -l lua_test/run.lua 2>&1 | tail -3      # all
nvim --headless -u NONE -l lua_test/run.lua client 2>&1 | tail  # one module
```
(`nvim -l` prints to stderr, hence `2>&1`.) The plugin finds the engine at `_build/default/bin/main.exe`; override with `opts.bin` or the `SCAFFOLD_BIN` environment variable.

## 5. Wire into LazyVim (end of Part 10)
See FX-17 in the spec. Option names for lazy.nvim there are unverified: check the lazy.nvim documentation.

## 6. Before you commit or stream
Read STREAMING_SECURITY.md (it is separate and personal; keep it out of this folder).
