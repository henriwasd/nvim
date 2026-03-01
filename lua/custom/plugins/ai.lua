return {
  'milanglacier/minuet-ai.nvim',
  event = 'InsertEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      provider = 'gemini',
      provider_options = {
        gemini = {
          model = 'gemini-1.5-flash',
          system_prompt = [[You are a senior software engineer. Your task is to provide code completion suggestions.
            Provide only the code snippet that should be inserted at the cursor position.
            Do not provide any explanations or markdown code blocks.]],
        },
      },
      virtualtext = {
        enabled = true,
        keymap = {
          accept = '<A-a>', -- Alt + a para aceitar
          next = '<A-n>',   -- Alt + n para próxima sugestão
          prev = '<A-p>',   -- Alt + p para anterior
          dismiss = '<A-d>', -- Alt + d para cancelar
        },
      },
    }
  end,
}
