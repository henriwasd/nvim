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
  -- Stop Supermaven binary from running/polling at startup to save network and CPU resources.
  -- You can start/toggle it manually using keymaps or commands: :SupermavenStart / :SupermavenToggle
  pcall(function()
    require("supermaven-nvim.api").stop()
  end)
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
    { "<leader>a", group = "AI / Supermaven" },
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
  -- Disable default virtual text and optimize diagnostic updates
  vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false, -- Never update diagnostics while typing (huge performance boost!)
    severity_sort = true,
  })

  inline_diag.setup({
    preset = "cheap", -- Less CPU rendering overhead than 'modern'
    options = {
      throttle = 150, -- Throttle calculation to 150ms to save CPU
      softwrap = 15,
      multiple_diag_under_cursor = true,
    },
  })
end
