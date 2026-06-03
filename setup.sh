#!/usr/bin/env bash
# setup.sh — configura o comando wfsdd no shell (bash/zsh)
set -e

WORKFLOW_REPO="$(cd "$(dirname "$0")" && pwd)"

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
echo "    Abra um novo terminal ou rode: source $PROFILE"
echo "    Depois use: wfsdd init (na raiz de um projeto)"
