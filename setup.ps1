# Setup script for LazyVim Custom Configuration on Windows
# Runs via: powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/henriwasd/nvim/master/setup.ps1 | iex"

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   LazyVim Complete Setup & Dependencies     " -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$NvimDir = Join-Path $env:LOCALAPPDATA "nvim"

# 1. Check and Install Git (needed to clone and manage plugins)
Write-Host "`n[1/7] Verificando Git..." -ForegroundColor Yellow
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Git ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "Git nao encontrado! Instalando Git via winget..." -ForegroundColor Cyan
    try {
        winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
        Write-Host "Git instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Error "Nao foi possivel instalar o Git automaticamente. Instale o Git manualmente e execute este script novamente."
    }
}

# 2. Clone or Pull Configuration
if (Test-Path $NvimDir) {
    if (Test-Path (Join-Path $NvimDir ".git")) {
        Write-Host "`n[2/7] Configuracao existente detectada. Atualizando com 'git pull'..." -ForegroundColor Yellow
        Push-Location $NvimDir
        try {
            git pull
            Write-Host "Configuracao atualizada com sucesso!" -ForegroundColor Green
        } catch {
            Write-Warning "Falha ao executar 'git pull'. Verifique se ha alteracoes locais pendentes."
        }
        Pop-Location
    } else {
        Write-Warning "`n[2/7] A pasta $NvimDir ja existe, mas nao e um repositorio git. Pulando clonagem/atualizacao."
    }
} else {
    Write-Host "`n[2/7] Clonando repositorio de configuracao..." -ForegroundColor Yellow
    try {
        git clone https://github.com/henriwasd/nvim.git $NvimDir
        Write-Host "Repositorio clonado com sucesso em $NvimDir!" -ForegroundColor Green
    } catch {
        Write-Error "Falha ao clonar o repositorio."
    }
}

# 3. Check and Install Neovim
Write-Host "`n[3/7] Verificando Neovim..." -ForegroundColor Yellow
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Write-Host "Neovim ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "Neovim nao encontrado. Instalando via winget..." -ForegroundColor Cyan
    try {
        winget install -e --id Neovim.Neovim --accept-package-agreements --accept-source-agreements
        Write-Host "Neovim instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Warning "Nao foi possivel instalar o Neovim via winget."
    }
}

# 4. Check and Install Ripgrep (search inside files)
Write-Host "`n[4/7] Verificando Ripgrep (rg)..." -ForegroundColor Yellow
if (Get-Command rg -ErrorAction SilentlyContinue) {
    Write-Host "Ripgrep (rg) ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "Ripgrep nao encontrado. Instalando..." -ForegroundColor Cyan
    try {
        winget install -e --id BurntSushi.ripgrep.MSVC --accept-package-agreements --accept-source-agreements
        Write-Host "Ripgrep instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Warning "Falha ao instalar Ripgrep."
    }
}

# 5. Check and Install FD-find (fast file search)
Write-Host "`n[5/7] Verificando FD (fd)..." -ForegroundColor Yellow
if (Get-Command fd -ErrorAction SilentlyContinue) {
    Write-Host "FD (fd) ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "FD nao encontrado. Instalando..." -ForegroundColor Cyan
    try {
        winget install -e --id sharkdp.fd --accept-package-agreements --accept-source-agreements
        Write-Host "FD instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Warning "Falha ao instalar FD."
    }
}

# 6. Check and Install LazyGit (Git TUI)
Write-Host "`n[6/7] Verificando LazyGit..." -ForegroundColor Yellow
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Write-Host "LazyGit ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "LazyGit nao encontrado. Instalando..." -ForegroundColor Cyan
    try {
        winget install -e --id JesseDuffield.lazygit --accept-package-agreements --accept-source-agreements
        Write-Host "LazyGit instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Warning "Falha ao instalar LazyGit."
    }
}

# 7. Check and Install Node.js (needed for LSP servers via Mason.nvim)
Write-Host "`n[7/7] Verificando Node.js (necessario para LSPs, linters e formatadores)..." -ForegroundColor Yellow
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "Node.js ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "Node.js nao encontrado. Instalando versao LTS..." -ForegroundColor Cyan
    try {
        winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        Write-Host "Node.js instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Warning "Falha ao instalar Node.js."
    }
}

# EXTRA: Install Zig (perfect lightweight C compiler for nvim-treesitter on Windows)
Write-Host "`n[BONUS] Verificando compilador C para o Tree-sitter (Sintaxe)..." -ForegroundColor Yellow
if (Get-Command zig -ErrorAction SilentlyContinue) {
    Write-Host "Zig (compilador C) ja esta instalado." -ForegroundColor Green
} elseif (Get-Command gcc -ErrorAction SilentlyContinue) {
    Write-Host "GCC (compilador C) ja esta instalado." -ForegroundColor Green
} else {
    Write-Host "Nenhum compilador C encontrado. Instalando o Zig para compilacao rapida de parser do Treesitter..." -ForegroundColor Cyan
    try {
        winget install -e --id zig.zig --accept-package-agreements --accept-source-agreements
        Write-Host "Zig instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Warning "Falha ao instalar Zig via winget."
    }
}

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "           Configuracao Concluida!           " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host "Para aplicar todas as alteracoes de PATH do Windows:" -ForegroundColor Yellow
Write-Host "1. FECHE E REABRA o seu terminal (PowerShell)." -ForegroundColor Yellow
Write-Host "2. Execute o comando: nvim" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Green
