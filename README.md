# image-insert.nvim

A Neovim plugin to insert images directly from your clipboard into your buffer (e.g., Markdown).

https://github.com/user-attachments/assets/f2ed1b85-3fab-4ccd-b9f9-0a877fc19a70

<details> <summary> Keymappings in the demo </summary>

```lua
 keys = {
  {
    "<leader>pI",
    function()
      require("image-insert").insert_image({ insert_strategy = "insert_line_after" })
    end,
    desc = "[image-insert] Insert next line",
  },
  {
    "<leader>pi",
    function()
      require("image-insert").insert_image({ insert_strategy = "insert_after" })
    end,
    desc = "[image-insert] Insert after cursor",
  },
  {
    "<leader>PI",
    function()
      require("image-insert").insert_image({ insert_strategy = "insert_line_before" })
    end,
    desc = "[image-insert] Insert prev line",
  },
  {
    "<leader>Pi",
    function()
      require("image-insert").insert_image({ insert_strategy = "insert_before" })
    end,
    desc = "[image-insert] Insert before cursor",
  },
  {
    "<leader>pC",
    function()
      require("image-insert").insert_image({
        process = {
          { cmd = "", extension = "png" },
          { cmd = "", extension = "jpeg" },
          { cmd = "", extension = "avif" },
          { cmd = "convert - avif:-", extension = "avif" },
          { cmd = "magick - -quality 85 png:-", extension = "png" },
          { cmd = "magick - -quality 75 webp:-", extension = "webp" },
        },
      })
    end,
    desc = "[image-insert] Paste image from system clipboard",
  },
  {
    "<leader>pc",
    function()
      Snacks.picker.files({
        ft = { "jpg", "jpeg", "png", "webp", "heic", "avif" },
        actions = {
          confirm = function(picker, _)
            local items = picker:selected({ fallback = true })
            local files = vim.tbl_map(function(it)
              return it.file or it.text
            end, items)

            picker:close()

            vim.schedule(function()
              Snacks.notify("Selected:\n" .. table.concat(files, "\n"), { title = "image-insert.nvim" })

              for _, file in ipairs(files) do
                require("image-insert").insert_image({ insert_strategy = "insert_line_after" }, file)
              end
            end)
          end,
        },
      })
    end,
    desc = "[image-insert] Choose an image to paste",
  },
},
```

</details>

## Features

- Insert images from clipboard with a single command.
- Supports Windows (PowerShell), MacOS (pbctl, pngpaste), and Linux (xclip, wl-paste).
- Customizable directory and file naming.
- Support for image processing (e.g., resizing, format conversion) via external commands.
- Interactive selection if multiple processing options are configured.
- Markdown image syntax by default.
- Automatically calculates relative paths.
- Configuration can be overridden per call.

> [!NOTE]
> The plugin is only tested on MacOS, contributions to ensure compatibility with other platforms are welcome.

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
    relative_to_current_file = true,
    prompt_for_file_name = true,
    template = {
      markdown = "![$CURSOR]($FILE_PATH)",
      latex = [[
        \begin{figure}[ht]
          \centering
          \includegraphics[width=0.8\textwidth]{$FILE_PATH}
          \caption{$CURSOR}
          \label{fig:$LABEL}
        \end{figure}
      ]],
      tex = [[
        \begin{figure}[ht]
          \centering
          \includegraphics[width=0.8\textwidth]{$FILE_PATH}
          \caption{$CURSOR}
          \label{fig:$LABEL}
        \end{figure}
      ]],
      typst = [[
        #figure(
          image("$FILE_PATH", width: 80%),
          caption: [$CURSOR],
        ) <fig-$LABEL>
      ]],
      html = '<img src="$FILE_PATH" alt="$CURSOR" />',
    },
    process = {
      cmd = "",
      extension = "png",
    },
  },
}
```

## Configuration

| Option                     | Default               | Description                               |
| -------------------------- | --------------------- | ----------------------------------------- |
| `dir_path`                 | `"img"`               | Directory to save images.                 |
| `file_name`                | `"%Y-%m-%d_%H-%M-%S"` | Format for the file name (timestamp).     |
| `relative_to_current_file` | `true`                | Save images relative to the current file. |
| `prompt_for_file_name`     | `true`                | Prompt for a file name before saving.     |
| `template`                 | (see below)           | Markup template to insert.                |
| `insert_strategy`          | `"insert_after"`      | Insertion strategy (see below).           |
| `process`                  | (see below)           | Image processing configuration.           |

### Insertion Strategies

The `insert_strategy` option determines where the image markup is placed:

- `insert_after`: In the current line, after the cursor.
- `insert_before`: In the current line, before the cursor.
- `insert_line_after`: On a new line below the current one.
- `insert_line_before`: On a new line above the current one.

### Templates

Templates use placeholders that are replaced with runtime values.

| Placeholder         | Description                                              | Example                        |
| ------------------- | -------------------------------------------------------- | ------------------------------ |
| `$FILE_NAME`        | File name with extension.                                | `image.png`                    |
| `$FILE_NAME_NO_EXT` | File name without extension.                             | `image`                        |
| `$FILE_PATH`        | Relative file path.                                      | `img/image.png`                |
| `$LABEL`            | Lowercase name with dashes.                              | `the-image` (from `The Image`) |
| `$CURSOR`           | Position of cursor after insertion (enters insert mode). |                                |

By default, the template is a table indexed by filetype. The plugin automatically handles indentation and empty lines to
allow for clean configuration using Lua\'s long brackets (`[[ ... ]]`):

- The indentation of the first contentful line is treated as the base indentation and is removed from all lines.
- Leading empty lines and trailing whitespace-only lines (common when using long brackets) are automatically stripped.
- A single trailing newline is stripped if present.

```lua
template = {
  markdown = "![$CURSOR]($FILE_PATH)",
  latex = [[
    \begin{figure}[ht]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
      \caption{$CURSOR}
      \label{fig:$LABEL}
    \end{figure}
  ]],
  tex = [[
    \begin{figure}[ht]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
      \caption{$CURSOR}
      \label{fig:$LABEL}
    \end{figure}
  ]],
  typst = [[
    #figure(
      image("$FILE_PATH", width: 80%),
      caption: [$CURSOR],
    ) <fig-$LABEL>
  ]],
  html = '<img src="$FILE_PATH" alt="$CURSOR" />',
}
```

The plugin selects the template based on the current buffer\'s `filetype`. If no specific template is found, it falls back to `markdown`.

Templates can also be defined as a function:

```lua
template = function(context)
  return "![" .. context.cursor .. "](" .. context.file_path .. ")"
end
```

### Process

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

- Run `:ImageInsert` to insert an image from your clipboard.
- Run `:ImageInsert /path/to/image.png` to insert an existing image.

You can also call the function directly with overrides:

```lua
-- Insert from clipboard with custom directory
require("image-insert").insert_image({ dir_path = "assets" })

-- Insert existing file
require("image-insert").insert_image({}, "/path/to/image.png")
```

### Snacks.nvim

The plugin can be integrated with [Snacks.nvim picker](https://github.com/folke/snacks.nvim) which includes built-in support for previewing media files.

<details> <summary>Example configuration</summary>

```lua
function()
  Snacks.picker.files({
    ft = { "jpg", "jpeg", "png", "webp", "heic", "avif" },
    -- Override what happens when you press <CR> (confirm)
    actions = {
      confirm = function(picker, item)
        -- Get multi-selection (or current item if nothing is selected)
        local items = picker:selected({ fallback = true })
        -- Convert items -> file paths
        local files = vim.tbl_map(function(it)
          -- for the files picker items typically have it.file (and it.text)
          return it.file or it.text
        end, items)

        picker:close()

        -- Schedule if you’re going to open/edit files, etc.
        vim.schedule(function()
          vim.notify("Selected:\n" .. table.concat(files, "\n"))

          for _, file in ipairs(files) do
            require("image-insert").insert_image({ insert_strategy = "insert_line_after" }, file)
          end
        end)
      end,
    },
  })
end,
```

The above function should be bound to a keymap, e.g. through lazy.nvim.

</details>

## Acknowledgments

This plugin is inspired by [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim).

## Milestones

- [x] Implement `process` config to preprocess inserted images
- [x] Add support for selection from an array of `process` options
- [x] Support template variables and cursor placement
- [x] Support selection of figures from `dir_path`
  - [x] Insert image that is selected in Snacks
  - [x] Support multi-image selection
  - [x] Bug: could not enter insert mode when selecting from `dir_path` with a template that includes `$CURSOR`
- [x] Support multiline templates
- [x] Support templates for different filetypes
