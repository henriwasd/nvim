return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "suketa/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")

    local flutter_bin
    if vim.fn.has("win32") == 1 then
      flutter_bin = "C:/Users/hen/develop/flutter/bin/flutter.bat"
    elseif vim.fn.has("macunix") == 1 then
      flutter_bin = "/Users/hen/develop/flutter/bin/flutter"
    else
      flutter_bin = "flutter"
    end

    dap.adapters.dart = {
      type = "executable",
      command = flutter_bin,
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
