# engine-room

The center of all I do on hosts takes place in containers and most of the
configuration is configured in the subdirectory `dotfiles`.

This repository provides the `engine-room:<TAG>`, a collection of Docker
containers for professional development work.

There is an `engine-room:base` container which is the base for most of the
other containers listed in the file `docker-compose.yml`.

The base container itself derives from `engine-room:os` and is ready to go
on any Docker host.

User and host specific configurations can be defined in dedicated Docker files.
Find examples in the provided `docker-compose.yml` file.

## Requirements on the Docker host

- `docker` and `docker-compose`
- `git` to clone the `engine-room` repository
- `python3` with package `PyYAML`
- Directory `/opt/bind` owned by the host user that uses Docker.
- optional: `KeePassXC` from <https://keepassxc.org> (for secrets management)

### ssh configuration

After cloning the repository to `$HOME/engine-room`, run

```bash
chmod -R 600 ~/engine-room/dotfiles/ssh

# NOT SYMBOLIC BUT HARD LINKS !!!

ln ~/engine-room/dotfiles/ssh/authorized_keys ~/.ssh/authorized_keys
ln ~/engine-room/dotfiles/ssh/config ~/.ssh/config
```

Both of the ssh files will be mounted as secrets into any running container.
Also ensure, that the private part of a key is added to the `ssh-agent` (check
it with `ssh-add -l`). The private key should have its public part listed in
the `~/.ssh/authorized_keys` file.

The file `~/.ssh/config` should contain the following:

```bash
Host NAME
    HostName localhost
    Port 1978
    User nörd
```

Here, `NAME` is the name of the host/ engine-room (service in
`docker-compose.yml`)

### Volume mounts

The directory `/opt/bind` is mounted in the containers via
`/opt/bind:/opt/bind`.

### Containers `dbmac` and `capella-x.y.z`

- Directory `/opt/bind/workspaces` owned by the host user that uses Docker.

## Installation

Clone this repository to your home directory.

## Containers

### `engine-room:capella`

Run the container with:

```bash
docker compose up capella-7.0.0
```

Work in the container:

```bash
docker exec -it --user=techuser capella zsh
```

Access desktop of the container:

Visit <http://localhost:10700/> in your browser.
