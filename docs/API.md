# 📚 API Documentation - EA Scalping Pro

Documentation complète des fonctions publiques et structures de données de l'EA.

## 📋 Table des Matières

- [Constantes](#constantes)
- [Structures de Données](#structures-de-données)
- [Fonctions Publiques](#fonctions-publiques)
  - [Validation](#validation)
  - [Trading](#trading)
  - [Position Management](#position-management)
  - [Indicators](#indicators)
  - [News Calendar](#news-calendar)
  - [Dashboard](#dashboard)
  - [Auto-Update](#auto-update)
  - [Utilities](#utilities)

---

## 🔢 Constantes

### Trading Constants
```mql5
#define PIPS_TO_POINTS_MULTIPLIER 10    // Conversion pips→points (4/5 digit brokers)
#define MIN_TP_PIPS_LIMIT 1.0           // Minimum realistic Take Profit (pips)
#define MIN_SL_PIPS_LIMIT 2.0           // Minimum realistic Stop Loss (pips)
#define MAX_TP_PIPS_LIMIT 100           // Maximum Take Profit (pips)
#define MAX_SL_PIPS_LIMIT 200           // Maximum Stop Loss (pips)
```

### News & Update Constants
```mql5
#define MIN_NEWS_UPDATE_INTERVAL 300    // Minimum 5 min between news API calls
#define NEWS_RELOAD_INTERVAL 21600      // Reload news every 6 hours
#define WEBQUEST_TIMEOUT_MS 5000        // WebRequest timeout (milliseconds)
#define HOURS_TO_SECONDS 3600           // Conversion factor
#define MIN_JSON_FILE_SIZE 1000         // Minimum expected JSON file size
```

### Dashboard Constants
```mql5
#define DASHBOARD_UPDATE_INTERVAL 2     // Update dashboard every 2 seconds
#define DASHBOARD_BG_WIDTH_PX 360       // Dashboard background width (pixels)
#define DASHBOARD_BG_HEIGHT_PX 300      // Dashboard background height (pixels)
#define DASHBOARD_TITLE_OFFSET_X 340    // Title X offset from right edge
#define DASHBOARD_TEXT_OFFSET_X 345     // Text X offset from right edge
```

### Performance Constants
```mql5
#define INDICATOR_CACHE_SECONDS 1       // Cache indicator values for N seconds
#define SECONDS_PER_DAY 86400           // Seconds in a day
#define RISK_WARNING_THRESHOLD 2.0      // Risk % threshold for warnings
```

---

## 📦 Structures de Données

### NewsEvent
Structure pour stocker événements du calendrier économique.

```mql5
struct NewsEvent {
   datetime time;      // Heure de l'événement (GMT)
   string title;       // Titre de l'événement
   string country;     // Pays (ex: "USD", "EUR")
   string impact;      // Impact: "High", "Medium", "Low"
   string forecast;    // Prévision
   string previous;    // Valeur précédente
};
```

**Exemple d'utilisation:**
```mql5
NewsEvent news_events[];
// ... chargement calendrier

for(int i=0; i<ArraySize(news_events); i++) {
    if(news_events[i].impact == "High") {
        Print("High-impact news: ", news_events[i].title,
              " at ", TimeToString(news_events[i].time));
    }
}
```

---

### SymbolIndicators
Structure pour gérer les indicateurs techniques par symbole.

```mql5
struct SymbolIndicators {
   string symbol;              // Nom du symbole (ex: "EURUSD")
   int handle_ema_fast;        // Handle EMA rapide
   int handle_ema_slow;        // Handle EMA lente
   int handle_rsi;             // Handle RSI
   int handle_atr;             // Handle ATR
   bool enabled;               // Symbole activé pour trading
   int positions_count;        // Nombre de positions ouvertes
   double last_profit;         // Dernier profit/perte
};
```

**Exemple d'utilisation:**
```mql5
SymbolIndicators indicators[];

// Initialiser pour EURUSD
int idx = 0;
indicators[idx].symbol = "EURUSD";
indicators[idx].handle_ema_fast = iMA("EURUSD", PERIOD_CURRENT, 10, 0, MODE_EMA, PRICE_CLOSE);
indicators[idx].enabled = true;
```

---

### CachedIndicators
Structure pour cache des valeurs indicateurs (optimisation performance).

```mql5
struct CachedIndicators {
   double ema_fast[3];     // Cache EMA rapide (3 dernières valeurs)
   double ema_slow[3];     // Cache EMA lente (3 dernières valeurs)
   double rsi[3];          // Cache RSI (3 dernières valeurs)
   double atr[2];          // Cache ATR (2 dernières valeurs)
   datetime last_update;   // Timestamp dernière mise à jour
};
```

**Notes:**
- Arrays statiques (taille fixe)
- Cache valide pendant INDICATOR_CACHE_SECONDS (1 seconde)
- Réduit appels CopyBuffer() et améliore CPU

---

## 🔧 Fonctions Publiques

### Validation

#### `ValidateInputParameters()`
Valide tous les paramètres d'entrée au démarrage de l'EA.

**Signature:**
```mql5
bool ValidateInputParameters()
```

**Retourne:**
- `true` si tous les paramètres sont valides
- `false` si au moins un paramètre invalide

**Validations effectuées:**
- `ScalpTP_Pips`: MIN_TP_PIPS_LIMIT ≤ value ≤ MAX_TP_PIPS_LIMIT
- `ScalpSL_Pips`: MIN_SL_PIPS_LIMIT ≤ value ≤ MAX_SL_PIPS_LIMIT
- `TrailingStop_Pips`: 0 ≤ value ≤ 100
- `BreakEven_Pips`: 0 ≤ value ≤ 50
- `MaxSpread_Points`: > 0
- `RiskPercent`: 0 < value ≤ 10
- `MaxLotSize`: > 0
- `MaxDailyLoss`: 0 < value ≤ 50
- `MaxTradesPerDay`: > 0
- `MaxOpenPositions`: > 0
- `MaxPositionsPerSymbol`: > 0
- Ratio risque/récompense: TP vs SL
- Risk warnings si RiskPercent > RISK_WARNING_THRESHOLD

**Exemple:**
```mql5
int OnInit() {
    if(!ValidateInputParameters()) {
        Print("❌ Paramètres invalides - EA désactivé");
        return INIT_PARAMETERS_INCORRECT;
    }
    return INIT_SUCCEEDED;
}
```

---

#### `AddWebRequestURL()`
Ajoute les URLs autorisées pour WebRequest (ForexFactory news).

**Signature:**
```mql5
void AddWebRequestURL()
```

**URLs ajoutées:**
- https://nfs.faireconomy.media
- https://cdn-nfs.faireconomy.media
- https://www.forexfactory.com

**Notes:**
- Appelée automatiquement dans OnInit()
- Utilisateur doit accepter manuellement dans MT5
- Nécessaire pour LoadNewsCalendar()

---

### Trading

#### `OpenPosition()`
Ouvre une nouvelle position de trading.

**Signature:**
```mql5
bool OpenPosition(string symbol, int direction)
```

**Paramètres:**
- `symbol` (string): Nom du symbole (ex: "EURUSD")
- `direction` (int): Direction du trade
  - `> 0`: BUY
  - `< 0`: SELL

**Retourne:**
- `true` si position ouverte avec succès
- `false` si échec

**Comportement:**
1. Calcule lot size avec CalculateLotSize()
2. Récupère prix BID/ASK
3. Configure SL/TP selon ScalpSL_Pips et ScalpTP_Pips
4. Envoie ordre avec OrderSend()
5. Log détaillé en cas d'erreur (prix, volume, SL, TP, spread, etc.)

**Exemple:**
```mql5
// Ouvrir BUY sur EURUSD
if(OpenPosition("EURUSD", 1)) {
    Print("✅ Position BUY ouverte");
} else {
    Print("❌ Échec ouverture position");
}

// Ouvrir SELL sur GBPUSD
if(OpenPosition("GBPUSD", -1)) {
    Print("✅ Position SELL ouverte");
}
```

---

#### `CalculateLotSize()`
Calcule la taille du lot basé sur le risque et le SL.

**Signature:**
```mql5
double CalculateLotSize(string symbol)
```

**Paramètres:**
- `symbol` (string): Nom du symbole

**Retourne:**
- `double`: Taille du lot normalisée

**Calcul:**
```
risk_amount = balance × RiskPercent / 100
sl_points = ScalpSL_Pips × PIPS_TO_POINTS_MULTIPLIER
lot = risk_amount / (sl_points × tick_value / tick_size)
```

**Contraintes appliquées:**
- lot ≥ SYMBOL_VOLUME_MIN
- lot ≤ min(SYMBOL_VOLUME_MAX, MaxLotSize)
- lot arrondi au SYMBOL_VOLUME_STEP
- lot normalisé à 2 décimales

**Exemple:**
```mql5
double lot = CalculateLotSize("EURUSD");
Print("Lot calculé: ", DoubleToString(lot, 2));

// Exemple output: "Lot calculé: 0.05"
```

---

#### `CanOpenNewTrade()`
Vérifie si un nouveau trade peut être ouvert (toutes vérifications).

**Signature:**
```mql5
bool CanOpenNewTrade(string symbol)
```

**Paramètres:**
- `symbol` (string): Nom du symbole à trader

**Retourne:**
- `true` si trade autorisé
- `false` sinon

**Vérifications effectuées:**
1. **News Filter**: IsNewsTime() si UseNewsFilter activé
2. **Daily Reset**: CheckDailyReset()
3. **Limites journalières**:
   - trades_today < MaxTradesPerDay
   - daily_profit > -(balance × MaxDailyLoss / 100)
4. **Limites positions**:
   - GetTotalPositions() < MaxOpenPositions
   - GetSymbolPositions() < MaxPositionsPerSymbol

**Exemple:**
```mql5
if(CanOpenNewTrade("EURUSD")) {
    int signal = GetSignalForSymbol("EURUSD");
    if(signal != 0) {
        OpenPosition("EURUSD", signal);
    }
}
```

---

### Position Management

#### `CountPositions()`
**✅ NEW v27.52:** Helper function pour compter positions (principe DRY).

**Signature:**
```mql5
int CountPositions(string symbol_filter = "", int max_count = 0)
```

**Paramètres:**
- `symbol_filter` (string, optionnel): Filtre par symbole
  - `""` (défaut): Compte toutes positions
  - `"EURUSD"`: Compte uniquement EURUSD
- `max_count` (int, optionnel): Limite max (early exit optimization)
  - `0` (défaut): Pas de limite
  - `5`: S'arrête à 5 positions

**Retourne:**
- `int`: Nombre de positions correspondant aux critères

**Exemple:**
```mql5
// Compter toutes positions
int total = CountPositions();

// Compter positions EURUSD uniquement
int eurusd_count = CountPositions("EURUSD");

// Compter avec early exit à 5
int limited = CountPositions("", 5);
```

---

#### `GetTotalPositions()`
Compte le nombre total de positions ouvertes par cet EA.

**Signature:**
```mql5
int GetTotalPositions()
```

**Retourne:**
- `int`: Nombre total de positions (filtré par MagicNumber)

**Notes:**
- Utilise CountPositions() helper (v27.52+)
- Early exit optimization si count >= MaxOpenPositions

**Exemple:**
```mql5
int total = GetTotalPositions();
Print("Positions ouvertes: ", total, "/", MaxOpenPositions);
```

---

#### `GetSymbolPositions()`
Compte positions ouvertes pour un symbole spécifique.

**Signature:**
```mql5
int GetSymbolPositions(string symbol)
```

**Paramètres:**
- `symbol` (string): Nom du symbole

**Retourne:**
- `int`: Nombre de positions pour ce symbole

**Notes:**
- Utilise CountPositions() helper (v27.52+)
- Early exit si count >= MaxPositionsPerSymbol

**Exemple:**
```mql5
int eurusd_positions = GetSymbolPositions("EURUSD");
if(eurusd_positions >= MaxPositionsPerSymbol) {
    Print("Limite atteinte pour EURUSD: ", eurusd_positions);
}
```

---

#### `ManageAllPositions()`
Gère toutes les positions ouvertes (trailing stop, break-even).

**Signature:**
```mql5
void ManageAllPositions()
```

**Actions effectuées:**
Pour chaque position avec ce MagicNumber:
1. **Trailing Stop**: Déplace SL selon profit
2. **Break-Even**: Place SL à prix d'entrée + commission
3. **Calcul profit journalier**: Mise à jour daily_profit

**Trailing Stop Logic:**
```
Si position_profit >= TrailingStop_Pips:
    new_sl = current_price - TrailingStop_Pips (pour BUY)
    new_sl = current_price + TrailingStop_Pips (pour SELL)

    Si new_sl meilleur que current_sl:
        Modifier SL
```

**Break-Even Logic:**
```
Si position_profit >= BreakEven_Pips:
    new_sl = open_price + 1 pip (pour BUY)
    new_sl = open_price - 1 pip (pour SELL)
```

**Exemple:**
```mql5
void OnTick() {
    ManageAllPositions();  // Appelé automatiquement
}
```

---

#### `CheckDailyReset()`
Réinitialise compteurs journaliers à minuit.

**Signature:**
```mql5
void CheckDailyReset()
```

**Actions:**
- Vérifie si nouveau jour (TimeCurrent() vs current_day)
- Si nouveau jour:
  - trades_today = 0
  - daily_profit = 0
  - current_day = nouveau jour
  - Log "🌅 Nouveau jour de trading"

**Notes:**
- Appelée automatiquement dans OnTick() et CanOpenNewTrade()
- Cache avec last_daily_check (évite checks répétitifs)

---

### Indicators

#### `UpdateIndicatorCache()`
**✅ REFACTORED v27.52:** Met à jour le cache des indicateurs (fixed static array warnings).

**Signature:**
```mql5
void UpdateIndicatorCache(int idx)
```

**Paramètres:**
- `idx` (int): Index dans indicators[] array

**Comportement:**
1. Check cache validity (last_update < INDICATOR_CACHE_SECONDS)
2. Si expiré:
   - Crée temp dynamic arrays
   - CopyBuffer() vers temp arrays
   - Copie vers cache static arrays
   - Update timestamp

**Optimisations:**
- Cache valide 1 seconde → réduit appels CopyBuffer
- Utilise temp arrays → élimine warnings compilation

**Exemple:**
```mql5
// Appelé automatiquement par GetSignalForSymbol()
UpdateIndicatorCache(0);  // Update cache pour symbole 0
```

---

#### `GetSignalForSymbol()`
Analyse indicateurs techniques et retourne signal de trading.

**Signature:**
```mql5
int GetSignalForSymbol(string symbol)
```

**Paramètres:**
- `symbol` (string): Symbole à analyser

**Retourne:**
- `1`: Signal BUY
- `-1`: Signal SELL
- `0`: Aucun signal / conditions non remplies

**Conditions BUY:**
```
1. EMA_fast[0] > EMA_slow[0] (crossover haussier)
2. RSI[0] < 70 (pas suracheté)
3. Spread <= MaxSpread_Points
```

**Conditions SELL:**
```
1. EMA_fast[0] < EMA_slow[0] (crossover baissier)
2. RSI[0] > 30 (pas survendu)
3. Spread <= MaxSpread_Points
```

**Exemple:**
```mql5
int signal = GetSignalForSymbol("EURUSD");
if(signal == 1) {
    Print("Signal BUY détecté");
    OpenPosition("EURUSD", 1);
} else if(signal == -1) {
    Print("Signal SELL détecté");
    OpenPosition("EURUSD", -1);
}
```

---

### News Calendar

#### `LoadNewsCalendar()`
Télécharge et parse le calendrier économique ForexFactory.

**Signature:**
```mql5
bool LoadNewsCalendar()
```

**Retourne:**
- `true` si calendrier chargé avec succès
- `false` si échec

**Source:**
- URL: https://nfs.faireconomy.media/ff_calendar_thisweek.json
- Format: JSON
- Timeout: WEBQUEST_TIMEOUT_MS (5000ms)

**Comportement:**
1. Check last_news_update (MIN_NEWS_UPDATE_INTERVAL)
2. WebRequest() pour télécharger JSON
3. Parse JSON vers news_events[] array
4. Log nombre d'événements chargés

**Retry Logic:**
- Si échec et (now - last_attempt) < MIN_NEWS_UPDATE_INTERVAL:
  - Return false (évite spam)
- Sinon:
  - Retry download

**Exemple:**
```mql5
if(LoadNewsCalendar()) {
    Print("Calendrier chargé: ", ArraySize(news_events), " événements");
} else {
    Print("Échec chargement calendrier");
}
```

---

#### `IsNewsTime()`
Vérifie si trading doit être suspendu (événement high-impact imminent).

**Signature:**
```mql5
bool IsNewsTime(string symbol)
```

**Paramètres:**
- `symbol` (string): Symbole à vérifier (ex: "EURUSD")

**Retourne:**
- `true` si dans fenêtre news (suspendre trading)
- `false` si safe pour trader

**Logique:**
```
Pour chaque événement dans news_events[]:
    Si event.impact == "High":
        Si symbol contient event.country (ex: EURUSD contient "USD"):
            before_window = event.time - MinutesBeforeNews*60
            after_window = event.time + MinutesAfterNews*60

            Si before_window <= now <= after_window:
                Return true (SUSPENDRE)
```

**Exemple:**
```mql5
if(IsNewsTime("EURUSD")) {
    Print("⚠️ News high-impact détectée - Trading suspendu");
    return;  // Ne pas trader
}

// Safe pour trader
OpenPosition("EURUSD", signal);
```

---

### Dashboard

#### `CreateDashboard()`
Crée le dashboard visuel sur le graphique MT5.

**Signature:**
```mql5
void CreateDashboard()
```

**Éléments créés:**
1. **Background**: Rectangle CORNER_RIGHT_UPPER
   - Taille: DASHBOARD_BG_WIDTH_PX × DASHBOARD_BG_HEIGHT_PX
   - Position: (Dashboard_X, Dashboard_Y)

2. **Title**: Label "EA SCALPING v27.52"
   - Font: Arial Black, 11pt
   - Couleur: Yellow
   - Offset: DASHBOARD_TITLE_OFFSET_X

3. **14 lignes de texte**: Labels dynamiques
   - Font: Courier New, 9pt
   - Spacing: 18px entre lignes
   - Offset: DASHBOARD_TEXT_OFFSET_X

**Notes:**
- Appelée automatiquement dans OnInit()
- Dashboard positionné en haut à DROITE (v27.52+)
- Objets nommés: "Dashboard_BG", "Dashboard_Title", "Dash_0" à "Dash_13"

---

#### `UpdateDashboard()`
Met à jour le contenu du dashboard (appelée régulièrement).

**Signature:**
```mql5
void UpdateDashboard()
```

**Informations affichées:**
```
EA SCALPING v27.52
─────────────────────────
Balance: 10000.00 $
Daily P/L: +125.50 $
Positions: 3 / 5
Trades Today: 12 / 50
─────────────────────────
EURUSD: 2 pos | +45.30 $
GBPUSD: 1 pos | +12.20 $
USDJPY: 0 pos | --
─────────────────────────
News Filter: ✅ Active
Update: ✅ v27.52 (latest)
```

**Throttling:**
- Update seulement si (now - last_dashboard_update) > DASHBOARD_UPDATE_INTERVAL
- Évite surcharge CPU

**Exemple:**
```mql5
void OnTick() {
    UpdateDashboard();  // Appelé automatiquement
}
```

---

### Auto-Update

#### `CheckForUpdates()`
Vérifie disponibilité nouvelle version sur GitHub.

**Signature:**
```mql5
void CheckForUpdates()
```

**Comportement:**
1. Check si EnableAutoUpdate == true
2. Check intervalle: (now - last_update_check) > CheckUpdateEveryHours × HOURS_TO_SECONDS
3. WebRequest() vers VERSION.txt GitHub
4. Compare avec CURRENT_VERSION
5. Si nouvelle version:
   - Log notification
   - Call DownloadAndInstallUpdate() après 5 secondes
6. Update last_update_check

**URLs:**
- Version: https://raw.githubusercontent.com/.../VERSION.txt
- Source: https://raw.githubusercontent.com/.../EA_MultiPairs_Scalping_Pro.mq5

**Exemple:**
```mql5
void OnTick() {
    if(EnableAutoUpdate) {
        CheckForUpdates();  // Appelé automatiquement
    }
}
```

---

#### `CompareVersions()`
Compare deux numéros de version (Semantic Versioning).

**Signature:**
```mql5
int CompareVersions(string v1, string v2)
```

**Paramètres:**
- `v1` (string): Première version (ex: "27.52")
- `v2` (string): Deuxième version (ex: "27.51")

**Retourne:**
- `1` si v1 > v2
- `-1` si v1 < v2
- `0` si v1 == v2

**Format supporté:**
- MAJOR.MINOR (ex: 27.52)
- MAJOR.MINOR.PATCH (ex: 27.5.2)

**Exemple:**
```mql5
int result = CompareVersions("27.52", "27.51");
// result = 1 (27.52 > 27.51)

result = CompareVersions("27.5", "28.0");
// result = -1 (27.5 < 28.0)

result = CompareVersions("27.52", "27.52");
// result = 0 (égal)
```

---

### Utilities

#### `Log()`
Fonction de logging centralisée avec niveaux.

**Signature:**
```mql5
void Log(LOG_LEVEL level, string message)
```

**Paramètres:**
- `level` (LOG_LEVEL): Niveau du message
  - LOG_DEBUG: Détails techniques
  - LOG_INFO: Informations générales
  - LOG_WARN: Avertissements
  - LOG_ERROR: Erreurs critiques
- `message` (string): Message à logger

**Comportement:**
1. Check si level >= MinLogLevel (filtrage)
2. Print vers Journal MT5
3. Si EnableFileLogging == true:
   - Écrire vers fichier log
   - Format: [TIMESTAMP] [LEVEL] Message

**Fichier log:**
- Path: MQL5/Files/
- Nom: EA_Scalping_v274_Log_[MagicNumber].txt

**Exemple:**
```mql5
Log(LOG_INFO, "EA démarré avec succès");
Log(LOG_WARN, "Spread élevé: " + IntegerToString(spread));
Log(LOG_ERROR, "Échec OrderSend: " + IntegerToString(GetLastError()));
Log(LOG_DEBUG, "Cache indicateurs mis à jour");
```

---

#### `GetTradeErrorDescription()`
Traduit code erreur MT5 en message lisible.

**Signature:**
```mql5
string GetTradeErrorDescription(int error_code)
```

**Paramètres:**
- `error_code` (int): Code erreur MT5 (ex: 10004)

**Retourne:**
- `string`: Description en français

**Codes principaux:**
- 10004: "Requester off quotes"
- 10006: "Request rejected"
- 10009: "Order locked"
- 10013: "Invalid request"
- 10014: "Invalid volume"
- 10015: "Invalid stops"
- 10016: "Market closed"
- 10019: "No money"
- 10025: "Trade disabled"

**Exemple:**
```mql5
if(!OrderSend(request, result)) {
    int err = GetLastError();
    string desc = GetTradeErrorDescription(err);
    Log(LOG_ERROR, "OrderSend failed: " + desc);
}
```

---

## 📊 Workflow Typique

### Startup (OnInit)
```
1. ValidateInputParameters()
2. AddWebRequestURL()
3. InitializeIndicators()
4. CreateDashboard()
5. LoadNewsCalendar()
6. CheckForUpdates()
```

### Chaque Tick (OnTick)
```
1. CheckDailyReset()
2. CheckForUpdates() (si interval atteint)
3. Pour chaque symbole activé:
   a. CanOpenNewTrade()
   b. GetSignalForSymbol()
   c. OpenPosition() si signal
4. ManageAllPositions()
5. UpdateDashboard()
```

### Arrêt (OnDeinit)
```
1. DeleteDashboard()
2. Release indicator handles
3. Close log file
```

---

## 🔐 Sécurité & Best Practices

### Input Validation
- **TOUJOURS** valider avant usage
- **NEVER** trust user inputs
- Log warnings pour valeurs limites

### Error Handling
- **TOUJOURS** vérifier retours fonctions
- Log contexte complet (v27.52+)
- Use GetTradeErrorDescription()

### Performance
- Cache indicator values (UpdateIndicatorCache)
- Early exit loops (CountPositions)
- Throttle dashboard updates

### Magic Numbers
- **ÉVITER** hardcoded values
- Use #define constants
- Document purpose

---

**Version:** 1.0
**EA Version compatible:** v27.52+
**Dernière mise à jour:** 2025-11-10
