"""Module to control the ``engine-room`` containers."""

from __future__ import annotations

import os
import pathlib
import platform
import pwd
import shutil
import socket
import subprocess
import sys
import time

import yaml

try:
    import click
except ModuleNotFoundError:
    raise EnvironmentError(f"Run {sys.executable} -m pip install click")

E = pathlib.Path("/etc")
H = pathlib.Path("/home/nörd")
D = pathlib.Path(os.getenv("DOT", H / "engine-room/dotfiles"))
O = pathlib.Path("/opt")  # noqa: E741
R = pathlib.Path("/root")
S = pathlib.Path("/run/secrets")
V = pathlib.Path(os.getenv("VOLUME", "/mnt/volume"))

CONTAINER_TAG = "base"
HOST = socket.gethostname().replace("engine-room-", "")
if HOST == "bwpm-RH7L6T19Y1":
    KEEPASS_DB_FILE = (
        pathlib.Path.home() / "engine-room/build/er-keypass-db-er.kdbx"
    )
else:
    KEEPASS_DB_FILE = pathlib.Path("/build/er-keypass-db-er.kdbx")
KEEPASS_DB_PASSWORD = os.getenv("KEEPASS_DB_PASSWORD", "")
MODULE_DIR: pathlib.Path = pathlib.Path(__file__).parents[0]
SSH_PORT = 1978
ENV_OF_ROOT_USER = {
    "KEEPASS_DB_PASSWORD": KEEPASS_DB_PASSWORD,
    "SSH_PORT": str(SSH_PORT),
}
PORTS = (
    SSH_PORT,
    4200,
    5001,
    5098,
    6006,
    8000,
    8081,
)
UID = os.getuid()
GID = os.getgid()
try:
    USERMAP_UID = pwd.getpwnam("nörd").pw_uid
    USERMAP_GID = pwd.getpwnam("nörd").pw_gid
except KeyError:
    # The user `nörd`exists when the command `startup` is run in the container
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


def _distribute_secrets() -> None:
    """Distribute secrets from KeePass database."""
    if not KEEPASS_DB_FILE.exists():
        return

    def on_error(stderr: bytes) -> None:
        if not stderr:
            return
        raise SystemExit(f"Error executing `' '.join(cmd)`: {stderr.decode()}")

    # Check if there is a group named `engine-room` in the KeePass database:
    cmd: list[str] = ["keepassxc-cli", "ls", "--quiet", str(KEEPASS_DB_FILE)]
    stdout, stderr = subprocess.Popen(
        cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE
    ).communicate(KEEPASS_DB_PASSWORD.encode())
    on_error(stderr)
    entries = stdout.decode().splitlines()
    if not stdout or "engine-room/" not in entries:
        click.echo(
            "No group named `engine-room` found in KeePass database"
            f" at `{KEEPASS_DB_FILE}`."
        )
        return
    # consider subgroup `env` of group `engine-room`:
    cmd = [
        "keepassxc-cli",
        "ls",
        "--quiet",
        "--recursive",
        "--flatten",
        str(KEEPASS_DB_FILE),
        "engine-room/env",
    ]
    stdout, stderr = subprocess.Popen(
        cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE
    ).communicate(KEEPASS_DB_PASSWORD.encode())
    on_error(stderr)
    if stdout:
        entries = stdout.decode().splitlines()
        for entry in entries:
            cmd = [
                "keepassxc-cli",
                "show",
                "--quiet",
                "--show-protected",
                str(KEEPASS_DB_FILE),
                f"engine-room/env/{entry}",
            ]
            stdout, stderr = subprocess.Popen(
                cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE
            ).communicate(KEEPASS_DB_PASSWORD.encode())
            on_error(stderr)
            if stdout:
                attr_name = "Password"
                key = f"{attr_name}:"
                attrs = [
                    attr.split(key)[1]
                    for attr in stdout.decode().splitlines()
                    if attr.startswith(key)
                ]
                if attrs and attrs[0].strip():
                    value = attrs[0].strip()
                    export_statement = f"export {entry}={value}"
                    if export_statement not in open(E / "zshenv").read():
                        with open(E / "zshenv", "a") as file:
                            file.write(f"\n{export_statement}")
    # consider subgroup `files` of group `engine-room`:
    cmd = [
        "keepassxc-cli",
        "ls",
        "--quiet",
        "--flatten",
        str(KEEPASS_DB_FILE),
        "engine-room/files",
    ]
    stdout, stderr = subprocess.Popen(
        cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE
    ).communicate(KEEPASS_DB_PASSWORD.encode())
    on_error(stderr)
    if stdout:
        entries = stdout.decode().splitlines()
        for file_path in [path for path in entries if not path.endswith("/")]:
            cmd = [
                "keepassxc-cli",
                "show",
                "--quiet",
                "--show-protected",
                str(KEEPASS_DB_FILE),
                f"engine-room/files/{file_path}",
            ]
            stdout, stderr = subprocess.Popen(
                cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE
            ).communicate(KEEPASS_DB_PASSWORD.encode())
            on_error(stderr)
            if stdout:
                file_content = ""
                attr_name = "Notes"
                key = f"{attr_name}:"
                attrs = [
                    attr.split(key)[1]
                    for attr in stdout.decode().splitlines()
                    if attr.startswith(key)
                ]
                if attrs and attrs[0].strip():
                    file_content = attrs[0].strip()
                if file_content:
                    file_path = file_path.replace("~", str(H))
                    pathlib.Path(file_path).write_text(file_content)


def _process_symbolic_links() -> None:
    """Create symbolic links to directories in Docker volume."""
    with open(MODULE_DIR / "config.yml") as f:
        config = yaml.safe_load(f)
    user = config["engine-rooms"][HOST]["user"]
    try:
        symlinks_host = config["engine-rooms"][HOST]["symlinks"]
        symlinks = {**config["symlinks"], **symlinks_host}
    except KeyError:
        symlinks = config["symlinks"]
    vars = {
        "D": os.path.expandvars(f"/home/{user}/engine-room/dotfiles"),
        "E": "/etc",
        "H": os.path.expandvars(f"/home/{user}"),
        "O": "/opt",
        "R": "/root",
        "S": "/run/secrets",
        "V": "/mnt/volume",
    }
    for k, v in vars.items():
        os.environ[k] = v
    for link, dest in symlinks.items():
        link = pathlib.Path(os.path.expandvars(link))
        dest = pathlib.Path(os.path.expandvars(dest))
        if dest.exists():
            if dest.is_dir():
                if link.is_symlink():
                    link.unlink()
                elif link.is_dir():
                    shutil.rmtree(link)
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

                content_to_merge = ""
                # if link.is_file() and link.name == "zshenv":
                #     content_to_merge = link.read_text()
                _create_symlink(link, dest)
                _change_ownership_recursively(dest)
                # if content_to_merge:
                #     link.write_text(f"{link.read_text()}\n{content_to_merge}")
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
            # of link or target are a file or a directory
            pass
            # target.mkdir(parents=True, exist_ok=True)
            # _change_ownership_recursively(target)
            # _create_symlink(link, target)


def _set_bind_mount_permissions() -> None:
    """Set permissions for bind mounts."""
    for directory in (
        H / ".ssh",
        H / "bak",
        H / "downloads",
        H / "engine-room",
        O / "bind",
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


def _install_pyenv_and_set_up_global_python() -> None:
    """Install pyenv and set up global python."""


@click.group()
def cli() -> None:
    """CLI to work with an `engine-room` container."""


@cli.command()
@click.argument("tag")
@click.option("-v", "--verbose", is_flag=True, help="Enable verbose output")
def run(tag: str, verbose: bool = False) -> None:
    """Run an `engine-room` container by tag.

    \b
    Arguments
    ---------
    tag
        Tag for the engine-room container to run
    """
    ssh_dir = pathlib.Path.home() / ".ssh"
    if not ssh_dir.is_dir():
        click.UsageError("Cannot find '.ssh' directory!")
    ssh_dir = ssh_dir.resolve()
    cmd: list[str] = ["docker", "rm", "--force", "engine-room"]
    subprocess.run(cmd, check=False, capture_output=True)
    if tag.startswith("bwpm"):
        tag = "dbmac"

    # Check if the volume exists
    check_command = ["docker", "volume", "ls", "-q", "--filter", f"name={tag}"]
    return_code = subprocess.run(check_command, capture_output=True, text=True)
    if return_code.returncode != 0:
        raise SystemExit(return_code.stderr)

    # If the volume does not exist, create it
    is_new_volume = False
    if not return_code.stdout.strip():
        create_command = ["docker", "volume", "create", tag]
        return_code = subprocess.run(
            create_command, capture_output=True, text=True
        )
        if return_code.returncode == 0:
            click.echo(f"Created volume {tag}")
        else:
            raise SystemExit(return_code.stderr)
        is_new_volume = True
    cmd = [
        "docker",
        "run",
        "-d",
        "--rm",
        "-it",
        "--cap-add=SYS_PTRACE",
        "--hostname",
        f"engine-room-{tag}",
        "--name",
        "engine-room",
    ]
    for key, val in ENV_OF_ROOT_USER.items():
        cmd.extend(["-e", f"{key}={val}"])

    for port in PORTS:
        cmd.extend(
            [
                "-p",
                f"{port}:{port}",
            ]
        )
    # volume mounts:
    cmd.extend(
        [
            "-v",
            f"{tag}:/mnt/volume",
            # bind volumes:
            "-v",
            f"{ssh_dir}/:/home/nörd/.ssh",
            "-v",
            f"{MODULE_DIR.resolve()}:/home/nörd/engine-room",
            # /opt/bind is the directory where the bind mounts are mounted
            # chosen, because given on macOS and Linux and on DB computer
            # I cannot create any directory in `/`
            "-v",
            "/opt/bind:/opt/bind",
        ]
    )
    ssh_auth_sock = "/run/host-services/ssh-auth.sock"
    cmd.extend(["-e", f"SSH_AUTH_SOCK={ssh_auth_sock}"])
    cmd.extend(["-v", f"{ssh_auth_sock}:{ssh_auth_sock}"])

    if platform.system().lower() in (
        "darwin",
        "linux",
    ):
        cmd.extend(["-v", "/tmp/:/tmp"])
        cmd.extend(["-v", "/var/run/docker.sock:/var/run/docker.sock"])
    if platform.system().lower() in (
        "darwin",
        "windows",
    ):
        cmd.extend(["-e", "DISPLAY=host.docker.internal:0.0"])
        downloads = pathlib.Path.home() / "Downloads"
    else:
        downloads = pathlib.Path.home() / "downloads"
    bak = pathlib.Path.home() / "bak"
    for directory in (downloads, bak):
        if directory.is_dir():
            cmd.extend(
                ["-v", f"{directory}:/home/nörd/{directory.name.lower()}"]
            )
    cmd.append(f"engine-room:{tag}")
    if verbose:
        click.echo(" ".join(cmd))
    subprocess.run(cmd, check=False, capture_output=True)
    if is_new_volume:
        time.sleep(5)
        subprocess.run(cmd, check=False, capture_output=True)


@cli.command()
@click.pass_context
@click.option("-v", "--verbose", is_flag=True, help="Enable verbose output")
def enter(ctx: click.core.Context, verbose: bool = False) -> None:
    """Enter the container."""
    if verbose:
        click.echo("Verbose mode is on")
    # check if the docker daemon is running
    cmd = ["docker", "info"]
    try:
        subprocess.run(cmd, check=True, capture_output=True)
    except subprocess.CalledProcessError:
        raise SystemExit(
            "The Docker daemon is not running. Start the Docker daemon."
        )
    cmd = [
        "docker",
        "ps",
        "--filter",
        "name=engine-room",
        "--format",
        "{{.Names}}",
    ]
    container_is_running = False
    try:
        result = subprocess.run(
            cmd, check=True, capture_output=True, text=True
        )
        container_is_running = result.stdout.strip() == "engine-room"
    except subprocess.CalledProcessError:
        raise SystemExit(
            "The Docker daemon is not running. Start the Docker daemon."
        )
    if not container_is_running:
        click.prompt(
            "I try to start the container `engine-room`. You can run"
            " `docker ps` to check, if the container is running."
            " Press ENTER to continue.",
            default="",
            show_default=False,
        )
        ctx.invoke(run, tag=socket.gethostname())
        raise SystemExit()
    ssh_auth_sock = os.getenv("SSH_AUTH_SOCK", "")
    if ssh_auth_sock:
        os.system(f"chmod 666 {ssh_auth_sock}")
    cmd = [
        "zsh",
        "-c",
        f"kitty +kitten ssh -p {SSH_PORT}"
        " -o StrictHostKeyChecking=no"
        " -o UserKnownHostsFile=/dev/null"
        " nörd@localhost",
    ]
    if verbose:
        click.echo(f"Running `{' '.join(cmd)}`")
    subprocess.run(cmd, check=False)


@cli.command()
def startup() -> None:
    """Start the `engine-room` container (entry point)."""
    (H / ".ssh").mkdir(exist_ok=True)
    _process_symbolic_links()
    # _distribute_secrets()
    _set_bind_mount_permissions()
    _install_pyenv_and_set_up_global_python()
    # gpg_agent_command = [
    #     "gpg-agent",
    #     "--homedir",
    #     "/home/nörd/.gnupg",
    #     "--daemon",
    # ]
    # subprocess.Popen(gpg_agent_command)
    sshd_path = "/usr/sbin/sshd"
    args = [sshd_path, "-D", f"-p {os.getenv('SSH_PORT', '22')}"]
    click.echo(
        f"engine-room listens on port `{SSH_PORT}` for ssh connections..."
    )
    os.execv(sshd_path, args)


if __name__ == "__main__":
    cli()
