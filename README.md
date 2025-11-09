# 🤖 EA Multi-Paires Scalping Pro pour MT5

Expert Advisor automatisé pour trading scalping multi-paires avec filtre news ForexFactory, dashboard en temps réel et optimisations performance.

**Version actuelle** : 27.4
**Dernière mise à jour** : 2025-11-08

---

## 📋 Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation)
- [Gestion des versions](#gestion-des-versions)
- [Documentation](#documentation)
- [Support](#support)

---

## ✨ Fonctionnalités

- ✅ Trading multi-symboles (6 paires de devises)
- ✅ Filtre news économiques ForexFactory (temps réel)
- ✅ Trailing Stop et Break-Even automatiques
- ✅ Dashboard visuel en temps réel
- ✅ Système de mise à jour automatique
- ✅ Cache indicateurs (-40% CPU)
- ✅ Validation complète des paramètres
- ✅ Logging avancé avec niveaux de sévérité

---

## 📦 Installation

1. **Télécharger** le fichier `EA_MultiPairs_News_Dashboard_v27.mq5`
2. **Copier** dans le dossier `MQL5/Experts/` de MT5
3. **Compiler** dans MetaEditor (F7)
4. **Glisser** sur un graphique MT5

Pour plus de détails, voir la documentation complète.

---

## 📌 Gestion des versions

Ce projet utilise le **Semantic Versioning** automatique : `MAJOR.MINOR.PATCH`

### ⚡ Utilisation rapide

**Linux / Mac / Git Bash :**
```bash
# Après chaque modification
./version-bump.sh patch "Fix: Description de votre correction"
./version-bump.sh minor "Add: Nouvelle fonctionnalité"
./version-bump.sh major "Breaking: Changement incompatible"

# Pousser les changements
git push origin <branche>
git push origin v27.4.1
```

**Windows PowerShell :**
```powershell
# Après chaque modification
.\version-bump.ps1 -Type patch -Description "Fix: Description"
.\version-bump.ps1 -Type minor -Description "Add: Description"
.\version-bump.ps1 -Type major -Description "Breaking: Description"

# Pousser les changements
git push origin <branche>
git push origin v27.4.1
```

### 📖 Guides de versioning

- **[VERSION_QUICKSTART.md](VERSION_QUICKSTART.md)** - Guide rapide (30 secondes)
- **[VERSIONING.md](VERSIONING.md)** - Documentation complète (conventions, exemples, troubleshooting)

### 🎯 Convention de commit

| Type | Utilisation | Exemple |
|------|-------------|---------|
| `patch` | Correction de bugs | `Fix: Correction erreur 10036` |
| `minor` | Nouvelles fonctionnalités | `Add: Support Telegram` |
| `major` | Changements incompatibles | `Breaking: Nouveau format API` |

### ✅ Ce que fait le script automatiquement

- Incrémente la version (27.4.0 → 27.4.1)
- Met à jour `VERSION.txt`
- Met à jour l'en-tête de l'EA
- Met à jour `MagicNumber` (274000 → 274001)
- Met à jour le titre du dashboard
- Ajoute une entrée dans `CHANGELOG.md`
- Crée un commit Git
- Crée un tag Git (v27.4.1)

---

## 📚 Documentation
