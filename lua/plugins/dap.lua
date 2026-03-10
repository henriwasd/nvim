return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "suketa/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")

    local function get_flutter_path()
      local data_path = vim.fn.stdpath("data")
      if vim.fn.has("win32") == 1 then
        return data_path .. "/flutter/bin/flutter.bat"
      else
        return data_path .. "/flutter/bin/flutter"
      end
    end

    dap.adapters.dart = {
      type = "executable",
      command = get_flutter_path(),
      args = { "debug_adapter" },
    }

    dap.configurations.dart = {
      {
        name = "Launch Flutter",
        type = "dart",
        request = "launch",
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
      },
    }
  end,
}
