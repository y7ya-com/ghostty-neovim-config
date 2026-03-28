# Setup Instructions

Recreate this Neovim + Ghostty config exactly as described below.

## System dependencies (macOS)

```bash
brew install neovim fzf ripgrep tree-sitter
npm install -g tree-sitter-cli
```

## File structure

```
~/.config/nvim/init.lua
~/.config/nvim/lua/plugins.lua
~/.config/ghostty/config
~/.config/ghostty/themes/vscode-dark-modern
```

Fetch each file from this repo and place it at the corresponding path.

## Theme

- VS Code Dark Modern colour scheme (Mofiqul/vscode.nvim)
- Ghostty uses a matching vscode-dark-modern theme file
- Float/hover popup: bg=#1f1f1f, border=#ffffff, rounded corners
- Ghostty split divider: #5a5a5a

## Plugin manager

lazy.nvim, auto-bootstrapped in init.lua.

## Plugins

- `Mofiqul/vscode.nvim` — theme
- `nvim-tree/nvim-tree.lua` + `nvim-web-devicons` — file tree, width 35, git icons
- `nvim-telescope/telescope.nvim` (master branch) + `plenary` — file finding, in-buffer fuzzy search, ignore pnpm-lock.yaml
- `ibhagwan/fzf-lua` — live grep, multiline=2 (filename line 1, match line 2), no preview, rg with --color=always --smart-case
- `nvim-treesitter/nvim-treesitter` — syntax highlighting
- `folke/noice.nvim` + `MunifTanjim/nui.nvim` — floating hover windows, rounded border, padding {1,2}, no scrollbar, suppress "No information available" notifications
- `williamboman/mason.nvim` + `mason-lspconfig` — auto-install ts_ls and tailwindcss
- `neovim/nvim-lspconfig`
- `hrsh7th/nvim-cmp` + `cmp-nvim-lsp` + `cmp-buffer` + `cmp-path` + `LuaSnip` + `cmp_luasnip`

## LSP

- `ts_ls` with `root_markers = { "tsconfig.json" }` so monorepos resolve per-subproject
- `tailwindcss` enabled
- `K` bound buffer-locally on LspAttach
- Right-click moves cursor to mouse position and triggers LSP hover
- `vim.diagnostic.config({ update_in_insert = true })` for live inline errors

## Keymaps (normal + insert + visual)

| Key | Action |
|-----|--------|
| Cmd+P | Telescope find_files |
| Cmd+F | Telescope current_buffer_fuzzy_find |
| Cmd+Shift+F | FzfLua live_grep |
| Cmd+E | NvimTreeToggle |
| K | LSP hover |
| Right-click | LSP hover at cursor |

## Ghostty

Pass keys through to Neovim via kitty keyboard protocol:

```
keybind = super+f=text:\x1b[102;9u
keybind = super+e=text:\x1b[101;9u
keybind = super+shift+f=text:\x1b[70;10u
```

Cmd+P passes through automatically without an override.

## Editor options

- Number + relative number
- Mouse enabled, clipboard=unnamedplus
- updatetime=250, scrolloff=8
- tabstop/shiftwidth=2, expandtab
- cursorline, ignorecase, smartcase

## PATH

Prepend your npm global bin to `vim.env.PATH` in init.lua so Neovim finds tree-sitter-cli. Find it with `npm bin -g`.

## Float highlights

Set these AFTER colorscheme loads or they get overridden:

```lua
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1f1f1f", fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1f1f1f", fg = "#ffffff" })
```
