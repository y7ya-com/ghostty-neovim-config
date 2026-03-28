local function context_menu(items, on_select)
  local width = 0
  for _, item in ipairs(items) do width = math.max(width, #item + 4) end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.tbl_map(function(i) return "  " .. i end, items))
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "mouse", row = 1, col = 0,
    width = width, height = #items,
    style = "minimal", border = "rounded",
  })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  vim.api.nvim_set_option_value("winhl", "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:NvimTreeCursorLine", { win = win })
  local function pick()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    vim.api.nvim_win_close(win, true)
    on_select(items[line])
  end
  local function close() vim.api.nvim_win_close(win, true) end
  for _, lhs in ipairs({ "<CR>", "<LeftRelease>" }) do
    vim.keymap.set("n", lhs, pick, { buffer = buf, nowait = true })
  end
  for _, lhs in ipairs({ "<Esc>", "q", "<S-RightMouse>" }) do
    vim.keymap.set("n", lhs, close, { buffer = buf, nowait = true })
  end
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf, once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end,
  })
end

return {
  -- File tabs
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        offsets = {
          { filetype = "NvimTree", text = "", padding = 1 },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
        diagnostics = "nvim_lsp",
      },
    },
  },

  -- VSCode Dark Modern theme
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    opts = {
      style = "dark",
    },
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view = { width = 30 },
      renderer = {
        group_empty = true,
        root_folder_label = false,
        highlight_git = "name",
        indent_markers = { enable = false },
        icons = {
          show = { git = false, folder_arrow = true, file = true },
          glyphs = {
            folder = {
              default = "󰉋",
              open = "󰉋",
            },
          },
        },
      },
      update_focused_file = { enable = true, update_root = false },
      actions = {
        change_dir = { enable = false },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set({ "n", "i", "v" }, "<LeftRelease>", function()
          local node = api.tree.get_node_under_cursor()
          if node then api.node.open.edit() end
        end, { buffer = bufnr, nowait = true })

        local function show_context_menu()
          local pos = vim.fn.getmousepos()
          vim.api.nvim_win_set_cursor(pos.winid, { pos.line, 0 })
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          context_menu(
            { "New file / folder", "Rename", "Delete", "Copy path" },
            function(choice)
              if choice == "New file / folder" then
                api.fs.create(node)
              elseif choice == "Rename" then
                api.fs.rename(node)
              elseif choice == "Delete" then
                api.fs.remove(node)
              elseif choice == "Copy path" then
                api.fs.copy.absolute_path(node)
              end
            end
          )
        end

        vim.keymap.set("n", "<RightMouse>", show_context_menu, { buffer = bufnr, nowait = true })
        vim.keymap.set("n", "<S-RightMouse>", show_context_menu, { buffer = bufnr, nowait = true })
        -- Disable double right-click cd (changes tree root to clicked folder)
        vim.keymap.set("n", "<2-RightMouse>", function() end, { buffer = bufnr, nowait = true })
      end,
    },
  },

  -- Fuzzy finder (file search + grep)
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = { "pnpm%-lock%.yaml" },
      },
      pickers = {
        live_grep = {
          entry_maker = function(line)
            local filename, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
            if not filename then return nil end
            local display_path = vim.fn.fnamemodify(filename, ":~:.")
            return {
              value = line,
              ordinal = filename .. " " .. text,
              display = function()
                local displayer = require("telescope.pickers.entry_display").create({
                  separator = "  ",
                  items = {
                    { width = 40 },
                    { remaining = true },
                  },
                })
                return displayer({
                  { display_path, "TelescopeResultsComment" },
                  { text:gsub("^%s+", ""), "TelescopeResultsNormal" },
                })
              end,
              filename = filename,
              lnum = tonumber(lnum),
              col = tonumber(col),
            }
          end,
        },
      },
    },
  },

  -- fzf-lua: used for live grep with 2-line results (filename + content)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      grep = {
        multiline = 2,
        formatter = "path.filename_first",
        rg_opts = "--color=always --column --line-number --no-heading --smart-case",
      },
      winopts = {
        height = 0.8,
        width = 0.85,
        preview = { hidden = "hidden" },
      },
    },
  },

  -- Treesitter: syntax highlighting (also powers Telescope preview highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Noice: proper floating windows for hover, diagnostics, cmdline
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      presets = {
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = { event = "notify", find = "No information available" },
          opts = { skip = true },
        },
      },
      lsp = {
        hover = {
          enabled = true,
          view = "hover",
        },
        signature = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      views = {
        hover = {
          border = { style = "rounded", padding = { 1, 2 } },
          position = { row = 2, col = 0 },
          size = { max_width = 80 },
          scrollbar = false,
          win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
          },
        },
      },
    },
  },

  -- LSP: auto-install and configure language servers
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "tailwindcss" },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("tailwindcss", { capabilities = capabilities })
      vim.lsp.enable({ "tailwindcss" })
    end,
  },

  -- TypeScript: typescript-tools replaces ts_ls with expanded type hover
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        expose_as_code_action = "all",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayVariableTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          expandParameters = true,
        },
      },
    },
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
