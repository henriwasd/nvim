-- ==========================================
-- PLUGIN CONFIGURATIONS
-- ==========================================

-- 1. Colorscheme (Gruvbox)
local ok_gruvbox, gruvbox = pcall(require, "gruvbox")
if ok_gruvbox then
  gruvbox.setup({
    transparent_mode = true,
  })
  vim.cmd("colorscheme gruvbox")
end

-- 2. Statusline (Lualine)
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup({
    options = {
      theme = "gruvbox",
      component_separators = "|",
      section_separators = "",
    },
  })
end

-- 3. Tabline (Bufferline)
local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
  bufferline.setup({
    options = {
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  })
end

-- 4. File Explorer (Neo-tree)
local ok_neotree, neotree = pcall(require, "neo-tree")
if ok_neotree then
  neotree.setup({
    window = {
      mappings = {
        ["h"] = "close_node",
        ["l"] = "open",
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_hidden = false,
        hide_by_name = {
          "node_modules",
          ".git",
          "*.DS_Store",
          "thumbs.db",
        },
      },
    },
  })
end

-- 5. Fuzzy Finder (Telescope)
local ok_telescope, telescope = pcall(require, "telescope")
if ok_telescope then
  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  })
end

-- 6. Syntax Highlighting (Treesitter)
local ok_ts, ts = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts.setup({
    ensure_installed = { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "javascript", "typescript", "dart" },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  })
end

-- 7. Autocomplete (nvim-cmp & LuaSnip)
local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_cmp and ok_luasnip then
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    }),
  })
end

-- 8. LSP config (Mason & Mason-lspconfig & nvim-lspconfig)
local ok_mason, mason = pcall(require, "mason")
local ok_mason_lsp, mason_lsp = pcall(require, "mason-lspconfig")
local ok_lspconfig, lspconfig = pcall(require, "lspconfig")

if ok_mason then
  mason.setup()
end

if ok_mason_lsp and ok_lspconfig then
  mason_lsp.setup({
    ensure_installed = { "lua_ls" },
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp_lsp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  local function setup_server(server_name)
    if server_name == "dartls" then
      return
    end

    -- Suporte nativo para Neovim 0.11+ / 0.12+
    if vim.lsp.config and vim.lsp.enable then
      local ok_config, config = pcall(vim.lsp.config, server_name)
      if not ok_config or not config then
        -- Não é um servidor LSP válido (ex: stylua, que é um formatador)
        return
      end

      local opts = {
        capabilities = capabilities,
      }

      if server_name == "lua_ls" then
        opts.settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        }
      end

      vim.lsp.config(server_name, opts)
      vim.lsp.enable(server_name)
    else
      -- Fallback para Neovim 0.10 e anteriores
      -- Verifica se é um servidor LSP suportado pelo lspconfig
      local ok_server, _ = pcall(function()
        return lspconfig[server_name]
      end)
      if not ok_server or not lspconfig[server_name] then
        return
      end

      local opts = {
        capabilities = capabilities,
      }

      if server_name == "lua_ls" then
        opts.settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        }
      end

      lspconfig[server_name].setup(opts)
    end
  end

  -- Configura os servidores já instalados
  for _, server in ipairs(mason_lsp.get_installed_servers()) do
    setup_server(server)
  end

  -- Configura dinamicamente novos servidores instalados via :Mason
  local ok_registry, registry = pcall(require, "mason-registry")
  if ok_registry then
    registry:on("package:install:success", function(pkg)
      local ok_mappings, mappings = pcall(require, "mason-lspconfig.mappings")
      if ok_mappings then
        local server_name = mappings.get_mason_map().package_to_lspconfig[pkg.name]
        if server_name then
          vim.schedule(function()
            setup_server(server_name)
          end)
        end
      end
    end)
  end
end

-- 8.5 Auto-formatting (conform.nvim)
local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      dart = { "dart_format" },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  })
end

-- 9. Git integrations (Gitsigns)
local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
  gitsigns.setup()
end

-- 10. Auto-pairs (Mini.pairs)
local ok_pairs, pairs = pcall(require, "mini.pairs")
if ok_pairs then
  pairs.setup()
end

-- 11. Surrounding text utility (Mini.surround)
local ok_surround, surround = pcall(require, "mini.surround")
if ok_surround then
  surround.setup({
    mappings = {
      add = "gsa",
      delete = "gsd",
      find = "gsf",
      find_left = "gsF",
      highlight = "gsh",
      replace = "gsr",
      update_n_lines = "gsn",
    },
  })
end

-- 12. Supermaven (AI completion)
local ok_sm, sm = pcall(require, "supermaven-nvim")
if ok_sm then
  sm.setup({
    keymaps = {
      accept_suggestion = "<C-l>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-j>",
    },
    color = {
      suggestion_color = "#888888",
      cterm = 244,
    },
  })
end

-- 13. Debugging (nvim-dap & nvim-dap-ui & nvim-dap-virtual-text)
local ok_dap, dap = pcall(require, "dap")
local ok_dapui, dapui = pcall(require, "dapui")
if ok_dap and ok_dapui then
  dapui.setup()

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  -- Extra F-key bindings for debugging
  local map = vim.keymap.set
  map("n", "<F5>", function()
    dap.continue()
  end, { desc = "Debug: Start/Continue" })
  map("n", "<F6>", function()
    dap.terminate()
  end, { desc = "Debug: Stop/Terminate" })
  map("n", "<F9>", function()
    dap.toggle_breakpoint()
  end, { desc = "Debug: Toggle Breakpoint" })
  map("n", "<F10>", function()
    dap.step_over()
  end, { desc = "Debug: Step Over" })
  map("n", "<F11>", function()
    dap.step_into()
  end, { desc = "Debug: Step Into" })
  map("n", "<leader>db", function()
    dap.toggle_breakpoint()
  end, { desc = "Debug: Toggle Breakpoint" })
end

-- 14. Flutter (Flutter Tools)
local ok_flutter, flutter = pcall(require, "flutter-tools")
if ok_flutter then
  flutter.setup({
    flutter_lookup_cmd = "mise where flutter",
    debug = {
      enabled = true,
      evaluate_to_string_in_debug_views = false,
    },
    dev_log = {
      enabled = false,
    },
    ui = {
      border = "rounded",
      notification_style = "plugin",
    },
    decorations = {
      statusline = {
        app_version = true,
        device = true,
      },
    },
    lsp = {
      -- color = {
      --   enabled = true,
      --   background = false,
      --   foreground = false,
      --   virtual_text = true,
      --   virtual_text_str = "■",
      -- },
      settings = {
        showTodos = true,
        completeFunctionCalls = true,
        renameFilesWithClasses = "prompt",
        enableSnippets = true,
        updateImportsOnRename = true,
        lineLength = 120,
      },
    },
    widget_guides = {
      enabled = true,
    },
  })
end

-- 15. Keybinding visual helper (which-key)
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.setup({
    preset = "classic",
  })
end

-- 16. Context-aware Comments (ts-comments)
local ok_ts_comments, ts_comments = pcall(require, "ts-comments")
if ok_ts_comments then
  ts_comments.setup()
end

