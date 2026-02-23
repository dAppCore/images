ARG GO_VERSION=1.26
FROM golang:${GO_VERSION}-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    git gcc libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Go CI tooling
RUN go install golang.org/x/vuln/cmd/govulncheck@latest \
    && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
