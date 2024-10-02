"""Module to control the ``engine-room`` containers."""

from __future__ import annotations

import os
import pathlib
import pwd
import shutil
import socket

E = pathlib.Path("/etc")
H = pathlib.Path("/home/techuser")
D = pathlib.Path(
    os.getenv("DOT", pathlib.Path("/home/techuser/engine-room/dotfiles"))
)
O = pathlib.Path("/opt")  # noqa: E741
R = pathlib.Path("/root")
V = pathlib.Path(os.getenv("VOLUME", "/mnt/volume"))

CONTAINER_TAG = "base"
HOST = socket.gethostname().replace("engine-room-", "")
MODULE_DIR: pathlib.Path = pathlib.Path(__file__).parents[0]
USERMAP_UID = pwd.getpwnam("techuser").pw_uid
USERMAP_GID = pwd.getpwnam("techuser").pw_gid

SYMBOLIC_LINK_MAP = {
    E / "zprofile": D / "zsh/profile/ALL_HOSTS.zsh",
    E / "zsh/zshenv": D / "zsh/env/ALL_HOSTS.zsh",
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
    # H / ".ssh/config": D / "ssh_config",
    H / ".vimrc": D / "vimrc",
    H / ".zsh_history": V / "zsh_history",
    H / ".zshenv": D / f"zsh/env/{HOST}.zsh",
    H / ".zshrc": D / "zsh/zshrc",
    H / "dev": V / "dev",
    H / "pygmentsstyles.py": D / "pygmentsstyles.py",
    O / ".venv": V / ".venv",
    R / ".vimrc": D / "vimrc",
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
            # do not change non nerd stuff (outside of H and V)
            (not path.is_relative_to(H) and not path.is_relative_to(V)),
            path == H,  # takes far too long
        )
    ):
        return
    print(f"Change ownership of {path}...")
    os.system(f"chown -R {USERMAP_UID}:{USERMAP_GID} {path}")


def _create_symlink(link: pathlib.Path, target: pathlib.Path) -> None:
    """Create symbolic link and make `nerd` the owner when needed."""
    link.parent.mkdir(parents=True, exist_ok=True)
    os.chown(link.parent, USERMAP_UID, USERMAP_GID)
    try:
        link.symlink_to(target)
    except FileExistsError:
        print(f"File exists: {link}")
        os.system(f"ls -lah {link.parent}")
    if link.is_relative_to(H):
        os.lchown(link, USERMAP_UID, USERMAP_GID)


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
                _create_symlink(link, target)
                _change_ownership_recursively(target)
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
            # we cannot create anything here because we do not know
            # of link or target are a file or a directory
            pass


def _set_bind_mount_permissions() -> None:
    """Set permissions for bind mounts."""
    for directory in (
        # H / ".ssh",
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


def _install_pyenv_and_set_up_global_python() -> None:
    """Install pyenv and set up global python."""


_process_symbolic_links()
_set_bind_mount_permissions()
_install_pyenv_and_set_up_global_python()

command = "/bin/bash"
script = "/home/techuser/.startup.sh"

# Use 'su' to switch to the user 'techuser' and execute the script
os.execv("/bin/su", ["su", "techuser", "-c", f"{command} {script}"])
