ELM = elm-make --warn --output
LOG = printf '%-12s  %s\n'

ELM_FILES = $(shell find src -name *.elm)


.PHONY: all
all: dist/index.html dist/index.js

.PHONY: clean
clean:
	rm -rf dist

dist/index.html: public/index.html
	@mkdir -p $(@D)
	@cp -f $< $@
	@$(LOG) 'Copy' "$< -> $@"

dist/index.js: $(ELM_FILES)
	@mkdir -p $(@D)
	@$(ELM) $@ $<
	@$(LOG) 'Build (Elm)' "$< -> $@"

