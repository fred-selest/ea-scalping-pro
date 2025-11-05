# 🤖 EA Multi-Paires Scalping Pro v27.2

Expert Advisor professionnel pour MetaTrader 5 avec trading multi-paires, filtre news en temps réel et dashboard intégré.

[![Version](https://img.shields.io/badge/version-27.2-blue.svg)](https://github.com/votre-user/ea-scalping-pro)
[![MT5](https://img.shields.io/badge/MT5-Build%203800+-green.svg)](https://www.metatrader5.com)
[![License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE)

---

## ✨ Fonctionnalités

### 📊 Trading Multi-Paires
- Support 6 paires simultanées : EUR/USD, GBP/USD, USD/JPY, AUD/USD, USD/CAD, NZD/USD
- Gestion indépendante des indicateurs par paire
- Limites configurables (total + par symbole)
- Diversification automatique du risque

### 📰 Filtre News ForexFactory
- API JSON temps réel
- Arrêt automatique avant news à fort impact
- Configurable : 30 min avant, 15 min après
- Filtre par devise (USD, EUR, GBP, JPY, etc.)
- Filtre par impact (High, Medium, Low)

### 📈 Dashboard Temps Réel
- Balance & Equity en direct
- Positions par paire avec P&L
- Statistiques quotidiennes
- 4 prochaines news économiques
- Statut complet de l'EA
- Mise à jour chaque seconde

### 🎯 Scalping Professionnel
- TP : 5-15 pips
- SL : 10-25 pips
- Trailing Stop automatique
- Break-Even automatique
- Filtre de spread
- Sessions de trading configurables

### 🔄 Auto-Update
- Vérification automatique des mises à jour
- Téléchargement depuis GitHub
- Instructions d'installation automatiques
- Désactivable

---

## 🚀 Installation Rapide

### Prérequis
- MetaTrader 5 Build 3800+
- Broker : FxPro (recommandé) ou compatible
- VPS Windows (recommandé pour scalping)
- Capital minimum : 1000 EUR

### Étape 1 : Configuration WebRequest
```
MT5 → Outils → Options → Expert Advisors → WebRequest
Ajouter ces URLs :
✅ https://nfs.faireconomy.media
✅ https://cdn-nfs.faireconomy.media
✅ https://www.forexfactory.com
✅ https://raw.githubusercontent.com (pour auto-update)
```

### Étape 2 : Installation
```bash
# Télécharger le fichier
git clone https://github.com/votre-user/ea-scalping-pro.git

# Copier dans MT5
Copier EA_MultiPairs_News_Dashboard_v27.mq5
vers: %APPDATA%\MetaQuotes\Terminal\[ID]\MQL5\Experts\

# Compiler
Ouvrir MetaEditor (F4) → F7 pour compiler
```

### Étape 3 : Utilisation
```
1. Glisser EA sur graphique M5 (n'importe quelle paire)
2. Paramètres → Charger preset débutant
3. Vérifier dashboard visible
4. Tester en DÉMO pendant 1 mois minimum
```

---

## ⚙️ Configuration

### Débutant (Capital 1000-3000 EUR)
```
Trade_EURUSD = true
Trade_GBPUSD = false
Trade_USDJPY = false

RiskPercent = 0.25%
MaxOpenPositions = 1
MaxTradesPerDay = 20

UseNewsFilter = true
MinutesBeforeNews = 60
```

### Intermédiaire (Capital 3000-7000 EUR)
```
Trade_EURUSD = true
Trade_GBPUSD = true
Trade_USDJPY = true

RiskPercent = 0.5%
MaxOpenPositions = 3
MaxTradesPerDay = 40

UseNewsFilter = true
MinutesBeforeNews = 30
```

### Avancé (Capital 7000+ EUR)
```
Trade_EURUSD = true
Trade_GBPUSD = true
Trade_USDJPY = true
Trade_AUDUSD = true

RiskPercent = 0.75%
MaxOpenPositions = 5
MaxTradesPerDay = 60

UseNewsFilter = true
MinutesBeforeNews = 20
```

---

## 📊 Résultats Attendus

### Backtest 6 mois (minimum requis)
- ✅ Profit Factor > 1.5
- ✅ Win Rate > 55%
- ✅ Max Drawdown < 15%
- ✅ Recovery Factor > 3.0
- ✅ Sharpe Ratio > 1.0

### Objectifs mensuels réalistes
- 🟢 Conservateur : 3-5% par mois
- 🟡 Modéré : 5-10% par mois
- 🔴 Agressif : 10-15% par mois (risque élevé)

---

## 📚 Documentation

- [📖 Guide Complet](README_SOLUTION_COMPLETE.md)
- [🎨 Guide Dashboard](GUIDE_DASHBOARD_v27.2.md)
- [🔄 Guide Auto-Update](GUIDE_AUTO_UPDATE.md)
- [🔧 Correction HTTP 429](FIX_HTTP_429_ERROR.md)
- [📋 Changelog](CHANGELOG.md)
- [⚙️ Paramètres FxPro](PARAMETRES_OPTIMISES_FXPRO.md)

---

## 🛡️ Sécurité & Conformité

### Broker recommandé : FxPro
- ✅ FCA (UK) - Financial Conduct Authority
- ✅ CySEC (Chypre) - Cyprus Securities
- ✅ FSCA (Afrique du Sud)
- ✅ Scalping autorisé
- ✅ EA autorisés

### Réglementation France (AMF)
- Broker agréé UE/ESMA requis
- Déclaration plus-values obligatoire
- Flat tax 30% ou barème IR

---

## 🐛 Support

### Issues
Signalez les bugs via [GitHub Issues](https://github.com/votre-user/ea-scalping-pro/issues)

### FAQ
Consultez le [Guide Complet](README_SOLUTION_COMPLETE.md)

### Contact
- 📧 Email : votre-email@domain.com
- 💬 Forum : [MQL5 Forum](https://www.mql5.com)

---

## 📋 Changelog

Voir [CHANGELOG.md](CHANGELOG.md) pour l'historique complet des versions.

### Dernière version : 27.2 (05 Nov 2025)
- ✅ Système auto-update intégré
- ✅ Dashboard amélioré (400×500px)
- ✅ Correction HTTP 429
- ✅ Symboles ASCII standards

---

## ⚠️ Avertissements

```
⚠️ Le trading comporte des risques de perte en capital
⚠️ Testez TOUJOURS en démo pendant au moins 1 mois
⚠️ Ne tradez JAMAIS avec de l'argent nécessaire
⚠️ Les performances passées ne garantissent pas les résultats futurs
⚠️ Le scalping nécessite VPS avec latence <20ms
⚠️ Capital minimum recommandé : 1000 EUR par paire
```

---

## 📜 License

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

---

## 🙏 Remerciements

- ForexFactory pour l'API économique
- FxPro pour conditions de trading excellentes
- Communauté MQL5 pour le support

---

## ⭐ Star ce projet

Si cet EA vous aide, donnez une ⭐ sur GitHub !

---

**© 2025 - EA Multi-Paires Scalping Pro**  
**Version : 27.2**  
**Dernière MAJ : 05 Novembre 2025**
