#!/usr/bin/env python3

import pathlib
import sys

import pyfzf

if __name__ == "__main__":
    dirs = sys.argv[1:]
    dirs = [d for d in dirs if not d.isdigit()]
    directory = pyfzf.pyfzf.FzfPrompt().prompt(dirs)
    if directory:
        directory = directory[0].strip()
        directory = directory.replace("~", str(pathlib.Path.home()))
        print(directory)

