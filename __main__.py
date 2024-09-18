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

SYMBOLIC_LINK_MAP = {
    E / "git_askpass.py": D / "git_askpass.py",
    E / "zshenv": D / "zsh/env/ALL_HOSTS.zsh",
    E / "zprofile": D / "zsh/profile/ALL_HOSTS.zsh",
    H / ".cache": V / "cache",
    H / ".cargo": V / "cargo",
    H / ".config/github-copilot": D / "github-copilot",
    H / ".config/kitty": D / "kitty-config",
    H / ".config/nvim": D / "nvim-config",
    H / ".config/pip": D / "pip",
    H / ".config/rclone": D / "rclone",
    H / ".gdbextension.py": D / "gdbextension.py",
    H / ".gdbinit": D / "gdbinit",
    H / ".gitconfig": D / "gitconfig",
    H / ".github-copilot": D / "github-copilot",
    H / ".gitignore": D / "gitignore",
    H / ".gitmessage": D / "gitmessage",
    H / ".gnupg": D / "gnupg",
    H / ".ipython": D / "ipython",
    H / ".jupyter": D / "jupyter",
    H / ".kube": D / "kube",
    H / ".local/share/npm": V / "npm",
    H / ".local/share/nvim": V / "nvim/share",
    H / ".local/state/nvim": V / "nvim/state",
    H / ".m2": V / "m2",  # Maven cache
    H / ".nvm": V / "nvm",  # Node Version Manager
    H / ".p10k.zsh": D / "zsh/p10k.zsh",
    H / ".pdbrc": D / "pdbrc",
    H / ".pdbrc.py": D / "pdbrc.py",
    H / ".pyenv": V / "pyenv",
    H / ".rustup": V / "rustup",
    H / ".vimrc": D / "vimrc",
    H / ".zsh_history": D / "zsh_history",
    H / ".zshenv": D / f"zsh/env/{HOST}.zsh",
    H / ".zshrc": D / "zsh/zshrc",
    H / "pygmentsstyles.py": D / "pygmentsstyles.py",
    H / "dev": V / "dev",
}
if HOST == "dbmac":
    SYMBOLIC_LINK_MAP.update(
        {
            H / "workspaces": V / "workspaces",
        }
    )


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
    for link, target in SYMBOLIC_LINK_MAP.items():
        if target.exists():
            if target.is_dir():
                if link.is_symlink():
                    link.unlink()
                elif link.is_dir():
                    shutil.rmtree(link)
                else:
                    link.parent.mkdir(parents=True, exist_ok=True)
                    _change_ownership_recursively(link.parent)
                _create_symlink(link, target)
            elif target.is_file():
                if link.is_symlink() or link.is_file():
                    link.unlink()
                else:
                    link.parent.mkdir(parents=True, exist_ok=True)
                    _change_ownership_recursively(link.parent)
                content_to_merge = ""
                # if link.is_file() and link.name == "zshenv":
                #     content_to_merge = link.read_text()
                _create_symlink(link, target)
                # if content_to_merge:
                #     link.write_text(f"{link.read_text()}\n{content_to_merge}")
        elif link.exists():
            if link.is_dir() and os.listdir(link):
                # landing here means the directory has been created during
                # docker build process and we copy link to target using shutil
                # shutil.copytree(link, target)
                os.system(f"cp -r {link} {target}")
                _change_ownership_recursively(target)
                shutil.rmtree(link)
            elif link.is_file():
                shutil.copy(link, target)
                link.unlink()
            _create_symlink(link, target)
        else:
            target.mkdir(parents=True, exist_ok=True)
            _change_ownership_recursively(target)
            _create_symlink(link, target)


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
@click.option(
    "--no-cache", is_flag=True, help="Pass --no-cache to docker build."
)
@click.option(
    "--keepass-db-file",
    envvar="KEEPASS_DB_FILE",
    type=click.Path(exists=True, dir_okay=False),
    required=False,
    help=(
        " Path to a KeePass database file (KDBX 4 format has been"
        " tested)."
        " Considered, when the container `os` is built (see name"
        " argument)."
        " `keepassxc-cli` must be available on the Docker host."
        " The password for the database must be given (prompt) during"
        " the Docker build process."
        " The KeePass database is expected to come with an"
        " `engine-room` group as child of the `root` group. The group"
        " `engine-room` can have a subgroup named `env` for secret"
        " environment variables which will be written to `/etc/zshenv`"
        " in the container."
        " Another subgroup named `files` can be given. Entries in that"
        " group can define secret files. The name of an entry on top"
        " level of the `files` group defines the path of the file in"
        " the container. If there is a group inside the `files` group,"
        " the name of the group defines the path for the parent"
        " directory of files in the container and entry names"
        " define the file names."
        " The content of files is defined in the field `notes` of an"
        " entry."
    ),
)
@click.argument("name", nargs=-1)
def build(
    no_cache: bool = True,
    keepass_db_file: pathlib.Path | None = None,
    name: tuple[str] | None = None,
) -> None:
    """Build specified or all `engine-room` container(s).

    \b
    Arguments
    ---------
    name
        Name of one or multiple engine-room containers. When not
        specified, all containers will be built in the
        order defined by the services in the docker-compose.yml file.
        When specified, the name must appear as service in the
        `docker-compose.yml` file.
    """
    cmd = ["docker", "compose", "build"]
    if name:
        # read service names from docker-compose.yml
        with open(MODULE_DIR / "docker-compose.yml") as file:
            names = yaml.safe_load(file)["services"].keys()
            unknown_names = set(name) - set(names)
            if unknown_names:
                raise click.UsageError(
                    f"Unknown container name(s): {', '.join(unknown_names)}"
                )
    cmd.extend(
        [
            "--build-arg",
            f"USERMAP_UID={UID}",
            "--build-arg",
            f"USERMAP_GID={GID}",
        ]
    )
    with_keepass_db_file = keepass_db_file is not None and (
        not name  # meaning undefined to build all containers including `os`
        or "os" in name  # meaning to build only the `os` container
    )
    tmp_keepass_db_file = MODULE_DIR / "build/er-keypass-db-er.kdbx"
    os.system(f"touch {tmp_keepass_db_file}")
    if with_keepass_db_file:
        shutil.copy(str(keepass_db_file), tmp_keepass_db_file)
        # container named `os` is built
        exe = "keepassxc-cli"
        try:
            subprocess.run(
                [exe, "--version"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
        except (subprocess.CalledProcessError, FileNotFoundError):
            raise click.UsageError(f"The command `{exe}` is not available.")
        password = click.prompt(
            f"Password for {keepass_db_file}", hide_input=True
        )
        cmd.extend(
            [
                "--build-arg",
                f"KEEPASS_DB_PASSWORD={password}",
            ]
        )
    build_cmd = cmd.copy()
    if name:
        for service in [n for n in names if n in name]:
            subprocess.run(build_cmd + [service], check=True, cwd=MODULE_DIR)
    else:
        subprocess.run(build_cmd, check=True, cwd=MODULE_DIR)
    if with_keepass_db_file:
        # make absolute path
        tmp_keepass_db_file = MODULE_DIR / tmp_keepass_db_file
        tmp_keepass_db_file.unlink()


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
    ssh_auth_sock = os.getenv("SSH_AUTH_SOCK", "")
    if ssh_auth_sock and pathlib.Path(ssh_auth_sock).is_socket():
        ssh_auth_sock = ssh_auth_sock.replace("/private/tmp", "/tmp")
        cmd.extend(["-e", f"SSH_AUTH_SOCK={ssh_auth_sock}"])
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
        click.echo(' '.join(cmd))
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
    id_file = pathlib.Path.home() / ".ssh/id_ed25519"
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
    _process_symbolic_links()
    _distribute_secrets()
    _set_bind_mount_permissions()
    _install_pyenv_and_set_up_global_python()
    gpg_agent_command = [
        "gpg-agent",
        "--homedir",
        "/home/nörd/.gnupg",
        "--use-standard-socket",
        "--daemon",
    ]
    subprocess.Popen(gpg_agent_command)
    sshd_path = "/usr/sbin/sshd"
    args = [sshd_path, "-D", f"-p {os.getenv('SSH_PORT', '22')}"]
    click.echo(
        f"engine-room listens on port `{SSH_PORT}` for ssh connections..."
    )
    os.execv(sshd_path, args)


if __name__ == "__main__":
    cli()
