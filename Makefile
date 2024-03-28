build:
	cd gen && cargo build

deploy:
	fly deploy

run:
	cd gen && cargo build
	./gen/target/debug/gen

fmt:
	cd gen && cargo fmt

test:
	cd gen && cargo tarpaulin --skip-clean --target-dir tmp/tarpaulin
