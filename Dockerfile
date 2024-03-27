FROM rust:1.73.0 as builder
WORKDIR /app
COPY gen /app/gen
RUN cd /app/gen && cargo build

FROM ubuntu:latest
WORKDIR /app
COPY --from=builder /app/gen/target/debug/gen /app/gen
COPY src /app/src
COPY layout /app/layout
ENTRYPOINT [ "/app/gen" ]
