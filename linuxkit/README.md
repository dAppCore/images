# LinuxKit Images

This directory contains documentation for LinuxKit image builds.

## Building with Core CLI

The recommended way to build LinuxKit images is using the `core` CLI:

```bash
# Install core CLI
go install github.com/host-uk/core/cmd/core@latest

# Build developer image (QCOW2 for QEMU/KVM)
core build --type linuxkit --config developer/linuxkit.yml --format qcow2-bios

# Build server-php image (QCOW2 for QEMU/KVM)
core build --type linuxkit --config server-php/linuxkit.yml --format qcow2-bios

# Build ISO for bare metal / other hypervisors
core build --type linuxkit --config developer/linuxkit.yml --format iso-bios
core build --type linuxkit --config server-php/linuxkit.yml --format iso-bios

# Build for specific architecture
core build --type linuxkit --config developer/linuxkit.yml --arch arm64
```

## Running Images

```bash
# Run with core CLI
core run core-dev-amd64.qcow2

# Run with custom resources
core run core-dev-amd64.qcow2 --memory 4096 --cpus 4

# Run in detached mode
core run -d core-dev-amd64.qcow2
```

## Output Formats

| Format | Use Case |
|--------|----------|
| `qcow2-bios` | QEMU/KVM (default) |
| `iso-bios` | Bare metal, VMware, VirtualBox |
| `raw-bios` | Direct disk write |
| `vhd` | Hyper-V |
| `vmdk` | VMware |
| `aws` | AWS EC2 AMI |
| `gcp` | Google Cloud |
| `azure` | Microsoft Azure |

## Image Architecture

### Developer Image

The developer LinuxKit image provides:

- Full developer toolchain (Node, Go, PHP, Python)
- Docker-in-LinuxKit for container workflows
- SSH access for remote development
- Persistent `/workspace` volume
- Pre-configured shell with aliases and starship prompt

### Server PHP Image

The server PHP LinuxKit image provides:

- Minimal Alpine base
- Nginx + PHP-FPM stack
- SSH access for management
- Health check endpoint at `/health`
- Persistent `/var/www/html` volume

## Customization

### Adding SSH Keys

Edit the `authorized_keys` file in the linuxkit.yml:

```yaml
files:
  - path: /etc/ssh/authorized_keys
    contents: |
      ssh-ed25519 AAAA... your-key@host
    mode: "0600"
```

### Environment Variables

Add environment variables to the service definition:

```yaml
services:
  - name: developer
    env:
      - MY_VAR=value
```

### Custom Packages

For additional packages, create a custom container image that inherits from the base and add it to the LinuxKit config.
