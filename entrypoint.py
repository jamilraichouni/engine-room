"""Module to control the ``engine-room`` containers."""

from __future__ import annotations

import logging
import os
import pathlib
import pwd
import shutil
import socket
import threading

import yaml

formatter: logging.Formatter = logging.Formatter(
    fmt="[%(asctime)s.%(msecs)03d] %(levelname)-8s : %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger()
for handler in logger.handlers:
    logger.removeHandler(handler)
logger.setLevel("DEBUG")
console_hdl: logging.Handler = logging.StreamHandler()
console_hdl.setLevel(logging.DEBUG)
console_hdl.setFormatter(formatter)
logger.addHandler(console_hdl)

HOST = socket.gethostname().replace("engine-room-", "")
MODULE_DIR = pathlib.Path(__file__).parents[0]
with open(MODULE_DIR / "config.yml") as f:
    CONFIG = yaml.safe_load(f)
SSH_PORT = 1978
UID = os.getuid()
GID = os.getgid()
USER = CONFIG["engine-rooms"][HOST]["user"]

logfile_path = pathlib.Path(f"/home/{USER}/engine-room/engine-room.log")
logger.info("Logging to '%s'", logfile_path)
logfile_path.unlink(missing_ok=True)
filehdl: logging.Handler = logging.FileHandler(filename=logfile_path, mode="w")
filehdl.setLevel(logging.DEBUG)
filehdl.setFormatter(formatter)
logger.addHandler(filehdl)
logger.info("HOST: '%s'", HOST)
logger.info("USER: '%s'", USER)

# Add single letter variables for common paths to environment
# These are used in the `config.yml` file to define shortcuts for paths
# and will be evaluated in the following using `os.path.expandvars`
LOCATIONS = {
    "D": pathlib.Path(
        os.path.expandvars(f"/home/{USER}/engine-room/dotfiles")
    ),
    "E": pathlib.Path("/etc"),
    "H": pathlib.Path(os.path.expandvars(f"/home/{USER}")),
    "O": pathlib.Path("/opt"),
    "R": pathlib.Path("/root"),
    "S": pathlib.Path("/run/secrets"),
    "V": pathlib.Path("/mnt/volume"),
}
D = LOCATIONS["D"]
E = LOCATIONS["E"]
H = LOCATIONS["H"]
O = LOCATIONS["O"]  # noqa: E741
R = LOCATIONS["R"]
S = LOCATIONS["S"]
V = LOCATIONS["V"]
KEEPASS_DB_FILE = H / "keepass.kdbx"

try:
    USERMAP_UID = pwd.getpwnam(USER).pw_uid
    USERMAP_GID = pwd.getpwnam(USER).pw_gid
except KeyError:
    # The user `nerd` exists when the command `startup` is run in the container
    # we land here, when the command `run` is run on the host
    USERMAP_UID = UID
    USERMAP_GID = GID


def _change_ownership_recursively(
    path, uid=USERMAP_UID, gid=USERMAP_GID
) -> None:
    """Change ownership of a directory recursively."""
    if any(
        (
            not pathlib.Path(path).exists(),
            # do not change non nerd stuff (outside of H and V)
            (not path.is_relative_to(H) and not path.is_relative_to(V)),
            path == H,  # takes far too long
        )
    ):
        return
    logger.debug("Change ownership of '%s'…", path)
    thread = threading.Thread(
        target=os.system, args=(f"chown -R {uid}:{gid} {path}",)
    )
    thread.start()
    # os.system(f"chown -R {uid}:{gid} {path}")


def _create_symlink(link: pathlib.Path, target: pathlib.Path) -> None:
    """Create symbolic link and make USER the owner when needed."""
    link.parent.mkdir(parents=True, exist_ok=True)
    os.chown(link.parent, USERMAP_UID, USERMAP_GID)
    link.symlink_to(target)
    if link.is_relative_to(H):
        os.lchown(link, USERMAP_UID, USERMAP_GID)


def _process_copies() -> None:
    "Copy files/ directories and set ownership and permissions."
    copies: list[dict] | None = (
        CONFIG["engine-rooms"][HOST]["copies"]
        if "copies" in CONFIG["engine-rooms"][HOST]
        else None
    )
    if copies is None:
        return
    logger.info("Process copies…")
    for copy in copies:
        source = pathlib.Path(os.path.expandvars(copy["source"]))
        target = pathlib.Path(os.path.expandvars(copy["target"]))
        if source.is_dir():
            logger.debug("Copy directory '%s' to '%s'…", source, target)
            shutil.copytree(source, target, dirs_exist_ok=True)
            os.system(f"chmod -R {copy['mode']} {target}")
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            logger.debug("Copy file '%s' to '%s'…", source, target)
            shutil.copy(source, target)
            os.system(f"chmod {copy['mode']} {target}")
        _change_ownership_recursively(target, copy["uid"], copy["gid"])


def _process_symbolic_links() -> None:
    """Create symbolic links to directories in Docker volume."""
    symlinks: dict | None = None
    try:
        symlinks_host = CONFIG["engine-rooms"][HOST]["symlinks"]
        symlinks = {**CONFIG["symlinks"], **symlinks_host}
    except KeyError:
        symlinks = CONFIG["symlinks"] if "symlinks" in CONFIG else None
    if symlinks is None:
        return
    logger.info("Process symbolic links…")
    for dest, link in symlinks.items():
        dest = pathlib.Path(os.path.expandvars(dest))
        link = pathlib.Path(os.path.expandvars(link))
        logger.debug("Create symbolic link '%s' to '%s'…", link, dest)
        if dest.exists():
            logger.debug("Destination '%s' exists…", dest)
            if dest.is_dir():
                logger.debug("Destination '%s' is a directory…", dest)
                if link.is_symlink():
                    link.unlink()  # better recreate with known target
                elif link.is_dir():
                    shutil.rmtree(link)  # volume has precedence over img data
                else:
                    link.parent.mkdir(parents=True, exist_ok=True)
                    _change_ownership_recursively(link.parent)
                _create_symlink(link, dest)
            elif dest.is_file():
                logger.debug("Destination '%s' is a file…", dest)
                if link.is_symlink() or link.is_file():
                    link.unlink()
                else:
                    link.parent.mkdir(parents=True, exist_ok=True)
                    _change_ownership_recursively(link.parent)
                _create_symlink(link, dest)
            _change_ownership_recursively(dest)
        elif link.exists():
            logger.debug(
                "Destination '%s' does not exist, but link '%s' exists…",
                dest,
                link,
            )
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
    logger.info("Set mount permissions…")
    for directory in (
        H / "downloads",
        H / "engine-room",
        O / "bind",
        V,
    ):
        logger.debug("Process directory '%s'…", directory)
        if directory.exists():
            logger.debug("Directory '%s' exists…", directory)
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
        logger.debug("Process socket '%s'…", sock)
        if sock.exists():
            logger.debug(
                "Socket '%s' exists and permissions are set to 777…", sock
            )
            os.system(f"chmod 777 {sock}")
    ssh_config = pathlib.Path("/run/secrets/ssh_config")
    if ssh_config.exists():
        os.system(f"chmod 600 {ssh_config}")


def _create_volume_dirs() -> None:
    """Create directories in volume."""
    logger.info("Create directories in volume…")
    for directory in (
        V / "nvim/share",
        V / "nvim/state",
    ):
        if directory.is_dir():
            logger.debug("Directory '%s' exists…", directory)
            continue
        logger.debug("Create directory '%s'…", directory)
        directory.mkdir(parents=True)


def _setup_secret_dirs() -> None:
    """Setup (create, ownership, permissions) dirs with secrets."""
    dirs = (
        ".ssh",
        # ".gnupg",
        # ".gnupg/private-keys-v1.d",
        # ".kube",
    )
    for directory in dirs:
        path = H / directory
        path.mkdir(parents=True, exist_ok=True)
        os.system(f"chown -R {USERMAP_UID}:{USERMAP_GID} {path}")
        os.system(f"chmod -R 700 {path}")
        # os.chown(path, USERMAP_UID, USERMAP_GID)


if __name__ == "__main__":
    """Start the `engine-room` container (entry point)."""
    # _setup_secret_dirs()
    _create_volume_dirs()
    for k, v in LOCATIONS.items():
        logger.debug("Set environment variable '%s' to '%s'…", k, v)
        os.environ[k] = str(v)
    _process_copies()
    _process_symbolic_links()
    _set_mount_permissions()
    logger.info("Setup completed.")
    try:
        entrypoint = CONFIG["engine-rooms"][HOST]["original-entrypoint"]
    except KeyError:
        entrypoint = [
            "/usr/sbin/sshd",
            "-D",
            f"-p {os.getenv('SSH_PORT', '1978')}",
        ]
    logger.info("Execute entrypoint command '%s'…", entrypoint[0])
    os.execv(entrypoint[0], entrypoint)
