# core-images

Container images for the host-uk ecosystem. Each image produces multiple outputs:
- **Docker image** → `ghcr.io/host-uk/<name>`
- **LinuxKit image** → `<name>-<arch>.qcow2` / `<name>-<arch>.iso`
- **TIM bundle** → `<name>-<os>-<arch>.tim` (future)

## Images

### Runtime

| Image | Purpose | Docker | LinuxKit |
|-------|---------|--------|----------|
| `developer` | Full-fat dev environment (100+ tools) | `ghcr.io/host-uk/core-dev` | `core-dev-amd64.qcow2` |
| `server-php` | Alpine + Nginx + PHP-FPM | `ghcr.io/host-uk/server-php` | `server-php-amd64.qcow2` |

### CI Build

| Image | Purpose | Docker |
|-------|---------|--------|
| `php` | PHP + extensions + Composer for CI | `lthn/build:php-8.3`, `lthn/build:php-8.4` |
| `go` | Go + govulncheck + golangci-lint for CI | `lthn/build:go-1.26` |

## Usage

### Docker

```bash
# Developer environment
docker run -it ghcr.io/host-uk/core-dev

# PHP server
docker run -p 80:80 ghcr.io/host-uk/server-php
```

### LinuxKit (via Core CLI)

```bash
# Build LinuxKit image
core build --type linuxkit --config developer/linuxkit.yml

# Run LinuxKit image
core run core-dev-amd64.qcow2

# Run with custom resources
core run core-dev-amd64.qcow2 --memory 4096 --cpus 4
```

### TIM (future, Docker-free)

```bash
# Install dev environment
core dev install

# Run directly
core run core-dev.tim

# Run PHP server
core run server-php.tim -p 80:80
```

## Building Locally

### Using Core CLI (recommended)

```bash
# Install core CLI
go install github.com/host-uk/core/cmd/core@latest

# Build LinuxKit images
core build --type linuxkit --config developer/linuxkit.yml --format qcow2-bios
core build --type linuxkit --config server-php/linuxkit.yml --format qcow2-bios

# Build Docker images
core build --type docker --config developer/Dockerfile
core build --type docker --config server-php/Dockerfile
```

### Using Task

```bash
# Requires: task (taskfile.dev)

# Build all
task build

# Build specific image
task build:developer
task build:server-php
```

## Structure

```
core-images/
├── php/                 # CI build image - PHP + extensions + Composer
│   └── Dockerfile
├── go/                  # CI build image - Go + linters
│   └── Dockerfile
├── developer/           # core-dev - Full dev environment
│   ├── Dockerfile       # Docker build
│   ├── linuxkit.yml     # LinuxKit build
│   ├── Borgfile         # TIM build (future)
│   └── config/
├── server-php/          # server-php - Nginx + PHP-FPM
│   ├── Dockerfile
│   ├── linuxkit.yml
│   ├── Borgfile
│   └── config/
└── linuxkit/            # LinuxKit documentation
    └── README.md
```

## CI/CD

### CI Build Images (`.forgejo/workflows/build.yml`)

Builds `lthn/build:php-8.3`, `lthn/build:php-8.4`, `lthn/build:go-1.26` and pushes to Docker Hub on merge to main.

### Runtime Images (`.github/workflows/build.yml`)

1. **Docker images** - Multi-arch (amd64, arm64) pushed to GHCR
2. **LinuxKit images** - qcow2 and ISO formats for both architectures
3. **Release artifacts** - LinuxKit images uploaded to GitHub Releases on tags

## Sources

Consolidated from:
- [docker-developer](https://github.com/host-uk/docker-developer)
- [docker-server-php](https://github.com/host-uk/docker-server-php)
