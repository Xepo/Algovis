JSFILES=generated/coderunner.js generated/visualizer.js generated/render.js generated/test.js generated/codeview.js
COFFEEBIN=../coffee
FLAGS=-c

Default: $(JSFILES)

generated/%.js: coffee/%.coffee
	$(COFFEEBIN) $(FLAGS) $< -o generated 2>&1 | sed -e "s@^@$<:@" 2>&1

default_snippets/%.js: default_snippets/%.coffee
	$(COFFEEBIN) $(FLAGS) $< -o default_snippets 2>&1 | sed -e "s@^@$<:@" 2>&1

