return {
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
      view = { width = 35 },
      renderer = {
        group_empty = true,
        icons = {
          show = { git = true },
        },
      },
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
      ensure_installed = { "ts_ls", "tailwindcss" },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        root_markers = { "tsconfig.json" },
      })
      vim.lsp.config("tailwindcss", { capabilities = capabilities })
      vim.lsp.enable({ "ts_ls", "tailwindcss" })
    end,
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
