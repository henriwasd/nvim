return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = 'VeryLazy',
  dependencies = 'nvim-tree/nvim-web-devicons',
  opts = {
    options = {
      mode = "buffers",
      diagnostics = 'nvim_lsp',
      always_show_bufferline = true,
    },
  },
  keys = {
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<leader>x', '<cmd>bd<cr>', desc = 'Close Buffer' },
  },
}
