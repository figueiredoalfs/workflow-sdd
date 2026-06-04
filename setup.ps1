# setup.ps1 - configura o comando wfsdd no perfil do PowerShell
param([string]$WorkflowRepo = $PSScriptRoot)

$WorkflowRepo = (Resolve-Path $WorkflowRepo).Path

Write-Host "==> Configurando workflow-sdd"
Write-Host "    Repositorio: $WorkflowRepo"

# Detectar perfil ativo
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) { $profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }

# Criar pasta e arquivo se nao existirem
$profileDir = Split-Path $profilePath
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force $profileDir | Out-Null }
if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Force $profilePath | Out-Null }

# Verificar se wfsdd ja esta no perfil
$content = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if ($content -match "function wfsdd") {
    # Atualizar o caminho do repo caso tenha mudado
    $newContent = $content -replace "(?m)^\s*\`$repo\s*=.*$", "    `$repo = `"$WorkflowRepo`""
    if ($newContent -ne $content) {
        Set-Content $profilePath $newContent -Encoding UTF8
        Write-Host "    [OK] Caminho do repositorio atualizado no perfil"
    } else {
        Write-Host "    [--] wfsdd ja configurado no perfil - nenhuma alteracao necessaria"
    }
} else {
    # Adicionar funcao ao perfil
    $function = @"

# workflow-sdd - gerencia o workflow SDD
# Uso: wfsdd <init|update|version>
function wfsdd {
    param([string]`$Command = "help")
    `$repo = "$WorkflowRepo"

    if (`$Command -eq "init") {
        & "`$repo\init-workflow.ps1" -WorkflowRepo `$repo

    } elseif (`$Command -eq "update") {
        Write-Host "==> Atualizando workflow-sdd..."
        Push-Location `$repo
        git pull origin master
        Pop-Location
        & "`$repo\init-workflow.ps1" -WorkflowRepo `$repo

    } elseif (`$Command -eq "version") {
        `$local = Get-Content "`$repo\version.txt" -Raw -ErrorAction SilentlyContinue
        `$local = if (`$local) { `$local.Trim() } else { "desconhecida" }
        try {
            `$remote = (Invoke-RestMethod "https://raw.githubusercontent.com/figueiredoalfs/workflow-sdd/master/version.txt" -TimeoutSec 5).Trim()
        } catch {
            `$remote = "sem conexao"
        }
        Write-Host "workflow-sdd"
        Write-Host "  local : `$local"
        Write-Host "  remote: `$remote"
        if (`$local -ne `$remote -and `$remote -ne "sem conexao") {
            Write-Host "  [!] Atualizacao disponivel -- rode: wfsdd update"
        }

    } else {
        Write-Host "Uso:"
        Write-Host "  wfsdd init     -- instala o workflow no projeto atual"
        Write-Host "  wfsdd update   -- atualiza o repositorio e reinstala"
        Write-Host "  wfsdd version  -- exibe versao local e remota"
    }
}
"@
    Add-Content $profilePath $function -Encoding UTF8
    Write-Host "    [OK] Funcao wfsdd adicionada ao perfil: $profilePath"
}

Write-Host ""
Write-Host "==> Configuracao concluida."
Write-Host "    Abra um novo terminal e use: wfsdd init (na raiz de um projeto)"
Write-Host "    Para aplicar sem reiniciar: . `"$profilePath`""
