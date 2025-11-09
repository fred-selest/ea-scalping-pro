# ⚡ Guide Rapide - Gestion des Versions

## 🚀 Démarrage en 30 secondes

### Linux / Mac / Git Bash
```bash
# 1. Installer (une seule fois)
chmod +x version-bump.sh

# 2. Utiliser après chaque modification
./version-bump.sh patch "Fix: Description de votre correction"
./version-bump.sh minor "Add: Description de votre nouvelle fonctionnalité"
./version-bump.sh major "Breaking: Description du changement majeur"

# 3. Pousser
git push origin $(git branch --show-current)
git push origin v27.4.1  # Remplacer par votre version
```

### Windows PowerShell
```powershell
# 1. Installer (une seule fois)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. Utiliser après chaque modification
.\version-bump.ps1 -Type patch -Description "Fix: Description"
.\version-bump.ps1 -Type minor -Description "Add: Description"
.\version-bump.ps1 -Type major -Description "Breaking: Description"

# 3. Pousser
git push origin <branche>
git push origin v27.4.1  # Remplacer par votre version
```

---

## 📝 Quand utiliser quoi ?

| Vous avez fait | Type à utiliser | Exemple |
|----------------|-----------------|---------|
| Corrigé un bug | `patch` | `Fix: Correction erreur 10036` |
| Ajouté une fonctionnalité | `minor` | `Add: Support Telegram` |
| Cassé la compatibilité | `major` | `Breaking: Nouveau format API` |

---

## ✅ Ce que fait le script AUTOMATIQUEMENT

- ✅ Incrémente la version (27.4.0 → 27.4.1)
- ✅ Met à jour `VERSION.txt`
- ✅ Met à jour l'en-tête de l'EA
- ✅ Met à jour `MagicNumber` (274000 → 274001)
- ✅ Met à jour le titre du dashboard
- ✅ Ajoute une entrée dans `CHANGELOG.md`
- ✅ Crée un commit Git
- ✅ Crée un tag Git (v27.4.1)

---

## 🎯 Workflow quotidien

```bash
# 1. Modifier votre code
nano EA_MultiPairs_News_Dashboard_v27.mq5

# 2. Compiler et tester (F7 dans MetaEditor)

# 3. Bumper la version
./version-bump.sh patch "Fix: Mon correctif"

# 4. Vérifier
git log -1        # Voir le commit créé
git tag -l        # Voir le tag créé
cat VERSION.txt   # Voir la nouvelle version

# 5. Pousser
git push origin <branche>
git push origin v27.4.1
```

---

## 🆘 Problèmes courants

### "Permission denied" (Linux/Mac)
```bash
chmod +x version-bump.sh
```

### "Execution Policy" (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Annuler un bump (AVANT push)
```bash
git reset --hard HEAD~1
git tag -d v27.4.1
```

---

## 📖 Documentation complète

Pour plus de détails, voir **VERSIONING.md** :
- Convention de commit détaillée
- Exemples pratiques complets
- Troubleshooting avancé
- Best practices

---

**Version actuelle** : Voir `VERSION.txt`
**Dernier tag** : `git describe --tags --abbrev=0`
