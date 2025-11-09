# 📌 Guide de Gestion des Versions - EA Scalping Pro

## 📖 Table des matières

1. [Semantic Versioning](#semantic-versioning)
2. [Scripts de versioning](#scripts-de-versioning)
3. [Convention de commit](#convention-de-commit)
4. [Workflow quotidien](#workflow-quotidien)
5. [Exemples pratiques](#exemples-pratiques)
6. [Fichiers automatiquement mis à jour](#fichiers-automatiquement-mis-à-jour)
7. [Gestion des tags Git](#gestion-des-tags-git)
8. [Troubleshooting](#troubleshooting)

---

## 🔢 Semantic Versioning

Nous utilisons le **Semantic Versioning (SemVer)** : `MAJOR.MINOR.PATCH`

```
Version actuelle: 27.4.0
                  │  │ │
                  │  │ └─── PATCH: Corrections de bugs
                  │  └───── MINOR: Nouvelles fonctionnalités compatibles
                  └──────── MAJOR: Changements incompatibles (breaking changes)
```

### Quand incrémenter ?

| Type | Quand l'utiliser | Exemple |
|------|------------------|---------|
| **MAJOR** | Changements incompatibles (breaking changes) | Changement API, nouveau Magic Number obligatoire |
| **MINOR** | Nouvelles fonctionnalités (compatibles) | Nouveau système de cache, nouvelle stratégie |
| **PATCH** | Corrections de bugs (compatibles) | Fix erreur 10036, correction parsing |

---

## 🛠️ Scripts de versioning

Deux scripts équivalents sont disponibles :

### Linux / Mac / Git Bash (Windows)
```bash
./version-bump.sh [major|minor|patch] "Description du changement"
```

### Windows PowerShell
```powershell
.\version-bump.ps1 -Type [major|minor|patch] -Description "Description"
```

### Installation

```bash
# Linux/Mac : Rendre le script exécutable
chmod +x version-bump.sh

# Windows : Autoriser l'exécution de scripts PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📝 Convention de commit

Préfixez vos descriptions avec ces mots-clés pour catégorisation automatique :

| Préfixe | Type de changement | Icône CHANGELOG |
|---------|-------------------|-----------------|
| `Fix:` ou `fix:` | Correction de bug | 🐛 Correctif |
| `Add:` ou `Feat:` | Nouvelle fonctionnalité | ✨ Nouvelle fonctionnalité |
| `Breaking:` | Changement incompatible | 💥 BREAKING CHANGE |
| `Opt:` ou `Perf:` | Optimisation performance | ⚡ Optimisation |
| `Doc:` | Documentation | 📝 Documentation |
| `Refactor:` | Refactorisation code | ♻️ Refactoring |
| Autre | Divers | 🔧 Divers |

**Exemples de descriptions :**
```
Fix: Correction erreur 10036 Stop Loss invalide
Add: Système de cache pour indicateurs
Breaking: Changement format API news
Opt: Optimisation boucles positions (-40% CPU)
Doc: Ajout guide ONNX complet
Refactor: Simplification ParseNewsJSON
```

---

## 🔄 Workflow quotidien

### 1️⃣ Faire des modifications

Travaillez normalement sur votre code :
```bash
# Modifier EA_MultiPairs_Scalping_Pro.mq5
# Tester les changements
# Compiler (F7) pour vérifier
```

### 2️⃣ Bumper la version

**Après chaque modification significative**, lancez le script :

```bash
# Correction de bug
./version-bump.sh patch "Fix: Correction erreur trailing stop"

# Nouvelle fonctionnalité
./version-bump.sh minor "Add: Support multi-timeframes"

# Changement majeur
./version-bump.sh major "Breaking: Nouveau système de signaux"
```

Le script va automatiquement :
- ✅ Incrémenter la version
- ✅ Mettre à jour VERSION.txt
- ✅ Mettre à jour le header de l'EA
- ✅ Mettre à jour #define CURRENT_VERSION
- ✅ Mettre à jour MagicNumber
- ✅ Mettre à jour dashboard title
- ✅ Ajouter entrée dans CHANGELOG.md
- ✅ Créer un commit Git
- ✅ Créer un tag Git

### 3️⃣ Pousser les changements

```bash
# Pousser le commit
git push origin <nom-branche>

# Pousser le tag
git push origin v27.4.1
```

### 4️⃣ Résultat

Vous obtenez :
```
✅ Version incrémentée : 27.4.0 → 27.4.1
✅ Commit créé : "patch(27.4.1): Fix: Correction erreur..."
✅ Tag créé : v27.4.1
✅ CHANGELOG.md mis à jour automatiquement
✅ MagicNumber mis à jour : 274001
✅ Dashboard affiche : "EA SCALPING v27.4.1"
```

---

## 📚 Exemples pratiques

### Exemple 1 : Correction d'un bug

**Situation** : Vous avez corrigé l'erreur 10036

```bash
# Linux/Mac
./version-bump.sh patch "Fix: Validation distance minimale SL broker"

# Windows
.\version-bump.ps1 -Type patch -Description "Fix: Validation distance minimale SL broker"
```

**Résultat** :
```
Version: 27.4.0 → 27.4.1
MagicNumber: 274000 → 274001
CHANGELOG: 🐛 Correctif
```

### Exemple 2 : Nouvelle fonctionnalité

**Situation** : Vous avez ajouté un système de notifications Telegram

```bash
./version-bump.sh minor "Add: Notifications Telegram pour signaux"
```

**Résultat** :
```
Version: 27.4.1 → 27.5.0
MagicNumber: 274001 → 275000
CHANGELOG: ✨ Nouvelle fonctionnalité
```

### Exemple 3 : Optimisation

**Situation** : Vous avez optimisé la boucle de positions

```bash
./version-bump.sh patch "Opt: Sortie anticipée boucles (-20% CPU)"
```

**Résultat** :
```
Version: 27.5.0 → 27.5.1
MagicNumber: 275000 → 275001
CHANGELOG: ⚡ Optimisation
```

### Exemple 4 : Breaking change

**Situation** : Vous avez changé la structure des paramètres (incompatible)

```bash
./version-bump.sh major "Breaking: Nouveau système paramètres obligatoire"
```

**Résultat** :
```
Version: 27.5.1 → 28.0.0
MagicNumber: 275001 → 280000
CHANGELOG: 💥 BREAKING CHANGE
```

---

## 📄 Fichiers automatiquement mis à jour

Le script met à jour automatiquement ces 7 éléments :

### 1. VERSION.txt
```
27.4.1
```

### 2. EA Header - #property version
```mql5
#property version   "27.4.1"
```

### 3. EA Header - //| VERSION:
```mql5
//| VERSION: 27.4.1                                                   |
```

### 4. EA Header - //| DATE:
```mql5
//| DATE: 2025-11-08                                                |
```

### 5. EA Code - #define CURRENT_VERSION
```mql5
#define CURRENT_VERSION "27.4.1"
```

### 6. EA Code - MagicNumber
```mql5
input int MagicNumber = 274001;  // Magic number v27.4.1
```

**Calcul MagicNumber** : `MAJOR * 10000 + MINOR * 100 + PATCH`
- 27.4.0 → 274000
- 27.4.1 → 274001
- 27.5.0 → 275000
- 28.0.0 → 280000

### 7. EA Code - Dashboard Title
```mql5
ObjectSetString(0, "Dashboard_Title", OBJPROP_TEXT, "EA SCALPING v27.4.1");
```

### 8. CHANGELOG.md
```markdown
## Version 27.4.1 (2025-11-08)

### 🐛 Correctif
- Fix: Validation distance minimale SL broker

---
```

---

## 🏷️ Gestion des tags Git

### Lister les tags
```bash
# Voir tous les tags
git tag

# Voir les tags avec descriptions
git tag -n

# Chercher un tag spécifique
git tag -l "v27.*"
```

### Voir les détails d'un tag
```bash
git show v27.4.1
```

### Pousser un tag
```bash
# Pousser un tag spécifique
git push origin v27.4.1

# Pousser tous les tags
git push origin --tags
```

### Supprimer un tag (si erreur)

```bash
# Supprimer localement
git tag -d v27.4.1

# Supprimer sur le remote (attention !)
git push origin :refs/tags/v27.4.1
```

### Naviguer entre versions
```bash
# Checkout une version spécifique
git checkout v27.4.1

# Voir les différences entre deux versions
git diff v27.4.0 v27.4.1

# Revenir à la dernière version
git checkout main
```

---

## 🔧 Troubleshooting

### Problème 1 : "Permission denied" (Linux/Mac)

**Erreur** :
```
bash: ./version-bump.sh: Permission denied
```

**Solution** :
```bash
chmod +x version-bump.sh
```

### Problème 2 : "Execution Policy" (Windows PowerShell)

**Erreur** :
```
cannot be loaded because running scripts is disabled on this system
```

**Solution** :
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problème 3 : Annuler un bump (AVANT push)

**Situation** : Vous avez fait un bump par erreur

**Solution** :
```bash
# Annuler le dernier commit
git reset --hard HEAD~1

# Supprimer le tag créé
git tag -d v27.4.1
```

### Problème 4 : Annuler un bump (APRÈS push)

**⚠️ Attention** : Plus complexe car déjà sur remote

**Solution** :
```bash
# 1. Créer un nouveau commit qui annule les changements
git revert HEAD

# 2. Bumper vers la version suivante avec les bonnes modifications
./version-bump.sh patch "Fix: Correction version précédente"
```

### Problème 5 : Fichiers non trouvés

**Erreur** :
```
❌ VERSION.txt introuvable
```

**Solution** :
```bash
# Vérifier que vous êtes dans le bon dossier
pwd  # Linux/Mac
cd   # Windows

# Se déplacer dans le dossier du projet
cd /path/to/ea-scalping-pro
```

### Problème 6 : Conflit de version

**Situation** : Le CHANGELOG.md a des conflits

**Solution** :
```bash
# 1. Résoudre les conflits manuellement
nano CHANGELOG.md  # ou éditeur de votre choix

# 2. Ajouter le fichier résolu
git add CHANGELOG.md

# 3. Continuer le bump
git commit --amend
```

---

## 📊 Historique des versions

Pour voir l'historique complet :

```bash
# Voir tous les commits avec leurs tags
git log --oneline --decorate --all

# Voir uniquement les versions (tags)
git tag -l -n1

# Voir le CHANGELOG
cat CHANGELOG.md
```

---

## 🎯 Best Practices

### ✅ À faire

1. **Bumper après chaque modification significative**
   - Ne pas accumuler plusieurs changements avant un bump
   - Permet un historique clair et traçable

2. **Utiliser des descriptions claires**
   ```bash
   ✅ Bon : "Fix: Correction erreur 10036 validation SL broker"
   ❌ Mauvais : "fix bug"
   ```

3. **Tester avant de bumper**
   - Compiler (F7) pour vérifier absence d'erreurs
   - Tester en démo si possible
   - Ensuite bumper la version

4. **Pousser régulièrement**
   ```bash
   # Après chaque bump
   git push origin <branche>
   git push origin v27.4.1
   ```

5. **Documenter les breaking changes**
   ```bash
   ./version-bump.sh major "Breaking: Nouveau format API - migration requise"
   # Puis ajouter des instructions de migration dans le CHANGELOG
   ```

### ❌ À éviter

1. **Ne pas modifier manuellement VERSION.txt**
   - Toujours utiliser le script
   - Assure cohérence entre tous les fichiers

2. **Ne pas oublier de pousser les tags**
   ```bash
   # ❌ Oublier cette commande
   git push origin v27.4.1
   ```

3. **Ne pas bumper pour des WIP (Work In Progress)**
   - Attendre que la fonctionnalité soit complète et testée

4. **Ne pas utiliser PATCH pour nouvelles fonctionnalités**
   - PATCH = bugs seulement
   - Nouvelles features = MINOR

---

## 🚀 Intégration CI/CD (Futur)

Pour automatiser encore plus, possibilité d'intégrer avec GitHub Actions :

```yaml
# .github/workflows/version.yml
name: Auto Version Bump

on:
  push:
    branches: [ main ]

jobs:
  bump:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Bump version
        run: ./version-bump.sh patch "Auto: CI/CD bump"
      - name: Push changes
        run: |
          git push origin main
          git push origin --tags
```

---

## 📞 Support

**Questions ?**
- Consultez ce guide : `VERSIONING.md`
- Voir exemples : Section "Exemples pratiques"
- Problèmes : Section "Troubleshooting"

**Auteur** : fred-selest
**Projet** : EA Scalping Pro
**GitHub** : https://github.com/fred-selest/ea-scalping-pro

---

**Dernière mise à jour** : 2025-11-08
**Version du guide** : 1.0
