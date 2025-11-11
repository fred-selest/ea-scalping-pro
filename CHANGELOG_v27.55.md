# Changelog v27.55 - Smart Risk Management

## 📅 Date : 2025-11-11

## 🎯 Améliorations Majeures

### 1. **Gestion des Corrélations entre Paires** ✨
**Objectif** : Éviter la double exposition au risque sur des paires corrélées

**Problème résolu** :
```
Avant: EURUSD + GBPUSD en même temps = corrélation 80% → risque doublé
Maintenant: Si position EURUSD existe, GBPUSD est bloqué
```

**Implémentation** :
- Matrix de corrélations pour 14 paires (positives et négatives)
- Filtre activable : `UseCorrelationFilter = true` (par défaut)
- Seuil configurable : `MaxCorrelation = 0.70` (70%)
- Fonction `HasCorrelatedPosition()` vérifie avant chaque trade

**Paires surveillées** :
```mql5
Corrélations positives :
- EURUSD ↔ GBPUSD (0.80)
- AUDUSD ↔ NZDUSD (0.85) - Très corrélées !
- EURUSD ↔ AUDUSD (0.75)

Corrélations négatives (inverses) :
- EURUSD ↔ USDCHF (-0.92) - Très inversées !
- USDJPY ↔ AUDUSD (-0.65) - Risk-on/off
```

**Impact estimé** :
- **-15 à -25% de drawdown**
- Meilleure diversification du portefeuille
- Réduction exposition USD

---

### 2. **Position Sizing Basé sur la Volatilité** 🎯
**Objectif** : Adapter la taille des lots selon la volatilité actuelle

**Problème résolu** :
```
Avant: Risque fixe 0.5% → même lot en haute/basse volatilité
Maintenant: Lots ajustés selon ATR actuel vs moyenne
```

**Implémentation** :
- Calcul ATR moyen sur 20 périodes (cache 4h)
- Ratio volatilité : ATR actuel / ATR moyen
- Ajustement inverse :
  - **Volatilité haute** (ratio > 1) → lots plus petits
  - **Volatilité basse** (ratio < 1) → lots plus grands
- Limite : Max 2× le risque normal

**Formule** :
```mql5
volatility_ratio = ATR_actuel / ATR_moyen
adjusted_risk = RiskPercent / volatility_ratio

// Limites de sécurité
adjusted_risk = min(adjusted_risk, RiskPercent × 2.0)
adjusted_risk = max(adjusted_risk, RiskPercent / 2.0)
```

**Exemples concrets** :
```
Risque de base: 0.5%

Scénario 1: Volatilité normale (ratio = 1.0)
→ Risque ajusté: 0.5% (inchangé)

Scénario 2: Volatilité élevée (ratio = 1.5)
→ Risque ajusté: 0.5 / 1.5 = 0.33%
→ Lots plus petits pour compenser

Scénario 3: Volatilité basse (ratio = 0.7)
→ Risque ajusté: 0.5 / 0.7 = 0.71%
→ Lots plus grands (opportunité!)
```

**Impact estimé** :
- **+20 à +30% de Sharpe Ratio**
- Meilleure gestion des périodes volatiles (news, crises)
- Profite mieux des périodes calmes

---

## 📊 Nouveaux Paramètres

```mql5
// Gestion corrélations
input bool     UseCorrelationFilter = true;      // Activer filtre
input double   MaxCorrelation = 0.70;            // Seuil 0-1

// Position sizing volatilité
input bool     UseVolatilityBasedSizing = true;  // Activer sizing adaptatif
input double   MaxVolatilityMultiplier = 2.0;    // Max 2× risque normal
```

---

## 🔧 Changements Techniques

### Nouvelles Structures

```mql5
// Corrélations
struct CorrelationPair {
   string symbol1;
   string symbol2;
   double correlation;  // -1 à 1
};
CorrelationPair correlations[14];  // 14 paires pré-configurées

// Cache ATR
struct ATRHistory {
   string symbol;
   double atr_values[20];
   int count;
   datetime last_update;
};
ATRHistory atr_history[];
```

### Nouvelles Fonctions

```mql5
// Vérifier corrélations
bool HasCorrelatedPosition(string symbol);

// Calculer ATR moyen (20 périodes)
double CalculateAverageATR(string symbol, int periods = 20);
```

### Fonctions Modifiées

```mql5
// CanTrade() - Ajout du filtre corrélation
bool CanTrade(string symbol) {
   // ... vérifications existantes
   if(HasCorrelatedPosition(symbol)) return false;  // 🆕
   return true;
}

// CalculateLotSize() - Ajout sizing volatilité
double CalculateLotSize(string symbol) {
   double base_risk = RiskPercent;

   if(UseVolatilityBasedSizing) {
      double volatility_ratio = ATR_actuel / ATR_moyen;
      base_risk = RiskPercent / volatility_ratio;  // 🆕
      // + limites sécurité
   }

   // ... calcul lot avec risque ajusté
}
```

---

## 📈 Impact Global Attendu

| Métrique | v27.54 | v27.55 | Amélioration |
|----------|--------|--------|--------------|
| **Drawdown Max** | 100% (référence) | ~75-85% | **-15 à -25%** |
| **Sharpe Ratio** | 1.0 (référence) | 1.20-1.30 | **+20 à +30%** |
| **Corrélation Exposition** | Non géré | Géré | **Protection** |
| **Adaptation Volatilité** | Fixe | Dynamique | **Intelligent** |
| **Risque par trade** | 0.5% fixe | 0.25-1.0% adaptatif | **Flexible** |

---

## 🧪 Configuration Recommandée

### Conservative (Recommandé pour débutants)
```mql5
UseCorrelationFilter = true
MaxCorrelation = 0.60              // Strict (60%)
UseVolatilityBasedSizing = true
MaxVolatilityMultiplier = 1.5     // Limité à 1.5×
```

### Moderate (Défaut)
```mql5
UseCorrelationFilter = true
MaxCorrelation = 0.70              // Modéré (70%)
UseVolatilityBasedSizing = true
MaxVolatilityMultiplier = 2.0      // Standard 2×
```

### Aggressive
```mql5
UseCorrelationFilter = true
MaxCorrelation = 0.80              // Plus permissif (80%)
UseVolatilityBasedSizing = true
MaxVolatilityMultiplier = 2.5      // Jusqu'à 2.5×
```

### Désactiver (pour comparaison)
```mql5
UseCorrelationFilter = false       // Comme v27.54
UseVolatilityBasedSizing = false   // Comme v27.54
```

---

## ⚠️ Notes Importantes

### Corrélations
- Les corrélations changent avec le temps (données moyennes historiques)
- Surveillance des corrélations USD (plus impactant)
- Logs DEBUG montrent les blocages : `🔗 GBPUSD bloqué - Position corrélée sur EURUSD`

### Volatilité
- Cache ATR mis à jour toutes les 4 heures
- Calcul sur 20 périodes (5 jours en H4, 20 jours en D1)
- Logs DEBUG montrent ajustements : `Volatility sizing: Ratio=1.35 | Risk: 0.5% → 0.37%`

### Performance
- Overhead minimal (< 1ms par trade)
- Cache ATR évite recalculs constants
- Pas d'impact sur vitesse d'exécution

---

## 🔄 Migration depuis v27.54

1. **Sauvegarder** paramètres actuels (.set)
2. **Charger** EA v27.55
3. **Nouveaux paramètres** automatiquement activés (recommandé)
4. **Tester** en démo pendant 1 semaine minimum
5. **Observer** logs (niveau DEBUG) pour comprendre comportement
6. **Ajuster** MaxCorrelation et MaxVolatilityMultiplier selon résultats

### Magic Number Changé
```
v27.54: 270540
v27.55: 270550  // Nouvelles positions séparées
```

---

## 📝 Fichiers Modifiés

- `EA_MultiPairs_Scalping_Pro.mq5` : Toutes les améliorations
- Version : **27.54 → 27.55**
- Property version : "27.540" → "27.550"
- Magic number : 270540 → 270550
- Ajout : 280+ lignes de code

---

## 🎓 Exemples d'Utilisation

### Exemple 1: Blocage par Corrélation
```
[10:15] Signal BUY EURUSD détecté (ADX=25, EMA cross up)
[10:15] CanTrade(EURUSD): OK - Pas de position corrélée
[10:15] ✅ EURUSD BUY ouvert - Ticket #123456

[10:20] Signal BUY GBPUSD détecté (ADX=28, EMA cross up)
[10:20] 🔗 GBPUSD bloqué - Position corrélée sur EURUSD (corr=0.80)
[10:20] ❌ GBPUSD: Trade annulé (corrélation)
```

### Exemple 2: Sizing Adaptatif
```
[14:00] EURUSD - Volatility sizing:
        ATR=45 | AvgATR=30 | Ratio=1.50
        Risk: 0.5% → 0.33% (volatilité haute)
        Lot calculé: 0.03 au lieu de 0.05

[18:00] GBPUSD - Volatility sizing:
        ATR=20 | AvgATR=30 | Ratio=0.67
        Risk: 0.5% → 0.75% (volatilité basse)
        Lot calculé: 0.07 au lieu de 0.05
```

---

## 🚀 Tests Recommandés

1. **Backtest** : 6-12 mois avec/sans nouveaux filtres
2. **Forward Test** : 30 jours démo
3. **Comparaison** :
   - v27.54 (sans filtres) vs v27.55 (avec filtres)
   - Métriques : Drawdown, Sharpe, Win Rate, Profit Factor
4. **Ajustement** : Optimiser MaxCorrelation selon résultats

---

**Développé par** : fred-selest
**Repository** : https://github.com/fred-selest/ea-scalping-pro
**Version** : 27.55
**Date** : 2025-11-11
