build:
	bundle exec ruby gen.rb
.PHONY: build

test:
	bundle exec ruby test/*.rb
.PHONY: test

tidy:
	find . -name "*.rb" -o -name "*.css" -o -name "*.html" -o -name "*.erb" -o -name "*.md" -o -name "*.yaml" | grep -v coverage | xargs sed -i 's/[[:space:]]*$$//'
.PHONY: tidy
