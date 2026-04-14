# ============================================================
# Core Scanner — GoLang + PHP + Python + Node.js Security Scanning
#
# Go tools:
#   govulncheck   — official Go vulnerability checker (golang.org/x/vuln)
#   gosec         — Go AST security checker (securego/gosec)
#   golangci-lint — meta-linter (govet, errcheck, staticcheck, gosec, ...)
#   trivy         — filesystem + container vulnerability scanner (Aqua)
#   grype         — vulnerability scanner for SBOMs and filesystems (Anchore)
#   syft          — SBOM generator (Anchore)
#   semgrep       — multi-language SAST (returntocorp)
#   nancy         — Sonatype OSS Index dep scanner
#
# PHP tools:
#   phpcs         — PHP_CodeSniffer — coding standard checker
#   psalm         — static analysis + type checking (vimeo/psalm)
#   enlightn      — Laravel security & performance auditor
#
# Python tools (installed via uv):
#   bandit        — Python AST security linter (PyCQA)
#   pyre-check    — Facebook type checker + Pysa taint analysis
#   safety        — Safety CLI — dep vulnerability checker (PyUp)
#
# Node.js tools (global npm):
#   npm-audit     — built-in npm dep vulnerability audit
#   nodejsscan    — static security scanner for Node.js (ajinabraham)
#   eslint        — pluggable linter
#   eslint-plugin-security      — Node.js security rules
#   eslint-plugin-no-secrets    — detect hardcoded secrets
#   eslint-plugin-node          — Node.js best-practice rules
#   @microsoft/eslint-plugin-sdl — Microsoft SDL security rules
#
# Build: docker build -t core-scanner .
# Go:    docker run --rm -v $(pwd):/src core-scanner govulncheck ./...
# PHP:   docker run --rm -v $(pwd):/src core-scanner phpcs --standard=PSR12 .
# Py:    docker run --rm -v $(pwd):/src core-scanner bandit -r .
# Node:  docker run --rm -v $(pwd):/src core-scanner npm audit
#        docker run --rm -v $(pwd):/src core-scanner eslint --rulesdir /eslint-rules .
# ============================================================

ARG ALPINE_VERSION=3.22
ARG NODE_VERSION=22
ARG GO_VERSION=1.24.2
ARG GOLANGCI_VERSION=v1.64.8
ARG GOSEC_VERSION=v2.22.3
ARG TRIVY_VERSION=0.61.0
ARG GRYPE_VERSION=0.90.0
ARG SYFT_VERSION=1.23.1
ARG NANCY_VERSION=v1.0.46
ARG PHP_VERSION=83
ARG PHPCS_VERSION=3.11.3
ARG PSALM_VERSION=6.x-dev

FROM golang:${GO_VERSION}-alpine AS go-tools

RUN apk add --no-cache git ca-certificates

ARG GOLANGCI_VERSION
ARG GOSEC_VERSION
ARG NANCY_VERSION

# govulncheck — official vuln checker
RUN go install golang.org/x/vuln/cmd/govulncheck@latest

# gosec — Go AST security checker
RUN go install github.com/securego/gosec/v2/cmd/gosec@${GOSEC_VERSION}

# golangci-lint — via official install script (avoids CGO issues)
RUN wget -O- https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
    | sh -s -- -b /usr/local/bin ${GOLANGCI_VERSION}

# nancy — Sonatype OSS Index
RUN go install github.com/sonatype-nexus-community/nancy@${NANCY_VERSION}

# ============================================================
# Final image
# ============================================================
FROM alpine:${ALPINE_VERSION}

ARG TRIVY_VERSION
ARG GRYPE_VERSION
ARG SYFT_VERSION
ARG GO_VERSION
ARG PHP_VERSION
ARG PHPCS_VERSION
ARG PSALM_VERSION
ARG NODE_VERSION

LABEL maintainer="Snider <snider@host.uk.com>"
LABEL org.opencontainers.image.source="https://github.com/host-uk/core-images"
LABEL org.opencontainers.image.description="GoLang + PHP security and code scanning toolchain"
LABEL org.opencontainers.image.licenses="EUPL-1.2"
LABEL org.opencontainers.image.vendor="Host UK"
LABEL org.opencontainers.image.title="Core Scanner"

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV GOPATH=/go
ENV UV_HOME="/root/.local"
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:/usr/local/bin:${UV_HOME}/bin:${PATH}"
ENV GOFLAGS="-mod=readonly"
ENV UV_SYSTEM_PYTHON=1

# Runtime deps — Python, PHP, Node.js
RUN apk add --no-cache \
    ca-certificates \
    git \
    curl \
    wget \
    python3 \
    python3-dev \
    py3-pip \
    py3-setuptools \
    bash \
    jq \
    nodejs \
    npm \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xmlwriter \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-pcntl \
    php${PHP_VERSION}-posix \
    php${PHP_VERSION}-fileinfo \
  && ln -sf /usr/bin/php${PHP_VERSION} /usr/local/bin/php

# composer — PHP dependency manager (needed for psalm + enlightn)
RUN wget -qO /tmp/composer-setup.php https://getcomposer.org/installer \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm /tmp/composer-setup.php \
    && composer --version

# Copy Go toolchain and built tools from builder
COPY --from=go-tools /usr/local/go /usr/local/go
COPY --from=go-tools /go/bin/govulncheck /usr/local/bin/govulncheck
COPY --from=go-tools /go/bin/gosec       /usr/local/bin/gosec
COPY --from=go-tools /go/bin/nancy       /usr/local/bin/nancy
COPY --from=go-tools /usr/local/bin/golangci-lint /usr/local/bin/golangci-lint

# trivy — Aqua filesystem + container scanner
RUN wget -qO /tmp/trivy.tar.gz \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    && tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy \
    && rm /tmp/trivy.tar.gz

# grype — Anchore vulnerability scanner
RUN wget -qO /tmp/grype.tar.gz \
      "https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}/grype_${GRYPE_VERSION}_linux_amd64.tar.gz" \
    && tar -xzf /tmp/grype.tar.gz -C /usr/local/bin grype \
    && rm /tmp/grype.tar.gz

# syft — SBOM generator (pairs with grype)
RUN wget -qO /tmp/syft.tar.gz \
      "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz" \
    && tar -xzf /tmp/syft.tar.gz -C /usr/local/bin syft \
    && rm /tmp/syft.tar.gz

# uv — fast Python package manager (replaces pip for all Python tools)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Python tools via uv
RUN uv tool install semgrep \
    && uv tool install bandit \
    && uv tool install safety \
    && uv tool install pyre-check

# Expose uv tool bins on PATH
RUN ln -sf "${UV_HOME}/bin/semgrep"  /usr/local/bin/semgrep \
    && ln -sf "${UV_HOME}/bin/bandit"   /usr/local/bin/bandit \
    && ln -sf "${UV_HOME}/bin/safety"   /usr/local/bin/safety \
    && ln -sf "${UV_HOME}/bin/pyre"     /usr/local/bin/pyre \
    && ln -sf "${UV_HOME}/bin/pysa"     /usr/local/bin/pysa 2>/dev/null || true

# phpcs — PHP_CodeSniffer
RUN wget -qO /usr/local/bin/phpcs \
      "https://github.com/PHPCSStandards/PHP_CodeSniffer/releases/download/${PHPCS_VERSION}/phpcs.phar" \
    && chmod +x /usr/local/bin/phpcs \
    && wget -qO /usr/local/bin/phpcbf \
      "https://github.com/PHPCSStandards/PHP_CodeSniffer/releases/download/${PHPCS_VERSION}/phpcbf.phar" \
    && chmod +x /usr/local/bin/phpcbf

# psalm — static analysis + type checking
RUN composer global require --no-progress --no-interaction vimeo/psalm \
    && ln -sf /root/.composer/vendor/bin/psalm /usr/local/bin/psalm \
    && ln -sf /root/.composer/vendor/bin/psalm-language-server /usr/local/bin/psalm-language-server

# enlightn — Laravel security + performance auditor
# Installed as a project-level dev dependency via composer require in the target project.
# The enlightn binary is provided here for standalone invocation:
RUN composer global require --no-progress --no-interaction enlightn/enlightn \
    && ln -sf /root/.composer/vendor/bin/enlightn /usr/local/bin/enlightn

# Node.js security tools — global npm installs
# npm audit is built into npm; remaining tools installed globally
RUN npm install -g --no-fund --no-audit \
    nodejsscan \
    eslint \
    eslint-plugin-security \
    eslint-plugin-no-secrets \
    eslint-plugin-n \
    @microsoft/eslint-plugin-sdl

# ESLint security config — ready-to-use ruleset for scanning arbitrary projects
COPY eslint.security.config.mjs /etc/scanner/eslint.security.config.mjs

# Warm trivy DB cache at build time (optional — speeds up first scan)
# Uncomment to bake the DB in (adds ~200MB to image):
# RUN trivy image --download-db-only

WORKDIR /src

# Default: show tool versions to confirm a working image
CMD ["sh", "-c", "\
  echo '=== Core Scanner ===' && \
  echo '--- Go ---' && \
  echo \"go:            $(go version)\" && \
  echo \"govulncheck:   $(govulncheck -version 2>&1 | head -1)\" && \
  echo \"gosec:         $(gosec --version 2>&1 | head -1)\" && \
  echo \"golangci-lint: $(golangci-lint version 2>&1 | head -1)\" && \
  echo \"trivy:         $(trivy --version 2>&1 | head -1)\" && \
  echo \"grype:         $(grype version 2>&1 | head -1)\" && \
  echo \"syft:          $(syft version 2>&1 | head -1)\" && \
  echo \"nancy:         $(nancy --version 2>&1 | head -1)\" && \
  echo '--- PHP ---' && \
  echo \"php:           $(php --version 2>&1 | head -1)\" && \
  echo \"composer:      $(composer --version 2>&1 | head -1)\" && \
  echo \"phpcs:         $(phpcs --version 2>&1 | head -1)\" && \
  echo \"psalm:         $(psalm --version 2>&1 | head -1)\" && \
  echo \"enlightn:      $(enlightn --version 2>&1 | head -1)\" && \
  echo '--- Python ---' && \
  echo \"python:        $(python3 --version 2>&1)\" && \
  echo \"uv:            $(uv --version 2>&1)\" && \
  echo \"bandit:        $(bandit --version 2>&1 | head -1)\" && \
  echo \"pyre:          $(pyre --version 2>&1 | head -1)\" && \
  echo \"safety:        $(safety --version 2>&1 | head -1)\" && \
  echo \"semgrep:       $(semgrep --version 2>&1 | head -1)\" && \
  echo '--- Node.js ---' && \
  echo \"node:          $(node --version 2>&1)\" && \
  echo \"npm:           $(npm --version 2>&1)\" && \
  echo \"nodejsscan:    $(nodejsscan --version 2>&1 | head -1)\" && \
  echo \"eslint:        $(eslint --version 2>&1 | head -1)\" \
"]
