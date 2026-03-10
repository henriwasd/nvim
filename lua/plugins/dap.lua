return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "suketa/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local flutter_path = vim.fn.stdpath("data") .. "/flutter/bin/cache/dart-sdk"
    local debugger_path = flutter_path .. "/bin/snapshots/pub_tools.dart"

    dap.adapters.dart = {
      type = "executable",
      command = "dart",
      args = { debugger_path },
    }

    dap.configurations.dart = {
      {
        name = "Launch Dart",
        type = "dart",
        request = "launch",
        program = "${workspaceFolder}/bin/${workspaceFolderBasename}.dart",
        cwd = "${workspaceFolder}",
      },
    }
  end,
}
