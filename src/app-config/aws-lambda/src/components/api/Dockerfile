# Builder: clean Debian, install a pristine Go toolchain to /opt/go
FROM debian:bookworm-slim AS build

ARG GO_VERSION=1.21.13
ARG GO_TARBALL=go${GO_VERSION}.linux-amd64.tar.gz
ARG GO_SHA256=61a5b0d62f19b0c2759f1a46998c7a5d8a2d4b3fc9e2f2b8bfa523c3f2d2aeb9  # update if needed

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git xz-utils coreutils && \
    rm -rf /var/lib/apt/lists/*

# Download & verify official Go
WORKDIR /tmp
RUN curl -fsSLO https://go.dev/dl/${GO_TARBALL} \
 && echo "${GO_SHA256}  ${GO_TARBALL}" | sha256sum -c -

# Install Go into /opt/go (NOT /usr/local/go to avoid any overlays)
RUN mkdir -p /opt \
 && tar -C /opt -xzf ${GO_TARBALL} \
 && mv /opt/go /opt/go${GO_VERSION}

# Configure Go environment
ENV GOROOT=/opt/go${GO_VERSION}
ENV GOPATH=/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
ENV GOTOOLCHAIN=local
ENV GOEXPERIMENT=
ENV GOFLAGS=
ENV GOPROXY=https://proxy.golang.org,direct
ENV GOMODCACHE=/go/pkg/mod

# Defensive: remove any stray iter sources if present in this toolchain
RUN rm -rf ${GOROOT}/src/iter || true \
 && rm -f ${GOROOT}/src/bytes/iter.go || true

# Build your module (context is the api/ folder)
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Prove the toolchain & a
