-- Ensure vite-plus managed binaries (tree-sitter, etc.) are in PATH
vim.env.PATH = "/Users/y/.vite-plus/bin:" .. vim.env.PATH

-- Leader key (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- Disable netrw (nvim-tree replaces it)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LSP keymaps: bind K buffer-locally on attach so it always has LSP context
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { buffer = args.buf, desc = "LSP hover" })
  end,
})

vim.keymap.set("n", "<RightMouse>", function()
  local pos = vim.fn.getmousepos()
  vim.api.nvim_set_current_win(pos.winid)
  vim.api.nvim_win_set_cursor(pos.winid, { pos.line, pos.column - 1 })
  vim.lsp.buf.hover()
end, { desc = "LSP hover on right-click" })


-- Show LSP diagnostics (red underlines) live while typing, not just on mode switch
vim.diagnostic.config({ update_in_insert = true })

-- Load plugins
require("lazy").setup("plugins")

-- Colorscheme
vim.cmd.colorscheme("vscode")

-- Float highlights must come AFTER colorscheme or it overrides them
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1f1f1f", fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1f1f1f", fg = "#ffffff" })

-- Keymaps: Ghostty uses kitty keyboard protocol, Neovim understands <D-...> (Cmd) natively
-- Cmd+P → find files (Ghostty passes through via kitty protocol automatically)
local all_modes = { "n", "i", "v" }
vim.keymap.set(all_modes, "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files (Cmd+P)" })
vim.keymap.set(all_modes, "<D-S-f>", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep (Cmd+Shift+F)" })
vim.keymap.set(all_modes, "<D-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in file (Cmd+F)" })
vim.keymap.set(all_modes, "<D-e>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree (Cmd+E)" })
