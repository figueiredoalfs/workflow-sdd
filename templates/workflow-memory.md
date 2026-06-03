---
name: workflow-padrao
description: Instrução de workflow padrão — toda feature ou correção usa o agente implementador; /imp para invocar diretamente
metadata:
  type: feedback
---

Toda vez que o usuário pedir para implementar algo (nova feature, correção de bug, novo comando,
refatoração), invocar o agente `implementador` antes de qualquer ação.

**Why:** O projeto usa o workflow SDD com fluxo definido (entrevista → análise de tamanho →
Speckit ou bypass → task-runner com checkpoints). Implementar diretamente sem passar pelo agente
quebra o fluxo e pode gerar código sem checkpoint testável ou sem documentação atualizada.

**How to apply:** Ao detectar intenção de implementação, invocar o agente implementador
automaticamente. O usuário também pode invocar diretamente com `/imp`.

O agente implementador lê `.specify/memory/constitution.md`, `README.md`, `CLAUDE.md` e
`.claude/agent-context.md` antes de qualquer ação — não é necessário repetir contexto do
projeto na conversa.
