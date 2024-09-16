#!/usr/bin/env python3

import os
import pathlib
import shutil

H = pathlib.Path("/home/nörd")
D = pathlib.Path(os.getenv("DOT", H / "engine-room/dotfiles"))
V = pathlib.Path(os.getenv("VOLUME", "/mnt/volume"))
HOST = os.getenv("HOSTNAME", "").replace("engine-room-", "")

SYMBOLIC_LINK_MAP = {
    pathlib.Path("/etc/git_askpass.py"): D / "git_askpass.py",
    pathlib.Path("/etc/zshenv"): D / "zsh/env/ALL_HOSTS.zsh",
    pathlib.Path("/etc/zprofile"): D / "zsh/profile/ALL_HOSTS.zsh",
    H / ".cache": V / "cache",
    H / ".cargo": V / "cargo",
    H / ".config/nvim": D / "nvim-config",
    H / ".config/pip": D / "pip",
    H / ".config/rclone": D / "rclone",
    H / ".gdbextension.py": D / "gdbextension.py",
    H / ".gdbinit": D / "gdbinit",
    H / ".gitconfig": D / "gitconfig",
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
    H / ".zshenv": D / f"env/{HOST}.zsh",
    H / ".zshrc": D / "zsh/zshrc",
    H / "pygmentsstyles.py": D / "pygmentsstyles.py",
    H / "dev": V / "dev",
    H / "workspaces": V / "workspaces",
}


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
    os.system(f"chown -R 1000:1000 {path}")


def _create_symlink(link: pathlib.Path, target: pathlib.Path) -> None:
    """Create symbolic link and make `nörd` the owner when needed."""
    link.parent.mkdir(parents=True, exist_ok=True)
    os.chown(link.parent, 1000, 1000)
    link.symlink_to(target)
    if link.is_relative_to(H):
        os.lchown(link, 1000, 1000)


def process_symbolic_links() -> None:
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
        elif link.exists():
            if link.is_dir():
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


def set_bind_mount_permissions() -> None:
    """Set permissions for bind mounts."""
    for dirname in (
        ".ssh",
        "bak",
        "downloads",
        "engine-room",
    ):
        directory = H / dirname
        if directory.exists():
            os.chown(directory, 1000, 1000)


def install_pyenv_and_set_up_global_python() -> None:
    """Install pyenv and set up global python."""


if __name__ == "__main__":
    process_symbolic_links()
    set_bind_mount_permissions()
    install_pyenv_and_set_up_global_python()
    sshd_path = "/usr/sbin/sshd"
    args = [sshd_path, "-D", f"-p {os.getenv('SSH_PORT', '22')}"]
    # args = [sshd_path, "-D"]
    os.execv(sshd_path, args)
