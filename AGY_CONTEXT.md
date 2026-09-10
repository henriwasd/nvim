# 🧠 Contexto de Arquitetura e Decisões (Para Antigravity / IA)

Este documento registra detalhadamente **o que foi feito, por que foi feito e como manter** a configuração do Neovim neste repositório. Use este arquivo como guia principal ao configurar ou ajustar este ambiente em outros computadores (ex: notebook de trabalho).

---

## 🎯 1. Motivação da Migração (LazyVim ➡️ Nativo)

* **Problema Original**: O usuário utilizava o framework LazyVim. Embora conveniente, ele carregava dezenas de módulos em cascata, gerando alto consumo de memória, inicialização mais lenta e pequeno input lag em máquinas com processadores mais fracos (como notebooks corporativos ou de baixo consumo).
* **Objetivo**: Eliminar completamente o LazyVim e o `lazy.nvim`, substituindo o máximo possível por **recursos nativos do Neovim (v0.12+)** e plugins minimalistas, mantendo rigorosamente todas as funcionalidades, atalhos e ergonomia que o usuário já utilizava, alcançando a **máxima performance possível**.

---

## ⚙️ 2. De-Para das Substituições (O que mudou e por quê)

| Recurso | Antes (LazyVim) | Agora (Nativo / Minimalista) | Motivo / Implementação |
| :--- | :--- | :--- | :--- |
| **Gerenciador de Pacotes** | `lazy.nvim` | **`vim.pack`** (Nativo Neovim 0.12) | A API nativa `vim.pack` (`lua/plugins.lua`) clona via blobless clone (`--filter=blob:none`), gerencia o runtimepath sem nenhum wrapper e fornece comandos `:PackUpdate` e `:PackStatus`. |
| **Autocomplete de Código** | `blink.cmp` + snippets | **`vim.lsp.completion`** + **`vim.snippet`** | Zero processos extras em segundo plano. Usa a engine nativa do Neovim 0.12. Atalhos configurados em `lua/config/keymaps.lua`: `<Tab>` e `<S-Tab>` navegam ou pulam placeholders; `<CR>` aceita a sugestão. |
| **Tema de Cores** | Plugin `gruvbox.nvim` | **`retrobox`** nativo | O `retrobox` é a recriação oficial do Gruvbox embutida no binário C do Neovim. Transparência feita via `nvim_set_hl` nativo em `lua/config/options.lua`. Zero I/O de disco. |
| **Statusline** | Plugin `lualine.nvim` | **Statusline em Lua puro** | Implementada em `lua/config/statusline.lua`. Renderiza em <0.05ms com modo colorido, branch Git (lida diretamente do `.git/HEAD`), diagnósticos de erro/aviso e posição do cursor. |
| **Terminal Integrado** | Plugin `snacks.terminal` | **Terminal Flutuante Nativo** | Implementado em `lua/config/terminal.lua` usando `nvim_open_win` e `jobstart`. Abre instantaneamente centralizado no diretório atual de trabalho (`cwd`). Alterna com `<C-/>`, `<c-_>` e `<leader>ft`. |
| **Diagnósticos** | Plugin `tiny-inline-diagnostic` | **`vim.diagnostic.config`** nativo | Exibe virtual text com `●`, ícones na gutter lateral e janela flutuante detalhada em `<leader>cd`. |
| **LSP** | Modelo legado de `lspconfig` | **`vim.lsp.config`** nativo | Neovim 0.11+ descontinuou o framework `require('lspconfig')`. Usamos a API nativa `vim.lsp.config('server', { ... })` e `vim.lsp.enable('server')` em `lua/lsp/init.lua`. |
| **Explorador de Arquivos** | `neo-tree` (desativado) / `oil` | **`oil.nvim`** | Permite editar diretórios como um buffer comum do Neovim (`dd` para apagar, editar texto para renomear, `:w` para salvar). Mapeado para `<leader>e`. |
| **Busca de Arquivos e Texto** | `snacks.picker` / `telescope` | **`mini.pick`** + `rg` + `fd` | Picker flutuante ultraleve (~1 arquivo Lua) integrado com `ripgrep` (`<leader>fg`) e `fd` (`<leader>ff`). Sem duplicatas redundantes no menu. |
| **Surround** | `mini.surround` | **`mini.surround`** | Mantido com os mesmos atalhos customizados: `gza` (adicionar), `gzd` (deletar), `gzr` (substituir). |
| **Múltiplos Cursores** | `vim-visual-multi` | **`vim-visual-multi`** | Mantido via `vim.pack` (`Ctrl+N` para multi-cursor). |
| **Which-Key** | `which-key.nvim` | **`which-key.nvim`** | Registrado via `vim.pack` com os menus limpos `f` (find), `b` (buffer), `c` (code), `e` (explorer). |

---

## 🛠️ 3. Guia de Manutenção e Regras para o Notebook de Trabalho

Quando estiver operando no notebook de trabalho:

### 1. Pré-requisitos do Sistema
* **Neovim >= 0.12**: Essencial para ter suporte a `vim.pack`, `vim.lsp.config` e `vim.lsp.completion`. Instale via `winget install Neovim.Neovim` (Windows) ou pacote oficial/appimage (Linux).
* **Ripgrep & FD**: Necessários para as buscas do `mini.pick`. No Windows: `winget install BurntSushi.ripgrep.MSVC` e `winget install sharkdp.fd`.

### 2. Regras de Código (Não viole!)
* **NÃO reinstale o LazyVim nem o `lazy.nvim`**. A arquitetura agora é nativa.
* **NÃO reative o auto-format global**. O usuário optou por `vim.g.autoformat = false` para não travar o fluxo de escrita. Formatação manual sempre por `<leader>cf` (`vim.lsp.buf.format`).
* **NÃO instale plugins visuais que usem timers pesados** (ex: `noice.nvim`, `mini.animate`, decorações de cursor excessivas).
* **Ao adicionar novos plugins**:
  1. Adicione a URL completa na tabela `M.specs` em `lua/plugins.lua`.
  2. Configure o plugin no mesmo arquivo usando `pcall(require, "nome")`.
  3. No Neovim, o `vim.pack.add` fará o clone automaticamente ao abrir o editor.
* **Ao configurar servidores de linguagens (LSP)**:
  - Adicione a configuração em `lua/lsp/init.lua` usando:
    ```lua
    vim.lsp.config("nome_do_server", { ... })
    vim.lsp.enable("nome_do_server")
    ```
  - **Atenção especial ao Windows**: Se o servidor rodar via Node.js (ex: `ts_ls`, `eslint`, `tailwindcss`), verifique se o comando precisa de `.cmd` no Windows (consulte a lógica de `ts_ls` existente em `lua/lsp/init.lua` como referência).

---

## 📂 4. Mapa Mental da Estrutura de Arquivos

```text
lua/
├── plugins.lua          -- Lista de repositórios git e setup do vim.pack
├── lsp/
│   └── init.lua         -- Configuração nativa de LSPs, autocomplete e diagnósticos
└── config/
    ├── options.lua      -- Opções nativas do Vim, wildmenu e tema retrobox com transparência
    ├── keymaps.lua      -- Todos os atalhos organizados (Ctrl+S, Ctrl+A, Alt+Setas, Terminal, MiniPick, Oil)
    ├── autocmds.lua     -- Autoreload de arquivos externos, highlight ao copiar (yank)
    ├── statusline.lua   -- Statusline 100% nativa em Lua (zero plugins)
    └── terminal.lua     -- Terminal flutuante nativo centralizado
```
