# init-workflow.ps1
# Instala o workflow SDD no projeto atual.
# Uso: .\init-workflow.ps1 (rodar na raiz do projeto)
# Ou com caminho do repo: .\init-workflow.ps1 -WorkflowRepo "C:\path\to\workflow-sdd"

param(
    [string]$WorkflowRepo = $PSScriptRoot
)

$Project = Get-Location

Write-Host "==> Instalando workflow SDD em: $Project"

# 1. Agentes Claude
$agentsDir = "$Project\.claude\agents"
if (-not (Test-Path $agentsDir)) { New-Item -ItemType Directory -Force $agentsDir | Out-Null }

Copy-Item "$WorkflowRepo\agents\implementador.md"        "$agentsDir\implementador.md"        -Force
Copy-Item "$WorkflowRepo\agents\task-runner.md"          "$agentsDir\task-runner.md"           -Force
Copy-Item "$WorkflowRepo\agents\constitution-manager.md" "$agentsDir\constitution-manager.md"  -Force
Write-Host "    [OK] Agentes copiados para .claude/agents/"

# 1b. Comando /imp (skill que invoca o agente implementador)
$impSkillDir = Join-Path $Project ".claude\skills\imp"
if (-not (Test-Path $impSkillDir)) { New-Item -ItemType Directory -Force $impSkillDir | Out-Null }
Copy-Item "$WorkflowRepo\templates\skills\imp\SKILL.md" (Join-Path $impSkillDir "SKILL.md") -Force
Write-Host "    [OK] Comando /imp criado em .claude/skills/imp/"

# 2. agent-context (só cria se não existir - não sobrescrever customizações)
$agentContext = "$Project\.claude\agent-context.md"
if (-not (Test-Path $agentContext)) {
    Copy-Item "$WorkflowRepo\templates\agent-context-template.md" $agentContext -Force
    Write-Host "    [OK] .claude/agent-context.md criado"
} else {
    Write-Host "    [--] .claude/agent-context.md já existe - mantido"
}

# 3. .specify/memory/ para a constitution
$specifyDir = Join-Path $Project ".specify\memory"
if (-not (Test-Path $specifyDir)) { New-Item -ItemType Directory -Force $specifyDir | Out-Null }
Write-Host "    [OK] .specify/memory/ garantido"

# 4. MEMORY.md e workflow.md na memória persistente do Claude Code
# Detecta o hash do path do projeto para achar a pasta de memória
$projectHash = ($Project.Path -replace '[:\\/ ]', '-').ToLower().TrimStart('-')
$memoryBase  = Join-Path $env:USERPROFILE ".claude\projects\$projectHash\memory"

if (Test-Path "$env:USERPROFILE\.claude\projects") {
    if (-not (Test-Path $memoryBase)) { New-Item -ItemType Directory -Force $memoryBase | Out-Null }

    $memoryIndex = "$memoryBase\MEMORY.md"
    if (-not (Test-Path $memoryIndex)) {
        Copy-Item "$WorkflowRepo\templates\MEMORY-template.md" $memoryIndex -Force
        Copy-Item "$WorkflowRepo\templates\workflow-memory.md" "$memoryBase\workflow.md" -Force
        Write-Host "    [OK] MEMORY.md e workflow.md criados em $memoryBase"
    } else {
        # Verifica se o ponteiro de workflow já está no índice
        $content = Get-Content $memoryIndex -Raw
        if ($content -notmatch "workflow\.md") {
            Add-Content $memoryIndex "`n- [Workflow padrão - usar agente implementador](workflow.md) - toda feature/correção invoca o agente implementador; /imp para invocar diretamente"
            Copy-Item "$WorkflowRepo\templates\workflow-memory.md" "$memoryBase\workflow.md" -Force
            Write-Host "    [OK] Ponteiro de workflow adicionado ao MEMORY.md existente"
        } else {
            Write-Host "    [--] MEMORY.md já tem ponteiro de workflow - mantido"
        }
    }
} else {
    Write-Host "    [--] Claude Code não detectado - MEMORY.md não criado (instale o Claude Code primeiro)"
}

# 5. specs/ no .gitignore - garantir que não está ignorado
$gitignore = "$Project\.gitignore"
if (Test-Path $gitignore) {
    $gi = Get-Content $gitignore -Raw
    if ($gi -match '(?m)^\s*specs/\s*$') {
        Write-Host "    [!]  AVISO: specs/ está no .gitignore - remova a linha para versionar o histórico de features"
    } else {
        Write-Host "    [OK] specs/ não está ignorado - histórico de features será versionado"
    }
}

Write-Host ""
Write-Host "==> Workflow SDD instalado."
Write-Host "    Próximo passo: abra o projeto no Claude Code e use /imp para iniciar"
Write-Host "    Se projeto novo: o implementador detectará a ausência da constitution e iniciará o bootstrap automaticamente"
