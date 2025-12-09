#!/bin/bash
# Fork Setup Helper - Remere's Map Editor Linux Port
# Este script automatiza a criação de um fork limpo com cherry-pick dos commits essenciais

set -e  # Exit on error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuração
UPSTREAM_REPO="https://github.com/opentibiabr/remeres-map-editor.git"
SOURCE_REPO="$(pwd)"
FORK_NAME="remeres-map-editor-linux"
WORKSPACE_DIR="$(dirname $(pwd))"
FORK_DIR="${WORKSPACE_DIR}/${FORK_NAME}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Remere's Map Editor - Linux Fork Setup Helper${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar dependências
echo -e "${YELLOW}[1/7] Verificando dependências...${NC}"
if ! command_exists git; then
    echo -e "${RED}ERRO: git não instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✓ git instalado${NC}"

# Solicitar URL do fork do usuário
echo ""
echo -e "${YELLOW}[2/7] Configuração do fork${NC}"
echo "Antes de continuar, você precisa:"
echo "  1. Acessar: ${UPSTREAM_REPO}"
echo "  2. Clicar em 'Fork' (canto superior direito)"
echo "  3. Criar fork na sua conta GitHub"
echo ""
read -p "Digite a URL do SEU fork (ex: https://github.com/SEU_USER/remeres-map-editor.git): " FORK_URL

if [ -z "$FORK_URL" ]; then
    echo -e "${RED}ERRO: URL do fork não fornecida${NC}"
    exit 1
fi

echo -e "${GREEN}✓ URL do fork: ${FORK_URL}${NC}"

# Criar diretório para o fork
echo ""
echo -e "${YELLOW}[3/7] Clonando fork...${NC}"
if [ -d "$FORK_DIR" ]; then
    echo -e "${RED}AVISO: Diretório ${FORK_DIR} já existe${NC}"
    read -p "Deseja remover e reclonar? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$FORK_DIR"
    else
        echo -e "${RED}Abortado pelo usuário${NC}"
        exit 1
    fi
fi

git clone "$FORK_URL" "$FORK_DIR"
cd "$FORK_DIR"
echo -e "${GREEN}✓ Fork clonado em: ${FORK_DIR}${NC}"

# Configurar remotes
echo ""
echo -e "${YELLOW}[4/7] Configurando remotes...${NC}"
git remote add upstream "$UPSTREAM_REPO"
git remote add source "$SOURCE_REPO"
git fetch source
git fetch upstream
echo -e "${GREEN}✓ Remotes configurados:${NC}"
git remote -v

# Criar branch linux-port
echo ""
echo -e "${YELLOW}[5/7] Criando branch linux-port...${NC}"
git checkout -b linux-port
echo -e "${GREEN}✓ Branch linux-port criada${NC}"

# Cherry-pick commits essenciais
echo ""
echo -e "${YELLOW}[6/7] Aplicando commits essenciais...${NC}"

# Array de commits essenciais (em ordem cronológica)
declare -a ESSENTIAL_COMMITS=(
    "be0f6bd:fix(cmake): define __LINUX__ macro"
    "8054c2a:fix(input): manually toggle checkable menu item"
    "b6dfa96:fix(input): extensive linux input audit"
    "15efe21:fix(rendering): resolve shade black screen"
    "9853adc:perf(linux): v3.9.13 - Critical performance breakthrough"
    "5bfa05f:fix(import): v3.9.15 - Complete ownership audit"
    "99e3005:fix(gtk): resolve invisible button text in all dialogs"
)

# Array de commits opcionais
declare -a OPTIONAL_COMMITS=(
    "b7cb235:perf(gtk): optimize modal popup menu"
    "a392e14:perf(gtk): remove CallAfter overhead"
)

# Função para aplicar commit
apply_commit() {
    local commit_hash=$(echo "$1" | cut -d: -f1)
    local commit_desc=$(echo "$1" | cut -d: -f2-)

    echo -e "  ${BLUE}→${NC} ${commit_desc} (${commit_hash})"

    if git cherry-pick "$commit_hash" 2>/dev/null; then
        echo -e "    ${GREEN}✓ Aplicado${NC}"
        return 0
    else
        echo -e "    ${YELLOW}⚠ Conflito detectado${NC}"
        echo "    Resolva conflitos manualmente e execute:"
        echo "      git cherry-pick --continue"
        echo "    Ou pule este commit:"
        echo "      git cherry-pick --skip"
        return 1
    fi
}

echo -e "${BLUE}Commits essenciais:${NC}"
for commit in "${ESSENTIAL_COMMITS[@]}"; do
    if ! apply_commit "$commit"; then
        echo -e "${RED}ERRO: Falha ao aplicar commit essencial${NC}"
        echo "Resolva conflitos e re-execute o script"
        exit 1
    fi
done

echo ""
read -p "Deseja aplicar commits opcionais (optimizations)? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${BLUE}Commits opcionais:${NC}"
    for commit in "${OPTIONAL_COMMITS[@]}"; do
        apply_commit "$commit" || echo -e "    ${YELLOW}⚠ Pulado (conflito)${NC}"
    done
fi

# Adicionar documentação
echo ""
echo -e "${YELLOW}[7/7] Adicionando documentação...${NC}"

# Copiar estrutura docs/
if [ -d "${SOURCE_REPO}/docs" ]; then
    cp -r "${SOURCE_REPO}/docs" .
    echo -e "  ${GREEN}✓${NC} docs/ copiado"
fi

# Copiar README.md atualizado
if [ -f "${SOURCE_REPO}/README.md" ]; then
    cp "${SOURCE_REPO}/README.md" .
    echo -e "  ${GREEN}✓${NC} README.md atualizado"
fi

# Copiar .gitignore atualizado
if [ -f "${SOURCE_REPO}/.gitignore" ]; then
    cp "${SOURCE_REPO}/.gitignore" .
    echo -e "  ${GREEN}✓${NC} .gitignore atualizado"
fi

# Commit de documentação
git add docs/ README.md .gitignore 2>/dev/null || true
git commit -m "docs: add comprehensive Linux port documentation

- Architecture documentation (event-driven model)
- Linux port audit and technical report
- Development notes and guides
- Updated README focused on Linux port
- Updated .gitignore for temporary files

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" || true

echo -e "${GREEN}✓ Documentação adicionada${NC}"

# Resumo
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Fork setup completo!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Próximos passos:"
echo ""
echo "  1. Revisar mudanças:"
echo "     cd ${FORK_DIR}"
echo "     git log --oneline --graph"
echo ""
echo "  2. Testar build:"
echo "     mkdir build && cd build"
echo "     cmake .."
echo "     cmake --build . -j\$(nproc)"
echo ""
echo "  3. Push para seu fork:"
echo "     git push origin linux-port"
echo ""
echo "  4. (Opcional) Merge em main:"
echo "     git checkout main"
echo "     git merge linux-port --no-ff"
echo "     git push origin main"
echo ""
echo "Diretório do fork: ${FORK_DIR}"
echo ""
