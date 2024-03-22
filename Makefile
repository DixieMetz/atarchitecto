SRC = $(wildcard src/*.js)
TESTS = $(wildcard test/*.js)
BINS = node_modules/.bin
DUO = $(BINS)/duo
MINIFY = $(BINS)/uglifyjs
BUILD_DIR = build
PROJECT = amplitude
OUT = $(PROJECT).js
MIN_OUT = $(PROJECT).min.js
MOCHA = $(BINS)/mocha-phantomjs

#
# Default target.
#

default: test

#
# Clean.
#

clean:
	@-rm -rf components
	@-rm -f amplitude.js amplitude.min.js
	@-rm -rf node_modules npm-debug.log


#
# Test.
#

test: build test/browser/index.html
	@$(MOCHA) test/browser/index.html


#
# Target for `node_modules` folder.
#

node_modules: package.json
	@npm install

#
# Target for updating version.

version: component.json package.json src/version.js
	node scripts/version

#
# Target for `amplitude.js` file.
#

$(OUT): node_modules $(SRC) version
	@$(DUO) --standalone amplitude src/index.js > $(OUT)
	@$(MINIFY) $(OUT) --output $(MIN_OUT)


#
# Target for `tests-build.js` file.
#

build: $(TESTS) $(OUT)
	@-mkdir -p build
	@$(DUO) --development test/tests.js > build/tests.js

#
# Target for release.
#

release: $(OUT)
	@-mkdir -p dist
	node scripts/release

.PHONY: clean
.PHONY: test
