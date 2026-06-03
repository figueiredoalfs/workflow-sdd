# workflow-sdd

Workflow de desenvolvimento orientado por especificação (SDD) para projetos Claude Code.

Três agentes portáveis + templates + script de bootstrap. Funciona em qualquer projeto — nenhum agente contém contexto de projeto específico.

## O que está incluído

```
agents/
  implementador.md        # Orquestrador principal
  task-runner.md          # Executor de tasks com checkpoint
  constitution-manager.md # Gestor da constituição (init / review / amend)

templates/
  constitution-template.md    # Template inicial da constitution
  agent-context-template.md   # Template do contexto comportamental
  MEMORY-template.md          # Template do índice de memória persistente
  workflow-memory.md          # Entrada de memória que ativa o implementador automaticamente

init-workflow.ps1   # Script de instalação (Windows/PowerShell)
init-workflow.sh    # Script de instalação (Linux/macOS/bash)
```

## Instalação

Na raiz do projeto:

**Windows (PowerShell):**
```powershell
& "C:\path\to\workflow-sdd\init-workflow.ps1"
```

**Linux/macOS:**
```bash
bash /path/to/workflow-sdd/init-workflow.sh
```

O script:
- Copia os três agentes para `.claude/agents/`
- Cria `.claude/agent-context.md` (se não existir)
- Garante `.specify/memory/` para a constitution
- Cria `MEMORY.md` com o gatilho de auto-invocação do implementador na memória persistente do Claude Code
- Avisa se `specs/` está no `.gitignore`

## Uso

Após instalar, abra o projeto no Claude Code.

O `MEMORY.md` faz o Claude carregar automaticamente a instrução de usar o implementador em toda nova conversa.

Para invocar manualmente: `/imp`

## Fluxo

```
Projeto novo?
  └─ implementador detecta ausência de constitution
     └─ chama constitution-manager init
        └─ entrevista → gera CLAUDE.md + constitution.md + agent-context.md
           └─ volta ao implementador → entrevista de feature → ...

Projeto existente?
  └─ implementador lê constitution + CLAUDE.md + agent-context
     └─ entrevista de feature
        └─ análise de tamanho
           ├─ < 300 linhas → bypass (implementa diretamente)
           └─ ≥ 300 linhas → Speckit (specify → plan → tasks) → task-runner
```

## Casos cobertos

| Caso | O que acontece |
|---|---|
| Projeto do zero | `constitution-manager init` — entrevista completa, gera todos os artefatos |
| Projeto com CLAUDE.md mas sem constitution | `constitution-manager review` — mapeia lacunas, reentrevista o necessário |
| Constitution desatualizada | `/imp` → `constitution-manager review` — usuário solicita reentrevista |
| Anti-padrão descoberto durante desenvolvimento | `constitution-manager amend` — proposta → aprovação → bump de versão |

## Agentes individuais

| Agente | Quando invocar |
|---|---|
| `/imp` | Qualquer feature ou correção |
| `constitution-manager` | Direto quando quiser fazer review ou amend sem implementar |
| `task-runner` | Raramente — normalmente invocado pelo implementador |
