
local ok_pairs, pairs = pcall(require, "mini.pairs")
if ok_pairs then
  pairs.setup()
end


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


  pcall(function()
    require("supermaven-nvim.api").stop()
  end)
end


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


local ok_ts_comments, ts_comments = pcall(require, "ts-comments")
if ok_ts_comments then
  ts_comments.setup()
end


local ok_hipatterns, hipatterns = pcall(require, "mini.hipatterns")
if ok_hipatterns then
  hipatterns.setup({
    highlighters = {
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end


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

  local ok_oil_git, oil_git = pcall(require, "oil-git-status")
  if ok_oil_git then
    oil_git.setup()
  end


  local ok_oil_lsp, oil_lsp = pcall(require, "oil-lsp-diagnostics")
  if ok_oil_lsp then
    oil_lsp.setup()
  end
end


local ok_grug, grug = pcall(require, "grug-far")
if ok_grug then
  grug.setup()
end


local ok_inc_rename, inc_rename = pcall(require, "inc_rename")
if ok_inc_rename then
  inc_rename.setup()
end


local ok_inline_diag, inline_diag = pcall(require, "tiny-inline-diagnostic")
if ok_inline_diag then

  vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
    severity_sort = true,
  })

  inline_diag.setup({
    preset = "cheap",
    options = {
      throttle = 150,
      softwrap = 15,
      multiple_diag_under_cursor = true,
    },
  })
end
