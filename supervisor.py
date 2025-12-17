#!/usr/bin/env python3
"""Simple process supervisor running multiple services in Docker container."""

import logging
import os
import pathlib
import pwd
import signal
import socket
import subprocess
import sys
import time
import typing as t

try:
    USER = pwd.getpwuid(os.getuid()).pw_name
    if USER == "root":
        USER = "nerd"
except Exception:  # noqa: BLE001
    USER = "nerd"

HOME = pathlib.Path(f"/home/{USER}")
HOST = socket.gethostname().replace("engine-room-", "")
ENTRYPOINT_SCRIPT = HOME / "engine-room" / "entrypoint.py"

logger = logging.getLogger("supervisor")


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
    logfile_path = pathlib.Path(f"/home/{USER}/engine-room/supervisor.log")
    logger.info("Logging to '%s'", logfile_path)
    logfile_path.unlink(missing_ok=True)
    filehdl: logging.Handler = logging.FileHandler(
        filename=logfile_path, mode="w"
    )
    filehdl.setLevel(logging.DEBUG)
    filehdl.setFormatter(formatter)
    logger.addHandler(filehdl)


def _main() -> None:
    _setup_logging()
    logger.info("HOST: '%s'", HOST)
    logger.info("USER: '%s'", USER)

    def _signal_handler(signum: int, _: t.Any) -> None:
        logger.info("Received signal %s, shutting down services...", signum)
        for name, proc in services:
            if proc.poll() is None:
                logger.info("Terminating %s (PID %d)...", name, proc.pid)
                proc.terminate()
                try:
                    proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    proc.kill()
        sys.exit(0)

    subprocess.run([sys.executable, str(ENTRYPOINT_SCRIPT)], check=False)
    services = []
    # ssh daemon
    sshd_proc = subprocess.Popen(
        ["/usr/sbin/sshd", "-D", "-p", os.getenv("SSH_PORT", "1978")],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    services.append(("sshd", sshd_proc))
    logger.info("Started sshd with PID %s", sshd_proc.pid)
    signal.signal(signal.SIGTERM, _signal_handler)
    signal.signal(signal.SIGINT, _signal_handler)
    try:
        while True:
            for name, proc in services:
                if proc.poll() is not None:
                    logger.info(
                        "Service %s (PID %d) has died with exit code %d",
                        name,
                        proc.pid,
                        proc.returncode,
                    )
                    # If SSH dies, we should exit
                    if name == "sshd":
                        _signal_handler(signal.SIGTERM, None)
            time.sleep(1)
    except KeyboardInterrupt:
        _signal_handler(signal.SIGINT, None)


if __name__ == "__main__":
    _main()
