---
name: imp
description: Invoca o agente implementador para features e correcoes via fluxo SDD. Use quando o usuario digitar /imp ou pedir implementacao estruturada de feature ou correcao neste projeto.
disable-model-invocation: true
---

# /imp — Agente Implementador

O usuario invocou o workflow SDD via `/imp`.

**Pedido:** use o texto apos `/imp` na mensagem do usuario como descricao inicial da feature ou correcao. Se estiver vazio, cumprimente brevemente e pergunte o que deseja implementar ou corrigir.

**Fonte de verdade:** leia e siga `.claude/agents/implementador.md` integralmente. Este skill resume o fluxo e adapta sub-agentes ao Cursor.

---

## Etapa 0 — Deteccao de estado

Antes de qualquer outra acao, verificar e ler:

| Arquivo | Se ausente ou incompleto |
|---|---|
| `.specify/memory/constitution.md` | Task `constitution-manager` modo `init` |
| `CLAUDE.md` | Task `constitution-manager` modo `review` |
| `README.md` | Ler para visao geral |
| `.claude/agent-context.md` | Criar minimo com secoes Ponteiros, Comportamento, Aprendizados |

So avancar apos todos presentes e lidos. Ao concluir a sessao, registrar aprendizados novos em `.claude/agent-context.md`.

---

## Etapa 1 — Entrevista

Com base no contexto lido, faca somente as perguntas necessarias (lacunas tipicas em `CLAUDE.md`).

Produza bloco estruturado: descricao tecnica, componentes afetados, entradas/saidas, criterios de aceite, restricoes.

**Nunca pule.** Confirme entendimento com o usuario antes de avancar.

---

## Etapa 2 — Analise de tamanho

Estimar linhas alteradas/criadas:

- **< 300 linhas** → bypass Speckit permitido (constitution §XI — declarar as 4 condicoes)
- **≥ 300 linhas** → fluxo SDD obrigatorio (Etapa 3)

---

## Etapa 3 — Especificacao (fluxo SDD)

Execute em sequencia (skills em `.cursor/skills/speckit-*`):

```
/speckit-specify   ← contexto da entrevista
/speckit-plan      ← deriva do spec gerado
/speckit-tasks     ← deriva do plan gerado
```

**PARAR** apos tasks geradas. Apresentar:

- Numero de tasks
- Resumo numerado
- Pergunta: *"Posso iniciar a implementacao?"*

Nao avancar sem aprovacao explicita.

---

## Etapa 4 — Implementacao

Apos aprovacao, invocar Task `task-runner` passando o caminho do `tasks.md` gerado.

Se a correcao for pequena (bypass), implementar diretamente respeitando constitution e checkpoints.

---

## Etapa 5 — Documentacao, emendas e deploy

1. Checklist constitution §XIII — atualizar artefatos afetados
2. Anti-padrao novo → Task `constitution-manager` modo `amend`
3. Validacao e restart conforme `CLAUDE.md § Stack e servico` e `§ Para agentes`
4. Aguardar confirmacao do usuario para merge/push

---

## Sub-agentes (Cursor)

| Agente | Quando | Como |
|---|---|---|
| `constitution-manager` | Bootstrap, review ou amend | Task com `subagent_type="constitution-manager"` |
| `task-runner` | Apos aprovacao das tasks | Task com `subagent_type="task-runner"` |

Instrucoes completas: `.claude/agents/constitution-manager.md` e `.claude/agents/task-runner.md`.
