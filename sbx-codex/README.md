# sbx-codex — Lethean codex sandbox template

Stacks the upstream `docker/sandbox-templates:codex` runtime contract on top of
`core-dev` so `sbx run -t lthn/sbx-codex:dev codex <repo>` drops codex into a
fully-loaded PHP/Go/Node/Python dev environment.

## Build

```bash
cd ~/Code/core/images/sbx-codex
docker build -t lthn/sbx-codex:dev .
```

Assumes `core-dev:latest` is already built locally. (`cd ../developer && docker build -t core-dev:latest .` if not.)

## Use

```bash
sbx run -t lthn/sbx-codex:dev codex ~/Code/core/agent
```

`codex` inside the sandbox sees:
- `php --version` → 8.3+
- `composer --version` → live
- `go version` → 1.26.x
- `node --version` → 24+
- `git config user.email` → `codex@lthn.ai` (overridable)
- Workspace bind-mounted at `/home/agent/workspace`

## Auth

- **OpenAI Codex OAuth**: already stored globally via `sbx secret set -g openai --oauth` on the host. sbx's proxy passes the token into the sandbox automatically; no config inside the container needed.
- **Forge/Mantis writes**: sbx doesn't support arbitrary service secrets (hardcoded list: anthropic/aws/droid/github/google/groq/mistral/nebius/openai/xai). For now, codex commits locally inside the bind-mounted workspace and Snider pushes from the host after review. Mantis #69 tracks the structural fix (public-read projects so tickets-by-URL work without any auth).
- **Git identity**: baked into the image (`Codex (sbx) <codex@lthn.ai>`). Override per-run with `git config user.email` inside the session if needed.

## Labels

- `com.docker.sandboxes=templates`
- `com.docker.sandboxes.flavor=codex-core-dev`
- `com.docker.sandboxes.base=core-dev:latest`
- EUPL-1.2

## Related

- `../developer/Dockerfile` — core-dev base image (PHP/Go/Node/Python toolchains, ~20GB)
- Upstream: https://hub.docker.com/r/docker/sandbox-templates (codex, codex-docker, shell, shell-docker variants)
