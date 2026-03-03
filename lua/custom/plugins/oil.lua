return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      -- Precisamos habilitar a signcolumn para ver os ícones do git
      win_options = {
        signcolumn = 'yes:2',
      },
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ['g?'] = 'actions.show_help',
        ['<CR>'] = 'actions.select',
        ['l'] = 'actions.select',
        ['h'] = 'actions.parent',
        ['<C-h>'] = false,
        ['<C-l>'] = false,
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = 'actions.close',
        ['-'] = 'actions.parent',
        ['_'] = 'actions.open_cwd',
        ['gs'] = 'actions.change_sort',
        ['gx'] = 'actions.open_external',
        ['g.'] = 'actions.toggle_hidden',
        ['g\\'] = 'actions.toggle_trash',
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', '<CMD>Oil<CR>', desc = 'Open parent directory' },
      { '<leader>e', '<CMD>Oil<CR>', desc = 'Open Oil file explorer' },
    },
  },
  -- Plugin para mostrar o status do Git no Oil
  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    config = function() require('oil-git-status').setup() end,
  },
}
