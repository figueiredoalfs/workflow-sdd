# Log de implementação — workflow-sdd

Registro de correções aplicadas a partir da instalação manual no **Bot Estudo** (2026-06-06), para que `wfsdd init` entregue o stack completo sem passos manuais.

---

## Contexto

No Bot Estudo, após `wfsdd init`, foi necessário instalar manualmente:

1. Comando `/imp` para **Cursor** (`.cursor/skills/imp/`)
2. **14 skills Speckit** em `.claude/skills/` e `.cursor/skills/`
3. Infra **`.specify/`** (scripts PowerShell, templates, extensão git, workflows)
4. Atualização do skill `/imp` com fluxo completo do implementador (Etapas 0–5 + Speckit)

Esses itens não faziam parte do `init-workflow` v1.0.0.

---

## Lacunas identificadas (v1.0.0)

| Item | v1.0.0 | Esperado |
|---|---|---|
| `/imp` Claude Code | `.claude/skills/imp/` | OK |
| `/imp` Cursor | ausente | `.cursor/skills/imp/` |
| Skills Speckit | ausentes | 14 skills em `.claude/` e `.cursor/` |
| `.specify/scripts/` | ausente | scripts PowerShell do spec-kit |
| `.specify/templates/` | ausente | templates spec/plan/tasks |
| `.specify/extensions/git/` | ausente | hooks git (feature branch, auto-commit) |
| `.specify/feature.json` | ausente | apontar para feature ativa em `specs/` |
| Skill `/imp` | resumo curto | fluxo completo + referência Speckit |

---

## Correções aplicadas (v1.1.0)

### 1. Bundle Speckit em `templates/speckit/`

Copiado do Bot Estudo (originado no Bot CTR v2, spec-kit v0.8.13):

```
templates/speckit/
├── extensions.yml
├── integration.json
├── init-options.json
├── feature.json.template      ← template genérico (não sobrescreve projeto)
├── extensions/git/            ← hooks speckit.git.*
├── integrations/              ← manifests
├── scripts/powershell/        ← create-new-feature, setup-plan, setup-tasks, ...
├── templates/                 ← spec, plan, tasks, checklist
└── workflows/speckit/
```

**Regra de init:** copia tudo para `.specify/` do projeto, **preservando**:
- `.specify/memory/constitution.md` (se existir)
- `.specify/feature.json` (se existir)

Se `feature.json` não existir, detecta a pasta mais recente em `specs/` ou usa `specs/001-feature-name`.

### 2. Skills em `templates/skills/`

| Skill | Destino no projeto |
|---|---|
| `imp/SKILL.md` | `.claude/skills/imp/` (Claude Code) |
| `imp/SKILL.cursor.md` | `.cursor/skills/imp/SKILL.md` (Cursor) |
| `speckit-*` (14 skills) | `.claude/skills/` **e** `.cursor/skills/` |

Skills Speckit incluídos:

- `speckit-specify`, `speckit-plan`, `speckit-tasks`, `speckit-implement`
- `speckit-clarify`, `speckit-checklist`, `speckit-analyze`, `speckit-constitution`
- `speckit-git-commit`, `speckit-git-feature`, `speckit-git-initialize`, `speckit-git-remote`, `speckit-git-validate`
- `speckit-taskstoissues`

### 3. Scripts `init-workflow.ps1` e `init-workflow.sh`

Novos passos adicionados:

- **1c** — `/imp` Cursor
- **1d** — skills Speckit (Claude + Cursor)
- **4/6** — bundle `.specify/` + `feature.json` condicional

Mensagem final atualizada com comandos Speckit disponíveis.

### 4. Template `/imp` enriquecido

- Claude: referência explícita a `/speckit-specify` → `/speckit-plan` → `/speckit-tasks`
- Cursor: fluxo completo Etapas 0–5, sub-agentes via Task tool, validação genérica via `CLAUDE.md`

---

## Estrutura instalada após `wfsdd init` (v1.1.0)

```
.claude/
  agents/          implementador, task-runner, constitution-manager
  skills/
    imp/           /imp (Claude Code)
    speckit-*/     14 comandos Speckit
  agent-context.md

.cursor/
  skills/
    imp/           /imp (Cursor)
    speckit-*/     14 comandos Speckit

.specify/
  memory/          constitution.md (gerada ou preservada)
  scripts/         PowerShell spec-kit
  templates/       spec, plan, tasks
  extensions/git/  hooks de branch e commit
  feature.json     feature ativa (criado ou preservado)
  extensions.yml, integration.json, workflows/

specs/             histórico de features (versionado)
```

---

## Como validar

```powershell
cd "C:\path\to\projeto-teste"
wfsdd init
```

Verificar:

- [ ] `.cursor/skills/imp/SKILL.md` existe
- [ ] `.cursor/skills/speckit-specify/SKILL.md` existe
- [ ] `.specify/scripts/powershell/check-prerequisites.ps1` existe
- [ ] Constitution existente **não** foi sobrescrita
- [ ] `/imp` e `/speckit-specify` aparecem no Cursor/Claude Code

---

## Projeto piloto

**Bot Estudo** — instalação manual em 2026-06-06 serviu de referência para este bundle. Após publicar v1.1.0, rodar `wfsdd update` no Bot Estudo para alinhar com o init automatizado.

---

## Próximos passos (backlog)

- [ ] Documentar requisito `specify-cli` (uv/pipx) no README se hooks PowerShell falharem
- [ ] Template `feature.json` detectar branch git atual além de `specs/`
- [ ] Teste automatizado do init em CI (projeto vazio → assert estrutura)
