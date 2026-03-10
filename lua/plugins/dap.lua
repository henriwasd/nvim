return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "suketa/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")

    local function get_flutter_bin()
      if vim.fn.has("win32") == 1 then
        return vim.fn.stdpath("data") .. "/flutter/bin/flutter.bat"
      end
      return "flutter"
    end

    dap.adapters.dart = {
      type = "executable",
      command = get_flutter_bin(),
      args = { "debug_adapter" },
    }

    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Flutter",
        program = "${workspaceFolder}/lib/main.dart",
      },
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart",
        program = "${workspaceFolder}/bin/${workspaceFolderBasename}.dart",
      },
    }
  end,
}
