# ============================================================
# Core Developer - Multi-Language Development Environment
#
# PHP 8.4, Go 1.24, Node 22, Python 3.13
# with Claude Code CLI support.
#
# Build: docker build -t core-dev .
# Run:   docker run -it -v $(pwd):/workspace core-dev
# ============================================================

ARG ALPINE_VERSION=3.22
ARG PYTHON_VERSION=3.13

# Stage 1: Get Python 3.13 from official image
FROM python:${PYTHON_VERSION}-alpine${ALPINE_VERSION} AS python-stage

# Stage 2: Main image
FROM alpine:${ALPINE_VERSION}

LABEL maintainer="Snider <snider@host.uk.com>"
LABEL org.opencontainers.image.source="https://github.com/host-uk/core-images"
LABEL org.opencontainers.image.description="PHP, Go, Node, Python developer environment"
LABEL org.opencontainers.image.licenses="EUPL-1.2"
LABEL org.opencontainers.image.vendor="Host UK"
LABEL org.opencontainers.image.title="Core Developer"

# Environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color
ENV EDITOR=nvim
ENV SHELL=/bin/zsh
ENV GOPATH=/root/go
ENV PATH="/root/go/bin:/root/.local/bin:/root/.composer/vendor/bin:/usr/local/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ============================================================
# Core System & Build Tools
# ============================================================
RUN apk add --no-cache \
    # Shells
    bash zsh zsh-vcs \
    # Network tools
    curl wget ca-certificates bind-tools iputils openssh-client \
    # Build essentials
    make gcc g++ musl-dev linux-headers \
    # Core utilities
    coreutils findutils grep sed gawk less tree shadow gettext \
    # Compression
    zip unzip tar gzip xz \
    # Process & system
    htop procps util-linux \
    # Crypto
    gnupg openssl

# ============================================================
# Modern CLI Tools (Files & Search)
# ============================================================
RUN apk add --no-cache \
    # File tools
    bat eza fd ripgrep fzf tree \
    # Terminal
    tmux starship \
    # Editors
    vim nano neovim \
    # Directory navigation
    zoxide

# ============================================================
# VCS & Git Tools
# ============================================================
RUN apk add --no-cache \
    git git-lfs github-cli lazygit

# ============================================================
# Node.js 22 LTS
# ============================================================
RUN apk add --no-cache nodejs npm

# Claude Code CLI (pinned version)
RUN npm install -g @anthropic-ai/claude-code@2.1.29

# ============================================================
# PHP Ecosystem
# ============================================================
RUN apk add --no-cache \
    php84 php84-phar php84-mbstring php84-openssl php84-curl \
    php84-iconv php84-tokenizer php84-dom php84-xml php84-xmlwriter \
    php84-simplexml php84-ctype php84-fileinfo php84-json \
    php84-posix php84-pcntl php84-zip php84-sodium php84-session \
    php84-pdo php84-pdo_mysql php84-pdo_pgsql php84-pdo_sqlite

RUN ln -sf /usr/bin/php84 /usr/bin/php

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer

# Allow Pest plugin and install PHP tools globally
RUN composer global config allow-plugins.pestphp/pest-plugin true && \
    composer global require --no-interaction \
    phpunit/phpunit:^11.0 \
    pestphp/pest:^3.0 \
    phpstan/phpstan:^2.0 \
    laravel/pint:^1.0

# FrankenPHP (static binary)
RUN curl -fsSL "https://github.com/dunglas/frankenphp/releases/latest/download/frankenphp-linux-$(uname -m | sed 's/aarch64/arm64/' | sed 's/x86_64/x86_64/')" -o /usr/local/bin/frankenphp && \
    chmod +x /usr/local/bin/frankenphp

# ============================================================
# Go Ecosystem
# ============================================================
RUN apk add --no-cache go

# Go tools (pinned to versions compatible with Go 1.24)
RUN go install golang.org/x/tools/gopls@v0.17.1 || true && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.62.2 && \
    go install github.com/go-task/task/v3/cmd/task@v3.40.1

# ============================================================
# Python 3.13 (copied from official image)
# ============================================================
# Runtime dependencies for Python
RUN apk add --no-cache libffi sqlite-libs xz-libs

# Copy Python installation from build stage
COPY --from=python-stage /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python-stage /usr/local/bin/python3.13 /usr/local/bin/python3.13
COPY --from=python-stage /usr/local/bin/pip3 /usr/local/bin/pip3
COPY --from=python-stage /usr/local/bin/pip3.13 /usr/local/bin/pip3.13
COPY --from=python-stage /usr/local/lib/python3.13 /usr/local/lib/python3.13
COPY --from=python-stage /usr/local/lib/libpython3.13.so.1.0 /usr/local/lib/
COPY --from=python-stage /usr/local/lib/libpython3.so /usr/local/lib/

# Create symlinks and update library cache
RUN ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip && \
    ldconfig /usr/local/lib || true

# ============================================================
# Database Clients
# ============================================================
RUN apk add --no-cache \
    postgresql16-client \
    mariadb-client \
    redis \
    sqlite

# ============================================================
# Docker Tools
# ============================================================
RUN apk add --no-cache docker-cli docker-cli-compose

# ============================================================
# Data Processing
# ============================================================
RUN apk add --no-cache jq yq

# ============================================================
# Shell Configuration
# ============================================================
# Oh-My-Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Zsh plugins
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# ============================================================
# Configuration Files
# ============================================================
COPY --chmod=644 config/zshrc /root/.zshrc
COPY --chmod=644 config/starship.toml /root/.config/starship.toml
COPY --chmod=644 config/tmux.conf /root/.tmux.conf
COPY --chmod=644 config/aliases.sh /etc/profile.d/aliases.sh

# ============================================================
# Entrypoint
# ============================================================
COPY --chmod=755 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# Create directories
RUN mkdir -p /root/.config /root/.claude /workspace

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/zsh"]
