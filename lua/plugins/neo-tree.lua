return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      mappings = {
        ["<c-v>"] = "open_vsplit", -- Mapeia Ctrl+V para abrir em split vertical
        ["<c-s>"] = "open_split",  -- Mapeia Ctrl+S para abrir em split horizontal
      },
    },
  },
}
