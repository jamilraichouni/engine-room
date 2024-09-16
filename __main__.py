"""Module to control the ``engine-room`` containers."""

import os
import pathlib
import platform
import subprocess
import sys
import time

try:
    import click
except ModuleNotFoundError:
    raise EnvironmentError(f"Run {sys.executable} -m pip install click")

CONTAINER_NAME = "engine-room"
CONTAINER_TAG = "base"
SSH_PORT = 1978
ENV = {
    "SSH_PORT": str(SSH_PORT),
}
MODULE_DIR: pathlib.Path = pathlib.Path(__file__).parents[0]
PORTS = (
    SSH_PORT,
    4200,
    5001,
    5098,
    6006,
    8000,
    8081,
)


@click.group()
def cli() -> None:
    """CLI to work with an `engine-room` container."""


@cli.command()
@click.argument("tag")
def run(tag: str) -> None:
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
    cmd: list[str] = ["docker", "rm", "--force", CONTAINER_NAME]
    subprocess.run(
        cmd, check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )

    # Check if the volume exists
    check_command = ["docker", "volume", "ls", "-q", "--filter", f"name={tag}"]
    result = subprocess.run(check_command, capture_output=True, text=True)

    # If the volume does not exist, create it
    is_new_volume = False
    if not result.stdout.strip():
        create_command = ["docker", "volume", "create", tag]
        subprocess.run(create_command, check=True)
        print(f"Created volume {tag}")
        is_new_volume = True
    cmd = [
        "docker",
        "run",
        "-d",
        "--rm",
        "-it",
        "--cap-add=SYS_PTRACE",
        "--hostname",
        f"{CONTAINER_NAME}-{tag}",
        "--name",
        CONTAINER_NAME,
    ]
    for key, val in ENV.items():
        cmd.extend(["-e", f"{key}={val}"])

    for port in PORTS:
        cmd.extend(
            [
                "-p",
                f"{port}:{port}",
            ]
        )
    cmd.extend(
        [
            "-v",
            f"{ssh_dir}/:/home/nörd/.ssh",
            "-v",
            f"{MODULE_DIR.resolve()}:/home/nörd/engine-room",
            "-v",
            f"{tag}:/mnt/volume",
        ]
    )
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
    cmd.append(f"{CONTAINER_NAME}:{tag}")
    print("Running ", " ".join(cmd))
    subprocess.run(cmd, check=False)
    if is_new_volume:
        time.sleep(5)
        subprocess.run(cmd, check=False)


@cli.command()
def enter() -> None:
    """Enter the container."""
    id_file = pathlib.Path.home() / ".ssh/id_ed25519"
    cmd: list[str] = [
        "zsh",
        "-c",
        f"ssh -i {id_file} -p {SSH_PORT}"
        " -o StrictHostKeyChecking=no"
        " -o UserKnownHostsFile=/dev/null nörd@localhost",
    ]
    subprocess.run(cmd, check=False)


if __name__ == "__main__":
    cli()
