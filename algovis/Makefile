JSFILES=visualize/coderunner.js visualize/visualizer.js visualize/render.js visualize/test.js
COFFEEBIN=../coffee
FLAGS=-c

Default: $(JSFILES)

%.js: %.coffee
	$(COFFEEBIN) $(FLAGS) $< 2>&1 | sed -e "s@^@$<:@" 2>&1

