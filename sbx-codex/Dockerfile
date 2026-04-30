# syntax=docker/dockerfile:1.6
# ============================================================
# Lethean sbx codex — core-dev base + sbx runtime contract
#
# core-dev gives us: PHP 8.3, Go 1.26, Node 24, Python 3.13,
# composer, pest, pint, security scanners, ~20GB of tooling.
#
# sandbox-templates:codex gives us: the sbx contract labels,
# /etc/sandbox-persistent.sh, and the codex CLI npm install.
#
# This template stacks them so `sbx run -t lthn/sbx-codex:dev codex <repo>`
# drops codex into a fully-loaded core-dev environment.
#
# Build:
#   cd ~/Code/core/images/sbx-codex
#   docker build -t lthn/sbx-codex:dev .
#
# Use:
#   sbx run -t lthn/sbx-codex:dev codex ~/Code/core/agent
# ============================================================

ARG SBX_SOURCE=docker/sandbox-templates:codex
ARG CORE_DEV=core-dev:latest

FROM ${SBX_SOURCE} AS sbx-source

FROM ${CORE_DEV}

USER root

# ── sbx contract ────────────────────────────────────────────
# The persistent startup script sbx's runtime sources on every
# interactive shell. Carries proxy/no_proxy/PATH additions.
COPY --from=sbx-source /etc/sandbox-persistent.sh        /etc/sandbox-persistent.sh
COPY --from=sbx-source /etc/profile.d/sandbox-persistent.sh /etc/profile.d/sandbox-persistent.sh

# Codex CLI + its npm deps, bit-for-bit from upstream.
# /usr/local/share/npm-global is already on core-dev's PATH.
COPY --from=sbx-source /usr/local/share/npm-global       /usr/local/share/npm-global

# Labels — sbx recognises this as a template and the `-t` flag picks it up.
LABEL com.docker.sandboxes=templates \
      com.docker.sandboxes.flavor=codex-core-dev \
      com.docker.sandboxes.base=core-dev:latest \
      org.opencontainers.image.title="Lethean sbx codex on core-dev" \
      org.opencontainers.image.vendor="Lethean Community" \
      org.opencontainers.image.licenses=EUPL-1.2 \
      org.opencontainers.image.source=https://forge.lthn.sh/core/images

# Env expected by the sbx runtime + codex.
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global \
    BASH_ENV=/etc/sandbox-persistent.sh \
    NO_PROXY=localhost,127.0.0.1,::1,172.17.0.0/16 \
    no_proxy=localhost,127.0.0.1,::1,172.17.0.0/16

# sbx mounts the workspace here by default.
WORKDIR /home/agent/workspace
RUN chown agent:agent /home/agent/workspace

USER agent

# PATH needs npm-global's bin first so `codex` resolves to the sbx build.
ENV PATH=/home/agent/.local/bin:/usr/local/share/npm-global/bin:${PATH}

# Pre-seed git identity so commits made by codex inside the sandbox are
# attributed correctly without every run re-configuring. Overridable via env.
RUN git config --global user.name  "Codex (sbx)" \
 && git config --global user.email "codex@lthn.ai" \
 && git config --global init.defaultBranch dev \
 && git config --global pull.rebase true

CMD ["codex"]
