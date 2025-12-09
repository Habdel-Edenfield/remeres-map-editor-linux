# 🚀 Plano de Migração - Remere's Map Editor Linux Fork

## 📋 Visão Geral

Este documento descreve o processo completo para migrar as mudanças locais do Linux port para um fork limpo do repositório original `opentibiabr/remeres-map-editor`.

**Objetivo:** Criar um fork limpo e bem estruturado que possa ser usado pela comunidade open source.

**Repositório alvo:** `https://github.com/Habdel-Edenfield/remeres-map-editor-linux`

**Repositório upstream:** `https://github.com/opentibiabr/remeres-map-editor`

---

## 🎯 Estrutura do Plano

### Fase 1: Preparação e Setup Inicial
### Fase 2: Análise e Catalogação de Mudanças
### Fase 3: Criação do Fork Limpo
### Fase 4: Aplicação Modular de Mudanças
### Fase 5: Validação e Testes
### Fase 6: Documentação e Finalização

---

## 📦 FASE 1: Preparação e Setup Inicial

### Task 1.1: Backup do Estado Atual
**Objetivo:** Garantir que temos backup de todas as mudanças locais

**Ações:**
```bash
# 1. Criar branch de backup
cd /home/user/workspace/remeres/canary_vs15
git checkout -b backup-pre-migration-$(date +%Y%m%d)

# 2. Commit todas as mudanças não commitadas
git add -A
git commit -m "backup: estado completo antes da migração"

# 3. Criar patch bundle de todas as mudanças
git format-patch origin/main --stdout > /tmp/remeres-linux-changes.patch

# 4. Verificar que o patch foi criado
ls -lh /tmp/remeres-linux-changes.patch
```

**Validação:**
- [ ] Branch de backup criada
- [ ] Patch bundle criado e verificável
- [ ] Todas as mudanças commitadas

---

### Task 1.2: Análise do Repositório Upstream
**Objetivo:** Entender a estrutura do repositório original

**Ações:**
```bash
# 1. Criar diretório temporário para análise
mkdir -p /tmp/remeres-upstream-analysis
cd /tmp/remeres-upstream-analysis

# 2. Clonar upstream (shallow para análise rápida)
git clone --depth 1 https://github.com/opentibiabr/remeres-map-editor.git upstream

# 3. Analisar estrutura
cd upstream
tree -L 2 -I 'build|.git' > /tmp/upstream-structure.txt
cat /tmp/upstream-structure.txt

# 4. Verificar versão atual
git log --oneline -10
git describe --tags 2>/dev/null || echo "Sem tags"

# 5. Verificar arquivos principais
ls -la source/CMakeLists.txt
head -50 source/CMakeLists.txt
```

**Validação:**
- [ ] Upstream clonado com sucesso
- [ ] Estrutura de diretórios documentada
- [ ] Versão/commit base identificada

---

## 📊 FASE 2: Análise e Catalogação de Mudanças

### Task 2.1: Identificar Commits Essenciais
**Objetivo:** Listar todos os commits que contêm mudanças Linux

**Ações:**
```bash
cd /home/user/workspace/remeres/canary_vs15

# 1. Listar todos os commits desde o inicial
git log --oneline --all > /tmp/all-commits.txt

# 2. Identificar commits por categoria
git log --oneline --grep="linux\|gtk\|cmake\|input\|perf\|fix" > /tmp/linux-commits.txt

# 3. Para cada commit essencial, extrair arquivos modificados
for commit in be0f6bd 8054c2a b6dfa96 15efe21 9853adc 5bfa05f 99e3005; do
    echo "=== Commit $commit ==="
    git show --stat $commit | head -20
    echo ""
done > /tmp/commits-analysis.txt

cat /tmp/commits-analysis.txt
```

**Validação:**
- [ ] Lista completa de commits identificada
- [ ] Arquivos modificados por commit documentados
- [ ] Categorização clara (essencial vs opcional)

---

### Task 2.2: Extrair Mudanças por Arquivo
**Objetivo:** Criar mapeamento arquivo → mudanças

**Ações:**
```bash
cd /home/user/workspace/remeres/canary_vs15

# 1. Listar todos os arquivos modificados
git diff --name-only origin/main HEAD > /tmp/modified-files.txt

# 2. Para cada arquivo, criar diff
mkdir -p /tmp/file-diffs
while IFS= read -r file; do
    if [ -f "$file" ]; then
        git diff origin/main HEAD -- "$file" > "/tmp/file-diffs/$(echo $file | tr '/' '_').diff"
    fi
done < /tmp/modified-files.txt

# 3. Criar índice de mudanças
echo "# Índice de Mudanças por Arquivo" > /tmp/changes-index.txt
for diff in /tmp/file-diffs/*.diff; do
    echo "- $(basename $diff)" >> /tmp/changes-index.txt
done

cat /tmp/changes-index.txt
```

**Validação:**
- [ ] Todos os arquivos modificados identificados
- [ ] Diffs individuais criados
- [ ] Índice de mudanças gerado

---

### Task 2.3: Identificar Dependências entre Commits
**Objetivo:** Entender ordem de aplicação das mudanças

**Ações:**
```bash
cd /home/user/workspace/remeres/canary_vs15

# 1. Criar grafo de dependências
git log --graph --oneline --all -20 > /tmp/commit-graph.txt

# 2. Verificar conflitos potenciais
git log --oneline be0f6bd..HEAD > /tmp/commit-range.txt

# 3. Documentar ordem recomendada
cat << 'EOF' > /tmp/commit-order.txt
Ordem de aplicação recomendada:

1. be0f6bd - CMake __LINUX__ macro (base, sem dependências)
2. 8054c2a - Input toggle fix (depende de __LINUX__)
3. b6dfa96 - Input audit extensivo (depende de 8054c2a)
4. 15efe21 - Rendering shade fix (independente)
5. 9853adc - Performance breakthrough (independente, mas crítico)
6. 5bfa05f - Ownership audit (independente, mas crítico)
7. 99e3005 - GTK3 dialog fix (independente)
8. b7cb235 - Menu cache optimization (opcional, depende de GTK)
9. a392e14 - CallAfter removal (opcional, depende de GTK)
EOF

cat /tmp/commit-order.txt
```

**Validação:**
- [ ] Ordem de aplicação definida
- [ ] Dependências identificadas
- [ ] Conflitos potenciais mapeados

---

## 🔨 FASE 3: Criação do Fork Limpo

### Task 3.1: Resetar Repositório Remoto
**Objetivo:** Limpar o repositório remoto e preparar para fork limpo

**Ações:**
```bash
# ATENÇÃO: Esta task requer acesso ao GitHub
# Opção 1: Via GitHub Web UI
# 1. Ir para https://github.com/Habdel-Edenfield/remeres-map-editor-linux/settings
# 2. Scroll até "Danger Zone"
# 3. "Delete this repository" OU
# 4. "Transfer ownership" para recriar

# Opção 2: Via Git (se tiver acesso direto)
cd /tmp
rm -rf remeres-map-editor-linux
git clone https://github.com/Habdel-Edenfield/remeres-map-editor-linux.git
cd remeres-map-editor-linux

# Backup do que existe (se necessário)
git branch backup-before-reset

# Resetar para estado limpo (se quiser manter histórico)
# OU deletar e recriar via GitHub
```

**Validação:**
- [ ] Repositório remoto resetado ou recriado
- [ ] Estado inicial limpo confirmado

---

### Task 3.2: Clonar e Configurar Fork Limpo
**Objetivo:** Criar clone local do fork limpo com remotes corretos

**Ações:**
```bash
# 1. Criar diretório de trabalho
cd /home/user/workspace/remeres
mkdir -p linux-fork
cd linux-fork

# 2. Clonar fork (ou criar novo se resetado)
git clone https://github.com/Habdel-Edenfield/remeres-map-editor-linux.git .
# OU se recriado:
# git init
# git remote add origin https://github.com/Habdel-Edenfield/remeres-map-editor-linux.git

# 3. Adicionar upstream
git remote add upstream https://github.com/opentibiabr/remeres-map-editor.git

# 4. Adicionar source (repositório local com mudanças)
git remote add source /home/user/workspace/remeres/canary_vs15

# 5. Verificar remotes
git remote -v

# 6. Fetch de todos os remotes
git fetch upstream
git fetch source

# 7. Verificar branches disponíveis
git branch -r
```

**Validação:**
- [ ] Fork clonado com sucesso
- [ ] Remotes configurados (origin, upstream, source)
- [ ] Fetch realizado com sucesso

---

### Task 3.3: Sincronizar com Upstream
**Objetivo:** Garantir que o fork está baseado no upstream mais recente

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork

# 1. Verificar branch main do upstream
git checkout -b main
git fetch upstream

# 2. Identificar commit base do upstream
UPSTREAM_MAIN=$(git ls-remote upstream HEAD | cut -f1)
echo "Upstream main commit: $UPSTREAM_MAIN"

# 3. Resetar main para upstream (se fork estiver vazio/resetado)
git reset --hard upstream/main

# 4. Verificar estado
git log --oneline -5
git status

# 5. Push inicial (se necessário)
# git push -u origin main --force  # CUIDADO: apenas se resetado
```

**Validação:**
- [ ] Branch main sincronizada com upstream
- [ ] Commit base identificado
- [ ] Estado limpo confirmado

---

## 🔧 FASE 4: Aplicação Modular de Mudanças

### Task 4.1: Criar Branch de Trabalho
**Objetivo:** Criar branch dedicada para Linux port

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork

# 1. Criar branch a partir do main limpo
git checkout -b linux-port

# 2. Verificar ponto de partida
git log --oneline -1
git status
```

**Validação:**
- [ ] Branch linux-port criada
- [ ] Baseada no main limpo do upstream

---

### Task 4.2: Aplicar Mudanças do CMake (Módulo 1)
**Objetivo:** Aplicar definição __LINUX__ e configurações CMake

**Commits relacionados:** `be0f6bd`

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Cherry-pick do commit CMake
git cherry-pick be0f6bd

# 2. Se houver conflitos, resolver manualmente
# git status  # verificar conflitos
# # Editar arquivos conflitados
# git add source/CMakeLists.txt
# git cherry-pick --continue

# 3. Verificar mudanças aplicadas
git show HEAD --stat
git diff main..HEAD -- source/CMakeLists.txt
```

**Validação:**
- [ ] Commit aplicado sem conflitos (ou resolvidos)
- [ ] Mudanças em CMakeLists.txt verificadas
- [ ] Build testado (opcional nesta fase)

---

### Task 4.3: Aplicar Correções de Input (Módulo 2)
**Objetivo:** Aplicar correções de input handling para Linux

**Commits relacionados:** `8054c2a`, `b6dfa96`

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Aplicar commit de toggle fix
git cherry-pick 8054c2a

# 2. Aplicar commit de input audit extensivo
git cherry-pick b6dfa96

# 3. Verificar mudanças
git log --oneline -3
git diff main..HEAD -- source/main_menubar.cpp
```

**Validação:**
- [ ] Commits aplicados
- [ ] Mudanças em main_menubar.cpp verificadas
- [ ] Sem conflitos

---

### Task 4.4: Aplicar Correções de Rendering (Módulo 3)
**Objetivo:** Aplicar correções de rendering e shade

**Commits relacionados:** `15efe21`

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Aplicar commit de rendering fix
git cherry-pick 15efe21

# 2. Verificar mudanças
git diff main..HEAD -- source/map_drawer.cpp source/definitions.h
```

**Validação:**
- [ ] Commit aplicado
- [ ] Mudanças verificadas
- [ ] Sem conflitos

---

### Task 4.5: Aplicar Otimizações de Performance (Módulo 4 - CRÍTICO)
**Objetivo:** Aplicar otimizações críticas de performance

**Commits relacionados:** `9853adc`

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Aplicar commit de performance breakthrough
git cherry-pick 9853adc

# 2. Este commit é grande, verificar cuidadosamente
git show --stat 9853adc

# 3. Verificar mudanças aplicadas
git diff main..HEAD -- source/map_drawer.cpp source/map_display.cpp
```

**Validação:**
- [ ] Commit aplicado (pode ter conflitos - resolver cuidadosamente)
- [ ] Mudanças críticas verificadas
- [ ] Arquivos principais modificados corretamente

---

### Task 4.6: Aplicar Correções de Ownership (Módulo 5 - CRÍTICO)
**Objetivo:** Aplicar correções de ownership e crash fixes

**Commits relacionados:** `5bfa05f`

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Aplicar commit de ownership audit
git cherry-pick 5bfa05f

# 2. Verificar mudanças
git diff main..HEAD -- source/editor.cpp
```

**Validação:**
- [ ] Commit aplicado
- [ ] Mudanças em editor.cpp verificadas
- [ ] Sem conflitos

---

### Task 4.7: Aplicar Correções GTK3 (Módulo 6)
**Objetivo:** Aplicar correções de UI para GTK3 dark theme

**Commits relacionados:** `99e3005`, `b7cb235`, `a392e14`

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Aplicar commit principal de GTK3 dialogs
git cherry-pick 99e3005

# 2. Aplicar otimizações opcionais
git cherry-pick b7cb235  # Menu cache
git cherry-pick a392e14  # CallAfter removal

# 3. Verificar mudanças
git diff main..HEAD -- source/common_windows.cpp
```

**Validação:**
- [ ] Commits aplicados
- [ ] Mudanças em common_windows.cpp verificadas
- [ ] Sem conflitos

---

### Task 4.8: Adicionar Configurações e Assets Linux (Módulo 7)
**Objetivo:** Adicionar arquivos específicos do Linux (ícones, .desktop, etc)

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Copiar ícones e assets Linux
cp -r /home/user/workspace/remeres/canary_vs15/icons ./build/icons 2>/dev/null || true
cp /home/user/workspace/remeres/canary_vs15/brushes/icon/rme_icon.xpm ./brushes/icon/ 2>/dev/null || true

# 2. Verificar se CMakeLists.txt já tem configuração de ícones
# (deve ter sido adicionado no módulo 1)

# 3. Adicionar .gitignore atualizado
cp /home/user/workspace/remeres/canary_vs15/.gitignore ./.gitignore

# 4. Commit de assets
git add build/icons brushes/icon/rme_icon.xpm .gitignore
git commit -m "feat(linux): add Linux-specific assets and configuration

- Add icon files in multiple sizes (16-256px)
- Update XPM icon for application
- Update .gitignore for Linux build artifacts"
```

**Validação:**
- [ ] Assets copiados
- [ ] .gitignore atualizado
- [ ] Commit criado

---

## 📚 FASE 5: Documentação

### Task 5.1: Adicionar Documentação Técnica
**Objetivo:** Copiar e adaptar documentação do projeto local

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Copiar estrutura de docs
cp -r /home/user/workspace/remeres/canary_vs15/docs ./

# 2. Atualizar README.md
cp /home/user/workspace/remeres/canary_vs15/README.md ./README.md

# 3. Adicionar CHANGELOG se existir
cp /home/user/workspace/remeres/canary_vs15/CHANGELOG.md ./CHANGELOG.md 2>/dev/null || true

# 4. Commit de documentação
git add docs/ README.md CHANGELOG.md
git commit -m "docs: add comprehensive Linux port documentation

- Architecture documentation (event-driven model)
- Linux port audit and technical report
- Development notes and guides
- Updated README focused on Linux port
- Changelog with version history"
```

**Validação:**
- [ ] Documentação copiada
- [ ] README atualizado
- [ ] Commit criado

---

## ✅ FASE 6: Validação e Testes

### Task 6.1: Build Test
**Objetivo:** Verificar que o projeto compila corretamente

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Criar diretório de build
mkdir -p build && cd build

# 2. Configurar CMake
cmake ..

# 3. Verificar configuração
cmake -L . | grep -i linux

# 4. Build
cmake --build . -j$(nproc)

# 5. Verificar executável
ls -lh canary-map-editor
file canary-map-editor
```

**Validação:**
- [ ] CMake configura sem erros
- [ ] Build completa sem erros
- [ ] Executável gerado corretamente

---

### Task 6.2: Runtime Test Básico
**Objetivo:** Verificar que o editor abre e funciona

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork/build

# 1. Teste de execução básica
./canary-map-editor --version 2>/dev/null || echo "Sem flag --version"

# 2. Teste de abertura (manual - requer GUI)
# ./canary-map-editor
# Verificar:
# - Editor abre sem crash
# - Interface visível
# - Menus funcionam
```

**Validação:**
- [ ] Executável roda sem crash imediato
- [ ] Interface abre corretamente (teste manual)

---

### Task 6.3: Teste de Funcionalidades Críticas
**Objetivo:** Validar funcionalidades críticas do Linux port

**Checklist de Testes:**
```bash
# Criar script de validação
cat > /tmp/test-checklist.txt << 'EOF'
Checklist de Validação:

[ ] Editor abre sem crash
[ ] Map import funciona (File → New → Map → Import)
[ ] Dialogs visíveis em dark theme GTK3
[ ] FPS ~60 Hz visual (verificar com FPS counter se disponível)
[ ] Input lag <100ms (testar zoom com mouse wheel)
[ ] Atalhos de teclado funcionam (Ctrl+N, Ctrl+O, Ctrl+S, Ctrl+Q)
[ ] Menu checkables funcionam (View menu items)
[ ] Show shade funciona (tecla Q ou menu)
[ ] Sem memory leaks (valgrind opcional)
EOF

cat /tmp/test-checklist.txt
```

**Validação:**
- [ ] Checklist executado
- [ ] Funcionalidades críticas validadas
- [ ] Problemas documentados (se houver)

---

## 🚀 FASE 7: Finalização e Push

### Task 7.1: Revisão Final
**Objetivo:** Revisar todas as mudanças antes do push

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Verificar histórico de commits
git log --oneline main..linux-port

# 2. Verificar diff total
git diff --stat main..linux-port

# 3. Verificar que não há arquivos temporários
git status

# 4. Criar resumo de mudanças
git log main..linux-port --format="%h - %s" > /tmp/migration-summary.txt
cat /tmp/migration-summary.txt
```

**Validação:**
- [ ] Histórico de commits limpo
- [ ] Sem arquivos temporários
- [ ] Resumo de mudanças criado

---

### Task 7.2: Push para Repositório Remoto
**Objetivo:** Enviar branch linux-port para o GitHub

**Ações:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# 1. Push da branch
git push -u origin linux-port

# 2. Verificar no GitHub
# Ir para: https://github.com/Habdel-Edenfield/remeres-map-editor-linux
# Verificar branch linux-port
```

**Validação:**
- [ ] Push realizado com sucesso
- [ ] Branch visível no GitHub

---

### Task 7.3: Criar Pull Request (Opcional)
**Objetivo:** Criar PR para mesclar linux-port em main (se desejado)

**Ações:**
```bash
# Via GitHub Web UI:
# 1. Ir para: https://github.com/Habdel-Edenfield/remeres-map-editor-linux
# 2. Clicar em "Compare & pull request"
# 3. Base: main, Compare: linux-port
# 4. Título: "feat: Linux port with performance optimizations (v3.9.15)"
# 5. Descrição: Copiar resumo de mudanças
# 6. Criar PR

# OU mesclar localmente:
cd /home/user/workspace/remeres/linux-fork
git checkout main
git merge linux-port --no-ff -m "feat: Linux port with performance optimizations (v3.9.15)"
git push origin main
```

**Validação:**
- [ ] PR criado OU merge realizado
- [ ] Main atualizado com Linux port

---

## 📋 Resumo Executivo

### Commits Aplicados (9 total)
1. ✅ `be0f6bd` - CMake __LINUX__ macro
2. ✅ `8054c2a` - Input toggle fix
3. ✅ `b6dfa96` - Input audit extensivo
4. ✅ `15efe21` - Rendering shade fix
5. ✅ `9853adc` - Performance breakthrough (CRÍTICO)
6. ✅ `5bfa05f` - Ownership audit (CRÍTICO)
7. ✅ `99e3005` - GTK3 dialog fix
8. ✅ `b7cb235` - Menu cache optimization
9. ✅ `a392e14` - CallAfter removal

### Arquivos Principais Modificados
- `source/CMakeLists.txt` - Configuração Linux
- `source/main_menubar.cpp` - Input handling
- `source/map_drawer.cpp` - Performance optimizations
- `source/map_display.cpp` - Input coalescing
- `source/editor.cpp` - Ownership safety
- `source/common_windows.cpp` - GTK3 dialogs
- `source/definitions.h` - Version bump
- `README.md` - Documentação Linux
- `.gitignore` - Build artifacts
- `docs/` - Documentação técnica completa

### Tempo Estimado
- **Fase 1-2 (Preparação):** 30-60 minutos
- **Fase 3 (Setup Fork):** 15-30 minutos
- **Fase 4 (Aplicação):** 1-2 horas (depende de conflitos)
- **Fase 5 (Documentação):** 15-30 minutos
- **Fase 6 (Validação):** 30-60 minutos
- **Fase 7 (Finalização):** 15 minutos

**Total:** ~3-5 horas

---

## 🔄 Manutenção Futura

### Sincronização com Upstream
```bash
cd /home/user/workspace/remeres/linux-fork
git fetch upstream
git checkout main
git merge upstream/main
git checkout linux-port
git rebase main  # Reaplicar mudanças Linux em cima do novo upstream
```

### Adicionar Novas Mudanças
```bash
# 1. Fazer mudanças no repositório local (canary_vs15)
# 2. Commit
# 3. No fork:
git checkout linux-port
git cherry-pick <commit-hash>
# 4. Testar e push
```

---

## ✅ Checklist Final

- [ ] Fase 1: Backup e análise completos
- [ ] Fase 2: Mudanças catalogadas
- [ ] Fase 3: Fork limpo criado e sincronizado
- [ ] Fase 4: Todos os módulos aplicados
- [ ] Fase 5: Documentação adicionada
- [ ] Fase 6: Build e testes passando
- [ ] Fase 7: Push realizado e PR criado (se desejado)

---

**Data de Criação:** 2025-12-08
**Versão do Plano:** 1.0
**Status:** Pronto para execução
