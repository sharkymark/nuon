FROM golang:1.22.2-bookworm as build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o api

FROM alpine:3.19
COPY --from=build /app/api /main
RUN chmod +x /main
ENTRYPOINT ["/main"]
