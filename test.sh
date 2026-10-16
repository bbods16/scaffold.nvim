#!/bin/sh
# usage: ./test.sh [module]    e.g. ./test.sh util
if [ -z "$1" ]; then dune test; exit $?; fi
dune build ./test/main.exe 2>&1 | head -20
P=$(dune exec test/main.exe -- -list-test 2>/dev/null | grep "^scaffold:[0-9]*:$1:" | head -1 | cut -d: -f1-3)
if [ -z "$P" ]; then echo "no such test module: $1"; exit 2; fi
dune exec test/main.exe -- -only-test "$P"
