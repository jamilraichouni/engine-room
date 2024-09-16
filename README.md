# engine-room

A collection of `engine-room-<NAME>` Docker containers. Hacking on any host
happens in one common and feature-rich container.

An `engine-room` can be individualized (named service) in the file
`docker-compose.yml`. `engine-room:<NAME>` images are defined in the directory
`images`.

The `base` container itself derives from `engine-room:os` and is ready to go
on any Docker host.

Therefore, it is often sufficient to use the `engine-room:base` container for
any named engine-room service and just configure the service specific
environment variables, volumes, secrets, ports, etc. in the
`docker-compose.yml` file.

Shared configuration is provided in the tracked `dotfiles` or the untracked
`secrets` directory.

## Requirements on the Docker host

### Command line tools

`docker`, `docker-compose`, and the files of this repository located
(recommended is a `git clone`) at `~/engine-room`.

A running `ssh-agent` with the private key(s) of the user. An unlocked
KeePassXC database can launch the `ssh-agent` and add the private key(s) to it.

### Docker in Docker volume mounts

Docker resources file sharing settings are for the computer and not for any
container running on it. This is why bind volume mount host paths must exist
with one and the same path on the computer and in a container that runs another
Docker container.

On macOS and Linux we have an `/opt` directory.

It is recommended to create a directory `/opt/bind` on the host and to mount it
into any engine-room container.

### XQuartz


### Containers `dbmac` and `capella-x.y.z`

- Directory `/opt/bind/workspaces` owned by the host user.

## Installation on the Docker host

```bash
git clone git@github.com:jamilraichouni/engine-room.git ~/engine-room
echo -e "USERMAP_UID=$(id -u)\nUSERMAP_GID=$(id -g)" > ~/engine-room/.env
find ~/engine-room/dotfiles/ssh -type f -exec chmod 600 {} +
find ~/engine-room/secrets -type f -exec chmod 600 {} +
```

Ensure that secret environment variables are defined. An option is to create a
file `/etc/zshenv.secrets` that will be sourced by `/etc/zshenv`:

Look into the file `~/engine-room/docker-compose.yml` for references to
secret environment variables.

## Optional terminal configuration on the Docker host

Only, if you want to work in the terminal of the host with the same
configuration as in the containers.

Install `fzf` to `/usr/local/bin/fzf`. `fzf` comes ready as release on GitHub:
<https://github.com/junegunn/fzf/releases>.

```bash
mkdir -p ~/bin
ln -s ~/engine-room/bin/pathprepend.zsh ~/bin/pathprepend
ln -s ~/engine-room/bin/ssh.zsh ~/bin/ssh
ln ~/engine-room/dotfiles/ssh/authorized_keys ~/.ssh/authorized_keys
ln ~/engine-room/dotfiles/ssh/config ~/.ssh/config
cat << 'EOF' > /tmp/setup_docker_host.zsh
# backup and replace system-wide zsh configuration
for F in /etc/zshenv /etc/zprofile /etc/zshrc; do [[ -f $F ]]  && mv $F{,.bak}; done

# environment variables
ln -s ~/engine-room/dotfiles/zsh/env/ALL_HOSTS.zsh ~/.zshenv
# login zsh configuration
ln -s ~/engine-room/dotfiles/zsh/profile/ALL_HOSTS.zsh ~/.zprofile
# interactive zsh configuration
ln -s ~/engine-room/dotfiles/zsh/interactive/ALL_HOSTS.zsh ~/.zshrc
rm -f /usr/local/bin/nvim
ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim
EOF
sudo zsh /tmp/setup_docker_host.zsh
```

Secrets that are referenced by any service (engine-room) in the file
`docker-compose.yml`) must be either defined as environment variable on the
host (e. g. `/etc/zshenv`) or as file in the Git ignored directory
`~/engine-room/secrets`.

## ssh configuration

Both of the ssh files will be mounted as secrets into any running container.
Also ensure, that the private part of a key is added to the `ssh-agent` (check
it with `ssh-add -l`). The private key should have its public part listed in
the `~/.ssh/authorized_keys` file.

The file `~/.ssh/config` should contain the following:

```bash
Host NAME
    HostName localhost
    Port 1978
    User nerd
```

Here, `NAME` is the name of the host/ engine-room (service in
`docker-compose.yml`)
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
