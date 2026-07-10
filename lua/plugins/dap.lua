local ok_dap, dap = pcall(require, "dap")
local ok_dapui, dapui = pcall(require, "dapui")
if ok_dap and ok_dapui then
  dapui.setup()

  -- Setup Dart/Flutter adapter and configs
  local flutter_bin = "flutter"
  if vim.fn.executable("mise") == 1 then
    local handle = io.popen("mise where flutter")
    if handle then
      local result = handle:read("*a")
      handle:close()
      if result then
        result = result:gsub("%s+$", "") -- trim whitespace/newlines
        if result ~= "" then
          local bin_bat = result .. "/bin/flutter.bat"
          local bin_sh = result .. "/bin/flutter"
          if vim.fn.executable(bin_bat) == 1 then
            flutter_bin = bin_bat
          elseif vim.fn.executable(bin_sh) == 1 then
            flutter_bin = bin_sh
          end
        end
      end
    end
  end

  local command = flutter_bin
  local args = { "debug-adapter" }
  if vim.fn.has("win32") == 1 then
    command = "cmd.exe"
    args = { "/c", flutter_bin, "debug-adapter" }
  end

  dap.adapters.dart = {
    type = "executable",
    command = command,
    args = args,
  }

  dap.configurations.dart = {
    {
      type = "dart",
      request = "launch",
      name = "Launch Flutter",
      program = "${workspaceFolder}/lib/main.dart",
      cwd = "${workspaceFolder}",
      toolArgs = {},
    }
  }

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
