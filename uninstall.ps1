# Uninstall script for LazyVim Setup & Dependencies on Windows
# Runs via: powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/henriwasd/nvim/master/uninstall.ps1 | iex"

$ErrorActionPreference = "Continue"

Write-Host "=============================================" -ForegroundColor Red
Write-Host "  LazyVim Uninstall & Cleanup Script        " -ForegroundColor Red
Write-Host "=============================================" -ForegroundColor Red

# List of Winget Package IDs installed by setup.ps1
$packages = @(
    @{ Name = "Neovim"; Id = "Neovim.Neovim" },
    @{ Name = "Ripgrep"; Id = "BurntSushi.ripgrep.MSVC" },
    @{ Name = "FD-find"; Id = "sharkdp.fd" },
    @{ Name = "LazyGit"; Id = "JesseDuffield.lazygit" },
    @{ Name = "Zig Compiler"; Id = "zig.zig" },
    @{ Name = "Node.js LTS"; Id = "OpenJS.NodeJS.LTS" },
    @{ Name = "Git"; Id = "Git.Git" }
)

Write-Host "`n[1/2] Desinstalando ferramentas instaladas pelo setup..." -ForegroundColor Yellow

foreach ($pkg in $packages) {
    Write-Host "`nVerificando $($pkg.Name) ($($pkg.Id))..." -ForegroundColor Cyan
    try {
        winget uninstall -e --id $pkg.Id --accept-source-agreements
        Write-Host "$($pkg.Name) removido com sucesso." -ForegroundColor Green
    } catch {
        Write-Warning "Nao foi possivel remover $($pkg.Name) via winget ou o pacote nao esta instalado."
    }
}

Write-Host "`n[2/2] Limpando pastas de dados, estado e cache do Neovim..." -ForegroundColor Yellow

$nvimData  = Join-Path $env:LOCALAPPDATA "nvim-data"
$nvimState = Join-Path $env:LOCALAPPDATA "nvim-state"
$nvimCache = Join-Path $env:LOCALAPPDATA "temp\nvim"

if (Test-Path $nvimData) {
    Write-Host "Removendo pasta de dados de plugins: $nvimData" -ForegroundColor Cyan
    Remove-Item -Recurse -Force $nvimData -ErrorAction SilentlyContinue
}

if (Test-Path $nvimState) {
    Write-Host "Removendo pasta de estado: $nvimState" -ForegroundColor Cyan
    Remove-Item -Recurse -Force $nvimState -ErrorAction SilentlyContinue
}

if (Test-Path $nvimCache) {
    Write-Host "Removendo pasta de cache: $nvimCache" -ForegroundColor Cyan
    Remove-Item -Recurse -Force $nvimCache -ErrorAction SilentlyContinue
}

Write-Host "`n=============================================" -ForegroundColor Green
Write-Host "        Desinstalacao Concluida!             " -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
