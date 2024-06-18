FROM oven/bun:1.1-slim
WORKDIR /app
COPY . /app
RUN bun install --production
ENTRYPOINT [ "bun", "run", "server.ts" ]
