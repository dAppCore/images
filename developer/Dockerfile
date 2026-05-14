# ============================================================
# Core Developer — Multi-Language Development Environment
#
# build-base: ALL system packages (apt-get happens once, here)
# build-php/go/node/python: language toolchains (parallel, FROM build-base)
# build-security: security scanners + SBOM tools (FROM build-base)
# core-dev: final assembly — COPY from stages + user setup only
#
# Build: docker build -t core-dev .
# Run:   docker run -it -v $(pwd):/workspace core-dev
# ============================================================

# ============================================================
# Stage: build-base — ALL system packages
# ============================================================
FROM debian:trixie-slim AS build-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y build-essential ca-certificates curl gnupg zsh wget dnsutils iputils-ping openssh-client socat \
    openssl tmux jq git git-lfs htop procps zip unzip xz-utils gawk less tree docker.io docker-compose lynis file \
    gettext-base ripgrep fd-find fzf shellcheck default-mysql-client mariadb-client postgresql-client redis-tools sqlite3 \
    bat lsb-release apt-transport-https gcc g++ binutils binutils-gold openssl libncurses5-dev libncursesw5-dev


# ---- Non-root user (Claude Code refuses to run as root) ----
ARG DEV_USER=agent
ARG DEV_UID=1000
ARG DEV_GID=1000

RUN groupadd -g ${DEV_GID} ${DEV_USER}
RUN useradd -m -u ${DEV_UID} -g ${DEV_USER} -s /bin/zsh ${DEV_USER}
RUN mkdir -p /home/${DEV_USER}/.config /home/${DEV_USER}/.claude /workspace
RUN chown -R ${DEV_USER}:${DEV_USER} /home/${DEV_USER} /workspace

RUN chown -R ${DEV_USER}:${DEV_USER} /home/${DEV_USER}

ENV HOME=/home/${DEV_USER}
ENV GOPATH=$HOME/go
ENV PATH="$PATH:$HOME/.linuxbrew/bin:/usr/local/go/bin:${GOPATH}/bin:${HOME}/.local/bin:${HOME}/.composer/vendor/bin:/usr/local/bin:${PATH}"
ENV HOMEBREW_PREFIX=$HOME/.linuxbrew
# Install Homebrew (Linuxbrew)
RUN git clone https://github.com/Homebrew/brew ${HOME}/.linuxbrew/Homebrew
RUN mkdir ~/.linuxbrew/bin && ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin && eval "$(/usr/local/bin/brew shellenv)"



RUN chown -R agent:agent /home/agent

USER ${DEV_USER}

RUN brew install hadolint trivy syft grype gitleaks trufflehog dive conftest opa git-secrets gh

#RUN brew install openssl@3

USER root
# ============================================================
# Stage: build-php — PHP 8.5 + Composer + tools (FROM build-base)
# ============================================================
FROM build-base AS build-php

RUN curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ trixie main" > /etc/apt/sources.list.d/sury-php.list
RUN apt-get update
RUN apt-get install -y \
    php8.5-cli php8.5-common php8.5-curl php8.5-mbstring php8.5-xml \
    php8.5-zip php8.5-sqlite3 php8.5-mysql php8.5-pgsql php8.5-gd \
    php8.5-intl php8.5-bcmath php8.5-soap php8.5-redis php8.5-pcov \
    php8.5-readline php8.5-bz2 php8.5-imagick

RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/bin --filename=composer

RUN composer global config allow-plugins.pestphp/pest-plugin true
RUN composer global require --no-interaction \
    phpunit/phpunit:^11.0 \
    pestphp/pest:^3.0 \
    phpstan/phpstan:^2.0 \
    laravel/pint:^1.0 \
    squizlabs/php_codesniffer:^3.0 \
    phpmd/phpmd:^2.0 \
    friendsofphp/php-cs-fixer:^3.0
RUN composer global require --no-interaction vimeo/psalm
RUN composer global require --no-interaction rector/rector
RUN composer global require --no-interaction etsy/phan

RUN ARCH=$(dpkg --print-architecture | sed 's/arm64/arm64/' | sed 's/amd64/x86_64/') && \
    curl -fsSL "https://github.com/dunglas/frankenphp/releases/latest/download/frankenphp-linux-${ARCH}" \
    -o /usr/local/bin/frankenphp && chmod +x /usr/local/bin/frankenphp \
    || echo '#!/bin/sh\necho "FrankenPHP not available for this architecture"' > /usr/local/bin/frankenphp && chmod +x /usr/local/bin/frankenphp

RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://github.com/fabpot/local-php-security-checker/releases/latest/download/local-php-security-checker_linux_${ARCH}" \
    -o /usr/local/bin/local-php-security-checker && chmod +x /usr/local/bin/local-php-security-checker
# ============================================================
# Stage: build-go — Go 1.26.1 + tools (FROM build-base)
# ============================================================
FROM build-php AS build-go

ARG GO_VERSION=1.26.1
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:/${DEV_USER}/go/bin:${PATH}"
ENV GOPATH=/home/${DEV_USER}/go

USER ${DEV_USER}
# Dev tools
RUN go install golang.org/x/tools/gopls@latest
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
RUN go install github.com/go-task/task/v3/cmd/task@latest
RUN go install github.com/securego/gosec/v2/cmd/gosec@latest
RUN go install golang.org/x/vuln/cmd/govulncheck@latest
RUN go install honnef.co/go/tools/cmd/staticcheck@latest
RUN go install github.com/mgechev/revive@latest
RUN go install github.com/gordonklaus/ineffassign@latest
RUN go install github.com/kisielk/errcheck@latest
RUN go install github.com/fatih/gomodifytags@latest
RUN go install github.com/jgautheron/goconst/cmd/goconst@latest
#RUN go install github.com/nishanths/exhaustive/cmd/exhaustive@latest
RUN go install github.com/tomarrell/wrapcheck/v2/cmd/wrapcheck@latest
RUN go install github.com/dkorunic/betteralign/cmd/betteralign@latest
RUN go install github.com/polyfloyd/go-errorlint@latest

# Security + SBOM tools (need Go toolchain)
RUN go install github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@latest
RUN go install github.com/google/osv-scanner/cmd/osv-scanner@latest
RUN go install golang.stackrox.io/kube-linter/cmd/kube-linter@latest
RUN go install github.com/sigstore/cosign/v2/cmd/cosign@latest
RUN go install github.com/google/go-containerregistry/cmd/crane@latest
#RUN go install github.com/Checkmarx/kics/v2/cmd/kics@latest

# ============================================================
# Stage: build-node — Node.js 22 LTS + AI agent CLIs (FROM build-base)
# ============================================================
FROM build-go AS build-node

USER root
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs

ENV HOME=/home/agent
ENV HOMEBREW_PREFIX=$HOME/.linuxbrew
ENV HOMEBREW_CELLAR=$HOME/.linuxbrew/Cellar

RUN #brew install node
#RUN brew install --cask codex
#RUN brew install --cask claude-code
RUN npm install -g @anthropic-ai/claude-code @openai/codex opencode-ai
RUN npm install -g @biomejs/biome oxlint prettier eslint
RUN npm install -g markdownlint-cli markdownlint-cli2 jsonlint stylelint
RUN npm install -g typescript ts-prune
RUN npm install -g npm-audit-html license-checker
RUN npm install -g depcheck @cyclonedx/cdxgen snyk

# ============================================================
# Stage: build-python — Python 3.13 + linters (FROM build-base)
# ============================================================
FROM build-node AS build-python

RUN apt-get install -y python3 python3-pip python3-venv
ENV SETUPTOOLS_USE_DISTUTILS=stdlib
# Linters
RUN pip install --no-cache-dir --break-system-packages ruff mypy bandit pylint setuptools
RUN pip install --no-cache-dir --break-system-packages yamllint pyflakes pycodestyle pydocstyle
RUN pip install --no-cache-dir --break-system-packages safety vulture radon
RUN pip install --no-cache-dir --break-system-packages flake8 black isort autopep8

# Security + SBOM tools (need Python runtime)
RUN pip install --no-cache-dir --break-system-packages semgrep
RUN #pip install --no-cache-dir --break-system-packages scancode-toolkit
RUN pip install --no-cache-dir --break-system-packages detect-secrets
RUN #pip install --no-cache-dir --break-system-packages checkov
RUN pip install --no-cache-dir --break-system-packages pip-audit
RUN #pip install --no-cache-dir --break-system-packages tern
RUN pip install --no-cache-dir --break-system-packages in-toto

# ============================================================
# Stage: core-dev — Final assembly (COPY only, no installs)
# ============================================================
FROM build-python AS core-dev
ARG DEV_USER=agent

# ---- Config files ----
COPY --chmod=644 --chown=${DEV_USER} config/aliases.sh /etc/profile.d/aliases.sh
COPY --chmod=755 --chown=${DEV_USER} scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt-get clean
RUN npm cache clean --force

USER ${DEV_USER}
RUN brew upgrade
RUN brew autoremove
RUN brew cleanup --prune=all

LABEL maintainer="Snider <snider@lthn.ai>"
LABEL org.opencontainers.image.source="https://dappco.re/docker/developer"
LABEL org.opencontainers.image.description="Core Developer Tooling"
LABEL org.opencontainers.image.licenses="EUPL-1.2"
LABEL org.opencontainers.image.vendor="Lethean Community"
LABEL org.opencontainers.image.title="Core Developer"

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color
ENV EDITOR=nvim
ENV SHELL=/bin/zsh
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ---- COPY from parallel build stages ----



# ---- PATH ----
ENV GOPATH=/${DEV_USER}/go
ENV PATH="/usr/local/go/bin:/${DEV_USER}/go/bin:/${DEV_USER}/.composer/vendor/bin:/usr/local/bin:${PATH}"

WORKDIR /home/${DEV_USER}/workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
