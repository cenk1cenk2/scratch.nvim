# scratch.nvim

Create scratch buffers in Neovim.

## Features

- Create scratch buffers in a given filetype.
- Uses autocommands instead of `wipe` to close scratch buffers, so you can execute commands while the buffer is open.
- Execute the given file quickly.

## Installation

### `lazy.nvim`

```lua
{
  "cenk1cenk2/scratch.nvim",
}
```

## Configuration

### Setup

Plugin requires no setup by default. However if you want to change the default settings for good, then you can call it.

```lua
require("scratch").setup({
  -- your custom configuration
})
```

You can find the default configuration file and available options [here](https://github.com/cenk1cenk2/scratch.nvim/blob/main/lua/scratch/config.lua).

## Usage

You can assign the following commands to keybindings.

### Create a Scratch Buffer

Trigger a `vim.ui.select` to create a scratch buffer of selected type. The default behavior is to create the file in your current working directory.

```lua
require("scratch").create()
```

To skip the prompt and create a scratch buffer of a specific type, you can pass the filetype as an argument.

```lua
require("scratch").create({ filetype = "lua" })
```

If you do not want to create the buffer in your current directory, you can set it to use a temporary file.

```lua
require("scratch").create({ cwd = false })
```

If you want to use a specific relative directory to your current working directory, you can set it to use a relative directory.

```lua
require("scratch").create({ cwd = "relative/path" })
```

### Execute a Scratch Buffer

Trigger a `vim.ui.input` to execute a scratch buffer.

This command does not do much on its own, but you can combine it with other plugins to make sense.

An example usage with `toggleterm.nvim` is as follows.

```lua
require("scratch").execute(function(opts)
  -- callback arguments (opts) would be:
  ---@field filename string
  ---@field path string
  ---@field bufnr number
  ---@field command string

  local Terminal = require("toggleterm.terminal").Terminal

  local terminal = Terminal.create_terminal({
    cmd = ("%s -c '%s %s'"):format(vim.o.shell, opts.command, opts.path),
    close_on_exit = false,
    dir = vim.uv.cwd(),
  }):open()
end)
```
