ARG GO_VERSION=1.27.1
ARG HIVEC_VERSION=v0.2.15

# Estágio de build: Go e o compilador Hive (hivec)
FROM debian:bookworm-slim AS build
ARG TARGETARCH
ARG GO_VERSION
ARG HIVEC_VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" \
    | tar -C /usr/local -xz
RUN curl -fsSL \
      "https://github.com/R0DR160HM/hive-lang/releases/download/${HIVEC_VERSION}/hivec-linux-${TARGETARCH}" \
      -o /usr/local/bin/hivec \
 && chmod +x /usr/local/bin/hivec
ENV PATH="/usr/local/go/bin:${PATH}"
ENV CGO_ENABLED=0
WORKDIR /app
COPY . .
RUN hivec build /app/todo_api.hive \
 && test -x /app/todo_api

# Estágio final: só o executável
FROM gcr.io/distroless/static-debian12
COPY --from=build /app/todo_api /usr/local/bin/todo_api
WORKDIR /data
ENV PORT=8080
ENV DATABASE_PATH=/data/todo_api.db
EXPOSE 8080
VOLUME /data
ENTRYPOINT ["/usr/local/bin/todo_api"]
