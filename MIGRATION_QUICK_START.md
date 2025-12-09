# 🚀 Quick Start - Migração Linux Port

## Resumo Rápido

Este é um guia rápido para executar a migração. Para detalhes completos, veja [MIGRATION_PLAN.md](./MIGRATION_PLAN.md).

---

## ⚡ Execução Rápida (3-5 horas)

### Pré-requisitos
- Git configurado
- Acesso ao GitHub (repositório `Habdel-Edenfield/remeres-map-editor-linux`)
- CMake e dependências de build instaladas

---

## 📋 Passos Principais

### 1️⃣ Backup e Análise (30 min)
```bash
cd /home/user/workspace/remeres/canary_vs15
./migration-helper.sh backup
./migration-helper.sh analyze
```

**O que faz:**
- Cria backup do estado atual
- Analisa commits e mudanças
- Gera relatórios em `/tmp/`

---

### 2️⃣ Setup do Fork (15 min)
```bash
./migration-helper.sh setup
```

**O que faz:**
- Cria/clona fork limpo
- Configura remotes (origin, upstream, source)
- Sincroniza com upstream

**Manual (se necessário):**
```bash
cd /home/user/workspace/remeres
mkdir -p linux-fork && cd linux-fork
git clone https://github.com/Habdel-Edenfield/remeres-map-editor-linux.git .
git remote add upstream https://github.com/opentibiabr/remeres-map-editor.git
git remote add source /home/user/workspace/remeres/canary_vs15
git fetch upstream
git checkout -b main
git reset --hard upstream/main
```

---

### 3️⃣ Aplicar Mudanças (1-2 horas)
```bash
./migration-helper.sh apply
```

**O que faz:**
- Cria branch `linux-port`
- Aplica 9 commits essenciais via cherry-pick
- Pode requerer resolução manual de conflitos

**Commits aplicados (em ordem):**
1. `be0f6bd` - CMake __LINUX__ macro
2. `8054c2a` - Input toggle fix
3. `b6dfa96` - Input audit extensivo
4. `15efe21` - Rendering shade fix
5. `9853adc` - **Performance breakthrough (CRÍTICO)**
6. `5bfa05f` - **Ownership audit (CRÍTICO)**
7. `99e3005` - GTK3 dialog fix
8. `b7cb235` - Menu cache optimization
9. `a392e14` - CallAfter removal

**Se houver conflitos:**
```bash
cd /home/user/workspace/remeres/linux-fork
git status  # Ver arquivos conflitados
# Editar arquivos, resolver conflitos
git add <arquivos-resolvidos>
git cherry-pick --continue
```

---

### 4️⃣ Adicionar Assets e Documentação (30 min)

**Assets Linux:**
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# Copiar ícones
cp -r /home/user/workspace/remeres/canary_vs15/icons ./build/icons 2>/dev/null || true
cp /home/user/workspace/remeres/canary_vs15/brushes/icon/rme_icon.xpm ./brushes/icon/ 2>/dev/null || true

# Atualizar .gitignore
cp /home/user/workspace/remeres/canary_vs15/.gitignore ./.gitignore

git add build/icons brushes/icon/rme_icon.xpm .gitignore
git commit -m "feat(linux): add Linux-specific assets and configuration"
```

**Documentação:**
```bash
# Copiar docs
cp -r /home/user/workspace/remeres/canary_vs15/docs ./
cp /home/user/workspace/remeres/canary_vs15/README.md ./README.md
cp /home/user/workspace/remeres/canary_vs15/CHANGELOG.md ./CHANGELOG.md 2>/dev/null || true

git add docs/ README.md CHANGELOG.md
git commit -m "docs: add comprehensive Linux port documentation"
```

---

### 5️⃣ Build e Teste (30 min)
```bash
./migration-helper.sh build
```

**Manual:**
```bash
cd /home/user/workspace/remeres/linux-fork/build
cmake ..
cmake --build . -j$(nproc)
./canary-map-editor  # Teste manual
```

**Checklist de Validação:**
- [ ] Compila sem erros
- [ ] Editor abre sem crash
- [ ] Map import funciona
- [ ] Dialogs visíveis em dark theme
- [ ] FPS ~60 Hz
- [ ] Input lag <100ms

---

### 6️⃣ Push e Finalização (15 min)
```bash
cd /home/user/workspace/remeres/linux-fork
git checkout linux-port

# Revisar mudanças
git log --oneline main..linux-port
git diff --stat main..linux-port

# Push
git push -u origin linux-port
```

**Criar PR (opcional):**
- Via GitHub Web UI: Compare `linux-port` → `main`
- OU mesclar localmente:
```bash
git checkout main
git merge linux-port --no-ff -m "feat: Linux port with performance optimizations (v3.9.15)"
git push origin main
```

---

## 🎯 Resumo Visual

```
┌─────────────────────────────────────────┐
│  Repositório Local (canary_vs15)       │
│  └─ Commits Linux Port (9 commits)     │
└─────────────────────────────────────────┘
                    │
                    │ cherry-pick
                    ▼
┌─────────────────────────────────────────┐
│  Fork Limpo (linux-fork)                │
│  ├─ main (upstream)                     │
│  └─ linux-port (com mudanças Linux)     │
└─────────────────────────────────────────┘
                    │
                    │ push
                    ▼
┌─────────────────────────────────────────┐
│  GitHub (Habdel-Edenfield/...)          │
│  └─ Branch linux-port                   │
└─────────────────────────────────────────┘
```

---

## 🔧 Comandos Úteis

### Ver status da migração
```bash
cd /home/user/workspace/remeres/linux-fork
git log --oneline main..linux-port
git diff --stat main..linux-port
```

### Reverter commit problemático
```bash
git cherry-pick --abort  # Abortar cherry-pick atual
git reset --hard HEAD~1   # Reverter último commit
```

### Sincronizar com upstream (futuro)
```bash
git fetch upstream
git checkout main
git merge upstream/main
git checkout linux-port
git rebase main
```

---

## ⚠️ Troubleshooting

### Erro: "Commit não encontrado"
- Verificar se commit existe: `git show <commit-hash>`
- Pode ser que commit tenha hash diferente no fork
- Usar `git log --all --grep="mensagem"` para encontrar

### Erro: "Conflitos no cherry-pick"
- Normal em alguns commits
- Resolver manualmente editando arquivos
- `git add` após resolver
- `git cherry-pick --continue`

### Erro: "Build falha"
- Verificar dependências: `cmake ..` deve mostrar erros
- Verificar se `__LINUX__` está definido
- Comparar CMakeLists.txt com versão local

### Erro: "Push rejeitado"
- Fork pode ter mudanças remotas
- `git pull --rebase origin linux-port` primeiro
- OU `git push --force-with-lease` (cuidado!)

---

## ✅ Checklist Final

- [ ] Backup criado
- [ ] Fork limpo configurado
- [ ] Todos os 9 commits aplicados
- [ ] Assets Linux adicionados
- [ ] Documentação copiada
- [ ] Build passa
- [ ] Testes básicos OK
- [ ] Push realizado
- [ ] PR criado (ou merge em main)

---

## 📚 Documentação Completa

- **Plano Detalhado:** [MIGRATION_PLAN.md](./MIGRATION_PLAN.md)
- **Estratégia de Fork:** [FORK_STRATEGY.md](./FORK_STRATEGY.md)
- **Script Helper:** `./migration-helper.sh`

---

**Tempo Total Estimado:** 3-5 horas
**Dificuldade:** Média (pode requerer resolução manual de conflitos)
**Status:** Pronto para execução
