deploy:
	fly deploy

run:
	cd gen && cargo build
	./gen/target/debug/gen

fmt:
	cd gen && cargo fmt