# image-insert.nvim

A Neovim plugin to insert images directly from your clipboard into your buffer (e.g., Markdown).

## Features

- Insert images from clipboard with a single command.
- Supports Windows (PowerShell), MacOS (pbctl, pngpaste), and Linux (xclip, wl-paste).
- Customizable directory and file naming.
- Markdown image syntax by default.
- Automatically calculates relative paths.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Jacky-Lzx/image-insert.nvim",
  keys = {
    { "<leader>ip", "<cmd>ImageInsert<cr>", desc = "Insert image from clipboard" },
  },
  opts = {
    dir_path = "img",
    file_name = "%Y-%m-%d-%H-%M-%S",
    extension = "png",
    relative_to_current_file = true,
    prompt_for_file_name = true,
    template = "![$FILE_NAME]($FILE_PATH)",
  },
}
```

## Configuration

| Option                     | Default                       | Description                               |
| -------------------------- | ----------------------------- | ----------------------------------------- |
| `dir_path`                 | `"img"`                       | Directory to save images.                 |
| `file_name`                | `"%Y-%m-%d_%H-%M-%S"`         | Format for the file name (timestamp).     |
| `extension`                | `"png"`                       | Default image extension.                  |
| `relative_to_current_file` | `true`                        | Save images relative to the current file. |
| `prompt_for_file_name`     | `true`                        | Prompt for a file name before saving.     |
| `process_cmd`              | `""`                          | Pre-process command for copied images.    |
| `template`                 | `"![$FILE_NAME]($FILE_PATH)"` | Markup template to insert.                |

## Usage

Run `:ImageInsert` to insert an image from your clipboard.

## Acknowledgments

This plugin is inspired by [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim).

## Milestones

- [x] Implement `process_cmd` config to pre-process inserted images
