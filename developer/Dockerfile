# ============================================================
# Docker Developer - Claude-Focused Alpine Dev Image
#
# A kitchen-sink developer environment optimized for
# AI-assisted development with Claude Code CLI.
#
# Build: docker build -t docker-developer .
# Run:   docker run -it docker-developer
# ============================================================

ARG ALPINE_VERSION=3.22

# ============================================================
# Developer - Full development environment
# ============================================================
FROM alpine:${ALPINE_VERSION} AS developer

LABEL maintainer="Snider <snider@host.uk.com>"
LABEL org.opencontainers.image.source="https://github.com/host-uk/docker-developer"
LABEL org.opencontainers.image.description="Claude-focused Alpine developer environment"
LABEL org.opencontainers.image.licenses="EUPL-1.2"
LABEL org.opencontainers.image.vendor="Host UK"
LABEL org.opencontainers.image.title="Docker Developer"

# Environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color
ENV EDITOR=vim
ENV SHELL=/bin/zsh
ENV GOPATH=/root/go
ENV PATH="/root/go/bin:/root/.local/bin:/root/.composer/vendor/bin:/usr/local/bin:${PATH}"

# ============================================================
# Core System Tools
# ============================================================
RUN apk add --no-cache \
    # Shell and basics
    bash \
    zsh \
    zsh-vcs \
    curl \
    wget \
    ca-certificates \
    # Build tools
    make \
    cmake \
    ninja \
    meson \
    gcc \
    g++ \
    musl-dev \
    linux-headers \
    # Essential utilities
    git \
    git-lfs \
    openssh-client \
    gnupg \
    less \
    tree \
    ncdu \
    htop \
    # Editors
    vim \
    nano \
    # Text processing
    jq \
    yq \
    # Search tools
    ripgrep \
    fzf \
    # Modern CLI tools (from Alpine packages)
    bat \
    eza \
    fd \
    # Terminal multiplexer
    tmux \
    # Compression
    zip \
    unzip \
    tar \
    gzip \
    xz \
    # Networking
    bind-tools \
    iputils \
    # Process management
    shadow \
    # Template processing
    gettext \
    # For starship
    starship

# ============================================================
# Node.js Ecosystem
# ============================================================
RUN apk add --no-cache \
    nodejs \
    npm

# Install global Node.js packages
RUN npm install -g \
    @anthropic-ai/claude-code \
    typescript \
    ts-node \
    pnpm \
    yarn

# ============================================================
# Python Ecosystem
# ============================================================
RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev

# Install Python tools
RUN pip3 install --break-system-packages \
    pipx \
    uv \
    ipython \
    httpie

# ============================================================
# PHP Ecosystem
# ============================================================
RUN apk add --no-cache \
    php84 \
    php84-phar \
    php84-mbstring \
    php84-openssl \
    php84-curl \
    php84-iconv \
    php84-tokenizer \
    php84-dom \
    php84-xml \
    php84-xmlwriter \
    php84-simplexml \
    php84-ctype \
    php84-fileinfo \
    php84-json \
    php84-posix \
    php84-pcntl \
    php84-zip

# Create php symlink
RUN ln -sf /usr/bin/php84 /usr/bin/php

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer

# Install PHP dev tools globally
RUN composer global require --no-interaction \
    phpunit/phpunit:^11.0 \
    phpstan/phpstan:^2.0 \
    squizlabs/php_codesniffer:^3.0 \
    friendsofphp/php-cs-fixer:^3.0

# ============================================================
# Go Ecosystem
# ============================================================
RUN apk add --no-cache go

# Install Go tools (pinned to versions compatible with Go 1.24)
RUN go install golang.org/x/tools/gopls@v0.17.1 && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.62.2

# ============================================================
# Database Clients
# ============================================================
RUN apk add --no-cache \
    postgresql16-client \
    mariadb-client \
    redis \
    sqlite

# ============================================================
# Container Tools
# ============================================================
RUN apk add --no-cache docker-cli

# ============================================================
# Git Enhancements
# ============================================================
RUN apk add --no-cache github-cli lazygit

# ============================================================
# Oh-My-Zsh Installation
# ============================================================
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# ============================================================
# Configuration Files
# ============================================================
COPY --chmod=644 config/zshrc /root/.zshrc
COPY --chmod=644 config/starship.toml /root/.config/starship.toml
COPY --chmod=644 config/tmux.conf /root/.tmux.conf

# ============================================================
# Entrypoint and Hooks
# ============================================================
COPY --chmod=755 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chmod=755 scripts/hooks.sh /usr/local/bin/hooks.sh

# Create config directories
RUN mkdir -p /root/.config/docker-developer/hooks/pre-start \
             /root/.config/docker-developer/hooks/post-start \
             /root/.claude \
             /workspace

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/zsh"]
