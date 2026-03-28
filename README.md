# nvim-config

VS Code Dark Modern-flavoured Neovim + Ghostty setup for TypeScript/SolidJS development.

## Structure

```
nvim/
  init.lua          # Core config, keymaps, LSP setup
  lua/plugins.lua   # All plugins via lazy.nvim
ghostty/
  config            # Ghostty terminal config
  themes/
    vscode-dark-modern  # Ghostty colour theme
```

## Installation

### System dependencies (macOS)

```bash
brew install neovim fzf ripgrep tree-sitter
npm install -g tree-sitter-cli
```

> **Note:** After copying configs, update the `vim.env.PATH` line in `nvim/init.lua` to match your npm global bin path. Run `npm bin -g` to find it.

### Copy configs

```bash
cp -r nvim/ ~/.config/nvim/
cp -r ghostty/ ~/.config/ghostty/
```

### First launch

Open Neovim — lazy.nvim will auto-install all plugins. Then install treesitter parsers:

```
:TSInstall typescript tsx javascript css html json lua markdown
```

Mason will auto-install `ts_ls` and `tailwindcss` language servers on first open of a TS file.

---

## Keymaps

| Key | Action |
|-----|--------|
| `Cmd+P` | Find files (Telescope) |
| `Cmd+F` | Search in current file (Telescope fuzzy) |
| `Cmd+Shift+F` | Live grep across project (fzf-lua, 2-line results) |
| `Cmd+E` | Toggle file tree |
| `K` | LSP hover (type info) |
| Right-click | LSP hover at mouse position |
| `Escape` | Enter normal mode |
| `qq` / `@q` | Record / replay macro |

---

## LLM Recreation Prompt

Paste this into any LLM to recreate or extend this setup from scratch:

```
I use Neovim inside Ghostty terminal on macOS for TypeScript/SolidJS development.
Recreate my setup with the following requirements:

THEME
- VS Code Dark Modern colour scheme throughout (Mofiqul/vscode.nvim)
- Ghostty terminal uses a matching vscode-dark-modern theme file
- Float/hover popup background: #1f1f1f with white (#ffffff) rounded border
- Ghostty split divider colour: #5a5a5a

PLUGIN MANAGER
- lazy.nvim (auto-bootstrapped in init.lua)

PLUGINS
- Mofiqul/vscode.nvim — theme
- nvim-tree/nvim-tree.lua + nvim-web-devicons — file tree (width 35, git icons)
- nvim-telescope/telescope.nvim (master branch) + plenary — file finding and
  in-buffer fuzzy search, ignore pnpm-lock.yaml
- ibhagwan/fzf-lua — live grep with multiline=2 (filename on line 1, match on
  line 2), no preview pane, rg with --color=always --smart-case
- nvim-treesitter/nvim-treesitter — syntax highlighting
- folke/noice.nvim + MunifTanjim/nui.nvim — proper floating hover windows with
  rounded border, padding {1,2}, scrollbar disabled, suppress "No information
  available" notifications
- williamboman/mason.nvim + mason-lspconfig — auto-install ts_ls and tailwindcss
- neovim/nvim-lspconfig
- hrsh7th/nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-path + LuaSnip + cmp_luasnip

LSP
- ts_ls configured with root_markers = { "tsconfig.json" } so monorepos resolve
  correctly per-subproject rather than from the workspace root tsconfig
- tailwindcss LSP enabled
- K keymap bound buffer-locally on LspAttach (not globally)
- Right-click in normal mode moves cursor to mouse position and shows LSP hover
- Live diagnostics in insert mode: vim.diagnostic.config({ update_in_insert = true })

KEYMAPS (all work in normal, insert, and visual mode)
- Cmd+P → Telescope find_files
- Cmd+F → Telescope current_buffer_fuzzy_find
- Cmd+Shift+F → FzfLua live_grep
- Cmd+E → NvimTreeToggle

GHOSTTY CONFIG
- Must pass Cmd+F, Cmd+E, Cmd+Shift+F through to Neovim via kitty keyboard
  protocol escape sequences (super+f → \x1b[102;9u, super+e → \x1b[101;9u,
  super+shift+f → \x1b[70;10u)
- Cmd+P passes through automatically without a keybind override
- unfocused-split-opacity = 1.0
- split-divider-color = #5a5a5a

EDITOR OPTIONS
- Line numbers + relative line numbers
- Mouse enabled
- clipboard = unnamedplus
- updatetime = 250
- scrolloff = 8
- tabstop/shiftwidth = 2, expandtab
- cursorline enabled
- ignorecase + smartcase

PATH
- Prepend npm global bin directory to vim.env.PATH so tree-sitter CLI is found
  by Neovim (run `npm bin -g` to get the path)

FLOAT HIGHLIGHTS (must be set after colorscheme loads or it gets overridden)
- NormalFloat: bg=#1f1f1f fg=#d4d4d4
- FloatBorder: bg=#1f1f1f fg=#ffffff
```
