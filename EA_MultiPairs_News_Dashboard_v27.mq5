//+------------------------------------------------------------------+
//| EA Multi-Paires Scalping Pro v27.0 - News Filter + Dashboard    |
//| Expert Advisor pour trading scalping multi-paires               |
//|------------------------------------------------------------------|
//| DESCRIPTION:                                                     |
//|   EA automatisé pour scalping sur 6 paires de devises avec:     |
//|   - Filtre économique temps réel (ForexFactory API)             |
//|   - Analyse technique multi-indicateurs (EMA, RSI, ATR)         |
//|   - Gestion avancée du risque et du capital                     |
//|   - Dashboard visuel en temps réel                              |
//|   - Système de mise à jour automatique                          |
//|                                                                  |
//| FONCTIONNALITÉS PRINCIPALES:                                    |
//|   ✓ Trading multi-symboles (EUR/USD, GBP/USD, USD/JPY, etc.)   |
//|   ✓ Filtre news économiques (pause trading avant/après news)    |
//|   ✓ Trailing Stop et Break-Even automatiques                    |
//|   ✓ Limites journalières (pertes max, nombre trades)           |
//|   ✓ Validation complète des paramètres d'entrée                |
//|   ✓ Système de logging avancé avec niveaux de sévérité         |
//|                                                                  |
//| OPTIMISATIONS v27.2:                                            |
//|   - Constantes pour valeurs magiques (pips, intervalles)       |
//|   - Parsing JSON amélioré avec validation robuste              |
//|   - Validation paramètres avec messages d'erreur détaillés     |
//|   - Système logging avec LOG_DEBUG/INFO/WARN/ERROR             |
//|   - Optimisation boucles (sortie anticipée)                    |
//|   - Messages d'erreur détaillés pour codes trading             |
//|                                                                  |
//| AUTEUR: fred-selest                                             |
//| GITHUB: https://github.com/fred-selest/ea-scalping-pro         |
//| VERSION: 27.2                                                   |
//| DATE: 2025-11-06                                                |
//+------------------------------------------------------------------+
#property version   "27.2"
#property strict
#property description "Multi-Symbol Scalping EA avec News Filter"
#property description "Dashboard temps réel + ONNX + FxPro optimisé"
#property description "v27.2 - Améliorations: Constantes, Validation, Logging"

// === CONSTANTS ===
#define PIPS_TO_POINTS_MULTIPLIER 10    // Conversion pips to points (10 for 4/5 digit brokers)
#define MIN_NEWS_UPDATE_INTERVAL 300    // Minimum 5 minutes between news API calls
#define NEWS_RELOAD_INTERVAL 21600      // Reload news every 6 hours
#define DASHBOARD_UPDATE_INTERVAL 2     // Update dashboard every 2 seconds
#define MIN_JSON_FILE_SIZE 1000         // Minimum expected file size for downloaded updates
#define SECONDS_PER_DAY 86400           // Seconds in a day for calculations
#define DASHBOARD_WIDTH 380             // Dashboard width + margin for chart shift
#define CHART_SHIFT_PERCENT 15          // Percentage of chart shift for dashboard space

// Logging levels
enum LOG_LEVEL {
   LOG_DEBUG = 0,
   LOG_INFO = 1,
   LOG_WARN = 2,
   LOG_ERROR = 3
};

// === SYMBOLES À TRADER ===
input group "=== TRADING SYMBOLS ==="
input bool     Trade_EURUSD = true;         // EUR/USD
input bool     Trade_GBPUSD = true;         // GBP/USD
input bool     Trade_USDJPY = true;         // USD/JPY
input bool     Trade_AUDUSD = false;        // AUD/USD
input bool     Trade_USDCAD = false;        // USD/CAD
input bool     Trade_NZDUSD = false;        // NZD/USD

// === PARAMÈTRES SCALPING ===
input group "=== SCALPING SETTINGS ==="
input double   ScalpTP_Pips = 8.0;
input double   ScalpSL_Pips = 15.0;
input double   TrailingStop_Pips = 5.0;
input double   BreakEven_Pips = 5.0;
input int      MaxSpread_Points = 20;

// === GESTION DU RISQUE ===
input group "=== RISK MANAGEMENT ==="
input double   RiskPercent = 0.5;
input double   MaxLotSize = 1.0;
input double   MaxDailyLoss = 3.0;
input int      MaxTradesPerDay = 50;
input int      MaxOpenPositions = 5;        // Total toutes paires confondues
input int      MaxPositionsPerSymbol = 2;   // Par paire

// === NEWS FILTER ===
input group "=== NEWS FILTER (ForexFactory) ==="
input bool     UseNewsFilter = true;        // Activer filtre news
input int      MinutesBeforeNews = 30;      // Stop trading avant news (minutes)
input int      MinutesAfterNews = 15;       // Attendre après news (minutes)
input bool     FilterHighImpact = true;     // Filtrer news impact élevé
input bool     FilterMediumImpact = true;   // Filtrer news impact moyen
input bool     FilterLowImpact = false;     // Filtrer news impact faible
input string   NewsCurrencies = "USD,EUR,GBP,JPY,AUD,CAD,NZD,CHF";  // Devises à surveiller

// === ONNX ===
input group "=== AI MODEL (ONNX) ==="
input bool     UseONNX = true;
input double   MinConfidence = 0.75;
input string   ModelFileName = "scalping_model.onnx";

// === DASHBOARD ===
input group "=== DASHBOARD SETTINGS ==="
input bool     ShowDashboard = true;        // Afficher dashboard
input int      Dashboard_X = 20;            // Position X
input int      Dashboard_Y = 30;            // Position Y
input color    Dashboard_Color = clrWhite;  // Couleur texte
input color    Dashboard_BG = clrNavy;      // Couleur fond
input bool     AutoShiftChart = true;      // Décaler graphique auto pour dashboard

// === TRADING HOURS ===
input group "=== TRADING HOURS ==="
input bool     Trade_Asian = false;
input bool     Trade_London = true;
input bool     Trade_NewYork = true;

// === TECHNICAL ===
input group "=== TECHNICAL INDICATORS ==="
input int      EMA_Fast = 8;
input int      EMA_Slow = 21;
input int      RSI_Period = 9;
input int      ATR_Period = 14;
input double   ATR_Filter = 1.5;

// === AUTO-UPDATE ===
input group "=== AUTO-UPDATE ==="
input bool     EnableAutoUpdate = false;    // Activer mises à jour auto
input string   UpdateURL = "https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/EA_MultiPairs_News_Dashboard_v27.mq5";  // URL du code source
input int      CheckUpdateEveryHours = 24;  // Vérifier MAJ toutes les X heures

input int      MagicNumber = 270000;

// === VARIABLES GLOBALES ===
string symbols[];
int symbol_count = 0;

// Logging
input LOG_LEVEL MinLogLevel = LOG_INFO;  // Niveau minimum de log
bool EnableFileLogging = false;          // Log dans fichier (performance impact)

// Statistiques
int trades_today = 0;
double daily_profit = 0;
datetime current_day = 0;

// === NEWS CALENDAR ===
// Structure pour stocker les événements économiques du calendrier ForexFactory
struct NewsEvent {
   datetime time;       // Heure de l'événement (UTC)
   string title;        // Nom de l'événement (ex: "Non-Farm Payrolls")
   string country;      // Code devise (ex: "USD", "EUR")
   string impact;       // Niveau impact: "High", "Medium", "Low"
   string forecast;     // Prévision consensus
   string previous;     // Valeur précédente
};
NewsEvent news_events[];           // Tableau des événements chargés
datetime last_news_update = 0;     // Dernière mise à jour du calendrier
bool news_filter_active = false;   // État actuel du filtre

// Dashboard
string dashboard_text = "";
datetime last_dashboard_update = 0;

// Auto-Update
#define CURRENT_VERSION "27.2-FIXED"
datetime last_update_check = 0;
bool update_available = false;
string latest_version = "";

// === INDICATEURS TECHNIQUES ===
// Structure contenant les handles des indicateurs pour chaque symbole
// Chaque paire tradée a son propre jeu d'indicateurs indépendants
struct SymbolIndicators {
   string symbol;           // Nom du symbole (ex: "EURUSD")
   int handle_ema_fast;     // Handle EMA rapide (défaut: 8 périodes)
   int handle_ema_slow;     // Handle EMA lente (défaut: 21 périodes)
   int handle_rsi;          // Handle RSI (défaut: 9 périodes)
   int handle_atr;          // Handle ATR pour filtrage volatilité (défaut: 14)
   bool enabled;            // Symbole actif pour trading
   int positions_count;     // Nombre positions ouvertes pour ce symbole
   double last_profit;      // Dernier profit enregistré
};
SymbolIndicators indicators[];  // Tableau des indicateurs par symbole

//+------------------------------------------------------------------+
//| Fonction de logging avec niveaux de sévérité                    |
//+------------------------------------------------------------------+
void Log(LOG_LEVEL level, string message)
{
   // Filtrer selon niveau minimum
   if(level < MinLogLevel) return;

   string prefix = "";
   switch(level) {
      case LOG_DEBUG: prefix = "🔍 DEBUG: "; break;
      case LOG_INFO:  prefix = "ℹ️ INFO: "; break;
      case LOG_WARN:  prefix = "⚠️ WARN: "; break;
      case LOG_ERROR: prefix = "❌ ERROR: "; break;
   }

   string full_message = prefix + message;
   Print(full_message);

   // Log dans fichier si activé (impact performance)
   if(EnableFileLogging) {
      int file = FileOpen("EA_Scalping_Log_" + IntegerToString(MagicNumber) + ".txt",
                          FILE_WRITE|FILE_READ|FILE_TXT|FILE_COMMON);
      if(file != INVALID_HANDLE) {
         FileSeek(file, 0, SEEK_END);
         FileWrite(file, TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " | " + full_message);
         FileClose(file);
      }
   }
}

//+------------------------------------------------------------------+
//| Obtenir description détaillée d'un code d'erreur trading        |
//+------------------------------------------------------------------+
string GetTradeErrorDescription(uint error_code)
{
   switch(error_code) {
      case 10004: return "Serveur de trading occupé - Réessayer";
      case 10006: return "Requête rejetée - Commande invalide";
      case 10007: return "Requête annulée par le trader";
      case 10008: return "Commande déjà placée";
      case 10009: return "Commande envoyée - En attente confirmation";
      case 10010: return "Requête acceptée";
      case 10011: return "Requête en cours de traitement";
      case 10012: return "Uniquement ordres en attente autorisés";
      case 10013: return "Ouverture uniquement de positions longues autorisée";
      case 10014: return "Ouverture uniquement de positions courtes autorisée";
      case 10015: return "Clôture uniquement autorisée";
      case 10016: return "Clôture position uniquement par position opposée";
      case 10017: return "Clôture position uniquement par ordre de clôture";
      case 10018: return "Nombre de positions ouvertes limite atteinte";
      case 10019: return "Volume de transactions limité atteint";
      case 10020: return "Nombre d'ordres en attente limite atteint";
      case 10021: return "Volume d'ordres limité atteint";
      case 10022: return "Ordre invalide (Stop Loss/Take Profit)";
      case 10023: return "Ordre invalide (proche du marché)";
      case 10024: return "Requête non valide - Aucun changement";
      case 10025: return "Système d'auto-trading désactivé";
      case 10026: return "Système d'auto-trading désactivé côté serveur";
      case 10027: return "Requête verrouillée pour traitement";
      case 10028: return "Position/Ordre gelé(e)";
      case 10029: return "Type de remplissage d'ordre non supporté";
      case 10030: return "Pas de connexion au serveur de trading";
      case 10031: return "Uniquement comptes réels autorisés";
      case 10032: return "Limite d'ordres en attente atteinte";
      case 10033: return "Volume d'ordres et positions atteint la limite";
      case 10034: return "Format ou paramètres d'ordre incorrects";
      case 10035: return "Prix d'ordre invalide";
      case 10036: return "Prix Stop Loss invalide";
      case 10037: return "Prix Take Profit invalide";
      case 10038: return "Volume invalide dans la requête";
      case 10039: return "Prix marché inexistant";
      case 10040: return "Symbole non disponible";
      case 10041: return "Symbole désactivé";
      case 10042: return "Validité de l'ordre expirée";
      case 10043: return "Date d'expiration ordre invalide";
      case 10044: return "Position avec ticket spécifié introuvable";
      case 10045: return "Ordre avec ticket spécifié introuvable";
      case 10046: return "Échec du trade - Pas de connexion";
      default: return "Erreur inconnue: " + IntegerToString(error_code);
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("🚀 EA Multi-Paires Scalping Pro v27.0 - Initialisation...");

   // Valider les paramètres d'entrée
   if(!ValidateInputParameters()) {
      Alert("❌ Paramètres invalides - Vérifiez les logs");
      return(INIT_PARAMETERS_INCORRECT);
   }

   // Autoriser WebRequest pour le calendrier économique
   if(!AddWebRequestURL()) {
      Print("⚠️ URLs WebRequest configurées - Redémarrage nécessaire");
   }

   // Construire la liste des symboles
   BuildSymbolList();
   
   if(symbol_count == 0) {
      Alert("❌ Aucun symbole sélectionné !");
      return(INIT_FAILED);
   }
   
   // Initialiser les indicateurs pour chaque symbole
   if(!InitializeIndicators()) {
      Print("❌ Erreur d'initialisation des indicateurs");
      return(INIT_FAILED);
   }
   
   // Charger les news
   if(UseNewsFilter) {
      LoadNewsCalendar();
   }
   
   // Créer le dashboard
   if(ShowDashboard) {
      CreateDashboard();
      // Forcer la première mise à jour immédiate
      Sleep(100);
      // Décaler le graphique pour laisser le dashboard visible
      ShiftChartForDashboard();
      UpdateDashboard();
   }
   
   // Vérifier les mises à jour
   if(EnableAutoUpdate) {
      CheckForUpdates();
   }
   
   Print("✅ EA initialisé avec succès");
   Print("📊 Symboles actifs: ", symbol_count);
   PrintSymbolList();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Valider les paramètres d'entrée                                 |
//+------------------------------------------------------------------+
bool ValidateInputParameters()
{
   bool valid = true;

   // Validation des paramètres de scalping
   if(ScalpTP_Pips <= 0 || ScalpTP_Pips > 100) {
      Print("❌ ERREUR: ScalpTP_Pips doit être entre 0.1 et 100 (valeur: ", ScalpTP_Pips, ")");
      valid = false;
   }

   if(ScalpSL_Pips <= 0 || ScalpSL_Pips > 200) {
      Print("❌ ERREUR: ScalpSL_Pips doit être entre 0.1 et 200 (valeur: ", ScalpSL_Pips, ")");
      valid = false;
   }

   if(TrailingStop_Pips < 0 || TrailingStop_Pips > 100) {
      Print("❌ ERREUR: TrailingStop_Pips doit être entre 0 et 100 (valeur: ", TrailingStop_Pips, ")");
      valid = false;
   }

   if(BreakEven_Pips < 0 || BreakEven_Pips > 100) {
      Print("❌ ERREUR: BreakEven_Pips doit être entre 0 et 100 (valeur: ", BreakEven_Pips, ")");
      valid = false;
   }

   // Validation gestion du risque
   if(RiskPercent < 0 || RiskPercent > 10) {
      Print("❌ ERREUR: RiskPercent doit être entre 0 et 10% (valeur: ", RiskPercent, ")");
      valid = false;
   }

   if(MaxLotSize <= 0 || MaxLotSize > 100) {
      Print("❌ ERREUR: MaxLotSize doit être entre 0.01 et 100 (valeur: ", MaxLotSize, ")");
      valid = false;
   }

   if(MaxDailyLoss < 0 || MaxDailyLoss > 100) {
      Print("❌ ERREUR: MaxDailyLoss doit être entre 0 et 100% (valeur: ", MaxDailyLoss, ")");
      valid = false;
   }

   if(MaxTradesPerDay < 1 || MaxTradesPerDay > 1000) {
      Print("❌ ERREUR: MaxTradesPerDay doit être entre 1 et 1000 (valeur: ", MaxTradesPerDay, ")");
      valid = false;
   }

   if(MaxOpenPositions < 1 || MaxOpenPositions > 100) {
      Print("❌ ERREUR: MaxOpenPositions doit être entre 1 et 100 (valeur: ", MaxOpenPositions, ")");
      valid = false;
   }

   if(MaxPositionsPerSymbol < 1 || MaxPositionsPerSymbol > 50) {
      Print("❌ ERREUR: MaxPositionsPerSymbol doit être entre 1 et 50 (valeur: ", MaxPositionsPerSymbol, ")");
      valid = false;
   }

   // Validation filtre news
   if(MinutesBeforeNews < 0 || MinutesBeforeNews > 240) {
      Print("❌ ERREUR: MinutesBeforeNews doit être entre 0 et 240 (valeur: ", MinutesBeforeNews, ")");
      valid = false;
   }

   if(MinutesAfterNews < 0 || MinutesAfterNews > 240) {
      Print("❌ ERREUR: MinutesAfterNews doit être entre 0 et 240 (valeur: ", MinutesAfterNews, ")");
      valid = false;
   }

   // Validation indicateurs techniques
   if(EMA_Fast < 1 || EMA_Fast > 200) {
      Print("❌ ERREUR: EMA_Fast doit être entre 1 et 200 (valeur: ", EMA_Fast, ")");
      valid = false;
   }

   if(EMA_Slow < 1 || EMA_Slow > 200) {
      Print("❌ ERREUR: EMA_Slow doit être entre 1 et 200 (valeur: ", EMA_Slow, ")");
      valid = false;
   }

   if(EMA_Fast >= EMA_Slow) {
      Print("❌ ERREUR: EMA_Fast (", EMA_Fast, ") doit être inférieur à EMA_Slow (", EMA_Slow, ")");
      valid = false;
   }

   if(RSI_Period < 2 || RSI_Period > 100) {
      Print("❌ ERREUR: RSI_Period doit être entre 2 et 100 (valeur: ", RSI_Period, ")");
      valid = false;
   }

   if(ATR_Period < 2 || ATR_Period > 100) {
      Print("❌ ERREUR: ATR_Period doit être entre 2 et 100 (valeur: ", ATR_Period, ")");
      valid = false;
   }

   // Avertissements (non bloquants)
   if(ScalpTP_Pips < ScalpSL_Pips) {
      Print("⚠️ AVERTISSEMENT: TP (", ScalpTP_Pips, ") < SL (", ScalpSL_Pips, ") - Ratio risque/rendement défavorable");
   }

   if(RiskPercent > 2.0) {
      Print("⚠️ AVERTISSEMENT: RiskPercent élevé (", RiskPercent, "%) - Risque accru");
   }

   if(valid) {
      Print("✅ Tous les paramètres d'entrée sont valides");
   }

   return valid;
}

//+------------------------------------------------------------------+
//| Ajouter les URLs autorisées pour WebRequest                      |
//+------------------------------------------------------------------+
bool AddWebRequestURL()
{
   // Liste des URLs nécessaires
   string urls[] = {
      "https://nfs.faireconomy.media",
      "https://cdn-nfs.faireconomy.media",
      "https://www.forexfactory.com"
   };
   
   Print("📡 Configuration WebRequest nécessaire :");
   Print("   Outils → Options → Expert Advisors → WebRequest");
   Print("   Ajouter les URLs suivantes :");
   
   for(int i = 0; i < ArraySize(urls); i++) {
      Print("   - ", urls[i]);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Construire la liste des symboles à trader                        |
//+------------------------------------------------------------------+
void BuildSymbolList()
{
   string temp_symbols[];
   int count = 0;
   
   if(Trade_EURUSD) { ArrayResize(temp_symbols, count+1); temp_symbols[count++] = "EURUSD"; }
   if(Trade_GBPUSD) { ArrayResize(temp_symbols, count+1); temp_symbols[count++] = "GBPUSD"; }
   if(Trade_USDJPY) { ArrayResize(temp_symbols, count+1); temp_symbols[count++] = "USDJPY"; }
   if(Trade_AUDUSD) { ArrayResize(temp_symbols, count+1); temp_symbols[count++] = "AUDUSD"; }
   if(Trade_USDCAD) { ArrayResize(temp_symbols, count+1); temp_symbols[count++] = "USDCAD"; }
   if(Trade_NZDUSD) { ArrayResize(temp_symbols, count+1); temp_symbols[count++] = "NZDUSD"; }
   
   ArrayResize(symbols, count);
   for(int i = 0; i < count; i++) {
      symbols[i] = temp_symbols[i];
   }
   
   symbol_count = count;
}

//+------------------------------------------------------------------+
//| Afficher la liste des symboles                                   |
//+------------------------------------------------------------------+
void PrintSymbolList()
{
   string list = "   ";
   for(int i = 0; i < symbol_count; i++) {
      list += symbols[i];
      if(i < symbol_count - 1) list += ", ";
   }
   Print(list);
}

//+------------------------------------------------------------------+
//| Initialiser les indicateurs pour tous les symboles              |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
   ArrayResize(indicators, symbol_count);
   
   for(int i = 0; i < symbol_count; i++) {
      indicators[i].symbol = symbols[i];
      indicators[i].enabled = true;
      indicators[i].positions_count = 0;
      indicators[i].last_profit = 0;
      
      // Créer les handles
      indicators[i].handle_ema_fast = iMA(symbols[i], PERIOD_CURRENT, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_ema_slow = iMA(symbols[i], PERIOD_CURRENT, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_rsi = iRSI(symbols[i], PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
      indicators[i].handle_atr = iATR(symbols[i], PERIOD_CURRENT, ATR_Period);
      
      if(indicators[i].handle_ema_fast == INVALID_HANDLE || 
         indicators[i].handle_ema_slow == INVALID_HANDLE ||
         indicators[i].handle_rsi == INVALID_HANDLE ||
         indicators[i].handle_atr == INVALID_HANDLE) {
         Print("❌ Erreur indicateurs pour ", symbols[i]);
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Charger le calendrier économique ForexFactory                    |
//+------------------------------------------------------------------+
void LoadNewsCalendar()
{
   // Éviter les appels trop fréquents (rate limiting)
   static datetime last_attempt = 0;
   if(TimeCurrent() - last_attempt < MIN_NEWS_UPDATE_INTERVAL) {
      return;
   }
   last_attempt = TimeCurrent();
   
   // URL de l'API ForexFactory (JSON)
   string url = "https://nfs.faireconomy.media/ff_calendar_thisweek.json";
   
   string cookie = NULL, referer = NULL;
   char data[], result[];
   string headers;
   int timeout = 5000;
   
   Print("📰 Téléchargement du calendrier économique...");
   
   int res = WebRequest("GET", url, cookie, referer, timeout, data, 0, result, headers);
   
   if(res == -1) {
      int error = GetLastError();
      Print("❌ Erreur WebRequest: ", error);
      
      if(error == 4060) {
         Print("⚠️ URL non autorisée. Ajoutez dans Outils → Options → Expert Advisors → WebRequest :");
         Print("   https://nfs.faireconomy.media");
      }
      return;
   }
   
   if(res == 200) {
      string json = CharArrayToString(result);
      ParseNewsJSON(json);
      last_news_update = TimeCurrent();
      Print("✅ Calendrier chargé: ", ArraySize(news_events), " événements");
   } else if(res == 429) {
      Print("⚠️ Limite de requêtes API atteinte (429). Réessai dans 30 minutes.");
      last_news_update = TimeCurrent(); // Éviter réessais immédiats
   } else {
      Print("⚠️ HTTP Error: ", res);
   }
}

//+------------------------------------------------------------------+
//| Parser le JSON des news avec gestion d'erreurs améliorée        |
//+------------------------------------------------------------------+
void ParseNewsJSON(string json)
{
   ArrayResize(news_events, 0);

   // Validation du JSON
   if(StringLen(json) < 10) {
      Print("⚠️ JSON invalide: trop court (", StringLen(json), " caractères)");
      return;
   }

   // Vérifier que c'est un tableau JSON
   if(StringFind(json, "[") < 0) {
      Print("⚠️ JSON invalide: pas de tableau détecté");
      return;
   }

   // Note: Parsing manuel optimisé - Format: [{"title":"...","country":"USD",...},...]
   int start = 0;
   int count = 0;
   int max_events = 1000; // Limite de sécurité pour éviter boucles infinies

   while(count < max_events) {
      int obj_start = StringFind(json, "{\"title\":", start);
      if(obj_start < 0) break;

      int obj_end = StringFind(json, "},", obj_start);
      if(obj_end < 0) obj_end = StringFind(json, "}]", obj_start);
      if(obj_end < 0) break;

      // Extraire l'objet JSON
      string obj = StringSubstr(json, obj_start, obj_end - obj_start);

      // Extraire les champs avec validation
      NewsEvent event;
      event.title = ExtractField(obj, "title");
      event.country = ExtractField(obj, "country");
      event.impact = ExtractField(obj, "impact");
      event.forecast = ExtractField(obj, "forecast");
      event.previous = ExtractField(obj, "previous");

      string date_str = ExtractField(obj, "date");
      event.time = ParseDateString(date_str);

      // Valider événement avant ajout
      if(event.time > 0 && StringLen(event.country) > 0) {
         // Filtrer par devise pertinente
         if(IsRelevantCurrency(event.country)) {
            ArrayResize(news_events, count + 1);
            news_events[count++] = event;
         }
      }

      start = obj_end + 1;
   }

   if(count >= max_events) {
      Print("⚠️ Limite d'événements atteinte (", max_events, "), certains événements ignorés");
   }
}

//+------------------------------------------------------------------+
//| Extraire un champ du JSON                                        |
//+------------------------------------------------------------------+
string ExtractField(string json, string field)
{
   string search = "\"" + field + "\":\"";
   int start = StringFind(json, search);
   if(start < 0) return "";
   
   start += StringLen(search);
   int end = StringFind(json, "\"", start);
   if(end < 0) return "";
   
   return StringSubstr(json, start, end - start);
}

//+------------------------------------------------------------------+
//| Parser une date string en datetime avec validation              |
//+------------------------------------------------------------------+
datetime ParseDateString(string date_str)
{
   // Format attendu: "2025-11-05T14:30:00+00:00" (ISO 8601)

   // Validation longueur minimale
   if(StringLen(date_str) < 19) {
      return 0;
   }

   MqlDateTime dt;
   ZeroMemory(dt);

   // Parser avec validation de plages
   dt.year = (int)StringToInteger(StringSubstr(date_str, 0, 4));
   dt.mon = (int)StringToInteger(StringSubstr(date_str, 5, 2));
   dt.day = (int)StringToInteger(StringSubstr(date_str, 8, 2));
   dt.hour = (int)StringToInteger(StringSubstr(date_str, 11, 2));
   dt.min = (int)StringToInteger(StringSubstr(date_str, 14, 2));
   dt.sec = (int)StringToInteger(StringSubstr(date_str, 17, 2));

   // Validation des valeurs
   if(dt.year < 2000 || dt.year > 2100) return 0;
   if(dt.mon < 1 || dt.mon > 12) return 0;
   if(dt.day < 1 || dt.day > 31) return 0;
   if(dt.hour < 0 || dt.hour > 23) return 0;
   if(dt.min < 0 || dt.min > 59) return 0;
   if(dt.sec < 0 || dt.sec > 59) return 0;

   return StructToTime(dt);
}

//+------------------------------------------------------------------+
//| Vérifier si la devise est pertinente                             |
//+------------------------------------------------------------------+
bool IsRelevantCurrency(string currency)
{
   string currencies[];
   StringSplit(NewsCurrencies, ',', currencies);
   
   for(int i = 0; i < ArraySize(currencies); i++) {
      StringTrimLeft(currencies[i]);
      StringTrimRight(currencies[i]);
      if(currencies[i] == currency) return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Vérifier si news à venir (filtre actif)                         |
//+------------------------------------------------------------------+
bool IsNewsTime(string symbol)
{
   if(!UseNewsFilter) return false;

   // Recharger les news toutes les 6 heures
   if(TimeCurrent() - last_news_update > NEWS_RELOAD_INTERVAL) {
      LoadNewsCalendar();
   }
   
   datetime now = TimeCurrent();
   
   // Extraire les devises du symbole
   string base = StringSubstr(symbol, 0, 3);
   string quote = StringSubstr(symbol, 3, 3);
   
   for(int i = 0; i < ArraySize(news_events); i++) {
      // Vérifier si news concerne ce symbole
      if(news_events[i].country != base && news_events[i].country != quote) continue;
      
      // Vérifier impact
      bool filter_this = false;
      if(news_events[i].impact == "High" && FilterHighImpact) filter_this = true;
      if(news_events[i].impact == "Medium" && FilterMediumImpact) filter_this = true;
      if(news_events[i].impact == "Low" && FilterLowImpact) filter_this = true;
      
      if(!filter_this) continue;
      
      // Vérifier temps
      int time_diff = (int)(news_events[i].time - now);
      
      if(time_diff > 0 && time_diff <= MinutesBeforeNews * 60) {
         // News à venir
         Print("📰 News filter: ", symbol, " - ", news_events[i].title, 
               " dans ", (time_diff/60), " min");
         return true;
      }
      
      if(time_diff < 0 && time_diff >= -MinutesAfterNews * 60) {
         // News vient de passer
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Obtenir le signal de trading pour un symbole                     |
//| RETOUR:                                                           |
//|   +1 = Signal BUY (EMA cross up OU RSI oversold + tendance)     |
//|   -1 = Signal SELL (EMA cross down OU RSI overbought + tendance)|
//|    0 = Pas de signal ou conditions non remplies                 |
//| LOGIQUE:                                                          |
//|   - Vérifie volatilité minimale avec ATR                        |
//|   - Détecte croisements EMA (fast > slow = bullish)             |
//|   - Confirme avec RSI (< 30 oversold, > 70 overbought)          |
//|   - Valide position prix vs EMAs pour tendance                  |
//+------------------------------------------------------------------+
int GetSignalForSymbol(string symbol)
{
   // Trouver les indicateurs pour ce symbole
   int idx = -1;
   for(int i = 0; i < ArraySize(indicators); i++) {
      if(indicators[i].symbol == symbol) {
         idx = i;
         break;
      }
   }
   
   if(idx < 0 || !indicators[idx].enabled) return 0;
   
   // Récupérer les valeurs
   double rsi[], ema_fast[], ema_slow[], atr[];
   
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(ema_fast, true);
   ArraySetAsSeries(ema_slow, true);
   ArraySetAsSeries(atr, true);
   
   if(CopyBuffer(indicators[idx].handle_rsi, 0, 0, 3, rsi) <= 0) return 0;
   if(CopyBuffer(indicators[idx].handle_ema_fast, 0, 0, 3, ema_fast) <= 0) return 0;
   if(CopyBuffer(indicators[idx].handle_ema_slow, 0, 0, 3, ema_slow) <= 0) return 0;
   if(CopyBuffer(indicators[idx].handle_atr, 0, 0, 2, atr) <= 0) return 0;
   
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

   // Filtre ATR (utiliser la volatilité minimale)
   if(atr[0] < ATR_Filter * PIPS_TO_POINTS_MULTIPLIER * point) return 0;
   
   // Analyse technique
   bool ema_cross_up = (ema_fast[1] <= ema_slow[1] && ema_fast[0] > ema_slow[0]);
   bool ema_cross_down = (ema_fast[1] >= ema_slow[1] && ema_fast[0] < ema_slow[0]);
   
   bool rsi_oversold = (rsi[0] < 30 && rsi[0] > rsi[1]);
   bool rsi_overbought = (rsi[0] > 70 && rsi[0] < rsi[1]);
   
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   bool price_above = (price > ema_fast[0] && ema_fast[0] > ema_slow[0]);
   bool price_below = (price < ema_fast[0] && ema_fast[0] < ema_slow[0]);
   
   if((ema_cross_up || rsi_oversold) && price_above) return 1;
   if((ema_cross_down || rsi_overbought) && price_below) return -1;
   
   return 0;
}

//+------------------------------------------------------------------+
//| Vérifier conditions de trading                                   |
//+------------------------------------------------------------------+
bool CanTrade(string symbol)
{
   // Vérifier spread
   long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   if(spread > MaxSpread_Points) return false;
   
   // Vérifier session
   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   int hour = time.hour;
   
   bool in_session = false;
   if(Trade_Asian && hour >= 0 && hour < 9) in_session = true;
   if(Trade_London && hour >= 8 && hour < 17) in_session = true;
   if(Trade_NewYork && hour >= 14 && hour < 23) in_session = true;
   
   if(!in_session) return false;
   
   // Vérifier news
   if(IsNewsTime(symbol)) return false;
   
   // Vérifier limites journalières (reset quotidien)
   if(TimeCurrent() - current_day > SECONDS_PER_DAY) {
      trades_today = 0;
      daily_profit = 0;
      current_day = TimeCurrent();
   }
   
   if(trades_today >= MaxTradesPerDay) return false;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(daily_profit < -(balance * MaxDailyLoss / 100)) return false;
   
   // Vérifier limites de positions
   if(GetTotalPositions() >= MaxOpenPositions) return false;
   if(GetSymbolPositions(symbol) >= MaxPositionsPerSymbol) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Compter les positions totales (optimisé avec sortie anticipée)  |
//+------------------------------------------------------------------+
int GetTotalPositions()
{
   int count = 0;
   int total = PositionsTotal();

   // Optimisation: si limite déjà atteinte, pas besoin de tout compter
   for(int i = total - 1; i >= 0; i--) {
      if(count >= MaxOpenPositions) {
         break; // Sortie anticipée
      }

      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) {
         count++;
      }
   }

   return count;
}

//+------------------------------------------------------------------+
//| Compter les positions pour un symbole (optimisé)                |
//+------------------------------------------------------------------+
int GetSymbolPositions(string symbol)
{
   int count = 0;
   int total = PositionsTotal();

   // Optimisation: sortie anticipée si limite atteinte
   for(int i = total - 1; i >= 0; i--) {
      if(count >= MaxPositionsPerSymbol) {
         break; // Sortie anticipée
      }

      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;

      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetString(POSITION_SYMBOL) == symbol) {
         count++;
      }
   }

   return count;
}

//+------------------------------------------------------------------+
//| Ouvrir position                                                   |
//+------------------------------------------------------------------+
bool OpenPosition(string symbol, int direction)
{
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   double lot = CalculateLotSize(symbol);
   double price = (direction > 0) ? SymbolInfoDouble(symbol, SYMBOL_ASK) 
                                   : SymbolInfoDouble(symbol, SYMBOL_BID);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = lot;
   request.type = (direction > 0) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   request.price = price;
   request.deviation = 3;
   request.magic = MagicNumber;
   request.comment = "ScalpMulti";
   request.type_filling = ORDER_FILLING_IOC;
   
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   // Calculer distances SL/TP en points
   double sl_distance = ScalpSL_Pips * PIPS_TO_POINTS_MULTIPLIER * point;
   double tp_distance = ScalpTP_Pips * PIPS_TO_POINTS_MULTIPLIER * point;
   
   if(direction > 0) {
      request.sl = NormalizeDouble(price - sl_distance, digits);
      request.tp = NormalizeDouble(price + tp_distance, digits);
   } else {
      request.sl = NormalizeDouble(price + sl_distance, digits);
      request.tp = NormalizeDouble(price - tp_distance, digits);
   }
   
   if(!OrderSend(request, result)) {
      Log(LOG_ERROR, "Échec OrderSend pour " + symbol + " - Code: " + IntegerToString(GetLastError()));
      return false;
   }

   if(result.retcode == TRADE_RETCODE_DONE) {
      trades_today++;
      Log(LOG_INFO, "✅ " + symbol + " " + (direction > 0 ? "BUY" : "SELL") +
          " | Lot: " + DoubleToString(lot, 2) +
          " | Ticket: " + IntegerToString(result.order));
      return true;
   } else {
      // Erreur détaillée avec description
      string error_msg = "Échec ouverture " + symbol + " " + (direction > 0 ? "BUY" : "SELL") +
                         " | Code: " + IntegerToString(result.retcode) +
                         " | " + GetTradeErrorDescription(result.retcode);
      Log(LOG_ERROR, error_msg);
      return false;
   }
}

//+------------------------------------------------------------------+
//| Calculer lot                                                      |
//+------------------------------------------------------------------+
double CalculateLotSize(string symbol)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk_amount = balance * RiskPercent / 100.0;
   
   double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   
   // Calculer valeur du pip
   double pip_value = tick_value / tick_size * point * PIPS_TO_POINTS_MULTIPLIER;
   double lot_size = risk_amount / (ScalpSL_Pips * pip_value);
   
   lot_size = MathFloor(lot_size / lot_step) * lot_step;
   lot_size = MathMax(min_lot, MathMin(lot_size, MaxLotSize));
   lot_size = MathMin(lot_size, max_lot);
   
   return NormalizeDouble(lot_size, 2);
}

//+------------------------------------------------------------------+
//| Créer le dashboard                                               |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Créer le dashboard SIMPLIFIÉ                                    |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   // Supprimer anciens objets
   for(int i=0; i<20; i++) {
      ObjectDelete(0, "Dash_"+IntegerToString(i));
   }
   ObjectDelete(0, "Dashboard_BG");
   ObjectDelete(0, "Dashboard_Title");
   
   // Fond
   ObjectCreate(0, "Dashboard_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_XDISTANCE, Dashboard_X);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_YDISTANCE, Dashboard_Y);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_XSIZE, 360);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_YSIZE, 300);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_COLOR, clrDodgerBlue);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BACK, true);
   
   // Titre
   ObjectCreate(0, "Dashboard_Title", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_XDISTANCE, Dashboard_X + 20);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_YDISTANCE, Dashboard_Y + 10);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, "Dashboard_Title", OBJPROP_FONT, "Arial Black");
   ObjectSetString(0, "Dashboard_Title", OBJPROP_TEXT, "EA SCALPING v27.2-SIMPLE");
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   
   // Créer 14 lignes de texte
   int yPos = Dashboard_Y + 40;
   int lineHeight = 18;
   
   for(int i=0; i<14; i++) {
      string objName = "Dash_"+IntegerToString(i);
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, Dashboard_X + 15);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yPos + (i * lineHeight));
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, objName, OBJPROP_FONT, "Courier New");
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, objName, OBJPROP_TEXT, "Chargement...");
   }
   
   ChartRedraw(0);
   Print("✅ Dashboard simplifié créé (14 lignes)");
}

//+------------------------------------------------------------------+
//| Décaler le graphique pour laisser espace au dashboard           |
//+------------------------------------------------------------------+
void ShiftChartForDashboard()
{
   if(!ShowDashboard || !AutoShiftChart) return;

   // Obtenir largeur graphique
   long chart_width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

   if(chart_width <= 0) {
      Log(LOG_WARN, "Impossible d'obtenir largeur graphique");
      return;
   }

   // Activer le décalage du graphique pour faire de la place au dashboard
   // Note: Le pourcentage de décalage est celui défini dans les propriétés du graphique MT5
   // L'utilisateur doit s'assurer que le décalage est suffisant (au moins 15%)
   ChartSetInteger(0, CHART_SHIFT, (long)1);
   ChartSetInteger(0, CHART_AUTOSCROLL, (long)0);  // Désactiver auto-scroll

   // Forcer actualisation
   ChartRedraw(0);

   Log(LOG_INFO, "✅ Décalage graphique activé pour dashboard");
}

//+------------------------------------------------------------------+
//| Mettre à jour le dashboard SIMPLIFIÉ                            |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   if(!ShowDashboard) return;
   // Limiter fréquence de mise à jour pour performance
   if(TimeCurrent() - last_dashboard_update < DASHBOARD_UPDATE_INTERVAL) return;

   last_dashboard_update = TimeCurrent();
   
   // Données
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double equity_pct = (equity / balance - 1) * 100;
   string currency = AccountInfoString(ACCOUNT_CURRENCY);
   
   // Calculer positions et profit (optimisé)
   int total_pos = 0;
   double total_profit = 0;
   int positions_total = PositionsTotal();

   for(int j = positions_total - 1; j >= 0; j--) {
      ulong ticket = PositionGetTicket(j);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;

      total_pos++;
      total_profit += PositionGetDouble(POSITION_PROFIT);
   }
   
   string profit_sign = total_profit >= 0 ? "+" : "";
   string equity_sign = equity_pct >= 0 ? "+" : "";
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   
   // Lignes du dashboard
   int line = 0;
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "===========================");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "COMPTE");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("Balance: %.2f %s", balance, currency));
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("Equity : %.2f (%s%.1f%%)", equity, equity_sign, equity_pct));
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "===========================");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "POSITIONS");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("Total  : %d pos", total_pos));
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("P&L    : %s%.2f %s", profit_sign, total_profit, currency));
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "===========================");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "STATISTIQUES");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("Trades : %d/%d", trades_today, MaxTradesPerDay));
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("Spread : %d pts", spread));
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, "===========================");
   ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT, StringFormat("News:%s Pos:%d/%d", UseNewsFilter?"ON":"OFF", total_pos, MaxOpenPositions));
   
   ChartRedraw(0);
}


//+------------------------------------------------------------------+
//| Tick handler                                                      |
//+------------------------------------------------------------------+
void OnTick()
{
   // Vérifier mises à jour périodiquement
   if(EnableAutoUpdate && TimeCurrent() - last_update_check > CheckUpdateEveryHours * 3600) {
      CheckForUpdates();
   }
   
   // Mettre à jour dashboard
   UpdateDashboard();
   
   // Gérer les positions (trailing, BE)
   ManageAllPositions();
   
   // Vérifier nouvelles bougies pour chaque symbole
   static datetime last_bars[];
   if(ArraySize(last_bars) != symbol_count) {
      ArrayResize(last_bars, symbol_count);
      ArrayInitialize(last_bars, 0);
   }
   
   for(int i = 0; i < symbol_count; i++) {
      datetime current_bar = iTime(symbols[i], PERIOD_CURRENT, 0);
      
      if(current_bar != last_bars[i]) {
         last_bars[i] = current_bar;
         
         // Nouvelle bougie - analyser
         if(CanTrade(symbols[i])) {
            int signal = GetSignalForSymbol(symbols[i]);
            if(signal != 0) {
               OpenPosition(symbols[i], signal);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Gérer toutes les positions                                       |
//+------------------------------------------------------------------+
void ManageAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      string symbol = PositionGetString(POSITION_SYMBOL);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double current_sl = PositionGetDouble(POSITION_SL);
      double current_tp = PositionGetDouble(POSITION_TP);
      int type = (int)PositionGetInteger(POSITION_TYPE);
      
      double current_price = (type == POSITION_TYPE_BUY) ? 
                             SymbolInfoDouble(symbol, SYMBOL_BID) : 
                             SymbolInfoDouble(symbol, SYMBOL_ASK);
      
      // Calculer profit en pips
      double profit_pips = 0;
      if(type == POSITION_TYPE_BUY) {
         profit_pips = (current_price - entry) / (PIPS_TO_POINTS_MULTIPLIER * point);
      } else {
         profit_pips = (entry - current_price) / (PIPS_TO_POINTS_MULTIPLIER * point);
      }
      
      bool modified = false;
      double new_sl = current_sl;
      
      // Break-Even
      if(profit_pips >= BreakEven_Pips && MathAbs(current_sl - entry) > point) {
         new_sl = entry;
         modified = true;
      }
      
      // Trailing Stop (activer si profit suffisant)
      if(profit_pips >= TrailingStop_Pips) {
         double trail_distance = TrailingStop_Pips * PIPS_TO_POINTS_MULTIPLIER * point;
         double new_trail_sl;
         
         if(type == POSITION_TYPE_BUY) {
            new_trail_sl = NormalizeDouble(current_price - trail_distance, digits);
            if(new_trail_sl > current_sl) {
               new_sl = new_trail_sl;
               modified = true;
            }
         } else {
            new_trail_sl = NormalizeDouble(current_price + trail_distance, digits);
            if(new_trail_sl < current_sl) {
               new_sl = new_trail_sl;
               modified = true;
            }
         }
      }
      
      if(modified) {
         MqlTradeRequest request;
         MqlTradeResult result;
         ZeroMemory(request);
         ZeroMemory(result);
         
         request.action = TRADE_ACTION_SLTP;
         request.symbol = symbol;
         request.position = ticket;
         request.sl = new_sl;
         request.tp = current_tp;
         
         if(!OrderSend(request, result)) {
            Log(LOG_ERROR, "Échec modification SL ticket " + IntegerToString(ticket) +
                " | Code: " + IntegerToString(result.retcode) +
                " | " + GetTradeErrorDescription(result.retcode));
         } else if(result.retcode == TRADE_RETCODE_DONE) {
            Log(LOG_DEBUG, "SL modifié pour ticket " + IntegerToString(ticket) +
                " | Nouveau SL: " + DoubleToString(new_sl, digits));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Vérifier les mises à jour disponibles                            |
//+------------------------------------------------------------------+
void CheckForUpdates()
{
   // Vérifier seulement si activé et pas trop récent
   if(!EnableAutoUpdate) return;
   
   if(TimeCurrent() - last_update_check < CheckUpdateEveryHours * 3600) {
      return;
   }
   
   last_update_check = TimeCurrent();
   
   Print("🔄 Vérification des mises à jour...");
   
   // URL de vérification de version (fichier texte simple)
   string version_url = "https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/VERSION.txt";
   
   string cookie = NULL, referer = NULL;
   char data[], result[];
   string headers;
   int timeout = 5000;
   
   int res = WebRequest("GET", version_url, cookie, referer, timeout, data, 0, result, headers);
   
   if(res == 200) {
      latest_version = CharArrayToString(result);
      StringTrimLeft(latest_version);
      StringTrimRight(latest_version);
      
      if(CompareVersions(latest_version, CURRENT_VERSION) > 0) {
         update_available = true;
         Print("✨ Mise à jour disponible : v", latest_version, " (actuelle : v", CURRENT_VERSION, ")");
         Print("📥 Téléchargement automatique dans 5 secondes...");
         
         // Attendre 5 secondes
         Sleep(5000);
         
         // Télécharger et installer
         DownloadAndInstallUpdate();
      } else {
         Print("✅ Vous utilisez la dernière version (v", CURRENT_VERSION, ")");
      }
   } else if(res == 429) {
      Print("⚠️ Limite API atteinte pour vérification MAJ. Réessai dans ", CheckUpdateEveryHours, "h");
   } else if(res == -1) {
      int error = GetLastError();
      if(error == 4060) {
         Print("⚠️ URL mise à jour non autorisée dans WebRequest");
         Print("   Ajoutez : https://raw.githubusercontent.com");
      }
   }
}

//+------------------------------------------------------------------+
//| Comparer deux versions (ex: "27.2" vs "27.1")                   |
//+------------------------------------------------------------------+
int CompareVersions(string v1, string v2)
{
   // Convertir en nombres comparables
   // Ex: "27.2" -> 27020, "27.10" -> 27100
   
   string parts1[], parts2[];
   StringSplit(v1, '.', parts1);
   StringSplit(v2, '.', parts2);
   
   int major1 = (int)StringToInteger(parts1[0]);
   int minor1 = ArraySize(parts1) > 1 ? (int)StringToInteger(parts1[1]) : 0;
   
   int major2 = (int)StringToInteger(parts2[0]);
   int minor2 = ArraySize(parts2) > 1 ? (int)StringToInteger(parts2[1]) : 0;
   
   int num1 = major1 * 1000 + minor1;
   int num2 = major2 * 1000 + minor2;
   
   if(num1 > num2) return 1;
   if(num1 < num2) return -1;
   return 0;
}

//+------------------------------------------------------------------+
//| Télécharger et installer la mise à jour                          |
//+------------------------------------------------------------------+
void DownloadAndInstallUpdate()
{
   Print("📥 Téléchargement de la version ", latest_version, "...");
   
   string cookie = NULL, referer = NULL;
   char data[], result[];
   string headers;
   int timeout = 30000; // 30 secondes pour télécharger le code
   
   int res = WebRequest("GET", UpdateURL, cookie, referer, timeout, data, 0, result, headers);
   
   if(res == 200) {
      string new_code = CharArrayToString(result);

      // Validation taille fichier téléchargé
      if(StringLen(new_code) < MIN_JSON_FILE_SIZE) {
         Print("❌ Fichier téléchargé trop petit, probablement erreur");
         return;
      }
      
      // Sauvegarder dans un fichier temporaire
      string temp_file = "EA_MultiPairs_UPDATE_v" + latest_version + ".mq5";
      string temp_path = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\MQL5\\Experts\\" + temp_file;
      
      int file = FileOpen(temp_file, FILE_WRITE|FILE_TXT|FILE_COMMON);
      if(file != INVALID_HANDLE) {
         FileWriteString(file, new_code);
         FileClose(file);
         
         Print("✅ Mise à jour téléchargée : ", temp_file);
         Print("🔧 IMPORTANT : Recompiler le fichier avec MetaEditor (F4 → F7)");
         Print("💡 Ou utilisez le script Deploy-EA-VPS.ps1 pour installation auto");
         
         // Créer un fichier d'instructions
         CreateUpdateInstructions(temp_file);
         
         Alert("✨ Mise à jour v" + latest_version + " téléchargée !\n" +
               "Fichier : " + temp_file + "\n" +
               "Voir fichier UPDATE_INSTRUCTIONS.txt pour installer");
      } else {
         Print("❌ Impossible de créer le fichier de mise à jour");
      }
   } else {
      Print("❌ Échec téléchargement mise à jour : HTTP ", res);
   }
}

//+------------------------------------------------------------------+
//| Créer fichier d'instructions pour installer la MAJ              |
//+------------------------------------------------------------------+
void CreateUpdateInstructions(string update_file)
{
   string instructions = 
      "╔══════════════════════════════════════════════════════════╗\n" +
      "║  INSTRUCTIONS D'INSTALLATION - MISE À JOUR v" + latest_version + "        ║\n" +
      "╚══════════════════════════════════════════════════════════╝\n\n" +
      
      "✅ Fichier téléchargé : " + update_file + "\n\n" +
      
      "📋 MÉTHODE 1 : Installation Manuelle (5 minutes)\n" +
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
      "1. Fermer tous les graphiques utilisant cet EA\n" +
      "2. Ouvrir MetaEditor (F4 dans MT5)\n" +
      "3. Ouvrir le fichier : " + update_file + "\n" +
      "4. Menu : Fichier → Enregistrer sous...\n" +
      "5. Nom : EA_MultiPairs_News_Dashboard_v27.mq5 (remplacer ancien)\n" +
      "6. Compiler (F7)\n" +
      "7. Vérifier : 0 error, 0 warning\n" +
      "8. Glisser le nouvel EA sur vos graphiques\n\n" +
      
      "📋 MÉTHODE 2 : Script PowerShell (2 minutes)\n" +
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
      "1. Télécharger : Deploy-EA-VPS.ps1\n" +
      "2. Clic droit → Exécuter avec PowerShell\n" +
      "3. Suivre les instructions\n" +
      "4. Le script compile automatiquement\n\n" +
      
      "🆕 NOUVEAUTÉS VERSION " + latest_version + "\n" +
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
      "Consultez le changelog sur GitHub pour détails\n\n" +
      
      "⚠️ ATTENTION\n" +
      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n" +
      "- Sauvegardez vos paramètres actuels avant MAJ\n" +
      "- Testez en démo avant de passer en réel\n" +
      "- Vérifiez que le dashboard s'affiche correctement\n\n" +
      
      "📞 Support : Consultez README_SOLUTION_COMPLETE.md\n" +
      "🌐 GitHub : [Votre URL GitHub]\n\n" +
      
      "Généré automatiquement le " + TimeToString(TimeCurrent()) + "\n";
   
   int file = FileOpen("UPDATE_INSTRUCTIONS.txt", FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(file != INVALID_HANDLE) {
      FileWriteString(file, instructions);
      FileClose(file);
      
      Print("📄 Instructions créées : UPDATE_INSTRUCTIONS.txt");
      Print("   Emplacement : ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\");
   }
}

//+------------------------------------------------------------------+
//| Deinitialisation                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Libérer les indicateurs
   for(int i = 0; i < ArraySize(indicators); i++) {
      if(indicators[i].handle_ema_fast != INVALID_HANDLE) 
         IndicatorRelease(indicators[i].handle_ema_fast);
      if(indicators[i].handle_ema_slow != INVALID_HANDLE) 
         IndicatorRelease(indicators[i].handle_ema_slow);
      if(indicators[i].handle_rsi != INVALID_HANDLE) 
         IndicatorRelease(indicators[i].handle_rsi);
      if(indicators[i].handle_atr != INVALID_HANDLE) 
         IndicatorRelease(indicators[i].handle_atr);
   }
   
   // Supprimer le dashboard
   ObjectDelete(0, "Dashboard_BG");
   ObjectDelete(0, "Dashboard_Title");
   ObjectDelete(0, "Dashboard_Text");

   // Restaurer les paramètres graphique par défaut
   if(AutoShiftChart && ShowDashboard) {
      ChartSetInteger(0, CHART_AUTOSCROLL, (long)1);  // Réactiver auto-scroll
      ChartRedraw(0);
      Log(LOG_INFO, "Paramètres graphique restaurés");
   }

   Comment("");
   
   Print("✅ EA Multi-Paires arrêté | Stats: ", trades_today, " trades | P&L: ", 
         DoubleToString(daily_profit, 2));
}
//+------------------------------------------------------------------+
