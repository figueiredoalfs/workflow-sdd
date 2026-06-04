# Memory Index

## Instrução permanente — workflow SDD

**OBRIGATÓRIO:** Toda vez que o usuário pedir para implementar algo (nova feature, correção de bug, novo comando, refatoração), invocar o agente `implementador` ANTES de qualquer ação. Usar `/imp` ou Agent tool com `subagent_type: implementador`.

**Motivo:** O projeto usa o workflow SDD com fluxo definido (entrevista → análise → Speckit ou bypass → task-runner com checkpoints). Implementar diretamente quebra o fluxo.

**Exceção:** Se o usuário pedir explicitamente para NÃO usar o agente, atender diretamente.
