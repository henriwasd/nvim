-- Sugestão de LSP baseada na extensão do arquivo, focando na velocidade de abertura
local lsp_suggest_group = vim.api.nvim_create_augroup("lsp_suggest_on_open", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = lsp_suggest_group,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local ignore_fts = { "lazy", "mason", "TelescopePrompt", "neo-tree", "Trouble", "dashboard", "", "text", "markdown" }

    if vim.tbl_contains(ignore_fts, ft) then
      return
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      -- Verifica se há LSPs ativos
      local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
      local clients = get_clients({ bufnr = args.buf })
      if #clients > 0 then
        return
      end

      -- Carregamento tardio e seguro
      local ok_lsp, lspconfig = pcall(require, "lspconfig")
      local ok_mason, mason_mapping = pcall(require, "mason-lspconfig.mapping")
      if not ok_lsp or not ok_mason then
        return
      end

      local configs = require("lspconfig.configs")
      local lsp_to_mason = mason_mapping.get_lspconfig_to_mason_map()
      local suggestions = {}

      for server_name, config in pairs(configs) do
        local def = config.default_config
        if def and def.filetypes and vim.tbl_contains(def.filetypes, ft) then
          local mason_name = lsp_to_mason[server_name]
          if mason_name then
            table.insert(suggestions, mason_name)
          end
        end
      end

      if #suggestions > 0 then
        -- Filtra repetidos
        local unique = {}
        local hash = {}
        for _, v in ipairs(suggestions) do
          if not hash[v] then
            unique[#unique + 1] = v
            hash[v] = true
          end
        end

        vim.notify(
          string.format(
            "Nenhum LSP ativo para '%s'.\nSugestões para instalar via :Mason:\n- %s",
            ft,
            table.concat(unique, "\n- ")
          ),
          vim.log.levels.INFO,
          { title = "LSP Suggestion" }
        )
      end
    end)
  end,
})

-- --- LSP ATTACH AUTOCMAND (Mapeamento de Teclas do LSP para buffers ativos) ---
local lsp_attach_group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_attach_group,
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Atalhos de Navegação do LSP
    map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
    map("n", "gr", function() require("telescope.builtin").lsp_references() end, { desc = "References" })
    map("n", "gI", function() require("telescope.builtin").lsp_implementations() end, { desc = "Goto Implementation" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
    map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
    map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })

    -- Ações de Código do LSP
    map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
    map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
    map("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action (Visual)" })
  end,
})
