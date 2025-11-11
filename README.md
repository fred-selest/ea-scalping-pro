#  EA Multi-Paires Scalping Pro pour MT5

Expert Advisor automatisé pour trading scalping multi-paires avec filtre news ForexFactory, dashboard en temps réel, sécurité renforcée et optimisations performance.

**Version actuelle** : 27.56
**Dernière mise à jour** : 2025-11-11

---

## 📋 Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation)
- [Configurations de Risque](#configurations-de-risque)
- [Gestion des versions](#gestion-des-versions)
- [Documentation](#documentation)
- [Tests](#tests)
- [CI/CD](#cicd)
- [Support](#support)

---

## ✨ Fonctionnalités

### Trading
- ✅ Trading multi-symboles (6 paires de devises)
- ✅ Filtre news économiques ForexFactory (temps réel)
- ✅ Trailing Stop et Break-Even automatiques
- ✅ 3 profils de risque préconfigurés (Conservateur/Modéré/Agressif)

### Interface
- ✅ Dashboard visuel en temps réel (positionné à droite)
- ✅ Affichage positions, profit, statistiques
- ✅ Indicateurs news et mises à jour

### Performances
- ✅ Cache indicateurs (-40% CPU)
- ✅ Early exit optimization
- ✅ Code refactoré (0 warnings compilation)
- ✅ Réduction 70% duplication code

### Sécurité & Qualité
- ✅ Système de mise à jour automatique avec vérification SHA256
- ✅ Rollback automatique en cas d'échec
- ✅ Validation complète des paramètres
- ✅ Logging avancé avec niveaux de sévérité
- ✅ Tests unitaires et CI/CD GitHub Actions

---

## 📦 Installation

### Installation Standard

1. **Télécharger** le fichier `EA_MultiPairs_Scalping_Pro.mq5`
2. **Copier** dans le dossier `MQL5/Experts/` de MT5
3. **Compiler** dans MetaEditor (F7)
4. **Glisser** sur un graphique MT5

### Installation avec Configuration de Risque

1. **Télécharger** l'EA + configuration souhaitée :
   - `configs/EA_Scalping_Conservative.set` (Débutants, risque faible)
   - `configs/EA_Scalping_Moderate.set` (Intermédiaires, risque moyen)
   - `configs/EA_Scalping_Aggressive.set` (Experts, risque élevé)

2. **Copier** fichier `.set` dans :
   ```
   C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Presets\
   ```

3. **Charger** configuration :
   - Glisser EA sur graphique
   - Onglet "Paramètres d'entrée"
   - Bouton "Charger"
   - Sélectionner fichier `.set`

📖 **Guide complet :** [configs/README.md](configs/README.md)

---

## ⚙️ Configurations de Risque

| Configuration | Risque | Capital Min | Profit/Mois | Drawdown | Profil |
|---------------|--------|-------------|-------------|----------|--------|
| 🟢 **Conservative** | 0.3% | 1000$ | 3-8% | 5-10% | Débutants |
| 🟡 **Moderate** | 0.5% | 2000$ | 8-15% | 10-15% | Intermédiaires |
| 🔴 **Aggressive** | 1.0% | 5000$ | 15-30% | 20-30% | Experts |

### 🟢 Conservative
- 2 paires actives (EURUSD, GBPUSD)
- TP/SL: 10/20 pips (ratio 1:2)
- Max 2 positions, 15 trades/jour
- Filtrage news strict

### 🟡 Moderate (Recommandé)
- 4 paires actives (majors)
- TP/SL: 8/15 pips (ratio ~1:1.9)
- Max 5 positions, 50 trades/jour
- Filtrage news modéré

### 🔴 Aggressive
- 6 paires actives (toutes)
- TP/SL: 6/12 pips (ratio 1:2)
- Max 10 positions, 100 trades/jour
- Filtrage news léger
- ⚠️ VPS recommandé

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

### Guides Complets

| Document | Description | Lignes |
|----------|-------------|--------|
| [API.md](docs/API.md) | Documentation API complète (fonctions, structures, exemples) | 950+ |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Guide dépannage (toutes erreurs MT5 documentées) | 520+ |
| [VERSIONING.md](VERSIONING.md) | Gestion versions détaillée | 683 |
| [VERSION_QUICKSTART.md](VERSION_QUICKSTART.md) | Guide rapide versioning | 122 |
| [configs/README.md](configs/README.md) | Guide configurations risque | 450+ |

### Documentation API

**Constantes, Structures et Fonctions documentées :**
- Trading: `OpenPosition()`, `CalculateLotSize()`, `CanOpenNewTrade()`
- Positions: `CountPositions()`, `GetTotalPositions()`, `ManageAllPositions()`
- Indicateurs: `UpdateIndicatorCache()`, `GetSignalForSymbol()`
- News: `LoadNewsCalendar()`, `IsNewsTime()`
- Dashboard: `CreateDashboard()`, `UpdateDashboard()`
- Auto-Update: `CheckForUpdates()`, `CompareVersions()`

Chaque fonction inclut :
- Signature complète
- Paramètres et types
- Valeur de retour
- Exemples d'utilisation
- Notes et best practices

### Guide Troubleshooting

**Erreurs documentées :**
- 10004-10036 (toutes erreurs MT5)
- Problèmes compilation
- Problèmes performance
- Problèmes dashboard
- Problèmes news filter
- Problèmes auto-update

Chaque erreur inclut :
- Symptôme
- Cause
- Solution étape par étape
- Code de correction

---

## 🧪 Tests

### Framework de Tests

```bash
# Exécuter tous les tests
cd tests
./run_tests.sh
```

### Tests Disponibles

| Test | Description | Status |
|------|-------------|--------|
| `test_version_comparison.mq5` | 8 test cases CompareVersions() | ✅ |
| `test_validation.mq5` | Validation paramètres | 📝 TODO |
| `test_position_counting.mq5` | Comptage positions | 📝 TODO |

### Écrire un Test

```mql5
//+------------------------------------------------------------------+
//| Test: Function Name                                               |
//+------------------------------------------------------------------+
void OnStart()
{
   int passed = 0;
   int failed = 0;

   // Test Case 1
   if(AssertEquals(expected, actual, "Test description")) {
      passed++;
   } else {
      failed++;
   }

   // Summary
   Print("Passed: ", passed, " | Failed: ", failed);
}
```

📖 **Guide complet :** [tests/README.md](tests/README.md)

---

## 🤖 CI/CD

### GitHub Actions Workflows

**1. Compile Check** (`.github/workflows/compile-check.yml`)
- ✅ Vérification fichiers EA
- ✅ Basic syntax checks
- ✅ Version consistency
- ✅ SHA256 file validation
- **Triggers:** Push, Pull Request

**2. Quality Check** (`.github/workflows/quality-check.yml`)
- ✅ Documentation completeness
- ✅ Scripts presence et syntax
- ✅ Security checks (SHA256, secrets)
- ✅ Code quality metrics
- **Triggers:** Push, Pull Request

### Statuts

[![Compile Check](https://github.com/fred-selest/ea-scalping-pro/workflows/Compile%20Check/badge.svg)](https://github.com/fred-selest/ea-scalping-pro/actions)
[![Quality Check](https://github.com/fred-selest/ea-scalping-pro/workflows/Quality%20Check/badge.svg)](https://github.com/fred-selest/ea-scalping-pro/actions)

---

## 📞 Support

### Resources

- 📚 **Documentation API:** [docs/API.md](docs/API.md)
- 🔧 **Troubleshooting:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- ⚙️ **Configurations:** [configs/README.md](configs/README.md)
- 📝 **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- 🐛 **Issues:** https://github.com/fred-selest/ea-scalping-pro/issues

### FAQ

**Q: Quelle configuration choisir ?**
```
Débutant (< 6 mois exp):      Conservative
Intermédiaire (6-24 mois):     Moderate (recommandé)
Expert (2+ ans):               Aggressive (avec prudence)
```

**Q: Capital minimum requis ?**
```
Conservative:  1000$
Moderate:      2000$
Aggressive:    5000$
```

**Q: Comment activer SHA256 vérification ?**
```
C'est automatique ! Le fichier .sha256 est généré à chaque version bump
et vérifié par auto-update-ea.ps1 lors des téléchargements.
```

### Avant de Signaler un Bug

1. ✅ Vérifier [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
2. ✅ Vérifier version à jour (GitHub)
3. ✅ Consulter [CHANGELOG.md](CHANGELOG.md)
4. ✅ Tester en compte DEMO
5. ✅ Collecter logs MT5 (Journal > Experts)

### Créer un Issue

**Template:**
```markdown
**Version EA:** 27.52
**MT5 Version:** [Aide > À propos]
**OS:** Windows 10/11
**Broker:** [Nom broker]
**Type compte:** Demo/Réel

**Configuration:**
- [ ] Conservative
- [ ] Moderate
- [ ] Aggressive
- [ ] Personnalisée

**Description:**
[Description du problème]

**Étapes reproduction:**
1. ...
2. ...
3. Erreur survient

**Logs MT5:**
```
[Coller dernières lignes journal]
```

**Captures d'écran:**
[Si applicable]
```

---

**Développé par:** [fred-selest](https://github.com/fred-selest)
**License:** MIT
**Version:** 27.52
**Dernière mise à jour:** 2025-11-10
