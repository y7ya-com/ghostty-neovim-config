-- Ensure vite-plus managed binaries (tree-sitter, etc.) are in PATH
vim.env.PATH = "/Users/y/.vite-plus/bin:" .. vim.env.PATH

-- Leader key (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic options
vim.opt.wrap = false
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 8
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
vim.opt.fillchars = { eob = " " }
vim.opt.laststatus = 0
vim.opt.showmode = false
vim.opt.title = true
vim.opt.titlestring = "%F — nvim"

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

-- Open file tree by default
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
  end,
})

-- All highlights must come AFTER colorscheme or it overrides them
vim.api.nvim_set_hl(0, "NormalFloat",        { bg = "#1f1f1f", fg = "#d4d4d4" })
vim.api.nvim_set_hl(0, "FloatBorder",        { bg = "#1f1f1f", fg = "#ffffff" })
-- NvimTree: VS Code sidebar bg (#181818 = rgb(24,24,24))
vim.api.nvim_set_hl(0, "NvimTreeNormal",              { bg = "#181818", fg = "#9ca3af" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC",            { bg = "#181818", fg = "#9ca3af" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer",         { bg = "#181818" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator",        { fg = "#181818", bg = "#181818" })
vim.api.nvim_set_hl(0, "NvimTreeCursorLine",          { bg = "#37373d" })
vim.api.nvim_set_hl(0, "NvimTreeFolderName",          { fg = "#cccccc" })
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",    { fg = "#cccccc" })
vim.api.nvim_set_hl(0, "NvimTreeIndentMarker",        { fg = "#181818" })
local function apply_nvimtree_colors()
  local amber = "#e2c08d"   -- vscode git modified
  local green = "#73c991"   -- vscode git untracked/added
  local gray  = "#858585"
  local bg    = "#181818"
  local red   = "#c74e39"   -- vscode git deleted
  local dim   = "#8c8c8c"   -- vscode git ignored
  local groups = {
    NvimTreeNormal              = { fg = "#cccccc", bg = bg },
    NvimTreeNormalNC            = { fg = "#cccccc", bg = bg },
    NvimTreeSpecialFile         = { fg = "#cccccc" },  -- remove pink underline
    NvimTreeEndOfBuffer         = { bg = bg },
    NvimTreeWinSeparator        = { fg = bg, bg = bg },
    NvimTreeCursorLine          = { bg = "#37373d" },
    NvimTreeFolderName          = { fg = "#cccccc" },
    NvimTreeOpenedFolderName    = { fg = "#ffffff", bold = true },
    NvimTreeIndentMarker        = { fg = bg },
    NvimTreeFolderArrowClosed   = { fg = "#6b6b6b" },
    NvimTreeFolderArrowOpen     = { fg = "#6b6b6b" },
    NvimTreeFolderIcon          = { fg = "#569cd6" },  -- vscode blue
    NvimTreeOpenedFile          = { fg = "#ffffff", bold = true },
    -- These *HL groups are what nvim-tree actually uses for filename coloring
    NvimTreeGitFileDirtyHL      = { fg = amber },
    NvimTreeGitFileStagedHL     = { fg = amber },
    NvimTreeGitFileNewHL        = { fg = green },
    NvimTreeGitFileRenamedHL    = { fg = green },
    NvimTreeGitFileDeletedHL    = { fg = red },
    NvimTreeGitFileMergeHL      = { fg = red },
    NvimTreeGitFileIgnoredHL    = { fg = dim },
    NvimTreeGitFolderDirtyHL    = { fg = amber },
    NvimTreeGitFolderStagedHL   = { fg = amber },
    NvimTreeGitFolderNewHL      = { fg = green },
    NvimTreeGitFolderRenamedHL  = { fg = green },
    NvimTreeGitFolderDeletedHL  = { fg = red },
    NvimTreeGitFolderMergeHL    = { fg = red },
    NvimTreeGitFolderIgnoredHL  = { fg = dim },
  }
  for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_nvimtree_colors })
apply_nvimtree_colors()

-- Keymaps: Ghostty uses kitty keyboard protocol, Neovim understands <D-...> (Cmd) natively
-- Cmd+P → find files (Ghostty passes through via kitty protocol automatically)
local all_modes = { "n", "i", "v" }
vim.keymap.set(all_modes, "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files (Cmd+P)" })
vim.keymap.set(all_modes, "<D-S-f>", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep (Cmd+Shift+F)" })
vim.keymap.set(all_modes, "<D-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in file (Cmd+F)" })
vim.keymap.set(all_modes, "<D-b>", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree (Cmd+B)" })
