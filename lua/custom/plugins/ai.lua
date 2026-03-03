return {
  'milanglacier/minuet-ai.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('minuet').setup {
      provider = 'gemini',
      provider_options = {
        gemini = {
          model = 'gemini-3-flash',
          system_prompt = [[You are a senior software engineer. Provide only code completions. Focus on idiomatic and efficient code.]],
        },
      },
      virtualtext = {
        enabled = true,
        keymap = {
          accept = '<A-a>',
          next = '<A-n>',
          prev = '<A-p>',
          dismiss = '<A-d>',
        },
      },
    }
  end,
}
