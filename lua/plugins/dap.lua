return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "suketa/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")

    local ok, flutter_dap = pcall(require, "flutter-tools.dap")
    if ok then
      local adapter = flutter_dap.get_adapter()
      dap.adapters.dart = adapter
    end

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
