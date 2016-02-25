ELM_INSTALL = elm package install -y
ELM_MAKE = elm-make --warn
LOG = printf '%-12s  %s\n'

ELM_FILES = $(shell find src -name *.elm)


.PHONY: all
all: dist/index.html dist/index.js

.PHONY: clean
clean:
	rm -rf dist

.PHONY: setup
setup:
	@$(ELM_INSTALL)

dist/index.html: public/index.html
	@mkdir -p $(@D)
	@cp -f $< $@
	@$(LOG) 'Copy' "$< -> $@"

dist/index.js: $(ELM_FILES)
	@mkdir -p $(@D)
	@$(ELM_MAKE) --output $@ $<
	@$(LOG) 'Build (Elm)' "$< -> $@"

