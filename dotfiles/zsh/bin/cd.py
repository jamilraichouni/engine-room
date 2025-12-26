#!/usr/bin/env python3

import os
import pathlib
import sys
from collections import OrderedDict

import pyfzf


def get_recent_dirs_from_history():
    recent_dirs = OrderedDict()
    home = str(pathlib.Path.home())
    history_file = pathlib.Path("/mnt/volume/zsh_history")
    if not history_file.exists():
        history_file = pathlib.Path.home() / ".zsh_history"

    if history_file.exists():
        try:
            with open(history_file, "rb") as f:
                lines = f.read().decode("utf-8", errors="ignore").splitlines()

            for line in reversed(lines):
                line = line.strip()
                if line.startswith(": ") and ";cd " in line:
                    parts = line.split(";cd ", 1)
                    if len(parts) == 2:
                        cd_part = parts[1].strip()
                        if cd_part and not cd_part.startswith("-"):
                            cd_part = cd_part.split(" && ")[0]
                            cd_part = cd_part.split(";")[0]
                            cd_part = cd_part.strip().strip('"').strip("'")

                            if cd_part.startswith("~"):
                                cd_part = cd_part.replace("~", home, 1)

                            if not cd_part.startswith("/"):
                                continue

                            if pathlib.Path(cd_part).exists():
                                recent_dirs[cd_part] = None
                                if len(recent_dirs) >= 100:
                                    break
        except Exception:  # noqa: BLE001, S110
            pass

    cwd = pathlib.Path.cwd()
    if cwd in recent_dirs:
        del recent_dirs[cwd]

    return list(recent_dirs.keys())


if __name__ == "__main__":
    if len(sys.argv) == 1:
        sys.exit(0)

    arg = sys.argv[1] if len(sys.argv) > 1 else ""

    if arg == "-":
        dirs = get_recent_dirs_from_history()
        if not dirs:
            sys.exit(0)

        selected = pyfzf.pyfzf.FzfPrompt().prompt(
            dirs, fzf_options="--reverse --height=40% --preview 'ls -la {}'"
        )
        if selected:
            directory = selected[0].strip()
            print(directory)
        else:
            print(os.getcwd(), file=sys.stderr)
            sys.exit(1)
    else:
        if arg.startswith("~"):
            arg = arg.replace("~", str(pathlib.Path.home()), 1)
        print(arg)

