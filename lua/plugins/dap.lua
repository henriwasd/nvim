return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/cmp-dap",
  },
  config = function()
    local dap = require("dap")

    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart",
        dartSdkPath = require("flutter-tools").get_sdk(),
        program = "${workspaceFolder}/bin/${workspaceFolderBasename}.dart",
        cwd = "${workspaceFolder}",
      },
      {
        type = "dart",
        request = "attach",
        name = "Attach to Dart",
        dartSdkPath = require("flutter-tools").get_sdk(),
        observatoryPort = "${port}",
      },
    }
  end,
}
