# 📋 CHANGELOG - EA Multi-Paires Scalping Pro

## Version 27.2 (05 Nov 2025)

### ✨ Nouvelles fonctionnalités
- ✅ **Système d'auto-update** intégré
  - Vérification automatique des mises à jour
  - Téléchargement depuis GitHub
  - Instructions d'installation automatiques
  - Configurable (désactivable)

### 🎨 Améliorations Dashboard
- ✅ Taille augmentée : 400×500 pixels
- ✅ Couleurs optimisées : Fond noir + texte blanc
- ✅ Titre jaune visible : "EA SCALPING MULTI-PAIRES v27"
- ✅ Symboles ASCII standards : ▲▼●◐○
- ✅ Sections bien séparées avec ━━━
- ✅ Police Courier New monospace claire
- ✅ Affichage news dans les 4 prochaines heures
- ✅ Spread actuel en temps réel

### 🔧 Corrections
- ✅ HTTP 429 corrigé avec rate limiting
- ✅ Intervalle rechargement news : 4h → 6h
- ✅ Gestion erreur 429 pour éviter boucle infinie
- ✅ Minimum 5 minutes entre appels API

### 📚 Documentation
- ✅ Guide dashboard v27.2 complet
- ✅ Guide correction HTTP 429
- ✅ Script PowerShell déploiement VPS
- ✅ Instructions auto-update

---

## Version 27.1 (05 Nov 2025)

### 🔧 Corrections critiques
- ✅ Correction erreur HTTP 429 (Too Many Requests)
- ✅ Ajout rate limiting sur API ForexFactory
- ✅ Éviter appels répétés en cas d'erreur
- ✅ Warning OrderSend corrigé

### 📈 Optimisations
- ✅ Gestion d'erreur améliorée
- ✅ Logs plus clairs
- ✅ Performance API optimisée

---

## Version 27.0 (05 Nov 2025)

### ✨ Fonctionnalités majeures
- ✅ **Trading multi-paires simultané**
  - Support 6 paires : EUR/USD, GBP/USD, USD/JPY, AUD/USD, USD/CAD, NZD/USD
  - Gestion indépendante par paire
  - Limites configurables par symbole
  
- ✅ **Filtre news ForexFactory**
  - API JSON officielle
  - Calendrier économique temps réel
  - Arrêt avant news (30 min configurable)
  - Reprise après news (15 min configurable)
  - Filtre par impact (High/Medium/Low)
  - Filtre par devise

- ✅ **Dashboard temps réel**
  - Balance et Equity
  - Positions par paire avec P&L
  - Statistiques quotidiennes
  - Prochaines news (3 événements)
  - Statut EA complet
  - Mise à jour chaque seconde

- ✅ **Scalping professionnel**
  - TP : 5-15 pips
  - SL : 10-25 pips
  - Trailing Stop automatique
  - Break-Even automatique
  - Filtre de spread
  
- ✅ **Gestion du risque avancée**
  - Risk per trade configurable
  - Stop loss quotidien
  - Limitation trades/jour
  - Limitation positions simultanées
  - Limitation par paire

- ✅ **Optimisé FxPro**
  - Compatible MT5 Standard et Raw
  - Détection automatique spread
  - Sessions de trading configurables
  - Calcul lot adaptatif

---

## Version 26.0 (04 Nov 2025)

### Fonctionnalités
- ✅ Scalping une seule paire
- ✅ Support ONNX Runtime (optionnel)
- ✅ Analyse technique (RSI, EMA, ATR)
- ✅ Trailing Stop et Break-Even
- ✅ Compatible FxPro

---

## Version 25.1 (04 Nov 2025)

### Corrections
- ✅ Code original corrigé
- ✅ Gestion mémoire sécurisée
- ✅ Calcul lot avec limites
- ✅ Validation paramètres
- ✅ Gestion erreurs complète

---

## Roadmap Future

### Version 28.0 (Prévu)
- 🔜 Intégration calendrier MT5 natif (CalendarValueHistory)
- 🔜 Support paires exotiques
- 🔜 Alertes Telegram
- 🔜 Statistiques avancées (export Excel)
- 🔜 Mode simulation (sans trading réel)

### Version 29.0 (Prévu)
- 🔜 Machine Learning intégré par paire
- 🔜 Optimisation automatique des paramètres
- 🔜 Backtesting intégré
- 🔜 Dashboard web (consultation à distance)

---

## Comment mettre à jour

### Méthode 1 : Auto-Update (recommandé)
```
1. Activer EnableAutoUpdate = true dans paramètres EA
2. L'EA vérifie automatiquement toutes les 24h
3. Téléchargement et instructions automatiques
```

### Méthode 2 : Manuel
```
1. Télécharger dernière version sur GitHub
2. Remplacer fichier .mq5 dans MQL5\Experts\
3. Recompiler (F7)
4. Réappliquer sur graphiques
```

### Méthode 3 : Script PowerShell
```
1. Exécuter Deploy-EA-VPS.ps1
2. Suivre instructions
3. Installation automatique
```

---

## Support et Contact

- 📖 Documentation : README_SOLUTION_COMPLETE.md
- 🐛 Issues : [GitHub Issues]
- 💬 Forum : [MQL5 Forum]
- 📧 Email : [Votre email support]

---

**Merci d'utiliser EA Multi-Paires Scalping Pro !**

Testez TOUJOURS en démo avant utilisation réelle.
Le trading comporte des risques de perte en capital.
