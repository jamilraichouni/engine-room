#!/usr/bin/env python3
"""Simple process supervisor for running multiple services in Docker container."""

import os
import pathlib
import pwd
import signal
import subprocess
import sys
import time

# Determine the user
try:
    USER = pwd.getpwuid(os.getuid()).pw_name
    if USER == "root":
        USER = "nerd"
except Exception:
    USER = "nerd"  # fallback

HOME = pathlib.Path(f"/home/{USER}")
ENTRYPOINT_SCRIPT = HOME / "engine-room" / "entrypoint.py"

# First, run the setup
subprocess.run([sys.executable, str(ENTRYPOINT_SCRIPT), "setup"])

# Services to run
services = []

# Start litellm
api_key_path = HOME / "engine-room" / "secrets" / "anthropic_api_key.token"
if api_key_path.exists():
    env = os.environ.copy()
    env["ANTHROPIC_API_KEY"] = api_key_path.read_text().strip()
    litellm_proc = subprocess.Popen(
        [
            "litellm",
            "--model",
            "anthropic/claude-opus-4-20250514",
            "--drop_params",
        ],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    services.append(("litellm", litellm_proc))
    print(f"Started litellm with PID {litellm_proc.pid}")

# Start SSH daemon
ssh_port = os.getenv("SSH_PORT", "1978")
sshd_proc = subprocess.Popen(
    ["/usr/sbin/sshd", "-D", "-p", ssh_port],
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
)
services.append(("sshd", sshd_proc))
print(f"Started sshd with PID {sshd_proc.pid}")


# Handle signals
def signal_handler(signum, frame):
    print(f"Received signal {signum}, shutting down services...")
    for name, proc in services:
        if proc.poll() is None:
            print(f"Terminating {name} (PID {proc.pid})...")
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
    sys.exit(0)


signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)

# Monitor services
try:
    while True:
        for name, proc in services:
            if proc.poll() is not None:
                print(
                    f"Service {name} (PID {proc.pid}) has died with exit code {proc.returncode}"
                )
                # If SSH dies, we should exit
                if name == "sshd":
                    signal_handler(signal.SIGTERM, None)
        time.sleep(1)
except KeyboardInterrupt:
    signal_handler(signal.SIGINT, None)
