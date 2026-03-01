return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]], -- Atalho Ctrl + \ para abrir/fechar
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'float', -- Terminal flutuante (pode ser 'horizontal' ou 'vertical')
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 3,
      },
    })

    -- Atalhos extras
    local opts = {noremap = true}
    vim.api.nvim_set_keymap('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', {desc = '[T]erminal [F]loating'})
    vim.api.nvim_set_keymap('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', {desc = '[T]erminal [H]orizontal'})
    vim.api.nvim_set_keymap('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical size=80<cr>', {desc = '[T]erminal [V]ertical'})
  end
}
