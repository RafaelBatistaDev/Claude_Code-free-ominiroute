<#
.SYNOPSIS
    OmniRoute CLI — Instalação para Windows 11
.DESCRIPTION
    Instala o OmniRoute CLI globalmente no Windows 11.
    Suporta Windows 10/11, Windows Server 2019+.
.NOTES
    Versão: 1.0.0
    Autor:  OmniRoute Team
    Execute como Administrador para instalação global para todos os usuários.
    Sem administrador, instala apenas para o usuário atual.
.EXAMPLE
    # Instalação padrão (usuário atual)
    .\install-omniroute.ps1

    # Instalação global (requer Admin)
    .\install-omniroute.ps1 -Global

    # Apenas verificar dependências
    .\install-omniroute.ps1 -Check

    # Modo silencioso
    .\install-omniroute.ps1 -Silent

    # Desinstalar
    .\install-omniroute.ps1 -Uninstall
#>

param(
    [switch]$Global,
    [switch]$Check,
    [switch]$Silent,
    [switch]$Uninstall,
    [switch]$Help
)

# ── Configuração de cores do terminal ───────────────────────────────────────────
$Host.UI.RawUI.ForegroundColor = [ConsoleColor]::White

function Write-Info {
    if (-not $Silent) { Write-Host "[INFO]   $args" -ForegroundColor Cyan }
}

function Write-Success {
    if (-not $Silent) { Write-Host "[OK]     $args" -ForegroundColor Green }
}

function Write-Warning {
    if (-not $Silent) { Write-Host "[AVISO]  $args" -ForegroundColor Yellow }
}

function Write-Error {
    Write-Host "[ERRO]   $args" -ForegroundColor Red
}

function Write-Header {
    if (-not $Silent) {
        Write-Host ""
        Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
        Write-Host "  OmniRoute CLI — Instalação Windows" -ForegroundColor Magenta
        Write-Host "══════════════════════════════════════════════════" -ForegroundColor Magenta
        Write-Host ""
    }
}

# ── Detecção de versão do Windows ──────────────────────────────────────────────
function Test-WindowsVersion {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $version = [Version]$os.Version
    $isWin11 = $version -ge [Version]"10.0.22000"
    $isWin10 = $version -ge [Version]"10.0.10240"

    if ($isWin11) {
        Write-Info "Windows 11 detectado (build $($version.Build))"
        return $true
    }
    elseif ($isWin10) {
        Write-Info "Windows 10 detectado (build $($version.Build))"
        Write-Warning "Windows 10 é suportado, mas Windows 11 é recomendado."
        return $true
    }
    else {
        Write-Warning "Versão do Windows desconhecida: $($os.Caption)"
        Write-Warning "O script pode não funcionar corretamente."
        return $false
    }
}

# ── Verificação de administrador ───────────────────────────────────────────────
function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ── Verificação de dependências ────────────────────────────────────────────────
function Test-Dependencies {
    Write-Info "Verificando dependências..."

    $foundAny = $false
    $hasNpm = $false
    $hasBun = $false

    # Verificar npm
    try {
        $npmVersion = npm --version 2>$null
        if ($LASTEXITCODE -eq 0 -and $npmVersion) {
            Write-Success "npm encontrado (versão $npmVersion)"
            $hasNpm = $true
            $foundAny = $true
        }
    }
    catch {
        # npm não encontrado
    }

    # Verificar Bun
    try {
        $bunVersion = bun --version 2>$null
        if ($LASTEXITCODE -eq 0 -and $bunVersion) {
            Write-Success "Bun encontrado (versão $bunVersion)"
            $hasBun = $true
            $foundAny = $true
        }
    }
    catch {
        # Bun não encontrado
    }

    # Verificar Node.js (independente)
    try {
        $nodeVersion = node --version 2>$null
        if ($LASTEXITCODE -eq 0 -and $nodeVersion) {
            Write-Success "Node.js encontrado (versão $nodeVersion)"
        }
    }
    catch {
        # Node não encontrado
    }

    if (-not $foundAny) {
        Write-Warning "Nenhum gerenciador de pacotes encontrado."
        Write-Warning "Instale Node.js/npm ou Bun para continuar."
        Write-Warning ""
        Write-Warning "Opção 1 — Node.js (recomendado para Windows):"
        Write-Warning "  1. Acesse https://nodejs.org (versão LTS)"
        Write-Warning "  2. Baixe e instale o instalador .msi"
        Write-Warning "  3. Após instalar, execute: npm install -g omniroute"
        Write-Warning ""
        Write-Warning "Opção 2 — Bun (mais rápido):"
        Write-Warning "  1. Abra o PowerShell como Administrador"
        Write-Warning "  2. Execute: powershell -c 'irm bun.sh/install.ps1 | iex'"
        Write-Warning "  3. Após instalar, reabra o terminal"
        return $false
    }

    return $true
}

# ── Instalação do Bun no Windows ───────────────────────────────────────────────
function Install-BunWindows {
    Write-Info "Instalando Bun para Windows..."

    try {
        # Usar o script oficial de instalação do Bun
        $installScript = Invoke-RestMethod -Uri "https://bun.sh/install.ps1" -UseBasicParsing
        Invoke-Expression $installScript

        # Recarregar PATH
        Refresh-Path

        # Verificar instalação
        $bunVersion = bun --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Bun instalado com sucesso (versão $bunVersion)"
            return $true
        }
        else {
            Write-Warning "Bun pode não estar no PATH imediatamente."
            return $true
        }
    }
    catch {
        Write-Error "Falha ao instalar Bun: $_"
        Write-Warning "Instale manualmente:"
        Write-Warning "  powershell -c 'irm bun.sh/install.ps1 | iex'"
        return $false
    }
}

# ── Recarregar PATH ────────────────────────────────────────────────────────────
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "Machine")
}

# ── Instalação do OmniRoute ────────────────────────────────────────────────────
function Install-OmniRoute {
    param([bool]$IsGlobal)

    Write-Header

    # Verificar Windows version
    Test-WindowsVersion

    if (-not (Test-Dependencies)) {
        $choice = Read-Host "Deseja instalar o Bun automaticamente? (S/N)"
        if ($choice -eq "S" -or $choice -eq "s") {
            if (-not (Install-BunWindows)) {
                Write-Error "Não foi possível continuar sem um gerenciador de pacotes."
                exit 1
            }
        }
        else {
            Write-Error "Instalação cancelada. Instale Node.js ou Bun primeiro."
            exit 1
        }
    }

    Write-Info "Iniciando instalação do OmniRoute CLI..."
    Write-Info ""

    # Determinar target de instalação
    $npmGlobalArg = if ($IsGlobal) { "-g" } else { "" }

    # Instalar via npm
    $useNpm = $false
    try {
        $npmVersion = npm --version 2>$null
        if ($LASTEXITCODE -eq 0) { $useNpm = $true }
    }
    catch {}

    if ($useNpm) {
        Write-Info "Instalando omniroute via npm..."
        if ($IsGlobal) {
            # Instalação global (requer Admin)
            try {
                npm install -g omniroute 2>&1 | Out-Null
                Write-Success "Pacote omniroute instalado globalmente via npm."
            }
            catch {
                Write-Warning "Falha na instalação global do npm."
                Write-Warning "Tente manualmente: npm install -g omniroute"
            }
        }
        else {
            # Instalação local do usuário
            try {
                npm install omniroute 2>&1 | Out-Null
                Write-Success "Pacote omniroute instalado localmente via npm."
            }
            catch {
                Write-Warning "Falha na instalação local do npm."
            }
        }
    }
    else {
        # Tentar Bun
        try {
            $bunVersion = bun --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Info "Instalando omniroute via Bun..."
                bun install -g omniroute 2>&1 | Out-Null
                Write-Success "Pacote omniroute instalado via Bun."
            }
        }
        catch {
            Write-Error "Nenhum gerenciador de pacotes disponível para instalar omniroute."
            exit 1
        }
    }

    # Verificar PATH do npm no Windows
    $npmPrefix = npm config get prefix 2>$null
    if ($npmPrefix) {
        $npmBinPath = Join-Path $npmPrefix ""
        Write-Info "npm prefix: $npmBinPath"

        # Verificar se o diretório está no PATH do sistema/usuário
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")

        if ($IsGlobal) {
            if ($machinePath -notlike "*$npmBinPath*") {
                Write-Warning "npm global bin não está no PATH do sistema!"
                if (Test-Administrator) {
                    $newPath = "$machinePath;$npmBinPath"
                    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
                    Write-Success "npm global bin adicionado ao PATH do sistema."
                }
                else {
                    Write-Warning "Execute como Administrador para adicionar ao PATH do sistema."
                    Write-Warning "  Caminho: $npmBinPath"
                }
            }
            else {
                Write-Success "npm global bin já está no PATH do sistema."
            }
        }
        else {
            if ($userPath -notlike "*$npmBinPath*") {
                $newPath = "$userPath;$npmBinPath"
                [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
                Write-Success "npm global bin adicionado ao PATH do usuário."
            }
            else {
                Write-Success "npm global bin já está no PATH do usuário."
            }
        }
    }

    # Atualizar PATH da sessão atual
    Refresh-Path

    Write-Success "OmniRoute CLI instalado com sucesso!"
    Write-Info ""
    Write-Info "Comandos disponíveis:"
    Write-Info "  omniroute --help    — Mostra ajuda"
    Write-Info "  omniroute --version — Mostra versão"
    Write-Info "  omniroute -p 20128  — Inicia servidor na porta 20128"
    Write-Info ""

    if (-not $Silent) {
        Write-Host "────────────────────────────────────────────────────" -ForegroundColor Magenta
        Write-Host "  Precisa reiniciar o terminal (ou abra um novo)" -ForegroundColor Yellow
        Write-Host "  para que as alterações no PATH façam efeito." -ForegroundColor Yellow
        Write-Host "────────────────────────────────────────────────────" -ForegroundColor Magenta
    }
}

# ── Desinstalação ──────────────────────────────────────────────────────────────
function Uninstall-OmniRoute {
    Write-Header
    Write-Info "Removendo OmniRoute CLI..."

    # Remover via npm
    try {
        npm uninstall -g omniroute 2>$null
        Write-Success "Pacote omniroute removido via npm."
    }
    catch {
        Write-Warning "Falha ao remover via npm. Pode já estar desinstalado."
    }

    # Tentar via Bun
    try {
        bun remove omniroute 2>$null
        bun remove -g omniroute 2>$null
    }
    catch {}

    # Remover diretórios de configuração
    $configDirs = @(
        "$env:APPDATA\omniroute",
        "$env:LOCALAPPDATA\omniroute",
        "$env:USERPROFILE\.omniroute"
    )

    foreach ($dir in $configDirs) {
        if (Test-Path $dir) {
            try {
                Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
                Write-Success "Removido: $dir"
            }
            catch {
                Write-Warning "Não foi possível remover: $dir"
            }
        }
    }

    Write-Success "OmniRoute CLI desinstalado com sucesso!"
}

# ── Ajuda ──────────────────────────────────────────────────────────────────────
function Show-Help {
    Write-Header
    Write-Host "Uso: .\install-omniroute.ps1 [opções]"
    Write-Host ""
    Write-Host "Opções:"
    Write-Host "  (sem opções)    Instala para o usuário atual"
    Write-Host "  -Global         Instala globalmente (requer Admin)"
    Write-Host "  -Check          Apenas verifica dependências"
    Write-Host "  -Uninstall      Remove a instalação"
    Write-Host "  -Silent         Modo silencioso (sem prompts)"
    Write-Host "  -Help           Mostra esta ajuda"
    Write-Host ""
    Write-Host "Exemplos:"
    Write-Host "  .\install-omniroute.ps1                  # Instalação padrão"
    Write-Host "  .\install-omniroute.ps1 -Global          # Instalação global (Admin)"
    Write-Host "  .\install-omniroute.ps1 -Check           # Verificar dependências"
    Write-Host "  .\install-omniroute.ps1 -Uninstall       # Desinstalar"
}

# ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ──
# EXECUÇÃO PRINCIPAL
# ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ── ──

# Política de execução
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq "Restricted") {
    Write-Warning "Política de execução restrita detectada."
    Write-Warning "Para executar este script, você precisa:"
    Write-Warning "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    Write-Warning ""
    Write-Warning "Ou execute o script com Bypass:"
    Write-Warning "  powershell -ExecutionPolicy Bypass -File install-omniroute.ps1"
    exit 1
}

# Processar argumentos
if ($Help) {
    Show-Help
    exit 0
}

if ($Check) {
    Write-Header
    Test-WindowsVersion
    Test-Dependencies
    exit 0
}

if ($Uninstall) {
    Uninstall-OmniRoute
    exit 0
}

# Instalação
if ($Global -and -not (Test-Administrator)) {
    Write-Warning "Instalação global requer privilégios de Administrador."
    Write-Warning ""

    $relaunch = Read-Host "Deseja reiniciar o script como Administrador? (S/N)"
    if ($relaunch -eq "S" -or $relaunch -eq "s") {
        try {
            Start-Process powershell.exe -ArgumentList @(
                "-NoProfile", "-ExecutionPolicy", "Bypass",
                "-File", "`"$PSCommandPath`"", "-Global"
            ) -Verb RunAs
            exit 0
        }
        catch {
            Write-Error "Falha ao reiniciar como Administrador: $_"
            exit 1
        }
    }
    else {
        Write-Warning "Continuando com instalação do usuário..."
        $Global = $false
    }
}

Install-OmniRoute -IsGlobal:$Global
