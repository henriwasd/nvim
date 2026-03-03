return {
  'akinsho/flutter-tools.nvim',
  lazy = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'stevearc/dressing.nvim', -- Better UI for selection
    'mfussenegger/nvim-dap', -- For debugging
  },
  config = function()
    require('flutter-tools').setup {
      ui = {
        border = 'rounded',
        notification_style = 'plugin',
      },
      decorations = {
        statusline = {
          app_version = true,
          device = true,
        },
      },
      outline = {
        open_cmd = '30vnew',
        auto_open = false,
      },
      debugger = {
        enabled = true,
        run_via_dap = true,
        exception_breakpoints = {},
      },
      dev_log = {
        enabled = true,
        open_cmd = 'tabedit',
      },
      lsp = {
        color = {
          enabled = true,
          virtual_text = true,
          virtual_text_str = '■',
        },
        on_attach = function(client, bufnr)
          vim.keymap.set(
            'n',
            '<leader>F',
            '<cmd>Telescope flutter commands<CR>',
            { buffer = bufnr, desc = 'Open [F]lutter Commands' }
          )
          vim.keymap.set('n', '<leader>fr', '<cmd>FlutterRun<CR>', { buffer = bufnr, desc = '[F]lutter [R]un' })
          vim.keymap.set('n', '<leader>fq', '<cmd>FlutterQuit<CR>', { buffer = bufnr, desc = '[F]lutter [Q]uit' })
          vim.keymap.set(
            'n',
            '<leader>fo',
            '<cmd>FlutterOutlineToggle<CR>',
            { buffer = bufnr, desc = '[F]lutter [O]utline Toggle' }
          )
          vim.keymap.set('n', '<leader>fd', '<cmd>FlutterDevices<CR>', { buffer = bufnr, desc = '[F]lutter [D]evices' })
          vim.keymap.set(
            'n',
            '<leader>fe',
            '<cmd>FlutterEmulators<CR>',
            { buffer = bufnr, desc = '[F]lutter [E]mulators' }
          )
          vim.keymap.set(
            'n',
            '<leader>fc',
            '<cmd>FlutterLogToggle<CR>',
            { buffer = bufnr, desc = '[F]lutter Console/[L]og Toggle' }
          )
        end,
        settings = {
          lineLength = 160,
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = 'prompt',
          enableSnippets = true,
          updateImportsOnRename = true,
        },
      },
    }
  end,
}
