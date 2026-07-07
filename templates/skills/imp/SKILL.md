---
description: Workflow SDD — invoca o agente implementador para features e correcoes
context: fork
agent: implementador
disable-model-invocation: true
argument-hint: [descricao da feature ou correcao]
---

O usuario invocou o workflow SDD via `/imp`.

**Pedido:** $ARGUMENTS

Atue como o agente **implementador** (`.claude/agents/implementador.md`). Siga o fluxo completo:

## Etapa 0 — Deteccao de estado

Verificar e ler constitution, CLAUDE.md, README.md, agent-context. Bootstrap/review via `constitution-manager` se necessario.

## Etapa 1 — Entrevista

Perguntas objetivas com base no contexto. Confirmar entendimento antes de avancar.

## Etapa 2 — Analise de tamanho

- < 300 linhas → bypass Speckit (constitution §XI)
- ≥ 300 linhas → Etapa 3

## Etapa 3 — SDD

Executar em sequencia: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` (skills em `.claude/skills/speckit-*`).

**PARAR** apos tasks: apresentar resumo numerado e perguntar *"Posso iniciar a implementacao?"*

## Etapa 4 — Implementacao

Apos aprovacao, invocar `task-runner` com caminho do `tasks.md`.

## Etapa 5 — Documentacao e deploy

Checklist §XIII, emendas se necessario, validacao e restart conforme `CLAUDE.md § Stack e servico`.

Se `$ARGUMENTS` estiver vazio, cumprimente brevemente e pergunte o que deseja implementar ou corrigir antes de avancar.
