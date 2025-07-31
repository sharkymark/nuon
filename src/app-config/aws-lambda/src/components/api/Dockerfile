# https://hub.docker.com/_/golang
FROM golang:1.21.9-alpine3.19 as build

# 🚫 Remove broken iter folder from the Go source tree
# RUN rm -rf /usr/local/go/src/iter

WORKDIR /app
COPY ./ ./
RUN go mod download
COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o api

FROM alpine:3.19
COPY --from=build /app/api /main
ENTRYPOINT ["/main"]
