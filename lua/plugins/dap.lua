return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    local flutter_sdk_path = vim.fn.stdpath("data") .. "/flutter"
    local dart_sdk_path = flutter_sdk_path .. "/bin/cache/dart-sdk"

    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Launch Dart",
        dartSdkPath = dart_sdk_path,
        program = "${workspaceFolder}/bin/${workspaceFolderBasename}.dart",
        cwd = "${workspaceFolder}",
      },
      {
        type = "dart",
        request = "attach",
        name = "Attach to Dart",
        dartSdkPath = dart_sdk_path,
        observatoryPort = "${port}",
      },
    }
  end,
}
