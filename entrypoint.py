"""Module to control the ``engine-room`` containers."""

from __future__ import annotations

import os
import pathlib
import pwd
import shutil
import socket
import subprocess

import yaml

HOST = socket.gethostname().replace("engine-room-", "")
MODULE_DIR: pathlib.Path = pathlib.Path(__file__).parents[0]
with open(MODULE_DIR / "config.yml") as f:
    CONFIG = yaml.safe_load(f)
SSH_PORT = 1978
UID = os.getuid()
GID = os.getgid()
USER = CONFIG["engine-rooms"][HOST]["user"]

E = pathlib.Path("/etc")
H = pathlib.Path(f"/home/{USER}")
D = pathlib.Path(os.getenv("DOT", H / "engine-room/dotfiles"))
O = pathlib.Path("/opt")  # noqa: E741
R = pathlib.Path("/root")
S = pathlib.Path("/run/secrets")
V = pathlib.Path(os.getenv("VOLUME", "/mnt/volume"))

KEEPASS_DB_FILE = H / "keepass.kdbx"

try:
    USERMAP_UID = pwd.getpwnam(USER).pw_uid
    USERMAP_GID = pwd.getpwnam(USER).pw_gid
except KeyError:
    # The user `nörd` exists when the command `startup` is run in the container
    # we land here, when the command `run` is run on the host
    USERMAP_UID = UID
    USERMAP_GID = GID


def _change_ownership_recursively(path) -> None:
    """Change ownership of a directory recursively."""
    if any(
        (
            not pathlib.Path(path).exists(),
            # do not change non nörd stuff (outside of H and V)
            (not path.is_relative_to(H) and not path.is_relative_to(V)),
            path == H,  # takes far too long
        )
    ):
        return
    print(f"Change ownership of {path}...")
    os.system(f"chown -R {USERMAP_UID}:{USERMAP_GID} {path}")


def _create_symlink(link: pathlib.Path, target: pathlib.Path) -> None:
    """Create symbolic link and make `nörd` the owner when needed."""
    link.parent.mkdir(parents=True, exist_ok=True)
    os.chown(link.parent, USERMAP_UID, USERMAP_GID)
    link.symlink_to(target)
    if link.is_relative_to(H):
        os.lchown(link, USERMAP_UID, USERMAP_GID)


def _process_symbolic_links() -> None:
    """Create symbolic links to directories in Docker volume."""
    try:
        symlinks_host = CONFIG["engine-rooms"][HOST]["symlinks"]
        symlinks = {**CONFIG["symlinks"], **symlinks_host}
    except KeyError:
        symlinks = CONFIG["symlinks"]

    # Add single letter variables for common paths to environment
    # These are used in the `config.yml` file to define shortcuts for paths
    # and will be evaluated in the following using `os.path.expandvars`
    vars = {
        "D": os.path.expandvars(f"/home/{USER}/engine-room/dotfiles"),
        "E": "/etc",
        "H": os.path.expandvars(f"/home/{USER}"),
        "O": "/opt",
        "R": "/root",
        "S": "/run/secrets",
        "V": "/mnt/volume",
    }
    for k, v in vars.items():
        os.environ[k] = v

    for dest, link in symlinks.items():
        dest = pathlib.Path(os.path.expandvars(dest))
        link = pathlib.Path(os.path.expandvars(link))
        if dest.exists():
            if dest.is_dir():
                if link.is_symlink():
                    link.unlink()  # better recreate with known target
                elif link.is_dir():
                    shutil.rmtree(link)  # volume has precedence over img data
                else:
                    link.parent.mkdir(parents=True, exist_ok=True)
                    _change_ownership_recursively(link.parent)
                _create_symlink(link, dest)
            elif dest.is_file():
                if link.is_symlink() or link.is_file():
                    link.unlink()
                else:
                    link.parent.mkdir(parents=True, exist_ok=True)
                    _change_ownership_recursively(link.parent)
                _create_symlink(link, dest)
            _change_ownership_recursively(dest)
        elif link.exists():
            if link.is_dir() and os.listdir(link):
                # landing here means the directory has been created during
                # docker build process and we copy link to target using shutil
                # shutil.copytree(link, target)
                os.system(f"cp -r {link} {dest}")
                _change_ownership_recursively(dest)
                shutil.rmtree(link)
            elif link.is_file():
                shutil.copy(link, dest)
                link.unlink()
            _create_symlink(link, dest)
        else:
            # we cannot create anything here because we do not know
            # if link or target are a file or a directory
            pass


def _set_mount_permissions() -> None:
    """Set permissions for bind mounts."""
    for directory in (
        H / "downloads",
        H / "engine-room",
        O / "bind",
        V,
    ):
        if directory.exists():
            try:
                os.chown(directory, USERMAP_UID, USERMAP_GID)
            except PermissionError as exp:
                print(
                    "Cannot change owner"
                    f" (uid={USERMAP_UID}, guid={USERMAP_GID})"
                    f" of '{directory}': {exp}"
                )
    sockets = (
        pathlib.Path("/run/host-services/ssh-auth.sock"),
        pathlib.Path("/var/run/docker.sock"),
    )
    for sock in sockets:
        if sock.exists():
            os.system(f"chmod 777 {sock}")
    ssh_config = pathlib.Path("/run/secrets/ssh_config")
    if ssh_config.exists():
        os.system(f"chmod 600 {ssh_config}")


def _create_volume_dirs() -> None:
    """Create directories in volume."""
    for directory in (
        V / "nvim/share",
        V / "nvim/state",
    ):
        directory.mkdir(parents=True, exist_ok=True)


def _setup_ssh() -> None:
    """Setup SSH."""
    ssh_dir = H / ".ssh"
    ssh_dir.mkdir(exist_ok=True)
    os.chown(ssh_dir, USERMAP_UID, USERMAP_GID)


if __name__ == "__main__":
    """Start the `engine-room` container (entry point)."""
    _setup_ssh()
    _create_volume_dirs()
    _process_symbolic_links()
    _set_mount_permissions()
    try:
        entrypoint = CONFIG["engine-rooms"][HOST]["original-entrypoint"]
    except KeyError:
        entrypoint = [
            "/usr/sbin/sshd",
            "-D",
            f"-p {os.getenv('SSH_PORT', '22')}",
        ]
    os.execv(entrypoint[0], entrypoint)
