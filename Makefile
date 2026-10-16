.PHONY: build test accept lua all
build:
	dune build
test:
	dune test
accept: build
	sh test/acceptance.sh
lua: build
	nvim --headless -u NONE -l lua_test/run.lua 2>&1 | tail -5
all: build test accept lua
