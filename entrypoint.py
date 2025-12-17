"""Module to control the ``engine-room`` containers."""

from __future__ import annotations

import asyncio
import logging
import os
import pathlib
import pwd
import shutil
import socket
import threading

import aiofiles
import yaml

HOST = socket.gethostname().replace("engine-room-", "")
MODULE_DIR = pathlib.Path(__file__).parents[0]
with pathlib.Path(MODULE_DIR / "config.yml").open() as f:
    CONFIG = yaml.safe_load(f)
SSH_PORT = 1978
UID = os.getuid()
GID = os.getgid()
USER = CONFIG["engine-rooms"][HOST]["user"]

logger = logging.getLogger("engine-room")


def _setup_logging() -> None:
    formatter: logging.Formatter = logging.Formatter(
        fmt="[%(asctime)s.%(msecs)03d] %(levelname)-8s : %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    for handler in logger.handlers:
        logger.removeHandler(handler)
    logger.setLevel("DEBUG")
    console_hdl: logging.Handler = logging.StreamHandler()
    console_hdl.setLevel(logging.DEBUG)
    console_hdl.setFormatter(formatter)
    logger.addHandler(console_hdl)
    logfile_path = pathlib.Path(f"/home/{USER}/engine-room/engine-room.log")
    logger.info("Logging to '%s'", logfile_path)
    logfile_path.unlink(missing_ok=True)
    filehdl: logging.Handler = logging.FileHandler(
        filename=logfile_path, mode="w"
    )
    filehdl.setLevel(logging.DEBUG)
    filehdl.setFormatter(formatter)
    logger.addHandler(filehdl)


# Add single letter variables for common paths to environment
# These are used in the `config.yml` file to define shortcuts for paths
# and will be evaluated in the following using `os.path.expandvars`
LOCATIONS = {
    "D": pathlib.Path(
        os.path.expandvars(f"/home/{USER}/engine-room/dotfiles"),
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


async def _change_ownership_recursively(
    path: os.PathLike,
    uid: str = USERMAP_UID,
    gid: str = USERMAP_GID,
) -> None:
    """Change ownership of a directory recursively."""
    if any(
        (
            not pathlib.Path(path).exists(),
            # do not change non nerd stuff (outside of H and V)
            (not path.is_relative_to(H) and not path.is_relative_to(V)),
            path == H,  # takes far too long
            path.is_relative_to(O),
        ),
    ):
        return
    logger.debug("Change ownership of '%s'…", path)
    thread = threading.Thread(
        target=os.system,
        args=(f"chown -R {uid}:{gid} {path}",),
    )
    thread.start()


async def _create_symlink(link: pathlib.Path, target: pathlib.Path) -> None:
    """Create symbolic link and make USER the owner when needed."""
    link.parent.mkdir(parents=True, exist_ok=True)
    os.chown(link.parent, USERMAP_UID, USERMAP_GID)
    link.symlink_to(target)
    if link.is_relative_to(H):
        os.lchown(link, USERMAP_UID, USERMAP_GID)


async def _copy(
    copy: dict,
    source: pathlib.Path,
    target: pathlib.Path,
) -> None:
    if source.is_dir():
        logger.debug("Copy directory '%s' to '%s'…", source, target)
        shutil.copytree(source, target, dirs_exist_ok=True)
        asyncio.create_subprocess_shell(
            f"chmod -R {copy['mode']} {target}",
        )
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        logger.debug("Copy file '%s' to '%s'…", source, target)
        shutil.copy(source, target)
        asyncio.create_subprocess_shell(f"chmod {copy['mode']} {target}")


async def _process_copies() -> None:
    """Copy files/ directories and set ownership and permissions."""
    copies: list[dict] | None = CONFIG["engine-rooms"][HOST].get(
        "copies",
        None,
    )
    if copies is None:
        return
    logger.info("Process copies…")
    tasks = []
    for copy in copies:
        source = pathlib.Path(os.path.expandvars(copy["source"]))
        target = pathlib.Path(os.path.expandvars(copy["target"]))
        tasks.append(asyncio.create_task(_copy(copy, source, target)))
        tasks.append(
            asyncio.create_task(
                _change_ownership_recursively(
                    target,
                    copy["uid"],
                    copy["gid"],
                ),
            ),
        )
    for task in tasks:
        await task


async def _process_symbolic_links() -> None:  # noqa: C901, PLR0912, PLR0915
    """Create symbolic links to directories in Docker volume."""
    symlinks: dict | None = None
    try:
        symlinks_host = CONFIG["engine-rooms"][HOST]["symlinks"]
        symlinks = {**CONFIG["symlinks"], **symlinks_host}
    except KeyError:
        symlinks = CONFIG.get("symlinks", None)
    if symlinks is None:
        return
    logger.info("Process symbolic links…")
    tasks = []
    for dest, link in symlinks.items():
        dest_ = pathlib.Path(os.path.expandvars(dest))
        link_ = pathlib.Path(os.path.expandvars(link))
        logger.debug("Create symbolic link '%s' to '%s'…", link_, dest_)
        if dest_.exists():
            logger.debug("Destination '%s' exists…", dest_)
            if dest_.is_dir():
                logger.debug("Destination '%s' is a directory…", dest_)
                if link_.is_symlink():
                    link_.unlink()  # better recreate with known target
                elif link_.is_dir():
                    try:
                        shutil.rmtree(
                            link_,
                        )  # volume has precedence over img data
                    except OSError:
                        logger.exception(
                            "Cannot remove directory '%s'",
                            link_,
                        )
                        continue
                else:
                    link_.parent.mkdir(parents=True, exist_ok=True)
                    tasks.append(
                        asyncio.create_task(
                            _change_ownership_recursively(link_.parent)
                        )
                    )
                tasks.append(
                    asyncio.create_task(_create_symlink(link_, dest_))
                )
            elif dest_.is_file():
                logger.debug("Destination '%s' is a file…", dest_)
                if link_.is_symlink() or link_.is_file():
                    link_.unlink()
                else:
                    link_.parent.mkdir(parents=True, exist_ok=True)
                    tasks.append(
                        asyncio.create_task(
                            _change_ownership_recursively(link_.parent)
                        )
                    )
                tasks.append(
                    asyncio.create_task(_create_symlink(link_, dest_))
                )
            tasks.append(
                asyncio.create_task(_change_ownership_recursively(dest_))
            )
        elif link_.exists():
            logger.debug(
                "Destination '%s' does not exist, but link '%s' exists…",
                dest_,
                link_,
            )
            if link_.is_dir() and link_.iterdir():
                # landing here means the directory has been created during
                # docker build process and we copy link to target using shutil
                os.system(f"cp -r {link_} {dest_}")  # noqa: S605
                tasks.append(
                    asyncio.create_task(_change_ownership_recursively(dest_))
                )
                shutil.rmtree(link_)
            elif link_.is_file():
                shutil.copy(link_, dest_)
                link_.unlink()
            tasks.append(asyncio.create_task(_create_symlink(link_, dest_)))
        else:
            # we cannot create anything here because we do not know
            # if link or target are a file or a directory
            pass
    for task in tasks:
        await task


async def _set_mount_permissions() -> None:
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
                print(  # noqa: T201
                    "Cannot change owner"
                    f" (uid={USERMAP_UID}, guid={USERMAP_GID})"
                    f" of '{directory}': {exp}",
                )
    sockets = (
        pathlib.Path("/run/host-services/ssh-auth.sock"),
        pathlib.Path("/var/run/docker.sock"),
    )
    for sock in sockets:
        logger.debug("Process socket '%s'…", sock)
        if sock.exists():
            logger.debug(
                "Socket '%s' exists and permissions are set to 777…",
                sock,
            )
            os.system(f"chmod 777 {sock}")  # noqa: S605
    ssh_config = pathlib.Path("/run/secrets/ssh_config")
    if ssh_config.exists():
        os.system(f"chmod 600 {ssh_config}")  # noqa: S605


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
        os.system(f"chown -R {USERMAP_UID}:{USERMAP_GID} {path}")  # noqa: S605
        os.system(f"chmod -R 700 {path}")  # noqa: S605


async def setup() -> None:
    """Run the setup tasks without starting services."""
    _create_volume_dirs()

    # Write environment variables to a file for zsh to source
    env_file = H / ".engine_room_env"
    async with aiofiles.open(env_file, "w") as f:
        for k, v in LOCATIONS.items():
            logger.debug("Set environment variable '%s' to '%s'…", k, v)
            os.environ[k] = str(v)
            await f.write(f"export {k}={v}\n")

    os.chown(env_file, USERMAP_UID, USERMAP_GID)
    tasks = []
    tasks.append(asyncio.create_task(_process_copies()))
    tasks.append(asyncio.create_task(_process_symbolic_links()))
    tasks.append(asyncio.create_task(_set_mount_permissions()))
    for task in tasks:
        await task
    logger.info("Setup completed.")


async def main() -> None:
    """Start the `engine-room` container (entry point)."""
    _setup_logging()
    logger.info("HOST: '%s'", HOST)
    logger.info("USER: '%s'", USER)
    await setup()


if __name__ == "__main__":
    asyncio.run(main())
