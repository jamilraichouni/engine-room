"""Configure pdb++.

Install via ``git clone <URL>; pip install ./pdbpp``.

"""
import atexit
import os
import pathlib
import pdb
import readline
import sys
import typing as t

if pathlib.Path.home() not in sys.path:
    sys.path.insert(0, str(pathlib.Path.home()))
STYLE: t.Any = "monokai"
try:
    from pygmentsstyles import VSCodeDarkStyle

    STYLE = VSCodeDarkStyle
except ImportError:
    print("Error: This is .pdbrc.py. Cannot import custom pygmentsstyles.py")

XDG_CACHE_HOME = os.getenv("XDG_CACHE_HOME", "~/.cache")
HIST_FILE = os.getenv("PDB_HIST_FILE", f"{XDG_CACHE_HOME}/python/pdb_history")
HIST_SIZE = os.getenv("PDB_HIST_SIZE", "10000")
HISTORY_FILE = pathlib.Path(HIST_FILE).expanduser().resolve()
HISTORY_LENGTH = int(HIST_SIZE)

# pylint:disable-next=no-member,too-few-public-methods
class Config(pdb.DefaultConfig):  # type: ignore
    """Set attributes configuring pdb++."""

    prompt = " "
    # prompt = "🐛 "
    sticky_by_default = False
    highlight = False
    truncate_long_lines = False
    use_pygments = True
    pygments_formatter_class = "pygments.formatters.TerminalTrueColorFormatter"
    pygments_formatter_kwargs = {"style": STYLE, "bg": "dark"}

    # def __init__(self):
    #     breakpoint()

    def setup(self, pdb_):
        """Set up debugger."""
        # pylint:disable=invalid-name
        Pdb = pdb_.__class__
        Pdb.do_st = Pdb.do_sticky
        pdb_.skip = ["**/capellambse.model"]
        if not HISTORY_FILE.exists():
            HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
            HISTORY_FILE.touch()

        readline.read_history_file(HISTORY_FILE)
        readline.set_history_length(HISTORY_LENGTH)
        atexit.register(readline.write_history_file, HISTORY_FILE)
