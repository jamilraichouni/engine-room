# engine-room

The center of all I do on hosts takes place in containers and is configured via
my `dotfiles` stored in the according subdirectory.

This repository provides the `engine-room:<TAG>` which is a collection of Docker
containers for professional development work.

There is an `engine-room:base` container which is the base for all optional
user and host specific Docker development containers.

The base container itself derives from `engine-room:os` and is ready to go
on any Docker host.

User and host specific configurations can be defined in dedicated Docker files.
Find examples in the provided `docker-compose.yml` file.

## Requirements

- `git`
- `docker`
- `docker-compose`
- `python3` with packages `click` and `PyYAML`
- optional: `KeePassXC` from <https://keepassxc.org> (for secrets management)

## Installation

Clone this repository to your home directory.
