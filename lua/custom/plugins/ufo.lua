return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  event = 'BufReadPost', -- Carrega apenas ao ler um arquivo
  config = function()
    -- Opções recomendadas pelo nvim-ufo
    vim.o.foldcolumn = '1' -- '0' para esconder a barra lateral de dobras
    vim.o.foldlevel = 99 -- Abre todas as dobras por padrão
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Atalhos de teclado específicos do UFO
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })

    require('ufo').setup({
      provider_selector = function(bufnr, filetype, buftype)
        -- Tenta usar LSP primeiro, depois Treesitter como fallback
        return { 'lsp', 'indent' }
      end
    })
  end,
}
