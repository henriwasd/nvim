local ok_flutter, flutter = pcall(require, "flutter-tools")
if ok_flutter then
  flutter.setup({
    flutter_lookup_cmd = "mise where flutter",
    debugger = {
      enabled = true,
      run_via_dap = true,
      register_configurations = function(paths)
        local dap = require("dap")
        local command = paths.flutter_bin
        local args = { "debug-adapter" }
        if vim.fn.has("win32") == 1 then
          command = "cmd.exe"
          args = { "/c", paths.flutter_bin, "debug-adapter" }
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
          }
        }
        pcall(function()
          require("dap.ext.vscode").load_launchjs()
        end)
      end,
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
