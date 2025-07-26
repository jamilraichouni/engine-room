# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

The "engine-room" is a Docker-based development environment system that
provides feature-rich containers for hacking on any host. It supports multiple
named services (engine-rooms) configured in `docker-compose.yml`.

## High-Level Architecture

- **Base Architecture**: The system is built on Docker containers with a
  layered approach:
  - `engine-room:os` - Base operating system image (Fedora 40)
  - `engine-room:base` - Common development environment built on top of OS
  - Specialized containers like `dbmac`, `capella-6.0.0`, `capella-7.0.0` for
    specific use cases

- **Configuration Management**:
  - `config.yml` defines symlinks, copies, and user configurations for each
    engine-room
  - `docker-compose.yml` orchestrates services with environment variables,
    secrets, volumes, and ports
  - Shared configuration via tracked `dotfiles` and untracked `secrets`
    directories

- **Entrypoint System**: Python-based `entrypoint.py` manages container
  initialization, including:
  - Symlink creation based on config.yml
  - Ownership management for files and directories
  - Environment setup with single-letter path variables ($D, $E, $H, etc.)

## Common Development Commands

### Docker Operations

```bash
# Start a service
docker compose up -d <service>

# Stop a service
docker compose down <service>

# Enter a container via SSH (requires SSH setup on port 1978)
ssh <service>

# Special entry for Capella containers
docker exec -it --user=techuser capella-7.0.0 zsh
```

### Build Commands

```bash
# Build a specific image
docker compose build <service>

# Build base image with specific JDK
docker compose build base --build-arg JDK_FILE=OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.4_7.tar.gz
```

### Python Development

The project uses `uv` for Python package management. Python dependencies are
managed at the system level using:

```bash
uv pip install --system --break-system-packages -r ~/engine-room/dotfiles/requirements.txt
```

## Key Services

- **base**: General development environment with Java, Python, and common tools
- **dbmac**: Deutsche Bahn Mac development environment with additional ports
  and secrets
- **capella-6.0.0/7.0.0**: Eclipse Capella modeling tool environments with
  remote desktop access
- **ja**: Java development environment
- **raspi5**: Raspberry Pi 5 specific environment

## Important Paths

- `/home/nerd/engine-room`: Main project directory
- `/mnt/volume`: Persistent volume mount for each container
- `/opt/bind`: Shared bind mount directory
- `/run/secrets`: Docker secrets mount location
- `~/engine-room/dotfiles`: Tracked configuration files
- `~/engine-room/secrets`: Untracked secrets (Git ignored)

## Testing

No specific test framework is configured. Testing would depend on the specific
project being developed within the containers.

## Linting and Type Checking

When working on Python code within containers, use standard tools:

```bash
# Python linting
ruff check .

# Python type checking
mypy .
```

## Notes for Claude Code

- This is a Docker container management system, not a traditional application
  project
- Always verify container state before making changes to configurations
- Secrets are managed via Docker secrets and environment variables
- The system supports Docker-in-Docker operations (Docker socket is mounted)
- XQuartz is used for GUI applications on macOS hosts
- SSH agent forwarding is configured for seamless Git operations
