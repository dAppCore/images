# ============================================================
# Core Developer - Full-Fat Development Environment
#
# A comprehensive developer environment with 100+ embedded tools
# for AI-assisted development with Claude Code CLI.
#
# Build: docker build -t core-dev .
# Run:   docker run -it -v $(pwd):/workspace core-dev
# ============================================================

ARG ALPINE_VERSION=3.22

FROM alpine:${ALPINE_VERSION}

LABEL maintainer="Snider <snider@host.uk.com>"
LABEL org.opencontainers.image.source="https://github.com/host-uk/core-images"
LABEL org.opencontainers.image.description="Full-fat developer environment with 100+ tools"
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
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH="/root/go/bin:/root/.cargo/bin:/root/.local/bin:/root/.composer/vendor/bin:/usr/local/bin:${PATH}"

# ============================================================
# Core System & Build Tools
# ============================================================
RUN apk add --no-cache \
    # Shells
    bash zsh zsh-vcs \
    # Network tools
    curl wget ca-certificates bind-tools iputils openssh-client \
    # Build essentials
    make cmake ninja meson gcc g++ musl-dev linux-headers \
    # Core utilities
    coreutils findutils grep sed gawk less tree ncdu shadow gettext \
    # Compression
    zip unzip tar gzip xz bzip2 zstd \
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
    vim nano neovim helix \
    # Directory navigation
    zoxide broot

# ============================================================
# VCS & Git Tools
# ============================================================
# Note: git-delta not in Alpine repos, install via cargo if needed
RUN apk add --no-cache \
    git git-lfs github-cli lazygit

# ============================================================
# Node.js Ecosystem
# ============================================================
RUN apk add --no-cache nodejs npm

# Bun runtime
RUN curl -fsSL https://bun.sh/install | bash && \
    ln -sf /root/.bun/bin/bun /usr/local/bin/bun && \
    ln -sf /root/.bun/bin/bunx /usr/local/bin/bunx

# Deno runtime
RUN curl -fsSL https://deno.land/install.sh | sh && \
    ln -sf /root/.deno/bin/deno /usr/local/bin/deno

# Global Node.js packages
RUN npm install -g \
    @anthropic-ai/claude-code \
    typescript ts-node \
    pnpm yarn \
    prettier eslint \
    @biomejs/biome \
    turbo nx \
    vitest \
    typedoc \
    @mermaid-js/mermaid-cli

# ============================================================
# Python Ecosystem
# ============================================================
RUN apk add --no-cache python3 py3-pip python3-dev

RUN pip3 install --break-system-packages \
    pipx uv \
    ipython httpie \
    ruff \
    mkdocs mkdocs-material \
    aider-chat \
    llm

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

# PHP tools via Composer (phpdocumentor excluded - doesn't support PHP 8.4 yet)
RUN composer global require --no-interaction \
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

RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install github.com/go-task/task/v3/cmd/task@latest && \
    go install github.com/casey/just@latest && \
    go install github.com/watchexec/watchexec/cmd/watchexec@latest 2>/dev/null || true && \
    go install github.com/boyter/scc/v3@latest

# ============================================================
# Rust Ecosystem
# ============================================================
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal

# Rust-based CLI tools
RUN . /root/.cargo/env && \
    cargo install --locked \
    hyperfine \
    tokei \
    xh \
    grex

# ============================================================
# Database Clients
# ============================================================
RUN apk add --no-cache \
    postgresql16-client \
    mariadb-client \
    redis \
    sqlite

# usql - universal SQL client
RUN go install github.com/xo/usql@latest

# ============================================================
# Infrastructure & DevOps
# ============================================================
RUN apk add --no-cache \
    docker-cli docker-cli-compose \
    kubectl helm \
    terraform ansible

# k9s - Kubernetes TUI
RUN curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/').tar.gz" | tar -xzf - -C /usr/local/bin k9s

# lazydocker
RUN curl -fsSL "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_$(uname -s)_$(uname -m).tar.gz" | tar -xzf - -C /usr/local/bin lazydocker

# dive - Docker image explorer
RUN go install github.com/wagoodman/dive@latest

# ctop - Container metrics
RUN curl -fsSL "https://github.com/bcicen/ctop/releases/latest/download/ctop-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')" -o /usr/local/bin/ctop && \
    chmod +x /usr/local/bin/ctop

# ============================================================
# HTTP & Networking
# ============================================================
RUN apk add --no-cache websocat

# grpcurl
RUN go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# mkcert - local CA
RUN curl -fsSL "https://github.com/FiloSottile/mkcert/releases/latest/download/mkcert-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')" -o /usr/local/bin/mkcert && \
    chmod +x /usr/local/bin/mkcert

# ============================================================
# Data Processing
# ============================================================
RUN apk add --no-cache jq yq miller

# fx - JSON viewer
RUN go install github.com/antonmedv/fx@latest

# gron - Make JSON greppable
RUN go install github.com/tomnomnom/gron@latest

# dasel - Query data formats
RUN curl -fsSL "https://github.com/TomWright/dasel/releases/latest/download/dasel_linux_$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')" -o /usr/local/bin/dasel && \
    chmod +x /usr/local/bin/dasel

# ============================================================
# Security Tools
# ============================================================
# age - encryption
RUN apk add --no-cache age

# sops - secrets management
RUN curl -fsSL "https://github.com/getsops/sops/releases/latest/download/sops-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')" -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# cosign - container signing
RUN go install github.com/sigstore/cosign/v2/cmd/cosign@latest

# trivy - vulnerability scanner
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/latest/download/trivy_$(uname -s)_$(uname -m).tar.gz" | tar -xzf - -C /usr/local/bin trivy

# trufflehog - secret scanner
RUN curl -fsSL "https://github.com/trufflesecurity/trufflehog/releases/latest/download/trufflehog_$(uname -s)_$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/').tar.gz" | tar -xzf - -C /usr/local/bin trufflehog

# ============================================================
# Monitoring
# ============================================================
RUN apk add --no-cache btop

# ============================================================
# Testing Tools
# ============================================================
# k6 - load testing
RUN curl -fsSL "https://github.com/grafana/k6/releases/latest/download/k6-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/').tar.gz" | tar -xzf - --strip-components=1 -C /usr/local/bin

# Playwright (via npm, already installed)

# ============================================================
# Misc Tools
# ============================================================
RUN apk add --no-cache direnv

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
