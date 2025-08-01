FROM golang:1.22.2-bookworm as build

# Neutralize CI env that can force stdlib rebuilds
ENV GOEXPERIMENT=
ENV GOFLAGS=
ENV GOPROXY=https://proxy.golang.org,direct

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go env && CGO_ENABLED=0 GOOS=linux go build -o /api .


FROM alpine:3.19
COPY --from=build /app/api /main
RUN chmod +x /main
ENTRYPOINT ["/main"]
