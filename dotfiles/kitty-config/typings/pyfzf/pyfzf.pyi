from typing import Any

FZF_URL: str

class FzfPrompt:
    executable_path: Any
    def __init__(self, executable_path: Any | None = ...) -> None: ...
    def prompt(self, choices: Any | None = ..., fzf_options: str = ..., delimiter: str = ...): ...
