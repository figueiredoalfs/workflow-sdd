---
description: Workflow SDD - invoca o agente implementador para features e correcoes
context: fork
agent: implementador
disable-model-invocation: true
argument-hint: [descricao da feature ou correcao]
---

O usuario invocou o workflow SDD via `/imp`.

**Pedido:** $ARGUMENTS

Atue como o agente **implementador** (`.claude/agents/implementador.md`). Siga o fluxo completo:

1. **Etapa 0** - Detectar estado do projeto (constitution, CLAUDE.md, agent-context) e bootstrap/review se necessario.
2. **Etapa 1** - Entrevistar o usuario sobre a feature ou correcao (perguntas objetivas com base no contexto ja lido).
3. **Etapas seguintes** - Analise de tamanho, Speckit ou bypass, task-runner, documentacao e emendas conforme o agente define.

Se `$ARGUMENTS` estiver vazio, cumprimente brevemente e pergunte o que deseja implementar ou corrigir antes de avancar.
