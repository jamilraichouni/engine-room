import os
import pathlib
import subprocess

PYENV_ROOT = pathlib.Path(os.getenv("PYENV_ROOT", ""))
PYTHON_VERSION = "3.12.6"

if pathlib.Path(PYENV_ROOT).is_dir():
    PYENV_ROOT = PYENV_ROOT.resolve()
    if not os.listdir(PYENV_ROOT / "versions"):
        subprocess.run(["pyenv", "update"], check=False)
        subprocess.run(["pyenv", "install", PYTHON_VERSION], check=False)
        subprocess.run(["pyenv", "global", PYTHON_VERSION], check=False)
        os.system("python -m pip install --upgrade pip")
        os.system(
            "python -m pip install -r /home/nörd/engine-room/dotfiles/requirements.txt"
        )
