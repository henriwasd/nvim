local M = {}

local asked_packages = {}
local checked_roots = {}
local setup_done = {}

local project_types = {
  {
    name = "Rust",
    markers = { "Cargo.toml" },
    filetypes = { "rust" },
    tools = {
      { name = "rust-analyzer", type = "lsp", lsp = "rust_analyzer" },
      { name = "codelldb", type = "dap" }
    }
  },
  {
    name = "JavaScript/TypeScript",
    markers = { "package.json", "tsconfig.json", "jsconfig.json" },
    filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    tools = {
      { name = "typescript-language-server", type = "lsp", lsp = "ts_ls" },
      { name = "biome", type = "tool" },
      { name = "prettier", type = "tool" }
    }
  },
  {
    name = "Go",
    markers = { "go.mod" },
    filetypes = { "go" },
    tools = {
      { name = "gopls", type = "lsp", lsp = "gopls" },
      { name = "delve", type = "dap" }
    }
  },
  {
    name = "Python",
    markers = { "pyproject.toml", "requirements.txt", "setup.py", "Pipfile" },
    filetypes = { "python" },
    tools = {
      { name = "pyright", type = "lsp", lsp = "pyright" },
      { name = "black", type = "tool" },
      { name = "ruff", type = "tool" }
    }
  },
  {
    name = "Ruby",
    markers = { "Gemfile", "Rakefile" },
    filetypes = { "ruby" },
    tools = {
      { name = "ruby-lsp", type = "lsp", lsp = "ruby_lsp" },
      { name = "rubocop", type = "tool" }
    }
  },
  {
    name = "PHP",
    markers = { "composer.json" },
    filetypes = { "php" },
    tools = {
      { name = "intelephense", type = "lsp", lsp = "intelephense" },
      { name = "phpstan", type = "tool" }
    }
  },
  {
    name = "C/C++",
    markers = { "CMakeLists.txt", "Makefile" },
    filetypes = { "c", "cpp", "objc", "objcpp" },
    tools = {
      { name = "clangd", type = "lsp", lsp = "clangd" },
      { name = "codelldb", type = "dap" }
    }
  },
  {
    name = "Tailwind CSS",
    markers = { "tailwind.config.js", "tailwind.config.ts", "tailwind.config.cjs", "tailwind.config.mjs" },
    tools = {
      { name = "tailwindcss-language-server", type = "lsp", lsp = "tailwindcss" }
    }
  },
  {
    name = "Terraform",
    filetypes = { "terraform", "hcl" },
    tools = {
      { name = "terraform-ls", type = "lsp", lsp = "terraformls" }
    }
  },
  {
    name = "Docker",
    markers = { "Dockerfile", "docker-compose.yml", "docker-compose.yaml" },
    filetypes = { "dockerfile" },
    tools = {
      { name = "dockerfile-language-server", type = "lsp", lsp = "dockerls" }
    }
  },
  {
    name = "HTML/CSS",
    filetypes = { "html", "css", "scss", "less" },
    tools = {
      { name = "html-lsp", type = "lsp", lsp = "html" },
      { name = "css-lsp", type = "lsp", lsp = "cssls" }
    }
  },
  {
    name = "JSON",
    filetypes = { "json", "jsonc" },
    tools = {
      { name = "json-lsp", type = "lsp", lsp = "jsonls" }
    }
  },
  {
    name = "YAML",
    filetypes = { "yaml" },
    tools = {
      { name = "yaml-language-server", type = "lsp", lsp = "yamlls" }
    }
  },
  {
    name = "Markdown",
    filetypes = { "markdown" },
    tools = {
      { name = "marksman", type = "lsp", lsp = "marksman" }
    }
  },
  {
    name = "Lua",
    markers = { "stylua.toml", ".stylua.toml" },
    filetypes = { "lua" },
    tools = {
      { name = "lua-language-server", type = "lsp", lsp = "lua_ls" },
      { name = "stylua", type = "tool" }
    }
  }
}

local function file_exists(path)
  local stat = (vim.uv or vim.loop).fs_stat(path)
  return stat ~= nil
end

local function setup_and_enable(lsp_name)
  -- Resolve older server name mapping (e.g. ts_ls -> tsserver)
  if lsp_name == "ts_ls" then
    local ok_configs, configs = pcall(require, "lspconfig.configs")
    if ok_configs then
      if not configs.ts_ls and configs.tsserver then
        lsp_name = "tsserver"
      end
    end
  end

  if vim.lsp.config then
    -- Neovim 0.11 native LSP config: just enable it!
    pcall(vim.lsp.enable, lsp_name)
  else
    -- Legacy lspconfig setup (Neovim 0.10 or older)
    local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
    if ok_lspconfig then
      if not setup_done[lsp_name] then
        setup_done[lsp_name] = true
        
        -- Get capabilities
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok_cmp_lsp then
          capabilities = cmp_lsp.default_capabilities(capabilities)
        end
        local ok_lsp_file_ops, lsp_file_ops = pcall(require, "lsp-file-operations")
        if ok_lsp_file_ops then
          capabilities = vim.tbl_deep_extend("force", capabilities, lsp_file_ops.default_capabilities())
        end

        if lspconfig[lsp_name] then
          pcall(lspconfig[lsp_name].setup, { capabilities = capabilities })
        end
      end
    end
  end
end

local function install_mason_package(mason_package, lsp_name)
  local ok_mr, mr = pcall(require, "mason-registry")
  if not ok_mr then return end

  local ok_pkg, p = pcall(mr.get_package, mason_package)
  if not ok_pkg then
    vim.notify("Package " .. mason_package .. " not found in Mason registry.", vim.log.levels.ERROR, { title = "Project LSP Manager" })
    return
  end

  vim.notify("Installing " .. mason_package .. " via Mason...", vim.log.levels.INFO, { title = "Project LSP Manager" })

  p:install():once("closed", function()
    vim.schedule(function()
      if p:is_installed() then
        vim.notify("Successfully installed " .. mason_package .. "!", vim.log.levels.INFO, { title = "Project LSP Manager" })
        if lsp_name then
          setup_and_enable(lsp_name)
        end
      else
        vim.notify("Failed to install " .. mason_package .. ".", vim.log.levels.ERROR, { title = "Project LSP Manager" })
      end
    end)
  end)
end

function M.check_and_suggest_tools()
  local ok_mr, mr = pcall(require, "mason-registry")
  if not ok_mr then return end

  local cwd = vim.fn.getcwd()
  local buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local buf_ft = vim.bo[buf].filetype

  -- Skip check for special buffers (e.g. prompt, telescope, oil, etc.)
  if buf_ft == "" or vim.bo[buf].buftype ~= "" then
    return
  end

  -- Determine root directory
  local start_dir = buf_name ~= "" and vim.fs.dirname(buf_name) or cwd
  local root_dir = vim.fs.root(start_dir, {
    ".git",
    "Cargo.toml",
    "package.json",
    "go.mod",
    "pyproject.toml",
    "requirements.txt",
    "pubspec.yaml",
    "composer.json",
    "CMakeLists.txt",
    "Makefile"
  }) or start_dir or cwd

  -- Ensure root path has forward slashes (standardizing across OS)
  root_dir = root_dir:gsub("\\", "/")

  -- If we've already checked this root directory in this session, skip prompting/checking again
  if checked_roots[root_dir] then
    -- Still make sure active LSPs for matched project types are enabled
    for _, project in ipairs(project_types) do
      local match = false
      if project.markers then
        for _, marker in ipairs(project.markers) do
          if file_exists(root_dir .. "/" .. marker) then
            match = true
            break
          end
        end
      end
      if not match and project.filetypes then
        for _, ft in ipairs(project.filetypes) do
          if ft == buf_ft then
            match = true
            break
          end
        end
      end

      if match then
        for _, tool in ipairs(project.tools) do
          if tool.type == "lsp" and mr.is_installed(tool.name) then
            setup_and_enable(tool.lsp)
          end
        end
      end
    end
    return
  end

  checked_roots[root_dir] = true

  local to_install = {}
  local to_enable = {}
  local matched_projects = {}

  for _, project in ipairs(project_types) do
    local match = false

    -- Check markers
    if project.markers then
      for _, marker in ipairs(project.markers) do
        if file_exists(root_dir .. "/" .. marker) then
          match = true
          break
        end
      end
    end

    -- Check filetype if no marker matched
    if not match and project.filetypes then
      for _, ft in ipairs(project.filetypes) do
        if ft == buf_ft then
          match = true
          break
        end
      end
    end

    if match then
      table.insert(matched_projects, project.name)
      for _, tool in ipairs(project.tools) do
        if mr.is_installed(tool.name) then
          if tool.type == "lsp" then
            table.insert(to_enable, tool.lsp)
          end
        else
          if not asked_packages[tool.name] then
            table.insert(to_install, tool)
          end
        end
      end
    end
  end

  -- Enable already installed servers
  for _, lsp_name in ipairs(to_enable) do
    setup_and_enable(lsp_name)
  end

  -- Prompt for uninstalled tools
  if #to_install > 0 then
    -- Mark them as asked so we don't spam prompt
    for _, tool in ipairs(to_install) do
      asked_packages[tool.name] = true
    end

    local tool_lines = {}
    for _, tool in ipairs(to_install) do
      local desc = tool.type == "lsp" and "LSP Server" or (tool.type == "dap" and "Debugger" or "Tool")
      table.insert(tool_lines, string.format("- %s (%s)", tool.name, desc))
    end

    vim.schedule(function()
      local confirm_msg = string.format(
        "Detected project type(s): %s\nWould you like to install the recommended tools via Mason?\n\n%s",
        table.concat(matched_projects, ", "),
        table.concat(tool_lines, "\n")
      )
      local choice = vim.fn.confirm(confirm_msg, "&Yes\n&No", 1)
      if choice == 1 then
        for _, tool in ipairs(to_install) do
          install_mason_package(tool.name, tool.lsp)
        end
      end
    end)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ProjectLspDetector", { clear = true })

  vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost", "BufNewFile", "DirChanged" }, {
    group = group,
    callback = function()
      -- Defer slightly to let buffers load and Mason load
      vim.defer_fn(function()
        M.check_and_suggest_tools()
      end, 200)
    end
  })
end

return M
