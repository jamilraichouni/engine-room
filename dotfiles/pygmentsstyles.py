"""Module with custom pygments style definitions."""
import typing as t

from pygments.style import Style  # type:ignore
from pygments.token import Token  # type:ignore

BLUE = "#569cd6"
BLUEGREEN = "#4ec9b0"
COMMENT = "italic #5f5f5f"
DARKBLUE = "#223e55"
FRONT = "#d4d4d4"
GRAY = "#808080"
GREEN = "#6a9955"
LIGHTBLUE = "#9cdcfe"
LIGHTGREEN = "#b5cea8"
LIGHTRED = "#d16969"
NUMBER = "#ff628c"
ORANGE = "#ce9178"
PINK = "#c586c0"
RED = "#f44747"
SILVER = "#c0c0c0"
VIOLET = "#646695"
YELLOW = "#dcdcaa"
YELLOWORANGE = "#d7ba7d"

# pylint:disable=no-member,too-few-public-methods
class VSCodeDarkStyle(Style):
    """Define own token colors."""

    styles: dict[t.Any, str] = {
        Token: FRONT,
        Token.Comment.Hashbang: COMMENT,
        Token.Comment.Multiline: COMMENT,
        Token.Comment.Preproc: "",
        Token.Comment.PreprocFile: "",
        Token.Comment.Single: COMMENT,
        Token.Comment.Special: COMMENT,
        Token.Comment: COMMENT,
        Token.Error: "#ff0000",
        Token.Escape: "",
        Token.Generic.Deleted: "",
        Token.Generic.Emph: "",
        Token.Generic.Error: "",
        Token.Generic.Heading: "",
        Token.Generic.Inserted: "",
        Token.Generic.Output: "",
        Token.Generic.Prompt: "",
        Token.Generic.Strong: "",
        Token.Generic.Subheading: "",
        Token.Generic.Traceback: "#ff0000",
        Token.Generic.Underline: "",
        Token.Generic: "",
        Token.Keyword.Constant: BLUE,
        Token.Keyword.Declaration: "#ff0000",
        Token.Keyword.Namespace: PINK,  # e. g. from, import
        Token.Keyword.Pseudo: "",
        Token.Keyword.Reserved: "",
        Token.Keyword.Type: "",
        Token.Keyword: PINK,
        Token.Literal.Date: "",
        Token.Literal.Number.Bin: "",
        Token.Literal.Number.Float: NUMBER,
        Token.Literal.Number.Hex: "",
        Token.Literal.Number.Integer.Long: NUMBER,
        Token.Literal.Number.Integer: NUMBER,
        Token.Literal.Number.Oct: "",
        Token.Literal.Number: "",
        Token.Literal.String.Affix: "",
        Token.Literal.String.Backtick: "",
        Token.Literal.String.Char: "",
        Token.Literal.String.Delimiter: "",
        Token.Literal.String.Doc: "",
        Token.Literal.String.Double: "",
        Token.Literal.String.Escape: "",
        Token.Literal.String.Heredoc: "",
        Token.Literal.String.Interpol: "",
        Token.Literal.String.Other: "",
        Token.Literal.String.Regex: "",
        Token.Literal.String.Single: "",
        Token.Literal.String.Symbol: "",
        Token.Literal.String: ORANGE,
        Token.Literal: "",
        Token.Name.Attribute: "",
        Token.Name.Builtin.Pseudo: "",
        Token.Name.Builtin: BLUEGREEN,
        Token.Name.Class: BLUEGREEN,
        Token.Name.Constant: YELLOWORANGE,
        Token.Name.Decorator: "",
        Token.Name.Entity: "",
        Token.Name.Exception: "#ff0000",
        Token.Name.Function.Magic: "",
        Token.Name.Function: YELLOW,
        Token.Name.Label: "",
        Token.Name.Namespace: "",
        Token.Name.Other: "",
        Token.Name.Property: "",
        Token.Name.Tag: "",
        Token.Name.Variable.Class: "",
        Token.Name.Variable.Global: "",
        Token.Name.Variable.Instance: YELLOW,
        Token.Name.Variable.Magic: "",
        Token.Name.Variable: "",
        Token.Name: LIGHTBLUE,
        Token.Operator.Word: BLUE,
        Token.Operator: "",
        Token.Other: "",
        Token.Punctuation.Marker: "",
        Token.Punctuation: FRONT,
        Token.Text.Whitespace: "",
        Token.Text: "",
    }
