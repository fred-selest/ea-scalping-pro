# 🔗 Integration Tests - EA Scalping Pro

## 📋 Vue d'Ensemble

Les tests d'intégration vérifient que plusieurs composants de l'EA fonctionnent correctement ensemble dans des scénarios proches de la réalité.

## 🎯 Objectifs

- **Tester les workflows complets** (de la détection du signal à l'ouverture de position)
- **Valider les interactions** entre modules (risk management + position management)
- **Simuler des scénarios réels** de trading
- **Détecter les problèmes d'intégration** non visibles dans les tests unitaires

## 📁 Structure

```
tests/integration/
├── README.md                          # Ce fichier
├── test_complete_trade_flow.mq5       # Test du cycle complet d'un trade
├── test_risk_management_integration.mq5  # Test de gestion du risque
├── test_multi_symbol_trading.mq5      # Test trading multi-symboles
├── test_news_filter_integration.mq5   # Test filtre news
└── scenarios/                         # Scénarios de test pré-définis
    ├── scenario_conservative.json
    ├── scenario_moderate.json
    └── scenario_aggressive.json
```

## 🧪 Tests Disponibles

### 1. test_complete_trade_flow.mq5

**Description:** Teste le cycle de vie complet d'un trade

**Scénarios testés:**
- Détection de signal BUY/SELL
- Validation des conditions (spread, news, risk)
- Calcul du lot size
- Ouverture de position
- Gestion SL/TP
- Trailing Stop
- Break Even
- Clôture de position

**Durée:** ~5-10 minutes

**Comment exécuter:**
```bash
# Via MetaEditor
MetaEditor.exe /compile:tests/integration/test_complete_trade_flow.mq5
MetaEditor.exe /run:tests/integration/test_complete_trade_flow.mq5

# Ou dans MT5
1. Ouvrir graphique EURUSD H1
2. Glisser-déposer le script sur le graphique
3. Cliquer OK
```

**Résultat attendu:**
```
✅ Signal detection: PASSED
✅ Risk validation: PASSED
✅ Lot calculation: PASSED
✅ Position opening: PASSED
✅ SL/TP management: PASSED
✅ Trailing stop: PASSED
✅ Break even: PASSED
✅ Position closing: PASSED
═════════════════════════════════════
INTEGRATION TEST: PASSED (8/8)
```

---

### 2. test_risk_management_integration.mq5

**Description:** Teste l'intégration de tous les contrôles de risque

**Scénarios testés:**
- Respect de MaxOpenPositions
- Respect de MaxPositionsPerSymbol
- Respect de MaxLotSize
- Respect de MaxDailyLoss
- Calcul correct du risque par trade
- Blocage après pertes journalières
- Reset des statistiques à minuit

**Durée:** ~3-5 minutes

**Résultat attendu:**
```
✅ MaxOpenPositions enforcement: PASSED
✅ MaxPositionsPerSymbol enforcement: PASSED
✅ MaxLotSize clamping: PASSED
✅ MaxDailyLoss trigger: PASSED
✅ Risk calculation accuracy: PASSED
✅ Daily reset mechanism: PASSED
═════════════════════════════════════
INTEGRATION TEST: PASSED (6/6)
```

---

### 3. test_multi_symbol_trading.mq5

**Description:** Teste le trading simultané sur plusieurs paires

**Scénarios testés:**
- Gestion de positions sur 6 symboles
- Comptage correct des positions par symbole
- Calcul du lot size par symbole
- Gestion des ordres simultanés
- Distribution équilibrée du risque
- Gestion du dashboard multi-symboles

**Symboles testés:** EURUSD, GBPUSD, USDJPY, AUDUSD, USDCAD, NZDUSD

**Durée:** ~10-15 minutes

**Résultat attendu:**
```
✅ EURUSD trading: PASSED
✅ GBPUSD trading: PASSED
✅ USDJPY trading: PASSED
✅ Position counting across symbols: PASSED
✅ Risk distribution: PASSED
✅ Dashboard updates: PASSED
═════════════════════════════════════
INTEGRATION TEST: PASSED (6/6)
```

---

### 4. test_news_filter_integration.mq5

**Description:** Teste le filtre d'actualités économiques

**Scénarios testés:**
- Téléchargement API ForexFactory
- Parsing du JSON
- Détection de news à venir
- Pause trading avant news
- Reprise trading après news
- Filtrage par impact (High/Medium/Low)
- Gestion des erreurs API

**Durée:** ~5 minutes (requiert connexion internet)

**Résultat attendu:**
```
✅ API connection: PASSED
✅ JSON parsing: PASSED
✅ News detection: PASSED
✅ Trading pause before news: PASSED
✅ Trading resume after news: PASSED
✅ Impact filtering: PASSED
✅ Error handling: PASSED
═════════════════════════════════════
INTEGRATION TEST: PASSED (7/7)
```

---

## 🚀 Exécution des Tests

### Méthode 1: Script Shell (Recommandé)

```bash
cd tests/integration
./run_integration_tests.sh
```

**Sortie:**
```
╔════════════════════════════════════════════════════════════╗
║  Integration Test Suite - EA Scalping Pro                 ║
╚════════════════════════════════════════════════════════════╝

Running: test_complete_trade_flow.mq5...
✅ PASSED (8/8 tests)

Running: test_risk_management_integration.mq5...
✅ PASSED (6/6 tests)

Running: test_multi_symbol_trading.mq5...
✅ PASSED (6/6 tests)

Running: test_news_filter_integration.mq5...
✅ PASSED (7/7 tests)

╔════════════════════════════════════════════════════════════╗
║  INTEGRATION TESTS SUMMARY                                 ║
╠════════════════════════════════════════════════════════════╣
║  Total Suites: 4                                           ║
║  Passed:       4 ✅                                        ║
║  Failed:       0 ❌                                        ║
║  Success Rate: 100%                                        ║
╚════════════════════════════════════════════════════════════╝
```

### Méthode 2: Manuellement dans MT5

1. **Ouvrir MetaTrader 5**
2. **Ouvrir un graphique** (EURUSD H1 recommandé)
3. **Navigator → Scripts**
4. **Glisser-déposer** le script de test sur le graphique
5. **Cliquer OK** dans la fenêtre de paramètres
6. **Vérifier les logs** dans l'onglet "Experts"

### Méthode 3: MetaEditor CLI

```bash
# Compiler tous les tests
MetaEditor.exe /compile:tests/integration/test_complete_trade_flow.mq5
MetaEditor.exe /compile:tests/integration/test_risk_management_integration.mq5
MetaEditor.exe /compile:tests/integration/test_multi_symbol_trading.mq5
MetaEditor.exe /compile:tests/integration/test_news_filter_integration.mq5

# Exécuter (dans MT5)
MetaEditor.exe /run:tests/integration/test_complete_trade_flow.mq5
```

---

## 📊 Scénarios de Test

Les scénarios pré-définis simulent des configurations réelles de l'EA.

### Scenario: Conservative

```json
{
  "name": "Conservative Profile",
  "balance": 1000,
  "risk_percent": 0.3,
  "max_lot": 0.2,
  "max_daily_loss": 1.5,
  "max_open_positions": 2,
  "max_positions_per_symbol": 1,
  "sl_pips": 20,
  "tp_pips": 10,
  "symbols": ["EURUSD", "GBPUSD"]
}
```

### Scenario: Moderate

```json
{
  "name": "Moderate Profile",
  "balance": 5000,
  "risk_percent": 0.5,
  "max_lot": 1.0,
  "max_daily_loss": 3.0,
  "max_open_positions": 5,
  "max_positions_per_symbol": 2,
  "sl_pips": 15,
  "tp_pips": 8,
  "symbols": ["EURUSD", "GBPUSD", "USDJPY", "AUDUSD"]
}
```

### Scenario: Aggressive

```json
{
  "name": "Aggressive Profile",
  "balance": 10000,
  "risk_percent": 1.0,
  "max_lot": 2.0,
  "max_daily_loss": 5.0,
  "max_open_positions": 10,
  "max_positions_per_symbol": 3,
  "sl_pips": 12,
  "tp_pips": 6,
  "symbols": ["EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD", "NZDUSD"]
}
```

---

## 🔍 Interprétation des Résultats

### ✅ PASSED

Tous les tests ont réussi. Le composant fonctionne correctement.

```
✅ Position opening: PASSED
   → Order sent successfully
   → Ticket: 123456
   → SL/TP correctly placed
```

### ❌ FAILED

Un test a échoué. Vérifier les logs pour plus de détails.

```
❌ MaxDailyLoss trigger: FAILED
   → Expected: Trading stopped
   → Actual: Trading continued
   → Daily loss: -3.5% (limit: -3.0%)
   → Review daily loss calculation logic
```

### ⚠️ WARNING

Test passé avec avertissement (comportement inattendu mais non bloquant).

```
⚠️ Dashboard updates: PASSED (with warnings)
   → Dashboard displayed correctly
   → Warning: Update latency 5s (expected < 2s)
   → Consider optimizing refresh rate
```

---

## 🐛 Debugging

### Activer les Logs Détaillés

Dans chaque test d'intégration, vous pouvez activer le mode DEBUG:

```mql5
#define DEBUG_MODE true  // Active logs détaillés

void OnStart() {
   if(DEBUG_MODE) {
      Print("[DEBUG] Starting integration test...");
      Print("[DEBUG] Account balance: ", AccountInfoDouble(ACCOUNT_BALANCE));
      // ...
   }
}
```

### Logs à Vérifier

**Onglet Experts (MT5 Terminal):**
```
[INFO] Integration test started: test_complete_trade_flow
[DEBUG] Symbol: EURUSD | Spread: 0.8 pips | Balance: 10000$
[DEBUG] Signal detected: BUY | EMA: 1.08523 > 1.08501 | RSI: 35.2
[DEBUG] Risk check: PASS | Lot calculated: 0.50 | Risk: 0.5%
[INFO] Position opened: Ticket #123456 | BUY EURUSD 0.50 lots
[DEBUG] SL: 1.08350 | TP: 1.08600 | Entry: 1.08500
...
✅ Test completed: PASSED (8/8)
```

### Fichiers de Log

Les tests d'intégration génèrent des fichiers de log dans:
```
C:\Users\[VotreNom]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Files\Logs\
```

**Exemple:** `integration_test_2025-11-10.log`

---

## 📈 Métriques de Performance

Les tests d'intégration collectent des métriques:

| Métrique | Seuil | Description |
|----------|-------|-------------|
| Temps d'exécution | < 1s | Temps pour ouvrir une position |
| Latence API | < 2s | Temps de réponse API news |
| Update dashboard | < 2s | Temps de rafraîchissement |
| Consommation CPU | < 20% | Utilisation CPU moyenne |
| Consommation RAM | < 100MB | Utilisation mémoire |

**Exemple de sortie:**
```
╔════════════════════════════════════════════════════════════╗
║  PERFORMANCE METRICS                                       ║
╠════════════════════════════════════════════════════════════╣
║  Position open time:  0.45s  ✅                            ║
║  API latency:         1.2s   ✅                            ║
║  Dashboard refresh:   1.8s   ✅                            ║
║  CPU usage:           12%    ✅                            ║
║  RAM usage:           45MB   ✅                            ║
╚════════════════════════════════════════════════════════════╝
```

---

## 🔄 CI/CD Integration

Les tests d'intégration sont exécutés automatiquement dans la CI/CD.

**GitHub Actions Workflow:** `.github/workflows/integration-tests.yml`

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  integration-tests:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install MT5
        run: choco install metatrader5
      - name: Run Integration Tests
        run: |
          cd tests/integration
          ./run_integration_tests.sh
```

**Badge de statut:**
```markdown
![Integration Tests](https://github.com/fred-selest/ea-scalping-pro/workflows/Integration%20Tests/badge.svg)
```

---

## 🎓 Bonnes Pratiques

### 1. Tester sur Compte Demo

**Toujours exécuter les tests d'intégration sur un compte DEMO**, jamais sur un compte réel.

### 2. Isoler les Tests

Chaque test doit être **indépendant** et ne pas dépendre des résultats des autres tests.

### 3. Nettoyer Après Tests

Les tests doivent **nettoyer** toutes les positions/ordres créés:

```mql5
void CleanupAfterTest() {
   // Clôturer toutes les positions de test
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket)) {
         if(PositionGetInteger(POSITION_MAGIC) == TEST_MAGIC) {
            // Clôturer position de test
         }
      }
   }
}
```

### 4. Utiliser des Magic Numbers de Test

Les tests doivent utiliser un **magic number unique** pour éviter de modifier les positions réelles:

```mql5
#define TEST_MAGIC 999999  // Magic number pour tests uniquement
```

### 5. Documenter les Échecs

Lorsqu'un test échoue, **documenter** le contexte complet:

```mql5
if(!test_result) {
   Print("❌ TEST FAILED: ", test_name);
   Print("   Expected: ", expected_value);
   Print("   Actual: ", actual_value);
   Print("   Context: Balance=", AccountInfoDouble(ACCOUNT_BALANCE),
         " | Spread=", SymbolInfoInteger(symbol, SYMBOL_SPREAD),
         " | Time=", TimeCurrent());
}
```

---

## 📞 Support

**Questions ou problèmes avec les tests d'intégration ?**

- Consulter: `docs/TROUBLESHOOTING.md`
- Consulter: `tests/README.md`
- Ouvrir une issue: [GitHub Issues](https://github.com/fred-selest/ea-scalping-pro/issues)

---

## 📝 Contribution

Pour ajouter un nouveau test d'intégration:

1. **Créer le fichier** `test_[nom_feature].mq5` dans `tests/integration/`
2. **Suivre le template** des tests existants
3. **Documenter** le test dans ce README
4. **Ajouter** le test à `run_integration_tests.sh`
5. **Tester localement** avant de commit
6. **Soumettre** une Pull Request

---

**Version:** 1.0
**Dernière mise à jour:** 2025-11-10
**Auteur:** EA Scalping Pro Team
