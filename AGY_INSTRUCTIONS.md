# 🤖 Instruções para Agentes de IA (Antigravity / agy)

Este repositório contém a configuração **Nativa de Alta Performance** do Neovim (v0.12+) do usuário, focada em zero bloat, inicialização instantânea e uso máximo dos recursos nativos do editor.

> [!IMPORTANT]
> **Consulte obrigatoriamente o arquivo [AGY_CONTEXT.md](AGY_CONTEXT.md) antes de realizar quaisquer alterações.**
> Ele contém todo o histórico da migração (saída do LazyVim para o Neovim Nativo), a localização dos backups, a lista completa de decisões de arquitetura e o guia passo a passo para manutenção em notebooks e outros PCs.

---

## ⚙️ Regras Principais de Arquitetura

1. **Backups Preservados**:
   - A configuração antiga pura do Neovim está guardada na branch `backup-pure-nvim`.
   - A configuração do LazyVim está preservada no histórico git.
2. **Filosofia de Alta Performance (Notebooks e PCs Fracos)**:
   - **Zero Frameworks Pesados**: Não reinstale LazyVim nem lazy.nvim. O gerenciamento de pacotes é feito pela API nativa **`vim.pack`** do Neovim 0.12 (`lua/plugins.lua`).
   - **Autocomplete 100% Nativo**: Usamos `vim.lsp.completion` do Neovim com o popup menu e snippets nativos (`vim.snippet`).
   - **Tema Nativo**: Usamos `retrobox` (o Gruvbox oficial embutido no Neovim) com transparência configurada nativamente.
   - **Statusline Nativa**: Implementada em Lua puro (`lua/config/statusline.lua`), sem bibliotecas externas pesadas.
   - **Terminal Flutuante Nativo**: Implementado via `nvim_open_win` e jobs nativos (`lua/config/terminal.lua`).
   - **Sem Formatação Automática ao Salvar**: O recurso de auto-format está desligado globalmente via `vim.g.autoformat = false`. Formatação manual disponível via `<leader>cf`.
   - **Explorador de Arquivos**: Usamos o **`oil.nvim`**, que edita diretórios como um buffer de texto nativo.
3. **Como Modificar**:
   - Novos plugins essenciais devem ser adicionados na lista `M.specs` em `lua/plugins.lua` através de URLs completas de git (ex: `'https://github.com/autor/repo'`).
   - Atualizações de plugins podem ser feitas via `:PackUpdate`.
   - Novos servidores LSP devem ser configurados em `lua/lsp/init.lua` via `vim.lsp.config(...)` e `vim.lsp.enable(...)`.
