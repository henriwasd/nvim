-- Sugestão de LSP baseada na extensão do arquivo desativada para ganho de performance ao abrir arquivos.
-- local lsp_suggest_group = vim.api.nvim_create_augroup("lsp_suggest_on_open", { clear = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   group = lsp_suggest_group,
--   callback = function(args)
--     local ft = vim.bo[args.buf].filetype
--     local ignore_fts =
--       { "lazy", "mason", "TelescopePrompt", "neo-tree", "Trouble", "dashboard", "", "text", "markdown" }
-- 
--     if vim.tbl_contains(ignore_fts, ft) then
--       return
--     end
-- 
--     vim.schedule(function()
--       if not vim.api.nvim_buf_is_valid(args.buf) then
--         return
--       end
-- 
--       -- Verifica se há LSPs ativos
--       local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
--       local clients = get_clients({ bufnr = args.buf })
--       if #clients > 0 then
--         return
--       end
-- 
--       -- Carregamento tardio e seguro
--       local ok_lsp, lspconfig = pcall(require, "lspconfig")
--       local ok_mason, mason_mapping = pcall(require, "mason-lspconfig.mapping")
--       if not ok_lsp or not ok_mason then
--         return
--       end
-- 
--       local configs = require("lspconfig.configs")
--       local lsp_to_mason = mason_mapping.get_lspconfig_to_mason_map()
--       local suggestions = {}
-- 
--       for server_name, config in pairs(configs) do
--         local def = config.default_config
--         if def and def.filetypes and vim.tbl_contains(def.filetypes, ft) then
--           local mason_name = lsp_to_mason[server_name]
--           if mason_name then
--             table.insert(suggestions, mason_name)
--           end
--         end
--       end
-- 
--       if #suggestions > 0 then
--         -- Filtra repetidos
--         local unique = {}
--         local hash = {}
--         for _, v in ipairs(suggestions) do
--           if not hash[v] then
--             unique[#unique + 1] = v
--             hash[v] = true
--           end
--         end
-- 
--         vim.notify(
--           string.format(
--             "Nenhum LSP ativo para '%s'.\nSugestões para instalar via :Mason:\n- %s",
--             ft,
--             table.concat(unique, "\n- ")
--           ),
--           vim.log.levels.INFO,
--           { title = "LSP Suggestion" }
--         )
--       end
--     end)
--   end,
-- })

-- --- LSP ATTACH AUTOCMAND (Mapeamento de Teclas do LSP para buffers ativos) ---
local lsp_attach_group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_attach_group,
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Desativa capacidades do Biome que conflitam com o tsserver (vtsls) para evitar duplicidades
    if client and client.name == "biome" then
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.referencesProvider = false
      client.server_capabilities.renameProvider = false
      client.server_capabilities.implementationProvider = false
      client.server_capabilities.hoverProvider = false
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Atalhos de Navegação do LSP (Deduplicados e formatados)
    map("n", "gd", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
        if err or not result or vim.tbl_isempty(result) then
          vim.notify("Nenhuma definição encontrada", vim.log.levels.INFO, { title = "LSP" })
          return
        end

        if not vim.islist(result) then
          result = { result }
        end

        local unique = {}
        local seen = {}
        for _, loc in ipairs(result) do
          local uri = loc.uri or loc.targetUri
          local range = loc.range or loc.targetSelectionRange
          if uri and range then
            -- Normaliza o caminho do arquivo para evitar duplicados por diferença de case/barras no Windows
            local path = vim.uri_to_fname(uri):lower():gsub("\\", "/")
            local line = range.start.line
            local char = range.start.character
            local key = path .. ":" .. line .. ":" .. char
            if not seen[key] then
              table.insert(unique, loc)
              seen[key] = true
            end
          end
        end

        if #unique == 0 then
          vim.notify("Nenhuma definição encontrada", vim.log.levels.INFO, { title = "LSP" })
        elseif #unique == 1 then
          vim.lsp.util.jump_to_location(unique[1], "utf-8", true)
        else
          -- Popula a quickfix list com os itens únicos e abre com o Telescope
          local qf_items = {}
          for _, loc in ipairs(unique) do
            local uri = loc.uri or loc.targetUri
            local range = loc.range or loc.targetSelectionRange
            local filename = vim.uri_to_fname(uri)
            
            -- Tenta ler a linha correspondente para mostrar no Telescope
            local line_text = ""
            local file = io.open(filename, "r")
            if file then
              local current_line = 0
              for l in file:lines() do
                if current_line == range.start.line then
                  line_text = l:gsub("^%s*", "")
                  break
                end
                current_line = current_line + 1
              end
              file:close()
            end

            table.insert(qf_items, {
              filename = filename,
              lnum = range.start.line + 1,
              col = range.start.character + 1,
              text = line_text ~= "" and line_text or "[Definição]",
            })
          end

          vim.fn.setqflist(qf_items, "r")
          require("telescope.builtin").quickfix({
            prompt_title = "Definições",
          })
        end
      end)
    end, { desc = "Go to Definition (Deduplicated)" })
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
    local ok_inc_rename, _ = pcall(require, "inc_rename")
    if ok_inc_rename then
      map("n", "<leader>cr", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true, desc = "Rename Symbol (Incremental)" })
      map("n", "<leader>rn", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true, desc = "Rename Symbol (Incremental)" })
    else
      map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
    end
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

    -- Seleciona o cliente prioritário (ignora biome pois conform.nvim roda biome-check de forma assíncrona)
    local client = nil
    local action_kinds = {}

    -- Procura primeiro por eslint
    for _, c in ipairs(clients) do
      if c.name == "eslint" then
        client = c
        action_kinds = { "source.fixAll.eslint" }
        break
      end
    end

    -- Se não encontrar eslint, procura por vtsls ou ts_ls
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

-- --- AUTO-RELOAD DE ARQUIVOS ALTERADOS NO DISCO (Autoread/Checktime) ---
local autoreload_group = vim.api.nvim_create_augroup("autoreload_on_change", { clear = true })

-- Verifica alterações no disco ao focar, trocar buffer ou inatividade
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  callback = function()
    if vim.fn.mode() ~= "c" and vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Notificação amigável quando o arquivo é recarregado
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = autoreload_group,
  callback = function()
    vim.notify("Arquivo alterado no disco. Buffer recarregado automaticamente.", vim.log.levels.WARN, { title = "Autoread" })
  end,
})
