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

# 1b. Comando /imp (Claude Code)
mkdir -p "$PROJECT/.claude/skills/imp"
cp "$WORKFLOW_REPO/templates/skills/imp/SKILL.md" "$PROJECT/.claude/skills/imp/SKILL.md"
echo "    [OK] Comando /imp criado em .claude/skills/imp/"

# 1c. Comando /imp (Cursor)
mkdir -p "$PROJECT/.cursor/skills/imp"
cp "$WORKFLOW_REPO/templates/skills/imp/SKILL.cursor.md" "$PROJECT/.cursor/skills/imp/SKILL.md"
echo "    [OK] Comando /imp criado em .cursor/skills/imp/"

# 1d. Skills Speckit -> .claude/skills e .cursor/skills
for skill_dir in "$WORKFLOW_REPO/templates/skills"/speckit-*; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    for dest in ".claude/skills" ".cursor/skills"; do
        mkdir -p "$PROJECT/$dest/$skill_name"
        cp "$skill_dir/SKILL.md" "$PROJECT/$dest/$skill_name/SKILL.md"
    done
done
echo "    [OK] Skills Speckit copiados para .claude/skills/ e .cursor/skills/"

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

# 4. Infra Speckit -> .specify/ (preserva constitution e feature.json existentes)
mkdir -p "$PROJECT/.specify"
for item in "$WORKFLOW_REPO/templates/speckit"/*; do
    base="$(basename "$item")"
    [ "$base" = "feature.json.template" ] && continue
    if [ -d "$item" ]; then
        cp -R "$item" "$PROJECT/.specify/"
    else
        cp "$item" "$PROJECT/.specify/"
    fi
done

if [ ! -f "$PROJECT/.specify/feature.json" ]; then
    detected="specs/001-feature-name"
    if [ -d "$PROJECT/specs" ]; then
        latest="$(ls -1 "$PROJECT/specs" 2>/dev/null | sort -r | head -1)"
        [ -n "$latest" ] && detected="specs/$latest"
    fi
    printf '{\n  "feature_directory": "%s"\n}\n' "$detected" > "$PROJECT/.specify/feature.json"
    echo "    [OK] .specify/feature.json criado ($detected)"
else
    echo "    [--] .specify/feature.json já existe — mantido"
fi

if [ -f "$PROJECT/.specify/memory/constitution.md" ]; then
    echo "    [--] .specify/memory/constitution.md preservada"
else
    echo "    [OK] Infra Speckit em .specify/ (constitution será gerada pelo constitution-manager init)"
fi

# 5. MEMORY.md na memória persistente do Claude Code
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

# 6. specs/ no .gitignore
if [ -f "$PROJECT/.gitignore" ] && grep -qE "^\s*specs/\s*$" "$PROJECT/.gitignore"; then
    echo "    [!]  AVISO: specs/ está no .gitignore — remova a linha para versionar o histórico de features"
else
    echo "    [OK] specs/ não está ignorado — histórico de features será versionado"
fi

echo ""
echo "==> Workflow SDD instalado."
echo "    Claude Code: /imp  |  Cursor: /imp"
echo "    Speckit: /speckit-specify, /speckit-plan, /speckit-tasks"
echo "    Se projeto novo: o implementador detectará a ausência da constitution e iniciará o bootstrap automaticamente"
