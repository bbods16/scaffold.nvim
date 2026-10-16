#!/bin/sh
# test/acceptance.sh  -- PROVIDED. End-to-end checks of the real binary (F-052 Main.main).
# Run from the project root after `dune build`:  sh test/acceptance.sh
BIN=${SCAFFOLD_BIN:-_build/default/bin/main.exe}
fail=0
check() { # name, args, stdin, want_exit, want_substring
  out=$(printf "%s" "$3" | $BIN $2 2>&1); code=$?
  if [ "$code" = "$4" ] && { [ -z "$5" ] || printf "%s" "$out" | grep -qF -- "$5"; }; then echo "PASS $1"; else echo "FAIL $1 (exit $code, want $4; output: $out)"; fail=1; fi
}
check "A-01 list prints algorithms and exits 0" "list --lang python" "$(printf '')" 0 'binary-search'
check "A-02 JSON mode" "list --lang ocaml --json" "$(printf '')" 0 '{"items":['
check "A-03 usage error exits 2" "gen --bogus" "$(printf '')" 2 'usage error: unknown flag: --bogus'
check "A-04 domain error exits 1" "list --lang cobol" "$(printf '')" 1 'unknown language: cobol'
check "A-05 stdin feeds --scan -" "gen --lang python --algo binary-search --scan -" "$(printf 'def binary_search(): pass
')" 0 'binary_search_2'
check "A-06 ask reads answers from stdin" "ask --lang python --algo stack" "$(printf 'MyStack
bool
')" 0 'class MyStack'
exit $fail
