#!/usr/bin/env bash
# setup.sh — configura o comando wfsdd no shell (bash/zsh)
# Pode ser rodado com "bash setup.sh" ou "source setup.sh" (recomendado — ver final do script).

# "$0" nao e confiavel quando o script e "sourced" (vira o nome do shell pai, nao o path
# do arquivo). BASH_SOURCE[0] funciona nos dois casos em bash; zsh usa $0 dentro de source.
if [ -n "$BASH_SOURCE" ]; then
    SETUP_SRC="${BASH_SOURCE[0]}"
else
    SETUP_SRC="$0"
fi
WORKFLOW_REPO="$(cd "$(dirname "$SETUP_SRC")" && pwd)"

echo "==> Configurando workflow-sdd"
echo "    Repositorio: $WORKFLOW_REPO"

# Detectar shell e arquivo de perfil
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
    PROFILE="$HOME/.zshrc"
else
    PROFILE="$HOME/.bashrc"
fi

echo "    Perfil: $PROFILE"

# Verificar se wfsdd ja esta no perfil
if grep -q "function wfsdd" "$PROFILE" 2>/dev/null; then
    # Atualizar caminho do repo
    sed -i "s|WFSDD_REPO=.*|WFSDD_REPO=\"$WORKFLOW_REPO\"|" "$PROFILE"
    echo "    [--] wfsdd ja configurado — caminho atualizado se necessario"
else
    cat >> "$PROFILE" << EOF

# workflow-sdd — gerencia o workflow SDD
# Uso: wfsdd <init|update|version>
WFSDD_REPO="$WORKFLOW_REPO"
function wfsdd() {
    local cmd="\${1:-help}"
    local repo="\$WFSDD_REPO"

    if [ "\$cmd" = "init" ]; then
        bash "\$repo/init-workflow.sh"

    elif [ "\$cmd" = "update" ]; then
        echo "==> Atualizando workflow-sdd..."
        pushd "\$repo" > /dev/null
        git pull origin master
        popd > /dev/null
        bash "\$repo/init-workflow.sh"

    elif [ "\$cmd" = "version" ]; then
        local_ver=\$(cat "\$repo/version.txt" 2>/dev/null | tr -d '[:space:]' || echo "desconhecida")
        remote_ver=\$(curl -sf --max-time 5 "https://raw.githubusercontent.com/figueiredoalfs/workflow-sdd/master/version.txt" | tr -d '[:space:]' || echo "sem conexao")
        echo "workflow-sdd"
        echo "  local : \$local_ver"
        echo "  remote: \$remote_ver"
        if [ "\$local_ver" != "\$remote_ver" ] && [ "\$remote_ver" != "sem conexao" ]; then
            echo "  [!] Atualizacao disponivel -- rode: wfsdd update"
        fi

    else
        echo "Uso:"
        echo "  wfsdd init     -- instala o workflow no projeto atual"
        echo "  wfsdd update   -- atualiza o repositorio e reinstala"
        echo "  wfsdd version  -- exibe versao local e remota"
    fi
}
EOF
    echo "    [OK] Funcao wfsdd adicionada a: $PROFILE"
fi

echo ""
echo "==> Configuracao concluida."

# Se o setup foi rodado de dentro de um projeto-alvo (nao do proprio repo workflow-sdd),
# instalar o workflow (agentes, skills e /imp) direto nesse projeto.
CURRENT_DIR="$(pwd)"
if [ "$CURRENT_DIR" != "$WORKFLOW_REPO" ]; then
    echo "    Instalando workflow no projeto atual: $CURRENT_DIR"
    bash "$WORKFLOW_REPO/init-workflow.sh"
fi

# Carregar a funcao wfsdd na sessao atual, se o script foi "sourced" (nao executado
# como subprocesso). Rodar via "bash setup.sh" nao propaga a funcao para o shell pai —
# isso e uma limitacao do bash, nao um bug: use "source setup.sh" para evitar o passo extra.
if (return 0 2>/dev/null); then
    source "$PROFILE"
    echo "    [OK] wfsdd disponivel nesta sessao (script foi 'sourced')"
else
    echo "    [!] Rode 'source $PROFILE' (ou abra um novo terminal) para usar wfsdd agora"
    echo "        Dica: da proxima vez rode 'source setup.sh' em vez de 'bash setup.sh'"
    echo "        para que wfsdd fique disponivel na sessao atual automaticamente"
fi
