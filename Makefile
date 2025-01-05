#! /usr/bin/env make -f

SHELL = /bin/sh

.SUFFIXES:

all: local

DEPS = Gemfile.lock
BUILD = _site
JEKYLL = bundle exec jekyll

$(DEPS): Gemfile
	command -v bundle || gem install bundler
	bundle install

$(BUILD):
	$(JEKYLL) build $(BUILD_OPTS)

serve: $(DEPS)
	$(JEKYLL) serve --watch --livereload --host localhost --port 4000 $(SERVE_OPTS)

local: JEKYLL_ENV = development
local: serve
debug: JEKYLL_ENV = debug
debug: serve
prod: JEKYLL_ENV = production
prod: serve

lint: $(DEPS)
	$(JEKYLL) doctor
	$(JEKYLL) build --profile $(BUILD_OPTS)

clean:
	-$(RM) -r _site
