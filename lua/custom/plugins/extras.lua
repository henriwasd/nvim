return {
  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    config = function() require('neoscroll').setup {} end,
  },

  -- Fast jumping (like Zed's jump)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash Treesitter' },
    },
  },

  -- Multi-cursor support
  {
    'mg979/vim-visual-multi',
    branch = 'master',
  },

  -- Better UI for some things
  {
    'stevearc/dressing.nvim',
    opts = {},
  },

  -- Indent guides (already in kickstart, but ensuring it looks good)
  -- { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
}
