-- Sugestão de LSP baseada na extensão do arquivo, focando na velocidade de abertura
local lsp_suggest_group = vim.api.nvim_create_augroup("lsp_suggest_on_open", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = lsp_suggest_group,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local ignore_fts =
      { "lazy", "mason", "TelescopePrompt", "neo-tree", "Trouble", "dashboard", "", "text", "markdown" }

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
    map("n", "gr", function()
      require("telescope.builtin").lsp_references()
    end, { desc = "References" })
    map("n", "gI", function()
      require("telescope.builtin").lsp_implementations()
    end, { desc = "Goto Implementation" })
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

-- --- ORGANIZAÇÃO DE IMPORTS AO SALVAR (Síncrona, Otimizada e Priorizada) ---
local organize_imports_group = vim.api.nvim_create_augroup("organize_imports_on_save", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = organize_imports_group,
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.jsonc" },
  callback = function(args)
    local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
    local clients = get_clients({ bufnr = args.buf })
    if #clients == 0 then
      return
    end

    -- Seleciona o cliente prioritário
    local client = nil
    local action_kinds = {}

    -- Procura primeiro por biome
    for _, c in ipairs(clients) do
      if c.name == "biome" then
        client = c
        action_kinds = { "source.organizeImports.biome", "source.organizeImports" }
        break
      end
    end

    -- Se não encontrar biome, procura por eslint
    if not client then
      for _, c in ipairs(clients) do
        if c.name == "eslint" then
          client = c
          action_kinds = { "source.fixAll.eslint" }
          break
        end
      end
    end

    -- Se não encontrar biome nem eslint, procura por vtsls ou ts_ls
    if not client then
      for _, c in ipairs(clients) do
        if c.name == "vtsls" or c.name == "ts_ls" then
          client = c
          action_kinds = { "source.organizeImports" }
          break
        end
      end
    end

    -- Executa se tiver um cliente selecionado
    if client then
      local last_line = vim.api.nvim_buf_line_count(args.buf)
      local last_char = 0
      if last_line > 0 then
        local lines = vim.api.nvim_buf_get_lines(args.buf, last_line - 1, last_line, false)
        if #lines > 0 then
          last_char = string.len(lines[1])
        end
      end
      local params = {
        textDocument = vim.lsp.util.make_text_document_params(args.buf),
        range = {
          start = { line = 0, character = 0 },
          ["end"] = { line = math.max(0, last_line - 1), character = last_char }
        },
        context = { only = action_kinds, diagnostics = {} }
      }

      -- Executa a requisição de forma síncrona com timeout baixo de 300ms para evitar travamentos
      local result = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 300)
      if result and result[client.id] and result[client.id].result then
        for _, r in ipairs(result[client.id].result) do
          -- Resolve a ação se necessário (comum em vtsls / ts_ls)
          if not r.edit and not r.command then
            local resolve_result = vim.lsp.buf_request_sync(args.buf, "codeAction/resolve", r, 300)
            if resolve_result and resolve_result[client.id] and resolve_result[client.id].result then
              r = resolve_result[client.id].result
            end
          end

          if r.edit then
            vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
          elseif r.command then
            vim.lsp.buf.execute_command(r.command)
          end
        end
      end
    end
  end,
})
