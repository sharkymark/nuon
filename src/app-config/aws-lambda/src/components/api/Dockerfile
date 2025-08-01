# Builder: Go 1.21 (no iter logic in stdlib)
FROM golang:1.21.13-bookworm AS build
WORKDIR /app

# This folder is a standalone module (has its own go.mod/go.sum)
COPY go.mod go.sum ./
RUN go mod download

COPY . .
# Build THIS module
RUN CGO_ENABLED=0 GOOS=linux go build -o /api .

# Minimal runtime
FROM alpine:3.19
COPY --from=build /api /main
ENTRYPOINT ["/main"]