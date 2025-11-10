# 🧪 Framework de Tests - EA Scalping Pro

Framework de tests unitaires et d'intégration pour l'EA.

## 📋 Structure

```
tests/
├── README.md                          # Ce fichier
├── unit/                              # Tests unitaires
│   ├── test_validation.mq5           # Tests ValidateInputParameters()
│   ├── test_version_comparison.mq5    # Tests CompareVersions()
│   └── test_position_counting.mq5     # Tests CountPositions()
├── integration/                       # Tests d'intégration
│   └── test_trading_workflow.mq5      # Test workflow complet
├── fixtures/                          # Données de test
│   ├── valid_params.json             # Paramètres valides
│   └── test_news.json                # Calendrier news test
└── run_tests.sh                       # Script exécution tests
```

## 🚀 Exécution des Tests

### Prérequis
- MetaTrader 5 installé
- MetaEditor 64-bit
- EA compilé sans erreurs

### Lancer tous les tests
```bash
cd tests
./run_tests.sh
```

### Lancer test spécifique
```bash
# Windows
metaeditor64.exe /compile:tests/unit/test_validation.mq5

# Linux/Wine
wine metaeditor64.exe /compile:tests/unit/test_validation.mq5
```

## 📝 Écrire un Test

### Template Test Unitaire

```mql5
//+------------------------------------------------------------------+
//| Test: [Nom de la fonction]                                        |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property version   "1.00"
#property script_show_inputs

// Include EA functions (adjust path)
#include "../EA_MultiPairs_Scalping_Pro.mq5"

//+------------------------------------------------------------------+
//| Test Main Function                                                |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("╔════════════════════════════════════╗");
   Print("║  Test: [Function Name]           ║");
   Print("╚════════════════════════════════════╝");

   int passed = 0;
   int failed = 0;

   // Test Case 1
   if(TestCase1()) {
      Print("✅ Test Case 1: PASSED");
      passed++;
   } else {
      Print("❌ Test Case 1: FAILED");
      failed++;
   }

   // Test Case 2
   if(TestCase2()) {
      Print("✅ Test Case 2: PASSED");
      passed++;
   } else {
      Print("❌ Test Case 2: FAILED");
      failed++;
   }

   // Results
   Print("");
   Print("════════════════════════════════════");
   Print("Total Tests: ", passed + failed);
   Print("Passed: ", passed);
   Print("Failed: ", failed);
   Print("Success Rate: ", (passed * 100.0 / (passed + failed)), "%");
   Print("════════════════════════════════════");

   if(failed == 0) {
      Print("✅ ALL TESTS PASSED");
   } else {
      Print("❌ SOME TESTS FAILED");
   }
}

//+------------------------------------------------------------------+
//| Test Case 1                                                       |
//+------------------------------------------------------------------+
bool TestCase1()
{
   // Setup
   // ...

   // Execute
   // ...

   // Assert
   return (expected == actual);
}

//+------------------------------------------------------------------+
//| Test Case 2                                                       |
//+------------------------------------------------------------------+
bool TestCase2()
{
   // Setup
   // ...

   // Execute
   // ...

   // Assert
   return (expected == actual);
}
```

## 📦 Tests Disponibles

### Unit Tests

#### test_validation.mq5
Teste la validation des paramètres d'entrée.

**Test Cases:**
- ✅ Paramètres valides acceptés
- ❌ TP trop petit rejeté (< MIN_TP_PIPS_LIMIT)
- ❌ TP trop grand rejeté (> MAX_TP_PIPS_LIMIT)
- ❌ SL trop petit rejeté
- ❌ SL trop grand rejeté
- ⚠️ Warning si TP < SL
- ⚠️ Warning si RiskPercent > RISK_WARNING_THRESHOLD

#### test_version_comparison.mq5
Teste la comparaison de versions.

**Test Cases:**
- ✅ v27.52 > v27.51 → retourne 1
- ✅ v27.51 < v27.52 → retourne -1
- ✅ v27.52 == v27.52 → retourne 0
- ✅ v28.0 > v27.99 → retourne 1
- ✅ v27.5.2 > v27.5.1 → retourne 1

#### test_position_counting.mq5
Teste le comptage de positions.

**Test Cases:**
- ✅ CountPositions("") retourne total
- ✅ CountPositions("EURUSD") retourne positions EURUSD
- ✅ Early exit avec max_count fonctionne
- ✅ GetTotalPositions() == CountPositions("", MaxOpenPositions)
- ✅ GetSymbolPositions("EURUSD") == CountPositions("EURUSD", MaxPositionsPerSymbol)

### Integration Tests

#### test_trading_workflow.mq5
Teste le workflow complet de trading.

**Test Cases:**
- ✅ OnInit() initialise correctement
- ✅ ValidateInputParameters() avant trading
- ✅ GetSignalForSymbol() détecte signaux
- ✅ CanOpenNewTrade() respecte limites
- ✅ OpenPosition() ouvre positions
- ✅ ManageAllPositions() gère positions
- ✅ CheckDailyReset() reset compteurs
- ✅ OnDeinit() nettoie ressources

## 🔍 Assertions Helpers

### AssertEquals
```mql5
template<typename T>
bool AssertEquals(T expected, T actual, string test_name)
{
   if(expected == actual) {
      Print("✅ ", test_name, ": PASSED");
      return true;
   } else {
      Print("❌ ", test_name, ": FAILED");
      Print("   Expected: ", expected);
      Print("   Actual: ", actual);
      return false;
   }
}
```

### AssertTrue
```mql5
bool AssertTrue(bool condition, string test_name)
{
   if(condition) {
      Print("✅ ", test_name, ": PASSED");
      return true;
   } else {
      Print("❌ ", test_name, ": FAILED (expected true, got false)");
      return false;
   }
}
```

### AssertFalse
```mql5
bool AssertFalse(bool condition, string test_name)
{
   return AssertTrue(!condition, test_name);
}
```

## 🎯 Best Practices

### 1. Test Isolation
- Chaque test doit être indépendant
- Pas d'état partagé entre tests
- Reset state dans OnStart()

### 2. Nommage
```
test_[function_name]_[scenario]_[expected_result]

Exemples:
- test_validate_valid_params_returns_true
- test_validate_invalid_tp_returns_false
- test_compare_newer_version_returns_positive
```

### 3. AAA Pattern
```mql5
// Arrange (Setup)
double tp = 5.0;
double sl = 10.0;

// Act (Execute)
bool result = ValidateTPSL(tp, sl);

// Assert (Verify)
return AssertTrue(result, "Valid TP/SL accepted");
```

### 4. Edge Cases
Tester:
- Valeurs limites (min, max)
- Valeurs invalides (négatif, zéro)
- Null/Empty strings
- Array bounds

### 5. Documentation
```mql5
//+------------------------------------------------------------------+
//| Test: ValidateInputParameters with invalid TP                    |
//| Expected: Function returns false                                  |
//| Setup: ScalpTP_Pips = -5.0 (invalid)                            |
//+------------------------------------------------------------------+
bool test_validate_invalid_tp()
{
   ScalpTP_Pips = -5.0;
   bool result = ValidateInputParameters();
   return AssertFalse(result, "Invalid negative TP rejected");
}
```

## 📊 Coverage Target

| Module | Functions | Tested | Coverage |
|--------|-----------|--------|----------|
| Validation | 2 | 2 | 100% |
| Trading | 5 | 3 | 60% |
| Position Mgmt | 4 | 4 | 100% |
| Indicators | 3 | 1 | 33% |
| News | 2 | 0 | 0% |
| Dashboard | 2 | 0 | 0% |
| Auto-Update | 3 | 1 | 33% |
| Utilities | 2 | 0 | 0% |

**Overall:** 13/21 = 62%

**Target:** 80% coverage minimum

## 🐛 Debugging Tests

### Verbose Output
```mql5
#property script_show_inputs
#define TEST_VERBOSE true

#ifdef TEST_VERBOSE
   #define TEST_LOG(msg) Print("[TEST] ", msg)
#else
   #define TEST_LOG(msg)
#endif
```

### Breakpoints
Use Print() statements liberally:
```mql5
Print("DEBUG: Variable value = ", value);
Print("DEBUG: Before function call");
CallFunction();
Print("DEBUG: After function call, result = ", result);
```

### Log Files
```mql5
int file = FileOpen("test_results.txt", FILE_WRITE|FILE_TXT);
FileWrite(file, "Test: ", test_name, " Result: ", result);
FileClose(file);
```

## 🔄 CI/CD Integration

Tests automatisés via GitHub Actions:

```yaml
# .github/workflows/test.yml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Unit Tests
        run: ./tests/run_tests.sh
```

## 📚 Resources

- **MQL5 Documentation:** https://www.mql5.com/en/docs
- **Testing Best Practices:** https://github.com/fred-selest/ea-scalping-pro/docs
- **Issue Tracker:** https://github.com/fred-selest/ea-scalping-pro/issues

---

**Version:** 1.0
**Dernière mise à jour:** 2025-11-10
