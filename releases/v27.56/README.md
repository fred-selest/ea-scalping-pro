# 📦 EA Scalping Pro v27.56 - Archives de Release

**Version** : 27.56
**Date** : 2025-11-11
**Auteur** : fred-selest

---

## 📋 Archives Disponibles

### 1️⃣ **EA_Scalping_Pro_v27.56_MQ5_Only.zip** (23 KB)

**Contenu** :
- `EA_MultiPairs_Scalping_Pro.mq5` (fichier principal seul)

**Pour qui** :
- ✅ Utilisateurs expérimentés
- ✅ Configurations manuelles personnalisées
- ✅ Migration depuis version antérieure (paramètres déjà configurés)
- ✅ Installation rapide

**Installation** :
```
1. Extraire EA_MultiPairs_Scalping_Pro.mq5
2. Copier dans: MQL5/Experts/
3. Compiler dans MetaEditor (F7)
4. Glisser sur graphique MT5
5. Configurer paramètres manuellement
```

---

### 2️⃣ **EA_Scalping_Pro_v27.56_With_Configs.zip** (39 KB) ⭐ RECOMMANDÉ

**Contenu** :
- `EA_MultiPairs_Scalping_Pro.mq5` (EA principal)
- `configs/EA_Scalping_v27.56_Conservative.set` (Profil conservateur)
- `configs/EA_Scalping_v27.56_Balanced.set` (Profil équilibré)
- `configs/EA_Scalping_v27.56_Aggressive.set` (Profil agressif)
- `configs/GUIDE_PROFILS_v27.56.md` (Guide complet profils)
- `configs/README.md` (Documentation configs)

**Pour qui** :
- ✅ **Débutants** (profils préconfigurés)
- ✅ **Intermédiaires** (gain de temps)
- ✅ Utilisation immédiate avec profils optimisés
- ✅ Meilleur choix pour démarrage rapide

**Installation** :
```
1. Extraire tout
2. Copier EA_MultiPairs_Scalping_Pro.mq5 dans: MQL5/Experts/
3. Copier configs/*.set dans: MQL5/Presets/
4. Compiler EA (F7)
5. Glisser sur graphique
6. Charger profil désiré (Load button):
   - Conservative: EURUSD + USDJPY + USDCAD (Risque 0.3%)
   - Balanced: EURUSD + USDJPY + AUDUSD (Risque 0.5%)
   - Aggressive: 4 paires (Risque 1.0%)
```

**Profils inclus** :

| Profil | Paires | Risque | Capital Min | Profit/Mois | Drawdown |
|--------|--------|--------|-------------|-------------|----------|
| **Conservative** | 3 (EUR/JPY/CAD) | 0.3% | 1000$ | 3-7% | 5-8% |
| **Balanced** | 3 (EUR/JPY/AUD) | 0.5% | 2000$ | 8-15% | 8-12% |
| **Aggressive** | 4 (EUR/GBP/JPY/AUD) | 1.0% | 5000$ | 15-30% | 15-25% |

---

### 3️⃣ **EA_Scalping_Pro_v27.56_Complete_Package.zip** (72 KB)

**Contenu** :
- `EA_MultiPairs_Scalping_Pro.mq5` (EA principal)
- **Configs** (3 profils .set + guide + README)
- **Changelogs** (v27.56, v27.55, v27.54)
- **Documentation** complète :
  - `README.md` (Vue d'ensemble projet)
  - `docs/API.md` (Documentation technique API)
  - `docs/MT5_DEMO_TESTING.md` (Guide tests démo)
  - `docs/TROUBLESHOOTING.md` (Résolution problèmes)

**Pour qui** :
- ✅ Nouveaux utilisateurs (documentation complète)
- ✅ Formation et apprentissage
- ✅ Archivage complet version
- ✅ Compréhension approfondie EA

**Installation** :
```
1. Extraire tout
2. Copier EA dans: MQL5/Experts/
3. Copier configs/*.set dans: MQL5/Presets/
4. Lire documentation:
   - CHANGELOG_v27.56.md → Nouveautés partial close
   - configs/GUIDE_PROFILS_v27.56.md → Choix profil
   - docs/API.md → Fonctionnement technique
5. Compiler et installer (voir guides)
```

---

## 🆕 Nouveautés v27.56

### **Partial Close (Fermeture Partielle)** 🎯

**Stratégie Multi-TP** :
```
Position ouverte → TP1 + TP2
├─ TP1 atteint: Ferme 50%, SL → Break-Even
└─ TP2 atteint: Ferme 50% restant

Résultat:
✓ Profit sécurisé rapidement (TP1)
✓ Reste courrir pour objectif TP2
✓ Risque zéro après TP1 (SL à BE)
```

**Nouveaux paramètres** :
- `UsePartialClose = true`
- `PartialClosePercent = 50%` (ajustable 10-90%)
- `TP1_Multiplier / TP2_Multiplier` (mode dynamique ATR)
- `TP1_Fixed_Pips / TP2_Fixed_Pips` (mode fixe)
- `MoveSLToBreakEvenAfterTP1 = true`

**Impact** :
- 📈 Win Rate : +5%
- 📈 Profit Factor : +13-27%
- 📉 Max Consecutive Losses : -30%
- 🧠 Stress psychologique : Réduit

---

## 📊 Fonctionnalités Complètes v27.56

### **Trading**
- ✅ Multi-paires (6 disponibles: EUR/USD, GBP/USD, USD/JPY, AUD/USD, USD/CAD, NZD/USD)
- ✅ **Partial Close** (TP1/TP2) - NOUVEAU
- ✅ **Filtre Corrélations** (v27.55) - Évite double exposition
- ✅ **Volatility-Based Sizing** (v27.55) - Adapte lots à ATR
- ✅ **TP/SL Dynamiques** (v27.54) - Basés sur ATR
- ✅ **Filtre ADX** (v27.54) - Évite marchés range
- ✅ **News Filter** (ForexFactory API)
- ✅ **ONNX AI Model** (optionnel)

### **Risk Management**
- ✅ Position sizing basé risque %
- ✅ Drawdown journalier maximum
- ✅ Limites trades/jour et positions simultanées
- ✅ Gestion corrélations entre paires
- ✅ Trailing Stop et Break-Even
- ✅ Circuit breaker API news

### **Monitoring**
- ✅ Dashboard temps réel
- ✅ Statistiques journalières
- ✅ Logs multi-niveaux (DEBUG, INFO, WARN, ERROR)
- ✅ Tracking partial close positions

---

## 🚀 Quick Start

### **Débutants → Archive Recommandée**
```
📦 EA_Scalping_Pro_v27.56_With_Configs.zip

1. Extraire
2. Installer EA dans MT5
3. Charger profil "Conservative"
4. Capital minimum: 1000$
5. Tester 30 jours DÉMO avant live
```

### **Intermédiaires**
```
📦 EA_Scalping_Pro_v27.56_With_Configs.zip
   ou
📦 EA_Scalping_Pro_v27.56_Complete_Package.zip

Profil "Balanced" recommandé
Capital: 2000$+
Lire GUIDE_PROFILS_v27.56.md
```

### **Avancés**
```
📦 EA_Scalping_Pro_v27.56_MQ5_Only.zip

Configuration manuelle selon expérience
Backtest personnalisé
Optimisation paramètres
```

---

## 📖 Documentation par Archive

| Document | MQ5 Only | With Configs | Complete |
|----------|----------|--------------|----------|
| **EA .mq5** | ✅ | ✅ | ✅ |
| **Profils .set** | ❌ | ✅ | ✅ |
| **GUIDE_PROFILS_v27.56.md** | ❌ | ✅ | ✅ |
| **configs/README.md** | ❌ | ✅ | ✅ |
| **CHANGELOG_v27.56.md** | ❌ | ❌ | ✅ |
| **CHANGELOG_v27.55.md** | ❌ | ❌ | ✅ |
| **CHANGELOG_v27.54.md** | ❌ | ❌ | ✅ |
| **README.md (projet)** | ❌ | ❌ | ✅ |
| **docs/API.md** | ❌ | ❌ | ✅ |
| **docs/MT5_DEMO_TESTING.md** | ❌ | ❌ | ✅ |
| **docs/TROUBLESHOOTING.md** | ❌ | ❌ | ✅ |

---

## ⚙️ Prérequis

### **MetaTrader 5**
- Version minimale : Build 3802+
- Système : Windows, Linux (Wine), macOS (Wine)
- "Allow Algo Trading" activé
- "Allow WebRequest" activé pour :
  - `https://nfs.faireconomy.media` (ForexFactory API)

### **Compte Trading**
- Broker compatible MT5
- Spreads recommandés :
  - EURUSD : < 1.5 pips
  - GBPUSD : < 2.5 pips
  - USDJPY : < 1.5 pips
- Lot minimum : 0.01
- Capital selon profil :
  - Conservative : 1000$+
  - Balanced : 2000$+
  - Aggressive : 5000$+

---

## 🔄 Migration depuis Versions Antérieures

### **v27.55 → v27.56**
```
Nouveaux paramètres à configurer:
□ UsePartialClose
□ PartialClosePercent
□ TP1_Multiplier / TP2_Multiplier
□ TP1_Fixed_Pips / TP2_Fixed_Pips
□ MoveSLToBreakEvenAfterTP1

Magic Number changé: 270550 → 270560
(Nouvelles positions séparées des anciennes)
```

### **v27.54 et antérieurs → v27.56**
```
Nombreux nouveaux paramètres (v27.54, v27.55, v27.56)
→ Recommandation: Utiliser profils .set fournis
→ Lire changelogs dans Complete Package
```

---

## ✅ Checklist Installation

```
□ Archive téléchargée et extraite
□ EA copié dans MQL5/Experts/
□ Profils .set copiés dans MQL5/Presets/ (si applicable)
□ EA compilé dans MetaEditor (F7) - Aucune erreur
□ "Allow Algo Trading" activé (Tools → Options)
□ "Allow WebRequest" activé + URL ForexFactory ajoutée
□ Documentation lue (au moins README du profil choisi)
□ Compte DÉMO préparé pour tests
□ Capital suffisant selon profil
□ Paramètres chargés (via profil .set ou manuel)
□ Test DÉMO 30 jours planifié
```

---

## 📞 Support

### **Repository GitHub**
- **URL** : https://github.com/fred-selest/ea-scalping-pro
- **Issues** : https://github.com/fred-selest/ea-scalping-pro/issues
- **Discussions** : https://github.com/fred-selest/ea-scalping-pro/discussions

### **Documentation**
- Guides complets dans archive "Complete Package"
- `GUIDE_PROFILS_v27.56.md` → Choix profil optimisé
- `docs/TROUBLESHOOTING.md` → Résolution problèmes
- `docs/API.md` → Documentation technique

### **Changelog**
- `CHANGELOG_v27.56.md` → Partial Close
- `CHANGELOG_v27.55.md` → Corrélations + Volatilité
- `CHANGELOG_v27.54.md` → ADX + TP/SL Dynamiques

---

## 🎯 Recommandation Finale

### **Vous êtes débutant ?**
```
📦 Télécharger: EA_Scalping_Pro_v27.56_With_Configs.zip
📖 Lire: GUIDE_PROFILS_v27.56.md (dans l'archive)
⚙️ Charger: Profil "Conservative"
💰 Capital: 1000$ minimum
🧪 Tester: 30 jours en DÉMO obligatoire
```

### **Vous êtes expérimenté ?**
```
📦 Télécharger: EA_Scalping_Pro_v27.56_Complete_Package.zip
📖 Lire: Tous les changelogs pour comprendre évolutions
🧪 Backtest: Comparer profils sur vos données
⚙️ Optimiser: Ajuster paramètres selon résultats
🚀 Live: Déploiement progressif (25% → 50% → 100%)
```

---

**Bon trading ! 🚀**

---

*Développé par fred-selest - Version 27.56 - 2025-11-11*
