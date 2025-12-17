# Automate Neovim using Python

## Help pages

`:h if_pyth.txt`

## Examples

In vim a function like `:echo nvim_list_bufs()` can be called in Python using
`vim.eval()`.

Working with buffers can be done using `vim.buffers` which is a more Pythonic
way.

```python
buffers = vim.eval("nvim_list_bufs()")
# better
buffers = vim.buffers
all_lines = vim.current.buffer[:]
all_lines = vim.buffers[bufid][:]
```

Interesting functions:

- `nvim_buf_get_name({buffer})`
- `nvim_set_current_buf({buffer})`

Snippet:

```python
loaded_buffers = [
    b for b in vim.eval("nvim_list_bufs()")
    if vim.eval(f"nvim_buf_is_loaded({b})")
]
```

## Set Buffer Content

Replace a single line import vim

### Set first line (0-indexed)

vim.current.buffer[0] = "New first line"

### Set current line

vim.current.line = "New current line"

### Set line in a specific buffer

vim.buffers[buffer_id][0] = "New first line"

Replace multiple lines (slice assignment) import vim

### Replace lines 0-2 with new content

vim.current.buffer[0:3] = ["line one", "line two", "line three"]

### Replace entire buffer

vim.current.buffer[:] = ["line 1", "line 2", "line 3"]

Delete lines import vim

### Delete a single line

del vim.current.buffer[0]

### Delete a range of lines

del vim.current.buffer[0:5]

### Delete entire buffer content

del vim.current.buffer[:]

or

vim.current.buffer[:] = None

Append lines import vim

### Append at the end

vim.current.buffer.append("new line at bottom")

### Append after a specific line number

vim.current.buffer.append("new line", 5)### after line 5

### Append multiple lines

vim.current.buffer.append(["line A", "line B", "line C"])

Insert at the beginning import vim

### Insert at top (before line 0)

vim.current.buffer[0:0] = ["new first line"]

Important Notes

- Lines must not contain newline characters (\n) except a trailing one (which
  is ignored)
- Buffer indexes are 0-based in Python
- Works the same for vim.current.buffer and vim.buffers[id]
