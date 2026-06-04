#!/usr/bin/env bash
# init-workflow.sh
# Instala o workflow SDD no projeto atual.
# Uso: bash /path/to/workflow-sdd/init-workflow.sh (rodar na raiz do projeto)

set -e

WORKFLOW_REPO="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$(pwd)"

echo "==> Instalando workflow SDD em: $PROJECT"

# 1. Agentes Claude
mkdir -p "$PROJECT/.claude/agents"
cp "$WORKFLOW_REPO/agents/implementador.md"        "$PROJECT/.claude/agents/implementador.md"
cp "$WORKFLOW_REPO/agents/task-runner.md"          "$PROJECT/.claude/agents/task-runner.md"
cp "$WORKFLOW_REPO/agents/constitution-manager.md" "$PROJECT/.claude/agents/constitution-manager.md"
echo "    [OK] Agentes copiados para .claude/agents/"

# 1b. Comando /imp (skill que invoca o agente implementador)
mkdir -p "$PROJECT/.claude/skills/imp"
cp "$WORKFLOW_REPO/templates/skills/imp/SKILL.md" "$PROJECT/.claude/skills/imp/SKILL.md"
echo "    [OK] Comando /imp criado em .claude/skills/imp/"

# 2. agent-context (só cria se não existir)
if [ ! -f "$PROJECT/.claude/agent-context.md" ]; then
    cp "$WORKFLOW_REPO/templates/agent-context-template.md" "$PROJECT/.claude/agent-context.md"
    echo "    [OK] .claude/agent-context.md criado"
else
    echo "    [--] .claude/agent-context.md já existe — mantido"
fi

# 3. .specify/memory/
mkdir -p "$PROJECT/.specify/memory"
echo "    [OK] .specify/memory/ garantido"

# 4. MEMORY.md na memória persistente do Claude Code
# Detecta pasta de memória pelo hash do path (mesmo algoritmo do Claude Code)
PROJECT_HASH=$(echo "$PROJECT" | sed 's|[:/\\ ]|-|g' | tr '[:upper:]' '[:lower:]' | sed 's|^-||')
MEMORY_BASE="$HOME/.claude/projects/$PROJECT_HASH/memory"

if [ -d "$HOME/.claude/projects" ]; then
    mkdir -p "$MEMORY_BASE"
    MEMORY_INDEX="$MEMORY_BASE/MEMORY.md"
    if [ ! -f "$MEMORY_INDEX" ]; then
        cp "$WORKFLOW_REPO/templates/MEMORY-template.md" "$MEMORY_INDEX"
        cp "$WORKFLOW_REPO/templates/workflow-memory.md" "$MEMORY_BASE/workflow.md"
        echo "    [OK] MEMORY.md e workflow.md criados em $MEMORY_BASE"
    elif ! grep -q "workflow\.md" "$MEMORY_INDEX"; then
        echo "" >> "$MEMORY_INDEX"
        echo "- [Workflow padrão — usar agente implementador](workflow.md) — toda feature/correção invoca o agente implementador; /imp para invocar diretamente" >> "$MEMORY_INDEX"
        cp "$WORKFLOW_REPO/templates/workflow-memory.md" "$MEMORY_BASE/workflow.md"
        echo "    [OK] Ponteiro de workflow adicionado ao MEMORY.md existente"
    else
        echo "    [--] MEMORY.md já tem ponteiro de workflow — mantido"
    fi
else
    echo "    [--] Claude Code não detectado — MEMORY.md não criado"
fi

# 5. specs/ no .gitignore
if [ -f "$PROJECT/.gitignore" ] && grep -qE "^\s*specs/\s*$" "$PROJECT/.gitignore"; then
    echo "    [!]  AVISO: specs/ está no .gitignore — remova a linha para versionar o histórico de features"
else
    echo "    [OK] specs/ não está ignorado — histórico de features será versionado"
fi

echo ""
echo "==> Workflow SDD instalado."
echo "    Próximo passo: abra o projeto no Claude Code e use /imp para iniciar"
echo "    Se projeto novo: o implementador detectará a ausência da constitution e iniciará o bootstrap automaticamente"
