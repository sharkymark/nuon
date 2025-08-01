# Builder: start from plain Debian, install Go manually
FROM debian:bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git && \
    rm -rf /var/lib/apt/lists/*

# Install a clean Go toolchain (no iter baggage)
ENV GO_VERSION=1.21.13
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -C /usr/local -xz
ENV GOROOT=/usr/local/go
ENV PATH=$GOROOT/bin:$PATH

WORKDIR /app
# This folder is its own module
COPY go.mod go.sum ./
RUN go mod download

COPY . .
# (Optional) prove no stray iter in this toolchain
RUN test ! -d /usr/local/go/src/iter || (echo "iter exists in GOROOT" && exit 1)

# Build this module
RUN CGO_ENABLED=0 GOOS=linux go version && \
    CGO_ENABLED=0 GOOS=linux go build -o /api .

# Minimal runtime
FROM alpine:3.19
COPY --from=build /api /main
ENTRYPOINT ["/main"]
