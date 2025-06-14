from IPython.core.ultratb import VerboseTB

VerboseTB.tb_highlight = "bg:#000000"

c = get_config()  # type: ignore # noqa: F821

c.InteractiveShell.warn_venv = False
c.TerminalIPythonApp.display_banner = False
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalInteractiveShell.term_title = True
