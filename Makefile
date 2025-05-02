build:
	bundle exec ruby gen.rb

deploy:
	fly deploy

run:
	cd gen && cargo build
	./gen/target/debug/gen

fmt:
	cd gen && cargo fmt

test:
	cd gen && cargo tarpaulin --skip-clean --target-dir tmp/tarpaulin

docker:
	docker build . -t explain:latest
	docker run explain:latest
