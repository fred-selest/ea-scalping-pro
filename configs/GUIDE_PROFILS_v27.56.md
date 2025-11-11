# Guide des Profils Optimisés v27.56

## 📋 Vue d'Ensemble

Les profils v27.56 sont **optimisés** pour les nouvelles fonctionnalités :
- ✅ **Partial Close** (TP1/TP2)
- ✅ **Filtre Corrélations** (évite double exposition)
- ✅ **Volatility-Based Sizing** (adapte lots à ATR)
- ✅ **TP/SL Dynamiques** (basés ATR)

---

## 🎯 Comparaison Rapide

| Critère | **CONSERVATIVE** | **BALANCED** | **AGGRESSIVE** |
|---------|------------------|--------------|----------------|
| **Niveau** | Débutant | Intermédiaire | Expérimenté |
| **Capital Min** | 1000$ | 2000$ | 5000$ |
| **Risque/Trade** | 0.3% | 0.5% | 1.0% |
| **Paires** | 3 (EUR/JPY/CAD) | 3 (EUR/JPY/AUD) | 4 (EUR/GBP/JPY/AUD) |
| **Drawdown Max** | 5-8% | 8-12% | 15-25% |
| **Profit/Mois** | 3-7% | 8-15% | 15-30% |
| **Trades/Jour** | 5-10 | 10-20 | 20-40 |
| **Sharpe Ratio** | 1.5-2.0 | 1.3-1.8 | 1.0-1.5 |
| **Surveillance** | Minimale | Modérée | Active |

---

## 🟢 CONSERVATIVE - Sécurité Maximale

### **Profil Idéal Pour :**
- ✅ Débutants en trading automatisé
- ✅ Comptes < 5000$
- ✅ Tolérance au risque faible
- ✅ Set & forget (surveillance minimale)
- ✅ Préservation du capital prioritaire

### **Configuration Paires**
```
✓ EURUSD - Major #1, spread minimal
✓ USDJPY - Safe haven, corrélation faible (0.15)
✓ USDCAD - Commodity, corrélation inverse (-0.55)
✗ GBPUSD - Évité (corrélé EUR 0.80)
```

### **Avantages Corrélations**
- **EURUSD ↔ USDJPY** : 0.15 → Excellent (quasi indépendants)
- **EURUSD ↔ USDCAD** : -0.55 → Diversification (inverse)
- **USDJPY ↔ USDCAD** : 0.10 → Excellent (négligeable)

**= Aucun risque de blocage par filtre corrélation !**

### **Paramètres Clés**
```
RiskPercent = 0.3%
MaxCorrelation = 0.60 (strict)
ADX_Threshold = 25.0 (évite range)
ATR_TP_Multiplier = 2.0 (TP larges)
ATR_SL_Multiplier = 3.0 (SL sécuritaires)
MaxVolatilityMultiplier = 1.5× (conservateur)
PartialClose = 50% à TP1
```

### **Résultats Attendus**
- 📈 **Profit mensuel** : 3-7% (stable)
- 📉 **Drawdown max** : 5-8% (excellent)
- 🎯 **Win rate** : 55-65%
- ⏱️ **Trades/jour** : 5-10 (qualité > quantité)

### **Capital Recommandé**
- Minimum : **1000$**
- Optimal : **2000-5000$**

---

## 🟡 BALANCED - Équilibre Performance/Risque

### **Profil Idéal Pour :**
- ✅ Traders intermédiaires
- ✅ Comptes 2000-10000$
- ✅ Tolérance risque modérée
- ✅ Recherche croissance stable
- ✅ Diversification géographique

### **Configuration Paires**
```
✓ EURUSD - Europe, liquidité maximale
✓ USDJPY - Asie/Safe haven
✓ AUDUSD - Océanie, risk-on indicator
✗ GBPUSD - Évité (corrélé EUR 0.80)
```

### **Stratégie Risk-On/Off**
**Point fort unique** : USDJPY et AUDUSD **inversement corrélés** (-0.65)

```
Marchés Risk-On (optimisme) :
  → AUDUSD ↗️ monte (commodities)
  → USDJPY ↘️ baisse (JPY faible)
  → Opportunités AUDUSD

Marchés Risk-Off (peur) :
  → USDJPY ↗️ monte (safe haven)
  → AUDUSD ↘️ baisse (risk assets)
  → Opportunités USDJPY
```

**= Opportunités dans TOUS les environnements !**

### **Gestion Corrélations**
- **EURUSD ↔ AUDUSD** : 0.75 → **Filtre bloquera si simultané**
- **EURUSD ↔ USDJPY** : 0.15 → Toujours OK
- **USDJPY ↔ AUDUSD** : -0.65 → Inverse = diversification

**En pratique** : Maximum 2 positions simultanées

### **Paramètres Clés**
```
RiskPercent = 0.5%
MaxCorrelation = 0.70 (standard)
ADX_Threshold = 20.0 (équilibré)
ATR_TP_Multiplier = 1.5
ATR_SL_Multiplier = 2.0
MaxVolatilityMultiplier = 2.0×
UseONNX = true (AI activé)
```

### **Résultats Attendus**
- 📈 **Profit mensuel** : 8-15% (bon potentiel)
- 📉 **Drawdown max** : 8-12% (acceptable)
- 🎯 **Win rate** : 50-60%
- ⏱️ **Trades/jour** : 10-20

### **Capital Recommandé**
- Minimum : **2000$**
- Optimal : **5000-10000$**

---

## 🔴 AGGRESSIVE - Performance Maximale

### **⚠️ AVERTISSEMENT**
**Profil pour traders EXPÉRIMENTÉS uniquement !**
- Risque drawdown 15-25%
- Surveillance active recommandée
- Capital minimum 5000$ OBLIGATOIRE

### **Profil Idéal Pour :**
- ✅ Traders expérimentés (> 1 an)
- ✅ Comptes > 10000$
- ✅ Haute tolérance risque
- ✅ Recherche performance agressive
- ✅ Surveillance active possible

### **Configuration Paires (4 actives)**
```
✓ EURUSD - Major #1
✓ GBPUSD - Major #2 (corrélé EUR!)
✓ USDJPY - Major #3
✓ AUDUSD - Océanie
✗ NZDUSD - Évité (corrélé AUD 0.85)
```

### **⚠️ Corrélations Élevées**
```
EURUSD ↔ GBPUSD : 0.80 (ÉLEVÉ)
EURUSD ↔ AUDUSD : 0.75
GBPUSD ↔ AUDUSD : 0.78
USDJPY ↔ AUDUSD : -0.65
```

### **Stratégie Filtre (CRUCIAL)**
`MaxCorrelation = 0.80` (vs 0.70 standard)

**Scénarios possibles** :
```
Scénario 1: EURUSD + GBPUSD simultanés
  → Corrélation 0.80 = LIMITE (juste autorisé)
  → AUDUSD bloqué (corr 0.75-0.78)
  → USDJPY OK (corr faible)

Scénario 2: EURUSD + USDJPY
  → GBPUSD peut passer (corr 0.80)
  → AUDUSD bloqué (corr 0.75)

Maximum réel : 2-3 positions simultanées
```

### **Paramètres Agressifs**
```
RiskPercent = 1.0% (double standard)
MaxCorrelation = 0.80 (permissif)
ADX_Threshold = 15.0 (accepte plus)
ATR_TP_Multiplier = 1.0 (TP serrés)
ATR_SL_Multiplier = 1.5 (scalping pur)
TP1_Multiplier = 0.8 (profit rapide)
MaxVolatilityMultiplier = 2.5×
MinConfidence = 0.65 (AI moins strict)
```

### **Résultats Attendus**
- 📈 **Profit mensuel** : 15-30% (haute perf)
- 📉 **Drawdown max** : 15-25% (ÉLEVÉ)
- 🎯 **Win rate** : 45-55%
- ⏱️ **Trades/jour** : 20-40 (très actif)

### **Capital Recommandé**
- Minimum : **5000$** (OBLIGATOIRE)
- Optimal : **10000-20000$**

### **⚠️ Recommandations Critiques**
1. ✅ Tester **30 jours en DÉMO** avant live
2. ✅ Commencer avec **50% du capital**
3. ✅ Monitoring quotidien obligatoire
4. ✅ Stop si drawdown > 15%
5. ✅ Review hebdomadaire par paire
6. ✅ Spreads broker < 2 pips (impact élevé)
7. ✅ VPS recommandé (stabilité)

---

## 📊 Tableau Comparatif Détaillé

### **Paires par Profil**

| Paire | Conservative | Balanced | Aggressive | Raison |
|-------|-------------|----------|------------|--------|
| **EURUSD** | ✅ | ✅ | ✅ | Major #1 - obligatoire |
| **GBPUSD** | ❌ | ❌ | ✅ | Corrélé EUR (0.80) |
| **USDJPY** | ✅ | ✅ | ✅ | Safe haven - essentiel |
| **AUDUSD** | ❌ | ✅ | ✅ | Risk-on, actif hors Asie OK |
| **USDCAD** | ✅ | ❌ | ❌ | Commodity, inverse EUR |
| **NZDUSD** | ❌ | ❌ | ❌ | Trop corrélé AUD (0.85) |

### **Paramètres Risque**

| Paramètre | Conservative | Balanced | Aggressive |
|-----------|--------------|----------|------------|
| **RiskPercent** | 0.3% | 0.5% | 1.0% |
| **MaxLotSize** | 0.2 | 0.5 | 2.0 |
| **MaxDailyLoss** | 1.5% | 3.0% | 5.0% |
| **MaxPositions** | 2 | 3 | 5 |
| **MaxCorrelation** | 0.60 | 0.70 | 0.80 |

### **Paramètres TP/SL**

| Paramètre | Conservative | Balanced | Aggressive |
|-----------|--------------|----------|------------|
| **ATR_TP_Mult** | 2.0× | 1.5× | 1.0× |
| **ATR_SL_Mult** | 3.0× | 2.0× | 1.5× |
| **TP1_Mult** | 1.2× | 1.0× | 0.8× |
| **TP2_Mult** | 3.0× | 2.5× | 2.0× |
| **ADX_Threshold** | 25.0 | 20.0 | 15.0 |

---

## 🚀 Installation et Utilisation

### **1. Charger un Profil dans MT5**

```
1. Ouvrir MetaTrader 5
2. Glisser EA sur graphique (n'importe quelle paire)
3. Dans onglet "Inputs" :
   → Cliquer bouton "Load"
   → Sélectionner fichier .set désiré :
      • EA_Scalping_v27.56_Conservative.set
      • EA_Scalping_v27.56_Balanced.set
      • EA_Scalping_v27.56_Aggressive.set
4. Vérifier paramètres chargés
5. Activer "Allow Algo Trading"
6. Cliquer OK
```

### **2. Vérifications Post-Installation**

✅ **Checklist obligatoire** :
```
□ MagicNumber = 270560 (v27.56)
□ UseCorrelationFilter = true
□ UseVolatilityBasedSizing = true
□ UseDynamicTPSL = true
□ UsePartialClose = true
□ ShowDashboard = true
□ Paires configurées selon profil
□ "Allow WebRequest" activé (Tools → Options)
□ URL ForexFactory autorisée
```

### **3. Test Recommandé**

**Phase 1 : Démo (OBLIGATOIRE)**
```
Durée : 30 jours minimum
Compte : Démo avec capital identique au live
Surveillance : Quotidienne
Métriques : Drawdown, Win Rate, Profit Factor
```

**Phase 2 : Live Progressif**
```
Semaine 1-2 : 25% du capital
Semaine 3-4 : 50% du capital
Semaine 5+   : 100% si résultats OK
```

---

## 📈 Sessions de Trading Optimales

### **Londres + New York (Configuration Actuelle)**
```
Sessions actives :
  Trade_Asian = false
  Trade_London = true
  Trade_NewYork = true

Meilleurs horaires (GMT) :
  08:00-17:00 : Session Londres
  13:00-17:00 : Overlap Londres/NY (MAXIMUM liquidité)
  17:00-22:00 : Session New York

Paires les plus actives :
  EURUSD : 08:00-22:00 (excellent toute la journée)
  GBPUSD : 08:00-17:00 (maximum à Londres)
  USDJPY : 08:00-22:00 (actif toutes sessions)
  USDCAD : 13:00-22:00 (best NY)
```

### **Si Activation Session Asie**
```
Trade_Asian = true (optionnel)

Recommandations :
  → Ajouter AUDUSD (très actif Sydney/Tokyo)
  → USDJPY excellent (home market Tokyo)
  → EURUSD/GBPUSD spreads plus larges
  → Vérifier spreads broker durant Asie

Horaires Asie (GMT) :
  00:00-09:00 : Sessions Sydney + Tokyo
```

---

## 🎓 Conseils Avancés

### **Optimiser pour votre Broker**

#### **Spreads**
```
Si spreads broker > moyennes :
  → Augmenter MaxSpread_Points
  → Préférer profil Conservative
  → Éviter profil Aggressive

Spreads typiques :
  EURUSD : 0.5-1.5 pips
  GBPUSD : 1.0-2.5 pips
  USDJPY : 0.5-1.5 pips
  AUDUSD : 1.0-2.0 pips
  USDCAD : 1.5-2.5 pips
```

#### **Commissions**
```
Si commissions élevées (> 5$/lot) :
  → Augmenter TP (moins de trades)
  → ATR_TP_Multiplier +0.5
  → MaxTradesPerDay -30%
```

### **Ajustements Saisonniers**

#### **Été (Juin-Août)**
```
Liquidité réduite (vacances) :
  → Réduire MaxPositions (-1)
  → Augmenter ADX_Threshold (+5)
  → MinutesBeforeNews +10
```

#### **Fin d'Année (Décembre)**
```
Volatilité erratique :
  → Passer profil inférieur
  → OU pause trading (23 déc - 2 jan)
```

### **Monitoring Performance**

#### **Métriques Clés**
```
Quotidien :
  □ Drawdown actuel
  □ Profit du jour
  □ Trades bloqués par corrélation

Hebdomadaire :
  □ Win rate par paire
  □ Profit factor global
  □ Max drawdown semaine
  □ Trades par paire

Mensuel :
  □ Sharpe Ratio
  □ Recovery factor
  □ Analyse news impacts
  □ Backtest vs résultats réels
```

#### **Red Flags (Arrêter Trading)**
```
⚠️ Drawdown > 15% (Aggressive)
⚠️ Drawdown > 10% (Balanced)
⚠️ Drawdown > 7% (Conservative)
⚠️ 5 pertes consécutives
⚠️ Win rate < 40% (sur 100 trades min)
⚠️ Slippage constant > 1 pip
```

---

## 🔄 Migration depuis Anciennes Versions

### **Depuis v27.54 → v27.56**

```
1. Fermer toutes positions v27.54
2. Sauvegarder anciens paramètres (.set)
3. Charger nouveau profil v27.56
4. Vérifier nouveaux paramètres :
   ✓ UsePartialClose
   ✓ PartialClosePercent
   ✓ TP1/TP2 Multipliers
   ✓ MoveSLToBreakEvenAfterTP1
5. MagicNumber changé : 270540 → 270560
   (nouvelles positions séparées)
```

### **Depuis v27.53 et antérieurs**

```
Nouveaux paramètres v27.54+ v27.55+ à configurer :
  □ UseDynamicTPSL
  □ ATR_TP_Multiplier
  □ ATR_SL_Multiplier
  □ ADX_Period
  □ ADX_Threshold
  □ UseCorrelationFilter
  □ MaxCorrelation
  □ UseVolatilityBasedSizing
  □ MaxVolatilityMultiplier
  □ UsePartialClose (v27.56)
  □ TP1/TP2 settings (v27.56)

Recommandation : Utiliser profils .set fournis
```

---

## 📞 Support et Ressources

### **Documentation**
- `CHANGELOG_v27.56.md` - Détails partial close
- `CHANGELOG_v27.55.md` - Corrélations + volatilité
- `CHANGELOG_v27.54.md` - ADX + dynamic TP/SL
- `docs/API.md` - Documentation technique
- `docs/TROUBLESHOOTING.md` - Résolution problèmes

### **Repository**
- GitHub : https://github.com/fred-selest/ea-scalping-pro
- Issues : https://github.com/fred-selest/ea-scalping-pro/issues

### **Auteur**
- Développeur : fred-selest
- Version : 27.56
- Date : 2025-11-11

---

## ✅ Checklist Finale

**Avant de commencer le trading live** :

```
□ Profil choisi selon expérience et capital
□ Fichier .set chargé correctement
□ MagicNumber = 270560
□ Toutes nouvelles features activées
□ 30 jours minimum en démo
□ Résultats démo satisfaisants
□ Capital suffisant (voir recommandations)
□ Broker spreads vérifiés
□ VPS configuré (optionnel mais recommandé)
□ Monitoring quotidien planifié
□ Limites de drawdown définies
□ Backup paramètres effectué
```

**Bonne chance avec votre trading ! 🚀**
