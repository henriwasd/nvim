return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<leader>a', '<cmd>Alpha<cr>', desc = 'Alpha Dashboard' },
  },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Cabeçalho Estilizado (ASCII Art)
    dashboard.section.header.val = {
      [[                               __                ]],
      [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[ /' _` \ /' __` \ / __` \/\ \/\ \/\ \  /' __` __` \  ]],
      [[ /\ \/\ \/\  __//\ \_\ \ \ \_/ \ \ \ /\ \/\ \/\ \ ]],
      [[ \ \_\ \_\ \____\ \____/\ \___/ \ \_\ \_\ \_\ \_\ ]],
      [[  \/_/\/_/\/____/\/___/  \/__/   \/_/\/_/\/_/\/_/ ]],
      [[                                                   ]],
    }

    -- Atalhos Rápidos
    dashboard.section.buttons.val = {
      dashboard.button('e', '  New file', ':ene <BAR> startinsert <CR>'),
      dashboard.button('p', '󰈞  Find project files', ':Telescope find_files <CR>'),
      dashboard.button('r', '󰄉  Recent files', ':Telescope oldfiles <CR>'),
      dashboard.button('g', '󰊢  Git Status (Neogit)', ':Neogit <CR>'),
      dashboard.button('c', '  Configuration', ':e $MYVIMRC <CR>'),
      dashboard.button('q', '󰅚  Quit Neovim', ':qa<CR>'),
    }

    -- Rodapé com contagem de plugins (Lazy stats)
    local stats = require('lazy').stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    dashboard.section.footer.val = '⚡ Loaded ' .. stats.count .. ' plugins in ' .. ms .. 'ms'

    alpha.setup(dashboard.opts)
  end,
}
