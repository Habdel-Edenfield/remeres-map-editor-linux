# Estratégia de Fork Limpo - Remere's Map Editor Linux

## Objetivo
Criar fork limpo do upstream oficial aplicando apenas mudanças essenciais do Linux port.

---

## 📋 Análise de Commits

### ✅ COMMITS ESSENCIAIS (Core Functionality)

Estes commits são **obrigatórios** - contêm as mudanças críticas do port Linux:

#### Performance Crítica
1. **9853adc** - `perf(linux): v3.9.13 - Critical performance breakthrough`
   - Z-axis occlusion culling (-87% overdraw)
   - Input coalescing (zoom lag 8s → <100ms)
   - **IMPACTO:** +567% FPS, editor utilizável
   - **ARQUIVOS:** map_drawer.cpp, map_display.cpp/h, application.cpp, definitions.h

2. **5bfa05f** - `fix(import): v3.9.15 - Complete ownership audit and crash fixes`
   - Ownership transfer protocol (nullptr após transfer)
   - GTK modal deadlock fix (ProgressBar sequencing)
   - Memory leak fixes (IMPORT_DONT)
   - **IMPACTO:** 0% crash rate em map import
   - **ARQUIVOS:** editor.cpp

#### Input Handling
3. **be0f6bd** - `fix(cmake): define __LINUX__ macro`
   - Habilita accelerator table nativo
   - **ARQUIVOS:** CMakeLists.txt

4. **8054c2a** - `fix(input): manually toggle checkable menu item`
   - Corrige tecla 'A' Autoborder
   - **ARQUIVOS:** main_menubar.cpp

5. **b6dfa96** - `fix(input): extensive linux input audit`
   - Adiciona Ctrl+N/O/S/Q
   - Toggle manual para View menu checkables
   - **ARQUIVOS:** main_menubar.cpp

#### UI/GTK3
6. **99e3005** - `fix(gtk): resolve invisible button text in all dialogs`
   - wxStdDialogButtonSizer para 7 dialogs
   - **IMPACTO:** 100% dialogs visíveis em dark themes
   - **ARQUIVOS:** common_windows.cpp

#### Rendering
7. **15efe21** - `fix(rendering): resolve shade black screen (GL_BLEND)`
   - Corrige show shade rendering
   - Remove conflito 'Q' shortcut
   - **ARQUIVOS:** definitions.h, main_menubar.cpp, map_drawer.cpp

---

### ⚙️ COMMITS OPCIONAIS (Optimizations)

Estes commits são **opcionais** - melhorias incrementais:

8. **85dff41** - `fix(gtk): ensure dialog button visibility` (primeira tentativa)
   - Substituído por commit 99e3005 (mais completo)
   - **RECOMENDAÇÃO:** SKIP (redundante)

9. **b7cb235** - `perf(gtk): optimize modal popup menu with caching`
   - Cache de posição para popup menu
   - Ganho: ~10-20ms
   - **RECOMENDAÇÃO:** INCLUIR (nice-to-have)

10. **a392e14** - `perf(gtk): remove CallAfter overhead`
    - Remove CallAfter() em menu click-through
    - Ganho: ~50-200ms
    - **RECOMENDAÇÃO:** INCLUIR (nice-to-have)

---

### 🗑️ COMMITS HOUSEKEEPING (Não incluir)

11. **a148f3b** - `chore: bump version to 3.9.0`
    - Apenas mudança de versão
    - **RECOMENDAÇÃO:** SKIP (será substituído)

12. **20b0a62** - `chore: add binary to .gitignore`
13. **3d14321** - `chore: untrack binary`
    - Ajustes de .gitignore
    - **RECOMENDAÇÃO:** CONSOLIDAR em commit único no fork

---

## 🎯 Plano de Execução

### Fase 1: Criar Fork Limpo

```bash
# 1. No GitHub: Fork de opentibiabr/remeres-map-editor
#    Nome sugerido: remeres-map-editor-linux

# 2. Clone do fork
cd ~/workspace/remeres/
git clone https://github.com/[SEU_USER]/remeres-map-editor-linux.git
cd remeres-map-editor-linux

# 3. Adicionar remotes
git remote add upstream https://github.com/opentibiabr/remeres-map-editor.git
git remote add source ~/workspace/remeres/canary_vs15

# 4. Fetch do source
git fetch source
```

### Fase 2: Cherry-Pick Commits Essenciais

```bash
# Branch para Linux port
git checkout -b linux-port

# Cherry-pick commits essenciais (em ordem)
git cherry-pick be0f6bd  # CMake __LINUX__ macro
git cherry-pick 8054c2a  # Input toggle fix
git cherry-pick b6dfa96  # Input audit
git cherry-pick 15efe21  # Rendering shade fix
git cherry-pick 9853adc  # CRITICAL: Performance breakthrough
git cherry-pick 5bfa05f  # CRITICAL: Ownership audit
git cherry-pick 99e3005  # GTK3 dialog fix

# Opcionais (nice-to-have)
git cherry-pick b7cb235  # Menu cache optimization
git cherry-pick a392e14  # CallAfter removal
```

### Fase 3: Adicionar Documentação

```bash
# Copiar estrutura docs/ organizada
cp -r ../canary_vs15/docs .

# Copiar README.md atualizado
cp ../canary_vs15/README.md .

# Copiar .gitignore atualizado
cp ../canary_vs15/.gitignore .

# Commit de organização
git add docs/ README.md .gitignore
git commit -m "docs: add comprehensive Linux port documentation

- Architecture documentation (event-driven model)
- Linux port audit and technical report
- Development notes and guides
- Updated README focused on Linux port
- Updated .gitignore for temporary files"
```

### Fase 4: Limpeza Final

```bash
# Remover binários Windows (se existirem no upstream)
git rm -f *.dll *.exe *.pdb 2>/dev/null || true

# Commit de limpeza (se necessário)
git commit -m "chore: remove Windows binaries (Linux-focused fork)"
```

### Fase 5: Push para Fork

```bash
# Push da branch
git push origin linux-port

# Criar PR no fork (se quiser mesclar em main)
# OU: Mesclar localmente
git checkout main
git merge linux-port --no-ff -m "feat: Linux port with performance optimizations (v3.9.15)"
git push origin main
```

---

## 📊 Resumo de Mudanças

**Commits incluídos:** 9 (7 essenciais + 2 opcionais)
**Commits skipped:** 4 (redundantes ou housekeeping)

**Arquivos modificados:**
- source/map_drawer.cpp (occlusion culling)
- source/map_display.cpp/h (input coalescing)
- source/editor.cpp (ownership safety)
- source/main_menubar.cpp (input handling)
- source/common_windows.cpp (GTK3 dialogs)
- source/CMakeLists.txt (__LINUX__ macro)
- source/definitions.h (version bump)
- docs/ (nova estrutura completa)
- README.md (foco Linux)
- .gitignore (temporários)

**Tamanho estimado:** ~100KB code + 2MB docs

---

## ✅ Validação

Após aplicar mudanças, validar:

```bash
# Build test
mkdir build && cd build
cmake ..
cmake --build . -j$(nproc)

# Run test
./canary-map-editor
```

**Checklist:**
- [ ] Compila sem erros
- [ ] Editor abre sem crash
- [ ] Map import funciona (File → New → Map → Import)
- [ ] Dialogs visíveis em dark theme
- [ ] FPS ~60 Hz visual
- [ ] Input lag <100ms

---

## 🔄 Sync com Upstream (Futuro)

Para manter fork atualizado:

```bash
# Fetch upstream
git fetch upstream

# Merge upstream/main em seu main
git checkout main
git merge upstream/main

# Rebase linux-port em cima do main atualizado
git checkout linux-port
git rebase main

# Resolver conflitos (se houver)
# Push force (branch rebased)
git push origin linux-port --force-with-lease
```

---

## 📝 Notas

- **Inicial commit upstream:** Verificar qual commit usar como base (provavelmente HEAD do upstream)
- **Tags de versão:** Considerar criar tag `v3.9.15-linux` após merge
- **Branch strategy:** Manter `main` sincronizado com upstream, `linux-port` para mudanças Linux
- **PR upstream:** Se quiser contribuir de volta, criar PR do linux-port → upstream main

---

**Data:** 2025-12-08
**Versão Linux Port:** v3.9.15
**Status:** Ready for execution
