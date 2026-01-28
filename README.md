# core-images

Container images for the host-uk ecosystem. Each image produces dual outputs:
- **Docker image** → `ghcr.io/host-uk/<name>`
- **TIM bundle** → `<name>-<os>-<arch>.tim`

## Images

| Image | Purpose | Docker | TIM |
|-------|---------|--------|-----|
| `developer` | Full-fat dev environment (100+ tools) | `ghcr.io/host-uk/core-dev` | `core-dev.tim` |
| `server-php` | Alpine + Nginx + PHP-FPM | `ghcr.io/host-uk/server-php` | `server-php.tim` |

## Usage

### Docker

```bash
# Developer environment
docker run -it ghcr.io/host-uk/core-dev

# PHP server
docker run -p 80:80 ghcr.io/host-uk/server-php
```

### TIM (Docker-free via Core)

```bash
# Install dev environment
core dev install

# Or run directly
core run core-dev.tim

# Run PHP server
core run server-php.tim -p 80:80
```

## Building

```bash
# Requires: task (taskfile.dev)

# Build all
task build

# Build specific image
task build:developer
task build:server-php

# Build TIM only
task build:developer:tim

# Build Docker only
task build:developer:docker
```

## Structure

```
core-images/
├── developer/           # core-dev.tim - Full dev environment
│   ├── Dockerfile
│   ├── Borgfile
│   └── config/
├── server-php/          # server-php.tim - Nginx + PHP-FPM
│   ├── Dockerfile
│   ├── Borgfile
│   └── config/
└── base/                # Shared base configurations
    └── alpine/
```

## Sources

Consolidated from:
- [docker-developer](https://github.com/host-uk/docker-developer)
- [docker-server-php](https://github.com/host-uk/docker-server-php)
