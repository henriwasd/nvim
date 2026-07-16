# 🚀 LazyVim Custom Config

Uma configuração do Neovim limpa, moderna e altamente otimizada, baseada no framework **[LazyVim](https://github.com/LazyVim/LazyVim)** com atalhos de produtividade e integrações inteligentes personalizadas.

---

## 📂 Estrutura do Projeto

```text
~/.config/nvim/
├── init.lua                 # Ponto de entrada (carrega lua/config/lazy.lua)
├── lazyvim.json             # Estado dos extras ativados via :LazyExtras
├── lazy-lock.json           # Lockfile de controle de versão dos plugins
├── LICENSE                  # Licença
├── README.md                # Este README
├── stylua.toml              # Formatação do StyLua
└── lua/
    ├── config/
    │   ├── autocmds.lua     # Comandos automáticos (sincronização de arquivos externos)
    │   ├── keymaps.lua      # Atalhos globais personalizados (Ctrl+S, Ctrl+A, Alt+Setas, Terminal cwd...)
    │   ├── lazy.lua         # Bootstrapping do lazy.nvim e plugins do LazyVim
    │   └── options.lua      # Configurações (shell do Windows, Neovide, desligamento de relativo e root do projeto)
    └── plugins/
        ├── blink.lua        # Autocompletar ultrarrápido com blink.cmp (preset default)
        ├── colorscheme.lua  # Tema Gruvbox personalizado (com fundo transparente)
        ├── diagnostics.lua  # Diagnósticos inline modernos (tiny-inline-diagnostic.nvim)
        ├── multicursor.lua  # Suporte a múltiplos cursores com vim-visual-multi
        └── surround.lua     # Manipulação de delimitadores com mini.surround (mapeamentos gz)
```

---

## ✨ Recursos & Customizações

### 📦 Gerenciamento Moderno de Plugins
*   **Lazy Loading**: Plugins carregados assincronamente sob demanda, mantendo o startup instantâneo.
*   **Controle e Estabilidade**: Lockfile (`lazy-lock.json`) para congelar versões e evitar quebras por atualizações de terceiros.
*   **LazyVim Extras**: Ative suporte a linguagens ou ferramentas visuais instantaneamente com `:LazyExtras`.

### ⚡ Autocompletar Inteligente e Rápido
*   **blink.cmp** (`lua/plugins/blink.lua`): Configurado com o preset `default`.
    *   Exibe documentação automaticamente após 250ms.
    *   Use `<C-x>` para abrir as sugestões / alternar a exibição da documentação.
    *   Use `<C-y>` ou `<CR>` (Enter) para aceitar a primeira sugestão ou a sugestão selecionada.

### 🔄 Sincronização Inteligente com o Disco
*   **Autoreload automático**: O Neovim detecta e recarrega arquivos que foram editados externamente (ex: pelo Git ou editores externos) assim que você foca o editor ou entra em um buffer.

### 🧙‍♂️ Edição Avançada
*   **Múltiplos Cursores**: Plugin `vim-visual-multi` ativado em `lua/plugins/multicursor.lua`.
*   **Surround**: Configuração personalizada do `mini.surround` com prefixo `gz` em `lua/plugins/surround.lua` (ex: `gza` para adicionar, `gzd` para deletar, `gzr` para substituir delimitadores).

### 🖥️ Controle de Janelas e Terminal
*   **Terminal no CWD**: Os atalhos do terminal (`<C-/>`, `<c-_>` e `<leader>ft`) foram ajustados para abrir o terminal no diretório atual de trabalho (`getcwd()`), ideal para monorepos. O terminal padrão na raiz do projeto pode ser acessado via `<leader>fT`.
*   **Sem Formatação ao Salvar**: O recurso de auto-format foi desligado por padrão (`vim.g.autoformat = false`). Formate manualmente com o atalho `<leader>cf`.
*   **Sem Números Relativos**: Desativado por padrão para maior clareza visual (`vim.opt.relativenumber = false`).

---

## ⌨️ Atalhos Personalizados Principais

| Atalho | Modo | Ação |
| :--- | :---: | :--- |
| `Ctrl + A` | Normal / Visual | Seleciona todo o conteúdo do arquivo |
| `Ctrl + S` | Normal / Insert / Visual | **Salva o arquivo** sem rodar autocmds/auto-format (salvamento rápido) |
| `<leader>cf` | Normal | **Formata o buffer atual manualmente** |
| `Ctrl + C` | Visual | Copia a seleção para a área de transferência do sistema |
| `Ctrl + V` | Insert / Visual | Cola da área de transferência do sistema |
| `Alt + ⬆️/⬇️/⬅️/➡️` | Todos | **Redimensiona painéis de janelas** |
| `<C-/>` ou `<leader>ft`| Normal | Abre terminal no **CWD** (diretório atual) |
| `<leader>fT` | Normal | Abre terminal na **Raiz do Projeto** |
| `gza` / `gzd` / `gzr` | Normal / Visual | Adiciona / Deleta / Substitui delimitadores (surround) |

---

## 🚀 Como Começar

### Pré-requisitos
*   Uma [Nerd Font](https://www.nerdfonts.com/) instalada (ex: JetBrainsMono Nerd Font) para renderizar os ícones corretamente.

---

### ⚡ Instalação Automatizada (Recomendado)

#### Windows (PowerShell)
Rode o comando abaixo para clonar a configuração e instalar todas as dependências (`Neovim`, `ripgrep`, `fd`, `lazygit`, `Node.js` e `compiler`):
```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/henriwasd/nvim/master/setup.ps1 | iex"
```

#### Linux (Debian, Ubuntu, Arch, Fedora)
Rode o comando abaixo no terminal para instalar a configuração e todas as dependências:
```bash
curl -fsSL https://raw.githubusercontent.com/henriwasd/nvim/master/setup.sh | bash
```

---

### 🛠️ Instalação Manual (Alternativa)

#### 🪟 Windows (PowerShell)

1. **Backup da configuração antiga** (se aplicável):
   ```powershell
   Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName nvim.backup
   ```

2. **Clonar o repositório** na pasta correta:
   ```powershell
   git clone https://github.com/henriwasd/nvim.git $env:LOCALAPPDATA\nvim
   ```

3. **Instalar dependências adicionais** via terminal:
   * **ripgrep** (busca de texto): `winget install BurntSushi.ripgrep.MSVC`
   * **fd** (busca de arquivos): `winget install sharkdp.fd`
   * **lazygit** (interface Git): `winget install JesseDuffield.lazygit`
   * **Node.js** (para LSPs): `winget install OpenJS.NodeJS.LTS`
   * **Zig** (compilador para Treesitter): `winget install zig.zig`

#### 🐧 Linux

1. **Backup da configuração antiga** (se aplicável):
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clonar o repositório** na pasta correta:
   ```bash
   git clone https://github.com/henriwasd/nvim.git ~/.config/nvim
   ```

3. **Instalar dependências** usando seu gerenciador de pacotes:
   * **Debian/Ubuntu**:
     ```bash
     sudo apt update && sudo apt install -y ripgrep fd-find nodejs npm build-essential
     ```
   * **Arch Linux**:
     ```bash
     sudo pacman -S ripgrep fd nodejs npm gcc lazygit
     ```
   * **Fedora**:
     ```bash
     sudo dnf install -y ripgrep fd-find nodejs npm gcc-c++ make
     ```

4. **Iniciar o Neovim**:
   ```bash
   nvim
   ```

