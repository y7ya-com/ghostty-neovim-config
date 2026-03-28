# Setup Instructions

Recreate this Neovim + Ghostty config exactly as described below.

## System dependencies (macOS)

```bash
brew install neovim fzf ripgrep tree-sitter trash
npm install -g tree-sitter-cli
```

> `trash` is required for safe file deletion (moves to macOS Trash instead of permanent delete).

## File structure

```
~/.config/nvim/init.lua
~/.config/nvim/lua/plugins.lua
~/.config/ghostty/config
~/.config/ghostty/themes/vscode-dark-modern
```

Fetch each file from this repo and place it at the corresponding path.

## Theme

- VS Code Dark Modern colour scheme (`Mofiqul/vscode.nvim`)
- Ghostty uses a matching `vscode-dark-modern` theme file
- Float/hover popup: `bg=#1f1f1f`, `border=#ffffff`, rounded corners
- NvimTree sidebar: `bg=#181818`, git status colours matching VS Code

## Plugin manager

`lazy.nvim`, auto-bootstrapped in `init.lua`.

## Plugins

| Plugin | Purpose |
|--------|---------|
| `Mofiqul/vscode.nvim` | VS Code Dark Modern theme |
| `akinsho/bufferline.nvim` | File tabs at top, NvimTree offset, LSP diagnostics in tabs |
| `nvim-tree/nvim-tree.lua` + `nvim-web-devicons` | File explorer, width 30, git highlighting |
| `nvim-telescope/telescope.nvim` (master) + `plenary` | File finding, in-buffer fuzzy search, ignore pnpm-lock.yaml |
| `ibhagwan/fzf-lua` | Live grep, multiline=2 (filename + match), no preview |
| `nvim-treesitter/nvim-treesitter` | Syntax highlighting |
| `folke/noice.nvim` + `MunifTanjim/nui.nvim` | Floating cmdline/hover, rounded border, padding {1,2}, no scrollbar |
| `williamboman/mason.nvim` + `mason-lspconfig` | Auto-install tailwindcss LSP |
| `neovim/nvim-lspconfig` | LSP base |
| `pmizio/typescript-tools.nvim` + `plenary` | TypeScript LSP (replaces ts_ls), inlay hints, expanded type info |
| `hrsh7th/nvim-cmp` + `cmp-nvim-lsp` + `cmp-buffer` + `cmp-path` + `LuaSnip` + `cmp_luasnip` | Autocompletion |

## LSP

- **TypeScript**: `typescript-tools.nvim` (direct tsserver integration, faster than ts_ls)
  - `includeInlayParameterNameHints = "all"`
  - `includeInlayVariableTypeHints = true`
  - `includeInlayFunctionLikeReturnTypeHints = true`
  - `expandParameters = true`
- **Tailwind CSS**: via mason-lspconfig
- `K` bound buffer-locally on LspAttach for hover
- `gt` bound buffer-locally on LspAttach for type definition
- `vim.diagnostic.config({ update_in_insert = true })` — live inline errors while typing

## File tree (nvim-tree)

- `update_focused_file`: enabled, `update_root = false` — tree highlights active file but never changes root
- `change_dir.enable = false` — navigation never changes cwd
- `<2-RightMouse>` disabled — prevents accidental root change on fast right-click
- `trash.cmd = "trash"` — Delete moves to macOS Trash (recoverable), not permanent
- Left-click opens files / expands folders
- Right-click or Shift+Right-click → custom context menu: New file/folder, Rename, Delete (trash), Copy path

## Keymaps

### Global (normal + insert + visual)

| Key | Action |
|-----|--------|
| Cmd+P | Telescope find files |
| Cmd+F | Telescope fuzzy find in current buffer |
| Cmd+Shift+F | FzfLua live grep |
| Cmd+B | Toggle file tree |
| Cmd+Z | Undo |
| Cmd+Shift+Z | Redo |

### Normal mode only

| Key | Action |
|-----|--------|
| Cmd+Click | LSP go to definition |
| Cmd+W | Close current buffer/tab |
| Cmd+] | Next tab |
| Cmd+[ | Previous tab |
| Right-click | LSP hover at mouse position |
| K | LSP hover |
| gt | LSP type definition |
| gd | LSP go to definition |

## Auto-save

Saves automatically on:
- Leaving insert mode (`InsertLeave`)
- Window losing focus (`FocusLost`)
- Any text change in normal mode (`TextChanged`)

Skips unnamed buffers and special buffers (terminals, etc.).

## Auto-reload

Files changed externally (e.g. by AI coding agents) are reloaded automatically via `checktime` on `FocusGained`, `BufEnter`, and `CursorHold`. Requires `autoread = true`.

## Ghostty config

```
theme = vscode-dark-modern
unfocused-split-opacity = 1.0
split-divider-color = #5a5a5a
window-decoration = true
macos-titlebar-style = native
```

### Keybinds passed through to Neovim (kitty keyboard protocol)

| Ghostty keybind | Escape sequence | Neovim key |
|----------------|-----------------|------------|
| Cmd+F | `\x1b[102;9u` | `<D-f>` |
| Cmd+B | `\x1b[98;9u` | `<D-b>` |
| Cmd+Shift+F | `\x1b[70;10u` | `<D-S-f>` |
| Cmd+Z | `\x1b[122;9u` | `<D-z>` |
| Cmd+Y | `\x1b[121;9u` | `<D-y>` |
| Cmd+Shift+Z | `\x1b[122;10u` | `<D-S-z>` |

> Cmd+P passes through automatically without an override.

## Editor options

| Option | Value |
|--------|-------|
| number + relativenumber | true |
| mouse | `a` (all modes) |
| mousemodel | `extend` (disables nvim built-in right-click popup) |
| clipboard | `unnamedplus` |
| updatetime | 250ms |
| scrolloff | 8 |
| tabstop / shiftwidth | 2 |
| expandtab | true |
| cursorline | true |
| cmdheight | 0 (no gap between editor and terminal split) |
| laststatus | 0 |
| ignorecase + smartcase | true |

## PATH

`init.lua` prepends `~/.vite-plus/bin` to `vim.env.PATH` so Neovim finds vite-plus managed binaries (tree-sitter, etc.).

## Highlights

Set **after** colorscheme loads or they get overridden:

```lua
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1f1f1f", fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1f1f1f", fg = "#ffffff" })
-- NvimTree sidebar highlights applied via apply_nvimtree_colors() function
-- re-applied on ColorScheme autocmd
```
