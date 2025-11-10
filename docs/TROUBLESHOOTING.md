# 🔧 Guide de Dépannage - EA Scalping Pro

Guide complet pour résoudre les problèmes courants rencontrés avec l'EA.

## 📋 Table des Matières

- [Erreurs de Compilation](#erreurs-de-compilation)
- [Erreurs de Trading](#erreurs-de-trading)
- [Problèmes de Performance](#problèmes-de-performance)
- [Problèmes Dashboard](#problèmes-dashboard)
- [Problèmes News Filter](#problèmes-news-filter)
- [Problèmes Auto-Update](#problèmes-auto-update)
- [Logs et Diagnostics](#logs-et-diagnostics)

---

## 🛠️ Erreurs de Compilation

### ❌ Erreur: "array out of range"
**Symptôme:** Crash ou erreur lors de l'accès aux arrays

**Causes possibles:**
- Index d'array invalide
- Données indicateurs pas encore chargées

**Solution:**
```mql5
// Toujours vérifier la taille avant d'accéder
if(ArraySize(array) > index && index >= 0) {
    value = array[index];
}
```

**Vérifications:**
1. Ouvrir Experts > Journal MT5
2. Chercher "array out of range"
3. Noter la ligne du code source

---

### ❌ Erreur: "cannot convert enum"
**Symptôme:** Compilation échoue sur ChartSetInteger

**Cause:** Type incorrect passé à ChartSetInteger

**Solution:**
```mql5
// ✅ CORRECT
ChartSetInteger(0, CHART_SHIFT, (long)1);

// ❌ INCORRECT
ChartSetInteger(0, CHART_SHIFT, 1);
```

---

### ⚠️ Warning: "cannot be used for static allocated array"
**Symptôme:** 4 warnings lors de la compilation

**Cause:** ArraySetAsSeries() sur array statique (CORRIGÉ dans v27.52+)

**Solution:** Mettre à jour vers la dernière version

---

## 🚫 Erreurs de Trading

### ❌ Erreur 10004: "Requester off quotes"
**Symptôme:** Ordres rejetés avec code 10004

**Cause:** Prix demandé plus disponible (marché volatile)

**Solutions:**
1. Augmenter `deviation` dans les paramètres
2. Trader pendant heures liquides (London/NY)
3. Vérifier le spread (ne pas trader si > MaxSpread_Points)

**Code:**
```mql5
request.deviation = 5;  // Augmenter si nécessaire
```

---

### ❌ Erreur 10006: "Request rejected"
**Symptôme:** OrderSend() retourne 10006

**Causes possibles:**
1. **Compte trading désactivé**
   - Vérifier avec broker
   - Autoriser trading algorithmique

2. **Symbol trading désactivé**
   ```mql5
   if(!SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE)) {
       Print("Trading désactivé pour ", symbol);
   }
   ```

3. **Heures de trading fermées**
   - Vérifier session de trading
   - Activer "Autoriser trading en dehors heures" si approprié

**Solution rapide:**
```mql5
// Dans MT5: Outils > Options > Expert Advisors
// ✅ Cocher "Autoriser le trading algorithmique"
```

---

### ❌ Erreur 10009: "Order locked"
**Symptôme:** Impossible de modifier position

**Cause:** Position en cours de traitement

**Solution:**
```mql5
// Attendre que l'ordre soit traité
Sleep(100);
// Réessayer
```

---

### ❌ Erreur 10013: "Invalid request"
**Symptôme:** Paramètres ordre invalides

**Causes:**
1. **Volume invalide**
   ```mql5
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   // Lot doit être: min_lot <= lot <= max_lot
   // Et multiple de lot_step
   ```

2. **SL/TP trop proche**
   ```mql5
   long stops_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   // SL/TP doivent être à au moins stops_level points du prix
   ```

3. **Prix non normalisé**
   ```mql5
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   price = NormalizeDouble(price, digits);
   ```

**Diagnostic:**
```mql5
// Activer MinLogLevel = LOG_DEBUG
// Vérifier les logs pour détails complets
```

---

### ❌ Erreur 10014: "Invalid volume"
**Symptôme:** Volume rejeté par broker

**Solution:**
```mql5
// Vérifier et corriger le volume
double lot = CalculateLotSize(symbol);

double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

lot = MathMax(lot, min_lot);
lot = MathMin(lot, max_lot);
lot = MathFloor(lot / lot_step) * lot_step;
lot = NormalizeDouble(lot, 2);
```

---

### ❌ Erreur 10015: "Invalid stops"
**Symptôme:** SL ou TP rejeté

**Causes:**
1. SL/TP dans mauvais sens
2. SL/TP trop proche (stops_level)
3. SL/TP non normalisé

**Solution:**
```mql5
long stops_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

// Minimum distance
double min_distance = stops_level * point;

// Pour BUY
double sl = NormalizeDouble(price - MathMax(sl_distance, min_distance), digits);
double tp = NormalizeDouble(price + MathMax(tp_distance, min_distance), digits);

// Pour SELL
double sl = NormalizeDouble(price + MathMax(sl_distance, min_distance), digits);
double tp = NormalizeDouble(price - MathMax(tp_distance, min_distance), digits);
```

---

### ❌ Erreur 10016: "Invalid stops in pending order"
**Symptôme:** Ordre en attente rejeté

**Cause:** Prix ordre trop proche du marché

**Solution:**
```mql5
long distance_level = SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL);
double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

// Ordre doit être à au moins distance_level points du prix actuel
double min_distance = distance_level * point;
```

---

### ❌ Erreur 10019: "Not enough money"
**Symptôme:** Fonds insuffisants

**Solutions:**
1. Réduire RiskPercent (ex: 0.5% → 0.2%)
2. Réduire MaxLotSize
3. Déposer plus de fonds
4. Activer hedging si compte le permet

**Vérification:**
```mql5
double balance = AccountInfoDouble(ACCOUNT_BALANCE);
double margin_free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

Print("Balance: ", balance);
Print("Marge libre: ", margin_free);
```

---

### ❌ Erreur 10025: "Trade disabled"
**Symptôme:** Trading désactivé

**Solutions:**
1. Outils > Options > Expert Advisors
   - ✅ Cocher "Autoriser le trading algorithmique"

2. Vérifier bouton "AutoTrading" activé (toolbar MT5)

3. Vérifier input parameter: `Trade_EURUSD = true`

---

### ❌ Erreur 10036: "Symbol not found"
**Symptôme:** Symbole introuvable

**Cause:** Symbol pas dans Market Watch

**Solution:**
```bash
# Dans OnInit(), l'EA ajoute automatiquement les symboles
# Si ça ne fonctionne pas:

1. Ouvrir Market Watch (Ctrl+M)
2. Clic droit > Symbols
3. Chercher le symbole (ex: EURUSD)
4. Activer "Show in Market Watch"
5. Redémarrer l'EA
```

---

## ⚡ Problèmes de Performance

### 🐌 EA très lent / MT5 freeze
**Symptôme:** Interface MT5 gèle, CPU élevé

**Causes:**
1. **Trop de symboles activés**
   - Désactiver symboles non utilisés
   - Recommandé: 3-5 symboles max

2. **Période indicateurs trop courte**
   ```mql5
   // Éviter périodes < 5
   input int EMA_Fast_Period = 10;  // Minimum recommandé
   ```

3. **Logs excessifs**
   ```mql5
   input LOG_LEVEL MinLogLevel = LOG_INFO;  // Pas LOG_DEBUG en prod
   ```

**Solutions:**
```mql5
// Optimisations dans EA v27.52+:
// - Cache indicateurs (1 seconde)
// - Early exit dans boucles position
// - Validation pré-calcul spread

// Si toujours lent:
Trade_AUDUSD = false;  // Désactiver symboles inutilisés
Trade_NZDUSD = false;
```

---

### 💾 Mémoire saturée
**Symptôme:** "not enough memory" errors

**Cause:** Arrays trop grands

**Solution:**
```mql5
// Limiter historique
#define MAX_BARS 1000

// Libérer indicateurs inutilisés
if(handle_indicator != INVALID_HANDLE) {
    IndicatorRelease(handle_indicator);
}
```

---

## 📊 Problèmes Dashboard

### ❌ Dashboard invisible
**Symptôme:** Dashboard n'apparaît pas

**Solutions:**
1. **Vérifier affichage objets**
   ```
   Graphique > Objets > Liste des objets
   Chercher "Dashboard_"
   ```

2. **Vérifier position**
   ```mql5
   // Dashboard est en haut à DROITE (v27.52+)
   // Si hors écran, ajuster Dashboard_X/Dashboard_Y
   input int Dashboard_X = 10;
   input int Dashboard_Y = 20;
   ```

3. **Recréer dashboard**
   ```
   - Retirer EA du graphique
   - Attendre 2 secondes
   - Re-attacher EA
   ```

---

### 📍 Dashboard mal positionné
**Symptôme:** Dashboard hors écran ou superposé

**Solution:**
```mql5
// Ajuster position dans inputs:
input int Dashboard_X = 10;   // Distance du bord droit (pixels)
input int Dashboard_Y = 20;   // Distance du haut (pixels)

// Valeurs recommandées:
// Dashboard_X: 10-50
// Dashboard_Y: 20-100
```

---

### 🔄 Dashboard pas mis à jour
**Symptôme:** Valeurs figées sur dashboard

**Causes:**
1. EA désactivé (bouton AutoTrading)
2. Erreur dans OnTick()

**Solution:**
```bash
# Ouvrir Experts > Journal
# Chercher erreurs EA

# Si pas d'erreur:
1. Vérifier AutoTrading activé
2. Vérifier Trade_EURUSD = true pour au moins 1 symbole
3. Redémarrer EA
```

---

## 📰 Problèmes News Filter

### ❌ Filtre news ne fonctionne pas
**Symptôme:** EA trade pendant news high-impact

**Causes:**
1. **News filter désactivé**
   ```mql5
   input bool UseNewsFilter = true;  // ✅ Doit être true
   ```

2. **Calendrier pas téléchargé**
   ```
   Vérifier dans Journal:
   "News calendar loaded: X events"

   Si 0 events:
   - Vérifier connexion internet
   - URL ForexFactory bloquée?
   ```

3. **Fuseau horaire incorrect**
   ```mql5
   // L'EA utilise GMT automatiquement
   // Si problème, vérifier serveur broker GMT offset
   ```

**Test du filtre:**
```bash
1. Aller sur ForexFactory.com
2. Noter heure prochaine news high-impact
3. Vérifier dashboard EA affiche "NEWS PENDING"
4. Attendre MinutesBeforeNews
5. EA doit stopper trading
```

---

### ⚠️ Warning: "Impossible de charger news"
**Symptôme:** EA continue sans filtre news

**Causes:**
1. **URL bloquée**
   - Firewall/Antivirus bloque
   - Broker proxy bloque WebRequest

2. **Connexion internet**
   - Vérifier ping

**Solution:**
```bash
# Ajouter URL à MT5
Outils > Options > Expert Advisors
Section "Autoriser les appels WebRequest pour les URL"
Ajouter:
- https://nfs.faireconomy.media
- https://cdn-nfs.faireconomy.media
- https://www.forexfactory.com

# Tester URL manuellement:
curl https://nfs.faireconomy.media/ff_calendar_thisweek.json
```

---

## 🔄 Problèmes Auto-Update

### ❌ SHA256 verification failed
**Symptôme:** "ERREUR DE SÉCURITÉ: Hash SHA256 ne correspond pas"

**Cause:** Fichier téléchargé corrompu ou modifié

**Solution:**
```powershell
# NE PAS IGNORER CETTE ERREUR
# C'est une protection sécurité

# Vérifier manuellement:
$url = "https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/EA_MultiPairs_Scalping_Pro.mq5"
$hashUrl = $url + ".sha256"

# Télécharger et comparer
Invoke-WebRequest -Uri $url -OutFile "temp.mq5"
Invoke-WebRequest -Uri $hashUrl -OutFile "temp.sha256"

$actualHash = (Get-FileHash -Path "temp.mq5" -Algorithm SHA256).Hash
$expectedHash = Get-Content "temp.sha256"

if ($actualHash -eq $expectedHash) {
    Write-Host "✅ Hash OK - safe to install"
} else {
    Write-Host "❌ Hash mismatch - DO NOT INSTALL"
}
```

---

### ❌ Rollback failed
**Symptôme:** "CRITIQUE: Impossible de restaurer le backup"

**Cause:** Backup corrompu ou supprimé

**Solution manuelle:**
```powershell
# 1. Trouver backup le plus récent
$backupPath = "C:\Program Files\MetaTrader 5\MQL5\Experts\Backups"
Get-ChildItem $backupPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# 2. Restaurer manuellement
$latestBackup = "EA_MultiPairs_v27.51_20251109_193000.mq5"
Copy-Item "$backupPath\$latestBackup" "C:\Program Files\MetaTrader 5\MQL5\Experts\EA_MultiPairs_Scalping_Pro.mq5" -Force

# 3. Redémarrer MT5
```

---

### ⚠️ Update available but not installing
**Symptôme:** EA détecte update mais ne télécharge pas

**Causes:**
1. **EnableAutoUpdate = false**
   ```mql5
   input bool EnableAutoUpdate = true;  // ✅ Activer
   ```

2. **WebRequest bloqué**
   - Voir section News Filter > URL bloquée

3. **Intervalle check pas atteint**
   ```mql5
   input int CheckUpdateEveryHours = 24;  // Check toutes les 24h
   // Réduire à 1 pour test
   ```

**Forcer check:**
```
1. Retirer EA du graphique
2. Attendre 5 secondes
3. Re-attacher EA
4. Update check forcé à OnInit()
```

---

## 📝 Logs et Diagnostics

### 🔍 Activer logs détaillés

```mql5
// Dans inputs EA:
input LOG_LEVEL MinLogLevel = LOG_DEBUG;  // Mode debug complet
input bool EnableFileLogging = true;       // Logs vers fichier

// Logs sauvegardés dans:
// C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Files\
// Fichier: EA_Scalping_v274_Log_[MagicNumber].txt
```

---

### 📊 Lire les logs

**Ouvrir Journal MT5:**
```
Vue > Boîte à outils > Experts
Onglet "Journal"

Filtrer par EA:
Clic droit > Filter > Nom EA
```

**Types de messages:**
- 🔧 `LOG_DEBUG` - Détails techniques (développement)
- ℹ️ `LOG_INFO` - Informations générales (par défaut)
- ⚠️ `LOG_WARN` - Avertissements (non bloquant)
- ❌ `LOG_ERROR` - Erreurs critiques

---

### 🐛 Rapport de bug

Si problème persiste, créer rapport avec:

**1. Informations système**
```
- Version MT5: Aide > À propos
- Version EA: Voir dashboard (ex: v27.52)
- OS: Windows 10/11, macOS, etc.
- Broker: Nom du broker
- Type compte: Démo/Réel, ECN/Standard
```

**2. Configuration**
```
- Symboles activés: Liste
- Paramètres modifiés: ScalpTP_Pips, etc.
- Timeframe graphique
```

**3. Logs**
```
- Journal MT5 (20 dernières lignes)
- Fichier log si disponible
- Captures d'écran erreur
```

**4. Étapes reproduction**
```
1. ...
2. ...
3. Erreur survient
```

**Créer issue sur GitHub:**
```
https://github.com/fred-selest/ea-scalping-pro/issues/new
```

---

## 📞 Support

### Resources
- **GitHub Issues:** https://github.com/fred-selest/ea-scalping-pro/issues
- **Documentation:** README.md, VERSIONING.md
- **Changelog:** CHANGELOG.md (historique modifications)

### Avant de demander support
- ✅ Vérifier ce guide troubleshooting
- ✅ Vérifier version EA à jour (github.com/fred-selest/ea-scalping-pro)
- ✅ Vérifier logs (Journal MT5)
- ✅ Tester en mode DEMO avant réel

---

**Version:** 1.0
**Dernière mise à jour:** 2025-11-10
**EA Version compatible:** v27.52+
