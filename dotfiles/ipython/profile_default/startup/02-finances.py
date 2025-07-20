import pathlib

try:
    import pandas as pd
except ImportError:
    pass

# get current working directory
cwd = pathlib.Path.cwd().resolve()
desired_path = (pathlib.Path.home() / "dev/github/finances").resolve()
if cwd != desired_path:
    del cwd, desired_path
    raise SystemExit(0)
del cwd, desired_path

pd.set_option("display.max_columns", None)
pd.set_option("display.max_rows", None)
pd.set_option(
    "display.width", None
)  # Disable line wrapping by setting width to None
pd.set_option("display.max_colwidth", None)  # Ensure columns are not truncated

import sqlite3  # noqa: E402, F401

from finances import *  # noqa: E402, F403
