return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = true,
    ft = { "dart" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      local flutter_path = nil
      if vim.fn.has("win32") == 1 then
        flutter_path = vim.fn.stdpath("data") .. "/flutter/bin/flutter.bat"
      end

      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = "plugin",
        },
        flutter_path = flutter_path,
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          },
        },
        lsp = {
          color = {
            enabled = true,
            background = false,
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
            lineLength = 120,
          },
        },
        debugger = {
          enabled = true,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dartls = {},
      },
      setup = {
        dartls = function()
          return true
        end,
      },
    },
  },
}
