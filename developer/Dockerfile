# ============================================================
# Core Developer — Multi-Language Development Environment
#
# Debian Trixie base, multi-stage scratch exports.
# Each language is a named stage — COPY --from to cherry-pick.
#
# Build: docker build -t core-dev .
# Run:   docker run -it -v $(pwd):/workspace core-dev
#
# Slim: docker-slim build --target core-dev --http-probe=false
# ============================================================

# ============================================================
# Stage: php — PHP 8.5 + Composer + tools
# ============================================================
FROM debian:trixie-slim AS php

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg && \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ trixie main" > /etc/apt/sources.list.d/sury-php.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    php8.5-cli php8.5-common php8.5-curl php8.5-mbstring php8.5-xml \
    php8.5-zip php8.5-sqlite3 php8.5-mysql php8.5-pgsql php8.5-gd \
    php8.5-intl php8.5-bcmath php8.5-soap php8.5-redis php8.5-pcov \
    php8.5-readline php8.5-bz2 php8.5-imagick && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer

RUN composer global config allow-plugins.pestphp/pest-plugin true && \
    composer global require --no-interaction \
    phpunit/phpunit:^11.0 \
    pestphp/pest:^3.0 \
    phpstan/phpstan:^2.0 \
    laravel/pint:^1.0

# FrankenPHP static binary — create placeholder if download fails
RUN ARCH=$(dpkg --print-architecture | sed 's/arm64/arm64/' | sed 's/amd64/x86_64/') && \
    curl -fsSL "https://github.com/dunglas/frankenphp/releases/latest/download/frankenphp-linux-${ARCH}" \
    -o /usr/local/bin/frankenphp && chmod +x /usr/local/bin/frankenphp \
    || echo '#!/bin/sh\necho "FrankenPHP not available for this architecture"' > /usr/local/bin/frankenphp && chmod +x /usr/local/bin/frankenphp

# Scratch export — just PHP runtime + composer + tools
FROM scratch AS php-export
COPY --from=php /usr/bin/php* /usr/bin/
COPY --from=php /usr/lib/php/ /usr/lib/php/
COPY --from=php /usr/share/php/ /usr/share/php/
COPY --from=php /usr/bin/composer /usr/bin/composer
COPY --from=php /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=php /root/.composer /root/.composer

# ============================================================
# Stage: golang — Go 1.26.1 + tools
# ============================================================
FROM debian:trixie-slim AS golang

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git && \
    rm -rf /var/lib/apt/lists/*

ARG GO_VERSION=1.26.1
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"
ENV GOPATH=/root/go

RUN go install golang.org/x/tools/gopls@latest 2>/dev/null || true && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest 2>/dev/null || true && \
    go install github.com/go-task/task/v3/cmd/task@latest 2>/dev/null || true

# Scratch export — Go toolchain + installed tools
FROM scratch AS golang-export
COPY --from=golang /usr/local/go /usr/local/go
COPY --from=golang /root/go/bin /root/go/bin

# ============================================================
# Stage: node — Node.js 22 LTS + AI agent CLIs
# ============================================================
FROM node:22-slim AS node

RUN npm install -g @anthropic-ai/claude-code @openai/codex

# Scratch export — Node runtime + global packages
FROM scratch AS node-export
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /usr/local/bin/npx /usr/local/bin/npx
COPY --from=node /usr/local/bin/claude /usr/local/bin/claude
COPY --from=node /usr/local/bin/codex /usr/local/bin/codex

# ============================================================
# Stage: python — Python 3.13
# ============================================================
FROM python:3.13-slim-trixie AS python

# Scratch export — Python runtime
FROM scratch AS python-export
COPY --from=python /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python /usr/local/bin/python3.13 /usr/local/bin/python3.13
COPY --from=python /usr/local/bin/pip3 /usr/local/bin/pip3
COPY --from=python /usr/local/lib/python3.13 /usr/local/lib/python3.13
COPY --from=python /usr/local/lib/libpython3.13.so.1.0 /usr/local/lib/
COPY --from=python /usr/local/lib/libpython3.so /usr/local/lib/

# ============================================================
# Stage: core-dev — Final assembled image
# ============================================================
FROM debian:trixie-slim AS core-dev

LABEL maintainer="Snider <snider@host.uk.com>"
LABEL org.opencontainers.image.source="https://github.com/host-uk/core-images"
LABEL org.opencontainers.image.description="PHP, Go, Node, Python developer environment"
LABEL org.opencontainers.image.licenses="EUPL-1.2"
LABEL org.opencontainers.image.vendor="Host UK"
LABEL org.opencontainers.image.title="Core Developer"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color
ENV EDITOR=nvim
ENV SHELL=/bin/zsh
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ---- System packages ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Shells
    bash zsh \
    # Network
    curl wget ca-certificates dnsutils iputils-ping openssh-client socat \
    # Build essentials
    make gcc g++ \
    # Core utilities
    coreutils findutils grep sed gawk less tree gettext-base \
    # Compression
    zip unzip tar gzip xz-utils \
    # Process & system
    htop procps \
    # Crypto
    gnupg openssl \
    # VCS
    git git-lfs \
    # Editors
    vim nano neovim \
    # Terminal
    tmux \
    # Database clients
    default-mysql-client postgresql-client redis-tools sqlite3 \
    # Docker
    docker.io docker-compose \
    # Data
    jq \
    # PHP shared lib deps (not pulled by COPY --from)
    libargon2-1 libsodium23 libonig5 libzip5 libgd3 \
    libicu76 libxml2 libpq5 libsqlite3-0 libcurl4t64 \
    libmagickwand-7.q16-10 libxslt1.1 \
    && rm -rf /var/lib/apt/lists/*

# ---- Modern CLI tools (from GitHub releases / cargo / pip) ----
RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y && \
    curl -fsSL https://github.com/dandavison/bat/releases/latest/download/bat_0.25.0_$(dpkg --print-architecture).deb -o /tmp/bat.deb && dpkg -i /tmp/bat.deb && rm /tmp/bat.deb || true

# gh CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# ripgrep + fd from Debian repos
RUN apt-get update && apt-get install -y --no-install-recommends ripgrep fd-find fzf && \
    ln -sf /usr/bin/fdfind /usr/bin/fd && \
    rm -rf /var/lib/apt/lists/*

# ---- Copy language runtimes from build stages ----
COPY --from=php /usr/bin/php8.5 /usr/bin/php8.5
COPY --from=php /usr/bin/php /usr/bin/php
COPY --from=php /usr/lib/php/ /usr/lib/php/
COPY --from=php /etc/php/ /etc/php/
COPY --from=php /usr/bin/composer /usr/bin/composer
COPY --from=php /root/.composer /root/.composer
COPY --from=php /usr/local/bin/frankenphp /usr/local/bin/frankenphp

COPY --from=golang /usr/local/go /usr/local/go
COPY --from=golang /root/go/bin /root/go/bin

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/npm /usr/local/bin/npm
COPY --from=node /usr/local/bin/npx /usr/local/bin/npx

COPY --from=python /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=python /usr/local/bin/python3.13 /usr/local/bin/python3.13
COPY --from=python /usr/local/bin/pip3 /usr/local/bin/pip3
COPY --from=python /usr/local/lib/python3.13 /usr/local/lib/python3.13
COPY --from=python /usr/local/lib/libpython3.13.so.1.0 /usr/local/lib/
COPY --from=python /usr/local/lib/libpython3.so /usr/local/lib/

# Symlinks for CLI tools from node_modules
RUN ln -sf /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js /usr/local/bin/claude && \
    ln -sf /usr/local/lib/node_modules/@openai/codex/bin/codex.js /usr/local/bin/codex && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip && \
    ldconfig

# ---- Shell configuration ----
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

COPY --chmod=644 config/zshrc /root/.zshrc
COPY --chmod=644 config/starship.toml /root/.config/starship.toml
COPY --chmod=644 config/tmux.conf /root/.tmux.conf
COPY --chmod=644 config/aliases.sh /etc/profile.d/aliases.sh
COPY --chmod=755 scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

# ---- Go + Node PATH for root (build verification) ----
ENV GOPATH=/root/go
ENV PATH="/usr/local/go/bin:/root/go/bin:/root/.composer/vendor/bin:/usr/local/bin:${PATH}"

# ---- Non-root user (Claude Code refuses to run as root) ----
ARG DEV_USER=dev
ARG DEV_UID=1000
ARG DEV_GID=1000

RUN groupadd -g ${DEV_GID} ${DEV_USER} && \
    useradd -m -u ${DEV_UID} -g ${DEV_USER} -s /bin/zsh ${DEV_USER} && \
    mkdir -p /home/${DEV_USER}/.config /home/${DEV_USER}/.claude /workspace && \
    chown -R ${DEV_USER}:${DEV_USER} /home/${DEV_USER} /workspace && \
    cp -r /root/.oh-my-zsh /home/${DEV_USER}/.oh-my-zsh && \
    cp /root/.zshrc /home/${DEV_USER}/.zshrc && \
    cp -r /root/.config/starship.toml /home/${DEV_USER}/.config/ && \
    cp /root/.tmux.conf /home/${DEV_USER}/.tmux.conf && \
    cp -r /root/.composer /home/${DEV_USER}/.composer && \
    chown -R ${DEV_USER}:${DEV_USER} /home/${DEV_USER}

ENV GOPATH=/home/${DEV_USER}/go
ENV PATH="/usr/local/go/bin:/home/${DEV_USER}/go/bin:/home/${DEV_USER}/.local/bin:/home/${DEV_USER}/.composer/vendor/bin:/usr/local/bin:${PATH}"
ENV HOME=/home/${DEV_USER}

USER ${DEV_USER}
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/zsh"]
