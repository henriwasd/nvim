return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['l'] = 'actions.select',
      ['h'] = 'actions.parent',
      ['<C-h>'] = false, -- Desabilita para não conflitar com navegação de janelas
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
}
