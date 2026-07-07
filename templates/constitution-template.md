# [Projeto] Constitution — v1.0.0

Esta constitution define as leis imutáveis do projeto — proibições absolutas e obrigações de processo.
Ela supersede qualquer outra instrução ad-hoc. Conflitos com `CLAUDE.md` são resolvidos atualizando ambos.

Contexto do projeto (arquitetura, banco, comandos, padrões de código): `README.md` e `CLAUDE.md`.

---

## I. [Lei específica do projeto]

TODO: preencher via `constitution-manager init`

---

## II. Fluxo de Desenvolvimento — Obrigações de Processo

### Análise de tamanho ANTES de começar

Antes de qualquer implementação, estimar o total de linhas de código alteradas/criadas:

- **< 300 linhas** → bypass do Speckit autorizado (ver seção III)
- **≥ 300 linhas** → fluxo SDD obrigatório: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks`

Após `/speckit-tasks` concluir, PARAR e apresentar ao usuário número de tasks, resumo e pergunta
de aprovação. Não avançar para implementação sem aprovação explícita.

### Tamanho máximo por task

Cada task do `tasks.md` DEVE alterar **≤ 300 linhas** de código (somando todos os arquivos).
Tasks maiores devem ser subdivididas. Tasks de documentação não contam no limite.

### Artefato testável obrigatório por task

Cada task DEVE ter um **Checkpoint** com critério de teste concreto e verificável, na
perspectiva de comportamento observável (ex: comando → resposta, endpoint → resultado).
Tasks sem checkpoint não são válidas.

### Testes de comportamento (permanentes) vs. testes de apoio (descartáveis)

O Checkpoint é sempre um cenário de **comportamento** (visão do usuário final) — nasce
antes da implementação, vira regressão permanente e é o único critério de bloqueio da task.

Testes unitários de apoio (andaime interno de TDD) podem ser criados, ajustados ou
descartados livremente durante a implementação. Eles guiam o design, mas não têm poder
de veto isolado: uma falha em teste de apoio com o Checkpoint passando é ruído de
implementação, não bug — não bloqueia o avanço da task nem conta como tentativa de revisão.

### Loop de implementação por task

```
1. Escrever/confirmar o Checkpoint (comportamento) — deve FALHAR antes de implementar (red)
2. Implementar, usando testes de apoio como andaime (descartável)
3. Executar o Checkpoint
4. Passou? → descartar testes de apoio sem valor de regressão duradouro,
             commit imediato + próxima task
   Falhou? → bug real — revisar → voltar ao passo 2
             (após 2 revisões ainda falhar → parar e reportar ao usuário)
```

### Commit por task (OBRIGATÓRIO)

```
git add -A
git commit -m "<tipo>(<escopo>): descrição da task"
```
Nunca acumular múltiplas tasks em um único commit.
Prefixos: feat, fix, docs, refactor, chore, perf.

### Merge e push — somente após confirmação

O agente NUNCA faz merge/push de forma autônoma. Aguardar confirmação explícita do usuário.

---

## III. Bypass do Speckit — Condições Obrigatórias

Omitir o Speckit **somente se todas as 4 condições forem verdadeiras** (declarar explicitamente):

| # | Condição | Critério |
|---|---|---|
| 1 | Causa raiz identificada com evidência | Li o dado / tracei o fluxo até a linha X |
| 2 | Escopo fechado | < 300 linhas alteradas no total |
| 3 | Sem novo comportamento | Só corrige o que estava errado |
| 4 | Sem nova tabela, coluna ou campo de configuração | Nenhuma mudança de schema |

Se qualquer condição falhar → fluxo SDD obrigatório.

---

## IV. Análise Pós-Causa-Raiz (obrigatória em toda correção de bug)

1. **Análise de recorrência** — Por que esse bug pode voltar?
2. **Sugestão de emenda à constitution** — A causa raiz revela anti-padrão não documentado?
   Se sim, invocar `constitution-manager` modo `amend` com a proposta redigida.
3. **Checklist de pontos similares** — O mesmo padrão existe em outros lugares?

---

## V. Checklist de Documentação (obrigatória — fluxo normal E bypass)

| Artefato | Atualizar quando |
|---|---|
| `CLAUDE.md` | Novo comando, novo módulo, nova regra de domínio, mudança de schema |
| `README.md` | Mudança visível ao usuário |
| Esta constitution | Nova proibição, novo princípio ou nova obrigação de processo |

Se nenhum artefato precisar de atualização, declarar explicitamente — nunca silenciar a etapa.

---

## Governance

Conflitos entre esta constitution e o `CLAUDE.md` são resolvidos atualizando ambos.

**Emendas requerem:**
- Atualização deste documento via `constitution-manager` modo `amend`
- Bump de versão semântica (MAJOR: remoção de princípio; MINOR: novo princípio; PATCH: clarificação)
- Commit: `docs(constitution): vX.Y.Z — <resumo>`

**Version**: 1.0.0 | **Ratified**: TODO | **Last Amended**: TODO
