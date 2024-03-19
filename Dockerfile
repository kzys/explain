FROM rust:1.73.0
WORKDIR /app
COPY gen /app/gen
RUN cd /app/gen && cargo build --release
ENTRYPOINT [ "/app/gen/target/release/gen" ]