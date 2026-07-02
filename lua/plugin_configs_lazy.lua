-- =============================================================================
-- LAZY PLUGIN CONFIGURATIONS (Loaded via vim.schedule)
-- =============================================================================

-- 5. Fuzzy Finder (Telescope)
local ok_telescope, telescope = pcall(require, "telescope")
if ok_telescope then
  telescope.setup({
    defaults = {
      path_display = { "truncate" },
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
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_matchparen_offscreen = { method = "popup" }

local ok_ts, ts = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts.setup({
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      "markdown",
      "markdown_inline",
      "javascript",
      "typescript",
      "dart",
      "html",
      "tsx",
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    matchup = {
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
      { name = "nvim_lsp_signature_help" },
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
  -- Configure global defaults (capabilities, etc.)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok_cmp_lsp then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end
  local ok_lsp_file_ops, lsp_file_ops = pcall(require, "lsp-file-operations")
  if ok_lsp_file_ops then
    lsp_file_ops.setup()
    capabilities = vim.tbl_deep_extend("force", capabilities, lsp_file_ops.default_capabilities())
  end

  -- Apply capabilities globally for all servers natively (including completion capabilities)
  if vim.lsp.config then
    vim.lsp.config("*", { capabilities = capabilities })
  end

  -- Customize specific servers natively
  if vim.lsp.config then
    -- lua_ls configuration (essential to avoid undefined global 'vim' warnings in neovim config files)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })
  end

  -- Setup mason-lspconfig (mason-lspconfig v2.0.0+ automatically manages and enables all installed servers natively)
  mason_lsp.setup({
    ensure_installed = { "lua_ls" },
  })
end

-- 8.5 Auto-formatting (conform.nvim)
local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      typescript = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "biome-check", "biome", "prettierd", "prettier", stop_after_first = true },
      json = { "biome-check", "biome", stop_after_first = true },
      jsonc = { "biome-check", "biome", stop_after_first = true },
      dart = { "dart_format" },
    },
    formatters = {
      ["biome-check"] = {
        condition = function(self, ctx)
          return vim.fs.root(ctx.filename, { "biome.json", "biome.jsonc" }) ~= nil
        end,
      },
      biome = {
        condition = function(self, ctx)
          return vim.fs.root(ctx.filename, { "biome.json", "biome.jsonc" }) ~= nil
        end,
      },
    },
    format_on_save = {
      timeout_ms = 2000,
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

-- 10.5 HTML Auto-tag & Rename (nvim-ts-autotag)
local ok_autotag, autotag = pcall(require, "nvim-ts-autotag")
if ok_autotag then
  autotag.setup({
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  })
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
  wk.add({
    { "<leader>w", group = "Window" },
    { "<leader>b", group = "Buffer" },
  })
end

-- 16. Context-aware Comments (ts-comments)
local ok_ts_comments, ts_comments = pcall(require, "ts-comments")
if ok_ts_comments then
  ts_comments.setup()
end

-- 17. Color render (mini.hipatterns)
local ok_hipatterns, hipatterns = pcall(require, "mini.hipatterns")
if ok_hipatterns then
  hipatterns.setup({
    highlighters = {
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end

-- 18. Git Diff and History visualizer (Diffview)
local ok_diffview, diffview = pcall(require, "diffview")
if ok_diffview then
  diffview.setup({
    enhanced_diff_hl = true,
    use_icons = true,
  })
end

-- 19. Git interface (Neogit)
local ok_neogit, neogit = pcall(require, "neogit")
if ok_neogit then
  neogit.setup({
    disable_commit_confirmation = true,
    integrations = {
      diffview = true,
      telescope = true,
    },
  })
end

-- 20. Oil (Edit filesystem directories like a buffer)
local ok_oil, oil = pcall(require, "oil")
if ok_oil then
  oil.setup({
    default_file_explorer = true,
    columns = {
      "icon",
    },
    win_options = {
      signcolumn = "yes:2",
    },
  })

  -- Git status integration for oil.nvim
  local ok_oil_git, oil_git = pcall(require, "oil-git-status")
  if ok_oil_git then
    oil_git.setup()
  end

  -- LSP diagnostics integration for oil.nvim
  local ok_oil_lsp, oil_lsp = pcall(require, "oil-lsp-diagnostics")
  if ok_oil_lsp then
    oil_lsp.setup()
  end
end

-- 21. Grug-far (Project search and replace)
local ok_grug, grug = pcall(require, "grug-far")
if ok_grug then
  grug.setup()
end

-- 22. Inc-rename (Incremental symbol rename preview)
local ok_inc_rename, inc_rename = pcall(require, "inc_rename")
if ok_inc_rename then
  inc_rename.setup()
end

-- 23. Inline Diagnostics (tiny-inline-diagnostic)
local ok_inline_diag, inline_diag = pcall(require, "tiny-inline-diagnostic")
if ok_inline_diag then
  -- Disable default virtual text to prevent duplication
  vim.diagnostic.config({ virtual_text = false })

  inline_diag.setup({
    preset = "modern", -- Options: 'classic', 'modern', 'cheap', 'ghost', 'none'
    options = {
      throttle = 20, -- Throttle time in ms
      softwrap = 15,
      multiple_diag_under_cursor = true,
    },
  })
end
