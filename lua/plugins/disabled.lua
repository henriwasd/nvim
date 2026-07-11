return {
  -- Desativa o Noice.nvim (linha de comando popup, notificações ricas)
  -- para evitar lentidão e input lag na renderização do terminal
  {
    "folke/noice.nvim",
    enabled = false,
  },

  -- Desativa animações do mini.animate (caso estejam ativas)
  -- para poupar ciclos de processamento da CPU
  {
    "echasnovski/mini.animate",
    enabled = false,
  },
}
