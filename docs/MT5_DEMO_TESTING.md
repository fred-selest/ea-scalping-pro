# 📊 Guide de Test MT5 Demo - Configurations de Risque

Ce guide explique comment tester les 3 configurations de risque de l'EA dans un compte MT5 Demo.

## 📋 Table des Matières
1. [Prérequis](#prérequis)
2. [Installation de l'EA](#installation-de-lea)
3. [Configuration du Compte Demo](#configuration-du-compte-demo)
4. [Test: Configuration Conservative](#test-configuration-conservative)
5. [Test: Configuration Moderate](#test-configuration-moderate)
6. [Test: Configuration Aggressive](#test-configuration-aggressive)
7. [Métriques à Surveiller](#métriques-à-surveiller)
8. [Validation des Résultats](#validation-des-résultats)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Prérequis

### Logiciels Requis
- **MetaTrader 5** (version 3600+)
- **Compte Demo MT5** avec broker supportant:
  - Hedging ou Netting
  - Trading algorithmique activé
  - Spread variable acceptable

### Capital Demo Recommandé
| Configuration | Capital Minimum | Capital Recommandé |
|---------------|-----------------|-------------------|
| Conservative  | 1,000$          | 2,000$            |
| Moderate      | 2,000$          | 5,000$            |
| Aggressive    | 5,000$          | 10,000$           |

### Symboles Requis
Assurez-vous que votre broker propose:
- **Minimum:** EURUSD, GBPUSD
- **Recommandé:** EURUSD, GBPUSD, USDJPY, AUDUSD
- **Complet:** EURUSD, GBPUSD, USDJPY, AUDUSD, USDCAD, NZDUSD

---

## 📥 Installation de l'EA

### 1. Compiler l'EA

```bash
# Windows (dans Git Bash ou PowerShell)
cd "C:\Program Files\MetaTrader 5\MQL5\Experts"
MetaEditor.exe /compile:"EA_MultiPairs_Scalping_Pro.mq5"

# Linux/macOS (avec Wine)
cd ~/.wine/drive_c/Program\ Files/MetaTrader\ 5/MQL5/Experts
wine MetaEditor.exe /compile:EA_MultiPairs_Scalping_Pro.mq5
```

### 2. Vérifier la Compilation

Dans MetaEditor:
- **Onglet Errors:** Doit afficher `0 error(s), 0 warning(s)`
- **Journal:** Doit montrer "Compilation successful"

### 3. Copier les Fichiers de Configuration

```bash
# Copier les .set files dans le dossier Presets
cp configs/*.set "C:\Users\[VotreNom]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Presets\"

# Linux/macOS
cp configs/*.set ~/.wine/drive_c/users/[VotreNom]/Application\ Data/MetaQuotes/Terminal/[ID]/MQL5/Presets/
```

---

## 🏦 Configuration du Compte Demo

### Créer un Compte Demo Adapté

1. **Ouvrir MT5** → Menu `File` → `Open an Account`
2. **Sélectionner votre broker**
3. **Paramètres recommandés:**
   - Type: Demo
   - Leverage: 1:100 ou 1:200
   - Deposit: Selon configuration testée
   - Server: Server avec faible latence

### Activer le Trading Algorithmique

1. **Menu Tools** → `Options` → `Expert Advisors`
2. **Cocher:**
   - ✅ Allow automated trading
   - ✅ Allow DLL imports
   - ✅ Allow WebRequest for URL: `https://api.forexlens.com`

3. **Ajouter URL dans Tools → Options → Expert Advisors → WebRequest:**
   ```
   https://api.forexlens.com
   ```

### Configurer les Symboles

1. **Menu View** → `Market Watch` (ou Ctrl+M)
2. **Clic droit** → `Show All Symbols`
3. **Activer les symboles requis:**
   - EURUSD
   - GBPUSD
   - USDJPY
   - AUDUSD
   - USDCAD (Aggressive seulement)
   - NZDUSD (Aggressive seulement)

---

## 🐢 Test: Configuration Conservative

**Objectif:** Valider stabilité et sécurité avec risque minimal

### Étape 1: Charger la Configuration

1. **Ouvrir le graphique EURUSD** (H1 recommandé)
2. **Glisser-déposer** `EA_MultiPairs_Scalping_Pro.ex5` sur le graphique
3. Dans la fenêtre de paramètres:
   - Cliquer sur **Load**
   - Sélectionner `EA_Scalping_Conservative.set`
   - Cliquer sur **OK**

### Étape 2: Vérifier les Paramètres Chargés

**Inputs à vérifier:**
```
RiskPercent = 0.3
MaxLotSize = 0.2
MaxDailyLoss = 1.5
MaxOpenPositions = 2
MaxPositionsPerSymbol = 1
ScalpTP_Pips = 10.0
ScalpSL_Pips = 20.0
Trade_EURUSD = true
Trade_GBPUSD = true
Trade_USDJPY = false
MinutesBeforeNews = 60
MinutesAfterNews = 30
```

### Étape 3: Démarrer le Test

1. **Vérifier l'icône EA:**
   - 😊 Smiley vert = EA actif
   - ❌ Croix rouge = EA désactivé (cliquer sur le bouton Expert Advisors)

2. **Ouvrir l'onglet Experts** (Terminal → Experts)

3. **Vérifier les premiers logs:**
   ```
   [INFO] EA_MultiPairs_Scalping_Pro v27.52 initialized
   [INFO] Risk Per Trade: 0.30%
   [INFO] Max Open Positions: 2
   [INFO] Trading pairs: EURUSD, GBPUSD
   ```

### Étape 4: Surveillance (2-7 jours)

**Métriques à surveiller quotidiennement:**

| Métrique | Valeur Attendue | ⚠️ Alerte si |
|----------|-----------------|--------------|
| Positions ouvertes | 0-2 | > 2 |
| Drawdown | < 5% | > 10% |
| Lot size max | ≤ 0.20 | > 0.20 |
| Trades/jour | 2-8 | > 15 |
| Win rate | 55-70% | < 45% |

### Étape 5: Analyse des Résultats

**Après 7 jours, vérifier:**

1. **Onglet History** (Terminal → Account History)
   - Sélectionner période: Last 7 days
   - Clic droit → Save as Report → HTML

2. **Calculer les métriques:**
   ```
   Profit Factor = Gross Profit / Gross Loss
   Expected Value = (Win Rate × Avg Win) - (Loss Rate × Avg Loss)
   Max Drawdown % = (Peak - Trough) / Peak × 100
   ```

3. **Critères de validation Conservative:**
   - ✅ Profit Factor > 1.2
   - ✅ Max Drawdown < 10%
   - ✅ Aucune violation de MaxDailyLoss
   - ✅ Win Rate > 50%
   - ✅ Aucune erreur critique dans les logs

---

## ⚖️ Test: Configuration Moderate

**Objectif:** Équilibre entre risque et rendement

### Étape 1: Charger la Configuration

1. **Graphique EURUSD** (si CE n'est pas déjà fait)
2. **Glisser-déposer** l'EA
3. **Load** → `EA_Scalping_Moderate.set`

### Étape 2: Vérifier les Paramètres

```
RiskPercent = 0.5
MaxLotSize = 1.0
MaxDailyLoss = 3.0
MaxOpenPositions = 5
MaxPositionsPerSymbol = 2
ScalpTP_Pips = 8.0
ScalpSL_Pips = 15.0
Trade_EURUSD = true
Trade_GBPUSD = true
Trade_USDJPY = true
Trade_AUDUSD = true
MinutesBeforeNews = 30
MinutesAfterNews = 15
```

### Étape 3: Surveillance (2-7 jours)

| Métrique | Valeur Attendue | ⚠️ Alerte si |
|----------|-----------------|--------------|
| Positions ouvertes | 0-5 | > 5 |
| Drawdown | < 10% | > 15% |
| Lot size max | ≤ 1.00 | > 1.00 |
| Trades/jour | 5-20 | > 30 |
| Win rate | 55-70% | < 50% |

### Étape 4: Critères de Validation Moderate

- ✅ Profit Factor > 1.3
- ✅ Max Drawdown < 15%
- ✅ Win Rate > 52%
- ✅ Rendement mensuel: 8-15%
- ✅ Sharpe Ratio > 1.0

---

## 🚀 Test: Configuration Aggressive

**Objectif:** Maximiser rendement avec risque élevé

### Étape 1: Charger la Configuration

1. **Load** → `EA_Scalping_Aggressive.set`

### Étape 2: Vérifier les Paramètres

```
RiskPercent = 1.0
MaxLotSize = 2.0
MaxDailyLoss = 5.0
MaxOpenPositions = 10
MaxPositionsPerSymbol = 3
ScalpTP_Pips = 6.0
ScalpSL_Pips = 12.0
Trade_EURUSD = true
Trade_GBPUSD = true
Trade_USDJPY = true
Trade_AUDUSD = true
Trade_USDCAD = true
Trade_NZDUSD = true
```

### Étape 3: Surveillance (2-7 jours)

| Métrique | Valeur Attendue | ⚠️ Alerte si |
|----------|-----------------|--------------|
| Positions ouvertes | 0-10 | > 10 |
| Drawdown | < 20% | > 30% |
| Lot size max | ≤ 2.00 | > 2.00 |
| Trades/jour | 10-40 | > 60 |
| Win rate | 55-70% | < 50% |

### Étape 4: Critères de Validation Aggressive

- ✅ Profit Factor > 1.4
- ✅ Max Drawdown < 30%
- ✅ Win Rate > 50%
- ✅ Rendement mensuel: 15-30%
- ✅ Sharpe Ratio > 0.8

---

## 📊 Métriques à Surveiller

### Dashboard EA (en temps réel)

Le dashboard affiche en haut à droite du graphique:

```
╔════════════════════════════════════╗
║  EA MultiPairs Scalping Pro v27.52 ║
╠════════════════════════════════════╣
║  Status: RUNNING                   ║
║  Positions: 3/5                    ║
║  Daily P&L: +45.32$ (+2.26%)      ║
║  Spread: 0.8 pips (OK)            ║
║  News: No major events            ║
╚════════════════════════════════════╝
```

### Onglet Terminal → Experts

**Logs à surveiller:**

✅ **Logs normaux:**
```
[INFO] EURUSD: BUY signal detected (EMA cross + RSI 35.2)
[INFO] EURUSD: Position opened - Ticket #123456 | Lot: 0.05 | TP: 1.08950 | SL: 1.08750
[INFO] GBPUSD: Position closed - Ticket #123455 | Profit: +12.45$ | Duration: 18 min
```

⚠️ **Logs d'alerte:**
```
[WARNING] EURUSD: High spread detected (2.5 pips) - Skip signal
[WARNING] Daily loss approaching limit: -2.8% / -3.0%
```

❌ **Logs critiques:**
```
[ERROR] OrderSend FAILED for EURUSD | Error: 10019 (No money)
[ERROR] News API unreachable - Trading continues without news filter
```

### Onglet Terminal → Trade

**Vérifier les positions ouvertes:**
- Symbol
- Volume (lot size)
- Price
- S/L (Stop Loss)
- T/P (Take Profit)
- Profit

### Onglet Terminal → History

**Analyser les trades fermés:**
- Win rate %
- Average win vs average loss
- Longest winning/losing streak
- Time in market (durée moyenne)

---

## ✅ Validation des Résultats

### Checklist de Validation Complète

#### 1. Sécurité et Limites

- [ ] **MaxOpenPositions** jamais dépassé
- [ ] **MaxPositionsPerSymbol** jamais dépassé
- [ ] **MaxLotSize** jamais dépassé
- [ ] **MaxDailyLoss** déclenche arrêt si atteint
- [ ] Aucun trade pendant période de news (si activé)

#### 2. Performance

- [ ] **Profit Factor** > seuil de configuration
- [ ] **Win Rate** entre 50-70%
- [ ] **Max Drawdown** sous limite
- [ ] Pas de série de pertes > 5 trades consécutifs
- [ ] Courbe d'équité globalement ascendante

#### 3. Technique

- [ ] Aucun message d'erreur critique
- [ ] Dashboard s'affiche correctement
- [ ] SL/TP correctement placés sur tous les trades
- [ ] Lot size calculé selon RiskPercent
- [ ] EA continue de fonctionner après redémarrage MT5

#### 4. Robustesse

- [ ] Test pendant annonce NFP ou autre news majeure
- [ ] Test pendant week-end (aucun trade)
- [ ] Test avec connexion internet interrompue
- [ ] Test avec spread élevé (> MaxSpread)
- [ ] EA se réinitialise correctement après crash MT5

---

## 🔧 Troubleshooting

### Problème: EA ne trade pas

**Vérifications:**
1. Icône EA est verte (😊) ?
2. `Trade_[SYMBOL]` = true pour au moins 1 paire ?
3. Spread actuel < MaxSpread_Points ?
4. Account balance > capital minimum ?
5. Trading autorisé dans Tools → Options ?

**Logs à chercher:**
```
[INFO] OnInit completed - EA ready to trade
```

### Problème: Trop de positions ouvertes

**Cause possible:** MaxOpenPositions mal configuré

**Solution:**
1. Modifier Input `MaxOpenPositions`
2. Cliquer sur OK (EA se réinitialise)
3. Vérifier log: `[INFO] Max Open Positions: [N]`

### Problème: Drawdown excessif

**Actions immédiates:**
1. **Arrêter l'EA** (clic droit sur graphique → Expert Advisors → Remove)
2. **Clôturer manuellement les positions perdantes** si nécessaire
3. **Analyser les logs** pour identifier la cause
4. **Réduire RiskPercent** (ex: 0.5% → 0.3%)
5. **Redémarrer l'EA** avec configuration ajustée

### Problème: Erreur 10019 (No money)

**Cause:** Capital insuffisant pour ouvrir position

**Solutions:**
1. Augmenter le capital demo
2. Réduire `RiskPercent`
3. Réduire `MaxLotSize`
4. Vérifier `MaxDailyLoss` (peut bloquer trading)

### Problème: Dashboard ne s'affiche pas

**Vérifications:**
1. Aller dans Tools → Options → Charts
2. Cocher "Show object descriptions"
3. Vérifier que `ShowDashboard = true` dans inputs
4. Redémarrer EA (F7 → OK)

---

## 📈 Exemple de Rapport de Test

### Configuration: Moderate
**Période:** 2025-11-01 au 2025-11-07 (7 jours)
**Capital initial:** 5,000$
**Broker:** ICMarkets Demo

#### Résultats

| Métrique | Valeur | Statut |
|----------|--------|--------|
| Profit net | +432.50$ | ✅ |
| Rendement | +8.65% | ✅ |
| Max Drawdown | -9.2% | ✅ |
| Nombre de trades | 87 | ✅ |
| Win Rate | 62.1% | ✅ |
| Profit Factor | 1.48 | ✅ |
| Avg Win | +12.35$ | ✅ |
| Avg Loss | -8.12$ | ✅ |
| Sharpe Ratio | 1.23 | ✅ |
| Longest win streak | 8 trades | ✅ |
| Longest loss streak | 4 trades | ✅ |

#### Violations
- Aucune violation de MaxOpenPositions
- Aucune violation de MaxDailyLoss
- 2 trades skippés (spread élevé) ✅ Comportement attendu

#### Conclusion
✅ **Configuration Moderate VALIDÉE** pour passage en compte réel

---

## 📝 Template de Rapport

Utilisez ce template pour documenter vos tests:

```markdown
# Test Report: [Configuration Name]

**Date:** YYYY-MM-DD to YYYY-MM-DD
**Duration:** [N] days
**Capital:** [Amount]$
**Broker:** [Broker Name]

## Configuration
- RiskPercent: [X]%
- MaxOpenPositions: [N]
- Symbols traded: [List]

## Results
- Net Profit: [Amount]$ ([X]%)
- Max Drawdown: [X]%
- Trades: [N]
- Win Rate: [X]%
- Profit Factor: [X.XX]

## Issues Encountered
- [Description]

## Validation Status
- [ ] Performance criteria met
- [ ] No critical errors
- [ ] Risk limits respected

## Recommendation
[ ] ✅ APPROVED for live trading
[ ] ⚠️ NEEDS ADJUSTMENTS: [Details]
[ ] ❌ REJECTED: [Reason]
```

---

## 🎯 Prochaines Étapes

Après validation des 3 configurations:

1. **Documenter les résultats** dans un rapport
2. **Choisir la configuration** adaptée à votre profil
3. **Tester en Forward Testing** (2-4 semaines supplémentaires)
4. **Commencer en réel avec capital réduit** (10-20% du capital prévu)
5. **Monitorer pendant 1 mois** avant d'augmenter le capital

---

## 📞 Support

**Questions ou problèmes ?**
- Consulter: `docs/TROUBLESHOOTING.md`
- Consulter: `docs/API.md`
- Ouvrir une issue: GitHub Issues

**Documentation complète:**
- Configuration: `configs/README.md`
- API Reference: `docs/API.md`
- Troubleshooting: `docs/TROUBLESHOOTING.md`

---

**Version:** 1.0
**Dernière mise à jour:** 2025-11-10
**Auteur:** EA Scalping Pro Team
