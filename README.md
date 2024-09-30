# engine-room

This repository provides a collection of `engine-room:<NAME>` Docker containers
for professional development work.

The idea is that the center of all we do on any host shall take in one common
and feature-rich engine-room container which is defined in the directory
`engine-rooms` and individualized in the file `docker-compose.yml`.

It is often already sufficient to use the `engine-room:base` container for
any named engine-room service and just configure the service specific environment
variables, volumes, secrets, ports, etc. in the `docker-compose.yml` file.

The `base` container itself derives from `engine-room:os` and is ready to go
on any Docker host.

Shared configuration is provided in the tracked `dotfiles` or the untracked
`secrets` directory.

## Requirements on the Docker host

### Command line tools

- `docker` and `docker-compose`
- `git` to clone the `engine-room` repository

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

### Secrets

Secrets that are referenced by any service (engine-room) in the file
`docker-compose.yml`) must be either defined as environment variable on the host
(e. g. `/etc/zshenv`) or as file in the Git ignored directory
`~/engine-room/secrets`.

### Docker in Docker volume mounts

When using Docker in Docker, volume mount host paths must exist with one and
the same path on the host and in the container since the Docker resources file
sharing settings are for the host and not for the container.

On macOS and Linux we have an `/opt` directory.

It is recommended to create a directory `/opt/bind` on the host and to mount it
into any engine-room container.

### Containers `dbmac` and `capella-x.y.z`

- Directory `/opt/bind/workspaces` owned by the host user that uses Docker.

## Installation

- Clone this repository to your home directory.
- Define any secrets in the directory `~/engine-room/secrets` or as environment
  variables on the host that should only be visible to the user `root`.

## Start/ stop/ enter containers

### Default

Start:

```bash
docker compose up -d <service>
```
(without `-d` for debugging to see the ouput of the container)

Stop:

```bash
docker compose down <service>
```

Enter:

```bash
ssh NAME  # with NAME as defined in ~/.ssh/config
```

### Special container `engine-room:capella`

Start:

```bash
docker compose up capella-7.0.0
```

Enter:

```bash
docker exec -it --user=techuser capella zsh
```

When `DISPLAY=:10` is set in the container, the Capella desktop can be accessed
via <http://localhost:10700/> in your browser.
