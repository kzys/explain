build:
	bundle exec ruby gen.rb
.PHONY: build

test:
	bundle exec ruby test/*.rb
.PHONY: test
