local lsp_attach_group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_attach_group,
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

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

    map("n", "gd", function()
      local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
      local clients = get_clients({ bufnr = 0 })
      local has_definition_support = false
      for _, c in ipairs(clients) do
        if c.initialized and c.supports_method("textDocument/definition") then
          has_definition_support = true
          break
        end
      end
      if not has_definition_support then
        local prev_tagfunc = vim.bo.tagfunc
        vim.bo.tagfunc = ""
        vim.cmd("normal! gd")
        vim.bo.tagfunc = prev_tagfunc
        return
      end

      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
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
          local qf_items = {}
          for _, loc in ipairs(unique) do
            local uri = loc.uri or loc.targetUri
            local range = loc.range or loc.targetSelectionRange
            local filename = vim.uri_to_fname(uri)

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
      local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
      local clients = get_clients({ bufnr = 0 })
      local has_references_support = false
      for _, c in ipairs(clients) do
        if c.initialized and c.supports_method("textDocument/references") then
          has_references_support = true
          break
        end
      end
      if not has_references_support then
        vim.notify("Nenhum cliente LSP com suporte a referências ativo", vim.log.levels.WARN, { title = "LSP" })
        return
      end

      local params = vim.lsp.util.make_position_params()
      params.context = { includeDeclaration = true }

      vim.lsp.buf_request(0, "textDocument/references", params, function(err, result)
        if err or not result or vim.tbl_isempty(result) then
          vim.notify("Nenhuma referência encontrada", vim.log.levels.INFO, { title = "LSP" })
          return
        end

        local unique = {}
        local seen = {}
        for _, loc in ipairs(result) do
          local uri = loc.uri or loc.targetUri
          local range = loc.range or loc.targetSelectionRange
          if uri and range then
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
          vim.notify("Nenhuma referência encontrada", vim.log.levels.INFO, { title = "LSP" })
        else
          local qf_items = {}
          for _, loc in ipairs(unique) do
            local uri = loc.uri or loc.targetUri
            local range = loc.range or loc.targetSelectionRange
            local filename = vim.uri_to_fname(uri)

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
              text = line_text ~= "" and line_text or "[Referência]",
            })
          end

          vim.fn.setqflist(qf_items, "r")
          require("telescope.builtin").quickfix({
            prompt_title = "Referências",
          })
        end
      end)
    end, { desc = "References (Deduplicated)" })
    map("n", "gI", function()
      require("telescope.builtin").lsp_implementations()
    end, { desc = "Goto Implementation" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
    map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
    map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })

    local ok_inc_rename, _ = pcall(require, "inc_rename")
    local rename_fn = vim.lsp.buf.rename
    local rename_opts = { desc = "Rename Symbol" }
    if ok_inc_rename then
      rename_fn = function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end
      rename_opts = { expr = true, desc = "Rename Symbol (Incremental)" }
    end
    map("n", "<leader>cr", rename_fn, rename_opts)
    map("n", "<leader>rn", rename_fn, rename_opts)

    map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
    map("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action (Visual)" })
  end,
})

local large_file_group = vim.api.nvim_create_augroup("large_file_optimization", { clear = true })
local file_utils = require("utils.file")

vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  group = large_file_group,
  callback = function(args)
    if file_utils.is_large_file(args.buf) then
      vim.bo[args.buf].swapfile = false
      vim.bo[args.buf].undofile = false
      vim.wo.foldmethod = "manual"
      vim.wo.foldexpr = ""
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = large_file_group,
  callback = function(args)
    local bufnr = args.buf
    if file_utils.is_large_file(bufnr) then
      vim.cmd("syntax clear")
      vim.cmd("syntax off")


      vim.cmd("NoMatchParen")

      local ok_ts, ts = pcall(require, "nvim-treesitter.configs")
      if ok_ts then
        pcall(vim.treesitter.stop, bufnr)
      end

      vim.notify("Arquivo grande detectado (> 1MB). Recursos pesados desabilitados para melhor performance.",
        vim.log.levels.WARN, { title = "Performance" })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = large_file_group,
  callback = function(args)
    local bufnr = args.buf
    if file_utils.is_large_file(bufnr) then
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        vim.lsp.buf_detach_client(bufnr, client.id)
      end
    end
  end,
})
