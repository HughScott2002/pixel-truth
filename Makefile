# Pixel Truth. Five verbs:
#   make dev      enter the shell with every capture tool
#   make run      capture; ARGS="connecting" for a single pass
#   make build    build the capture shell, proving the flake resolves
#   make test     syntax-check the scripts, then run the self-checking
#                 connecting capture of the shipped profile
#   make release  tag the current commit v$(VERSION), signed, and push
#
# Nix does the work under every target; make is only the front door.

VERSION := 0.1.0
SYSTEM := $(shell nix eval --impure --expr builtins.currentSystem 2>/dev/null)

.PHONY: help dev run build test release

help:
	@echo "dev       enter the capture shell"
	@echo "run       capture; ARGS=\"connecting\" for a single pass"
	@echo "build     build the capture shell"
	@echo "test      syntax checks + self-checking connecting capture"
	@echo "release   tag v$(VERSION) and push it"

dev:
	nix develop

run:
	nix develop -c bash capture.sh $(ARGS)

build:
	nix build .#devShells.$(SYSTEM).default

test:
	bash -n capture.sh
	bash -n rowruns.sh
	bash -n diff.sh
	nix develop -c bash capture.sh connecting

release:
	@if ! git diff --quiet || ! git diff --cached --quiet; then \
	    echo "uncommitted changes; commit first" >&2; exit 1; \
	fi
	git tag -s "v$(VERSION)" -m "Pixel Truth v$(VERSION)"
	git push origin "v$(VERSION)"
