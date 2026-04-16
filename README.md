# image-insert.nvim

A Neovim plugin to insert images directly from your clipboard into your buffer (e.g., Markdown).

## Features

- Insert images from clipboard with a single command.
- Supports Windows (PowerShell), MacOS (pbctl, pngpaste), and Linux (xclip, wl-paste).
- Customizable directory and file naming.
- Support for image processing (e.g., resizing, format conversion) via external commands.
- Interactive selection if multiple processing options are configured.
- Markdown image syntax by default.
- Automatically calculates relative paths.
- Configuration can be overridden per call.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "zexili/image-insert.nvim",
  keys = {
    { "<leader>ip", "<cmd>ImageInsert<cr>", desc = "Insert image from clipboard" },
  },
  opts = {
    dir_path = "img",
    file_name = "%Y-%m-%d-%H-%M-%S",
    relative_to_current_file = true,
    prompt_for_file_name = true,
    template = "![$CURSOR]($FILE_PATH)",
    process = {
      cmd = "",
      extension = "png",
    },
  },
}
```

## Configuration

| Option                     | Default                    | Description                               |
| -------------------------- | -------------------------- | ----------------------------------------- |
| `dir_path`                 | `"img"`                    | Directory to save images.                 |
| `file_name`                | `"%Y-%m-%d_%H-%M-%S"`      | Format for the file name (timestamp).     |
| `relative_to_current_file` | `true`                     | Save images relative to the current file. |
| `prompt_for_file_name`     | `true`                     | Prompt for a file name before saving.     |
| `template`                 | `"![$CURSOR]($FILE_PATH)"` | Markup template to insert.                |
| `process`                  | (see below)                | Image processing configuration.           |

### Templates

Templates use placeholders that are replaced with runtime values.

| Placeholder         | Description                                              | Example                        |
| ------------------- | -------------------------------------------------------- | ------------------------------ |
| `$FILE_NAME`        | File name with extension.                                | `image.png`                    |
| `$FILE_NAME_NO_EXT` | File name without extension.                             | `image`                        |
| `$FILE_PATH`        | Relative file path.                                      | `img/image.png`                |
| `$LABEL`            | Lowercase name with dashes.                              | `the-image` (from `The Image`) |
| `$CURSOR`           | Position of cursor after insertion (enters insert mode). |                                |

Templates can also be defined as a function:

```lua
template = function(context)
  return "![" .. context.cursor .. "](" .. context.file_path .. ")"
end
```

The `process` option can be a single table or a list of tables. Each table has the following structure:

- `cmd`: A shell command to process the image data (stdin). Example: `"magick - -quality 85 png:-"`.
- `extension`: The file extension to use for the saved image.

If multiple `process` options are provided, a selection menu will appear when you run `:ImageInsert`.

```lua
process = {
  { cmd = "", extension = "png" }, -- Direct save as PNG
  { cmd = "magick - -quality 80 webp:-", extension = "webp" }, -- Save as WebP
}
```

## Usage

Run `:ImageInsert` to insert an image from your clipboard.

You can also call the function directly with overrides:

```lua
require("image-insert").insert_image({ dir_path = "assets", prompt_for_file_name = false })
```

## Acknowledgments

This plugin is inspired by [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim).

## Milestones

- [x] Implement `process` config to pre-process inserted images
- [x] Add support for selection from an array of `process` options
- [x] Support template variables and cursor placement
