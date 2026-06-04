# workflow-sdd

Workflow de desenvolvimento orientado por especificação (SDD) para projetos Claude Code.

Três agentes portáveis + templates + scripts de bootstrap. Nenhum agente contém contexto de projeto — funcionam em qualquer repositório.

---

## Requisitos

- [Claude Code](https://claude.ai/code) instalado
- Git
- PowerShell (Windows) ou bash (Linux/macOS)

---

## Instalação em 2 passos

### Passo 1 — Clonar o workflow

```powershell
git clone https://github.com/figueiredoalfs/workflow-sdd.git
```

### Passo 2 — Configurar o comando global `wfsdd`

**Windows — rodar o setup automático (recomendado):**
```
setup.bat
```

**Windows — manual:**
```powershell
& "C:\path\to\workflow-sdd\setup.ps1"
```

**Linux/macOS — manual:**
```bash
bash /path/to/workflow-sdd/setup.sh
```

O setup adiciona a função `wfsdd` ao perfil do PowerShell (ou `~/.bashrc`/`~/.zshrc`), tornando o comando disponível em todo terminal.

---

## Comandos disponíveis

| Comando | O que faz |
|---|---|
| `wfsdd init` | Instala o workflow no projeto atual (rodar na raiz do projeto) |
| `wfsdd update` | Puxa atualizações do repositório e reinstala nos projetos |
| `wfsdd version` | Exibe versão local e remota; avisa se há atualização disponível |

---

## Como usar em um projeto

### Projeto novo

```powershell
cd meu-projeto
wfsdd init
```

Abrir o projeto no Claude Code — o agente `implementador` detecta a ausência da constitution e inicia o bootstrap automaticamente (entrevista → gera `CLAUDE.md` + `constitution.md`).

### Projeto existente

```powershell
cd projeto-existente
wfsdd init
```

O `implementador` detecta os arquivos existentes e entra direto no fluxo de feature. Se algum arquivo estiver desatualizado, chama o `constitution-manager review`.

### Invocar o implementador manualmente

No Claude Code:
```
/imp
```

---

## Fluxo de desenvolvimento

```
Abrir projeto no Claude Code
  └─ MEMORY.md carrega instrução de usar o implementador automaticamente

Pedir uma feature ou correção
  └─ implementador é invocado (/imp ou automático)
     │
     ├─ Etapa 0: detectar estado do projeto
     │   ├─ sem constitution → constitution-manager init (bootstrap)
     │   ├─ CLAUDE.md incompleto → constitution-manager review
     │   └─ tudo OK → continuar
     │
     ├─ Etapa 1: entrevista com o usuário
     │
     ├─ Etapa 2: análise de tamanho
     │   ├─ < 300 linhas → bypass (implementa direto)
     │   └─ ≥ 300 linhas → fluxo SDD
     │       └─ /speckit-specify → /speckit-plan → /speckit-tasks
     │           └─ aprovação do usuário → task-runner
     │
     └─ Etapa 5: documentação + emendas + deploy
         └─ se anti-padrão descoberto → constitution-manager amend
```

---

## Agentes

### `implementador`
Orquestrador principal. Detecta o estado do projeto, entrevista o usuário, orquestra o Speckit e delega ao `task-runner`.

**Invocar:** `/imp`

### `task-runner`
Executa tasks do `tasks.md` uma a uma. Para cada task: implementa → executa checkpoint → passa: commit + próxima / falha: revisa (máx 2x) → reporta.

**Invocar:** normalmente chamado pelo `implementador`. Para uso direto, informar o caminho do `tasks.md`.

### `constitution-manager`
Gerencia a constituição do projeto em três modos:

| Modo | Quando usar | Como invocar |
|---|---|---|
| `init` | Projeto novo sem constitution | Automático via `implementador` |
| `review` | Reentrevistar ou atualizar contexto desatualizado | `/imp` ou direto |
| `amend` | Proposta pontual de nova lei/anti-padrão | Automático após bug fix |

---

## Estrutura instalada no projeto

Após `wfsdd init`, o projeto recebe:

```
.claude/
  agents/
    implementador.md        ← orquestrador
    task-runner.md          ← executor de tasks
    constitution-manager.md ← gestor da constitution
  skills/
    imp/SKILL.md            ← comando /imp (invoca o implementador)
  agent-context.md          ← contexto comportamental (atualizado pelo agente)

.specify/
  memory/
    constitution.md         ← gerado pelo constitution-manager init
```

E na memória persistente do Claude Code (`~/.claude/projects/.../memory/`):
```
MEMORY.md       ← índice com ponteiro para workflow.md
workflow.md     ← instrução de auto-invocação do implementador
```

---

## Controle de versão dos agentes

Verificar versão local vs remota:
```powershell
wfsdd version
# workflow-sdd
#   local : 1.0.0
#   remote: 1.0.0
```

Atualizar:
```powershell
wfsdd update
```

Para bumpar a versão ao editar os agentes, atualizar `version.txt` na raiz do repositório antes do push.

---

## Estrutura do repositório

```
workflow-sdd/
├── agents/
│   ├── implementador.md
│   ├── task-runner.md
│   └── constitution-manager.md
├── templates/
│   ├── constitution-template.md
│   ├── agent-context-template.md
│   ├── MEMORY-template.md
│   ├── workflow-memory.md
│   └── skills/imp/SKILL.md   ← template do comando /imp
├── setup.bat               ← configuração automática (Windows, duplo clique)
├── setup.ps1               ← configuração PowerShell
├── setup.sh                ← configuração bash
├── init-workflow.ps1       ← instala em um projeto (chamado pelo wfsdd init)
├── init-workflow.sh        ← instala em um projeto (bash)
├── version.txt
└── README.md
```
