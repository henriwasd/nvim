return {
  {
    "nvim-mini/mini.surround",
    keys = function(_, keys)
      -- Popula os atalhos baseados em opts.mappings
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add Surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete Surrounding" },
        { opts.mappings.find, desc = "Find Surrounding" },
        { opts.mappings.find_left, desc = "Find Surrounding (Left)" },
        { opts.mappings.highlight, desc = "Highlight Surrounding" },
        { opts.mappings.replace, desc = "Replace Surrounding" },
        { opts.mappings.update_n_lines, desc = "Update Surrounding N Lines" },
      }
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gza", -- Adicionar no modo normal e visual
        delete = "gzd", -- Deletar
        find = "gzf", -- Encontrar (direita)
        find_left = "gzF", -- Encontrar (esquerda)
        highlight = "gzh", -- Destacar
        replace = "gzr", -- Substituir
        update_n_lines = "gzn", -- Atualizar N linhas
      },
    },
  },
}
