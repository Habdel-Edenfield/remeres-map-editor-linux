#!/bin/bash
# Script auxiliar para migração do Linux port para fork limpo
# Uso: ./migration-helper.sh [comando]

set -e

REPO_LOCAL="/home/user/workspace/remeres/canary_vs15"
REPO_FORK="/home/user/workspace/remeres/linux-fork"
REPO_UPSTREAM="https://github.com/opentibiabr/remeres-map-editor.git"
REPO_ORIGIN="https://github.com/Habdel-Edenfield/remeres-map-editor-linux.git"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Task 1: Backup do estado atual
task_backup() {
    print_header "Task 1.1: Backup do Estado Atual"
    
    cd "$REPO_LOCAL"
    
    # Criar branch de backup
    BACKUP_BRANCH="backup-pre-migration-$(date +%Y%m%d)"
    if git show-ref --verify --quiet refs/heads/$BACKUP_BRANCH; then
        print_warning "Branch $BACKUP_BRANCH já existe, pulando..."
    else
        git checkout -b "$BACKUP_BRANCH"
        print_success "Branch de backup criada: $BACKUP_BRANCH"
    fi
    
    # Commit mudanças não commitadas
    if ! git diff-index --quiet HEAD --; then
        git add -A
        git commit -m "backup: estado completo antes da migração" || true
        print_success "Mudanças não commitadas salvas"
    else
        print_success "Nenhuma mudança não commitada"
    fi
    
    # Criar patch bundle
    PATCH_FILE="/tmp/remeres-linux-changes-$(date +%Y%m%d).patch"
    git format-patch origin/main --stdout > "$PATCH_FILE" 2>/dev/null || \
        git format-patch HEAD~20 --stdout > "$PATCH_FILE" 2>/dev/null || true
    
    if [ -f "$PATCH_FILE" ] && [ -s "$PATCH_FILE" ]; then
        print_success "Patch bundle criado: $PATCH_FILE ($(du -h $PATCH_FILE | cut -f1))"
    else
        print_warning "Não foi possível criar patch bundle completo"
    fi
}

# Task 2: Analisar mudanças
task_analyze() {
    print_header "Task 2: Análise de Mudanças"
    
    cd "$REPO_LOCAL"
    
    # Listar commits essenciais
    echo -e "\n${BLUE}Commits Essenciais:${NC}"
    ESSENTIAL_COMMITS=("be0f6bd" "8054c2a" "b6dfa96" "15efe21" "9853adc" "5bfa05f" "99e3005" "b7cb235" "a392e14")
    
    for commit in "${ESSENTIAL_COMMITS[@]}"; do
        if git cat-file -e "$commit" 2>/dev/null; then
            MSG=$(git log -1 --format="%s" "$commit" 2>/dev/null)
            print_success "$commit - $MSG"
        else
            print_error "$commit - Commit não encontrado"
        fi
    done
    
    # Listar arquivos modificados
    echo -e "\n${BLUE}Arquivos Modificados:${NC}"
    git diff --name-only HEAD origin/main 2>/dev/null || \
        git diff --name-only HEAD HEAD~20 2>/dev/null | head -20
    
    # Criar análise de commits
    ANALYSIS_FILE="/tmp/commits-analysis-$(date +%Y%m%d).txt"
    echo "# Análise de Commits Linux Port" > "$ANALYSIS_FILE"
    echo "Data: $(date)" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
    
    for commit in "${ESSENTIAL_COMMITS[@]}"; do
        if git cat-file -e "$commit" 2>/dev/null; then
            echo "=== Commit $commit ===" >> "$ANALYSIS_FILE"
            git show --stat "$commit" | head -20 >> "$ANALYSIS_FILE"
            echo "" >> "$ANALYSIS_FILE"
        fi
    done
    
    print_success "Análise salva em: $ANALYSIS_FILE"
}

# Task 3: Setup do fork
task_setup_fork() {
    print_header "Task 3: Setup do Fork Limpo"
    
    # Criar diretório se não existir
    if [ ! -d "$REPO_FORK" ]; then
        mkdir -p "$(dirname $REPO_FORK)"
        cd "$(dirname $REPO_FORK)"
        
        # Tentar clonar fork existente
        if git clone "$REPO_ORIGIN" "$(basename $REPO_FORK)" 2>/dev/null; then
            print_success "Fork clonado de $REPO_ORIGIN"
        else
            print_warning "Fork não existe ou não é acessível. Criando novo..."
            git init "$(basename $REPO_FORK)"
            cd "$REPO_FORK"
            git remote add origin "$REPO_ORIGIN"
        fi
    fi
    
    cd "$REPO_FORK"
    
    # Adicionar remotes
    if ! git remote | grep -q upstream; then
        git remote add upstream "$REPO_UPSTREAM"
        print_success "Remote 'upstream' adicionado"
    fi
    
    if ! git remote | grep -q source; then
        git remote add source "$REPO_LOCAL"
        print_success "Remote 'source' adicionado"
    fi
    
    # Fetch
    print_header "Fetching remotes..."
    git fetch upstream 2>/dev/null || print_warning "Não foi possível fazer fetch do upstream"
    git fetch source 2>/dev/null || print_warning "Não foi possível fazer fetch do source"
    
    # Verificar remotes
    echo -e "\n${BLUE}Remotes configurados:${NC}"
    git remote -v
}

# Task 4: Aplicar mudanças
task_apply_changes() {
    print_header "Task 4: Aplicar Mudanças"
    
    cd "$REPO_FORK"
    
    # Verificar se estamos na branch correta
    if ! git branch --show-current | grep -q "linux-port"; then
        if git show-ref --verify --quiet refs/heads/linux-port; then
            git checkout linux-port
        else
            git checkout -b linux-port
            print_success "Branch linux-port criada"
        fi
    fi
    
    # Commits em ordem
    COMMITS=("be0f6bd" "8054c2a" "b6dfa96" "15efe21" "9853adc" "5bfa05f" "99e3005" "b7cb235" "a392e14")
    
    echo -e "\n${BLUE}Aplicando commits...${NC}\n"
    
    for commit in "${COMMITS[@]}"; do
        echo -e "${YELLOW}Aplicando $commit...${NC}"
        
        if git cherry-pick "$commit" 2>/dev/null; then
            print_success "Commit $commit aplicado"
        else
            print_error "Conflito ao aplicar $commit"
            echo -e "${YELLOW}Resolva os conflitos manualmente e execute:${NC}"
            echo "  git cherry-pick --continue"
            echo ""
            echo -e "${YELLOW}Ou pule este commit:${NC}"
            echo "  git cherry-pick --skip"
            read -p "Pressione Enter para continuar..."
        fi
    done
    
    echo -e "\n${GREEN}Resumo de commits aplicados:${NC}"
    git log --oneline main..linux-port 2>/dev/null || git log --oneline -10
}

# Task 5: Build test
task_build_test() {
    print_header "Task 6: Build Test"
    
    cd "$REPO_FORK"
    
    if [ ! -d "build" ]; then
        mkdir build
    fi
    
    cd build
    
    echo -e "${BLUE}Configurando CMake...${NC}"
    cmake .. || {
        print_error "CMake falhou"
        return 1
    }
    
    echo -e "\n${BLUE}Verificando configuração Linux...${NC}"
    cmake -L . | grep -i linux || print_warning "Macro __LINUX__ não encontrada na configuração"
    
    echo -e "\n${BLUE}Compilando...${NC}"
    cmake --build . -j$(nproc) || {
        print_error "Build falhou"
        return 1
    }
    
    if [ -f "canary-map-editor" ]; then
        print_success "Build completo! Executável: $(pwd)/canary-map-editor"
        file canary-map-editor
    else
        print_error "Executável não encontrado"
        return 1
    fi
}

# Menu principal
show_menu() {
    echo -e "\n${BLUE}=== Migration Helper ===${NC}\n"
    echo "1. Backup do estado atual"
    echo "2. Analisar mudanças"
    echo "3. Setup do fork limpo"
    echo "4. Aplicar mudanças (cherry-pick)"
    echo "5. Build test"
    echo "6. Executar todas as tasks (1-5)"
    echo "0. Sair"
    echo ""
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1) task_backup ;;
        2) task_analyze ;;
        3) task_setup_fork ;;
        4) task_apply_changes ;;
        5) task_build_test ;;
        6) 
            task_backup
            task_analyze
            task_setup_fork
            task_apply_changes
            task_build_test
            ;;
        0) exit 0 ;;
        *) print_error "Opção inválida" ;;
    esac
}

# Main
if [ $# -eq 0 ]; then
    show_menu
else
    case "$1" in
        backup) task_backup ;;
        analyze) task_analyze ;;
        setup) task_setup_fork ;;
        apply) task_apply_changes ;;
        build) task_build_test ;;
        all) 
            task_backup
            task_analyze
            task_setup_fork
            task_apply_changes
            task_build_test
            ;;
        *) 
            echo "Uso: $0 [backup|analyze|setup|apply|build|all]"
            exit 1
            ;;
    esac
fi
