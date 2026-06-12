-- =============================================================================
-- ESSENTIAL PLUGIN CONFIGURATIONS (Loaded synchronously at startup)
-- =============================================================================

-- 1. Colorscheme (Gruvbox)
local ok_gruvbox, gruvbox = pcall(require, "gruvbox")
if ok_gruvbox then
  gruvbox.setup({
    transparent_mode = true,
  })
  vim.cmd("colorscheme gruvbox")
end

-- 2. Statusline (Lualine)
local ok_lualine, lualine = pcall(require, "lualine")
if ok_lualine then
  lualine.setup({
    options = {
      theme = "gruvbox",
      component_separators = "|",
      section_separators = "",
    },
  })
end

-- 3. Tabline (Bufferline)
local ok_bufferline, bufferline = pcall(require, "bufferline")
if ok_bufferline then
  bufferline.setup({
    options = {
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  })
end
