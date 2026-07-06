-- 7. Autocomplete (nvim-cmp & LuaSnip)
local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_cmp and ok_luasnip then
  cmp.setup({
    performance = {
      debounce = 150,      -- Delay cmp updates while typing
      throttle = 60,        -- Limit completion rendering frequency
      fetching_timeout = 200, -- Maximum time to wait for a source before displaying results
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp", keyword_length = 2 },
      { name = "nvim_lsp_signature_help" },
      { name = "luasnip", keyword_length = 2 },
      { name = "buffer", keyword_length = 3 },
      { name = "path", keyword_length = 3 },
    }),
  })
end
