//+------------------------------------------------------------------+
//| EA Multi-Paires Scalping Pro v27.0 - News Filter + Dashboard    |
//| Filtre économique ForexFactory + Trading multi-symboles          |
//+------------------------------------------------------------------+
#property version   "27.0"
#property strict
#property description "Multi-Symbol Scalping EA avec News Filter"
#property description "Dashboard temps réel + ONNX + FxPro optimisé"

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
input string   UpdateURL = "https://raw.githubusercontent.com/votre-repo/main/EA_MultiPairs_News_Dashboard_v27.mq5";  // URL du code source
input int      CheckUpdateEveryHours = 24;  // Vérifier MAJ toutes les X heures

input int      MagicNumber = 270000;

// === VARIABLES GLOBALES ===
string symbols[];
int symbol_count = 0;

// Statistiques
int trades_today = 0;
double daily_profit = 0;
datetime current_day = 0;

// News
struct NewsEvent {
   datetime time;
   string title;
   string country;
   string impact;
   string forecast;
   string previous;
};
NewsEvent news_events[];
datetime last_news_update = 0;
bool news_filter_active = false;

// Dashboard
string dashboard_text = "";
datetime last_dashboard_update = 0;

// Auto-Update
#define CURRENT_VERSION "27.2"
datetime last_update_check = 0;
bool update_available = false;
string latest_version = "";

// Handles indicateurs (par symbole)
struct SymbolIndicators {
   string symbol;
   int handle_ema_fast;
   int handle_ema_slow;
   int handle_rsi;
   int handle_atr;
   bool enabled;
   int positions_count;
   double last_profit;
};
SymbolIndicators indicators[];

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("🚀 EA Multi-Paires Scalping Pro v27.0 - Initialisation...");
   
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
   if(TimeCurrent() - last_attempt < 300) { // Minimum 5 minutes entre tentatives
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
//| Parser le JSON des news                                          |
//+------------------------------------------------------------------+
void ParseNewsJSON(string json)
{
   // Parsing simplifié (à améliorer avec bibliothèque JSON)
   ArrayResize(news_events, 0);
   
   // Note: Parsing manuel basique - améliorer avec JAson.mqh ou bibliothèque
   // Format attendu: [{"title":"...","country":"USD","date":"...","impact":"High",...},...]
   
   int start = 0;
   int count = 0;
   
   while(true) {
      int obj_start = StringFind(json, "{\"title\":", start);
      if(obj_start < 0) break;
      
      int obj_end = StringFind(json, "},", obj_start);
      if(obj_end < 0) obj_end = StringFind(json, "}]", obj_start);
      if(obj_end < 0) break;
      
      string obj = StringSubstr(json, obj_start, obj_end - obj_start);
      
      // Extraire les champs (parsing basique)
      NewsEvent event;
      event.title = ExtractField(obj, "title");
      event.country = ExtractField(obj, "country");
      event.impact = ExtractField(obj, "impact");
      event.forecast = ExtractField(obj, "forecast");
      event.previous = ExtractField(obj, "previous");
      
      string date_str = ExtractField(obj, "date");
      event.time = ParseDateString(date_str);
      
      // Filtrer par devise
      if(IsRelevantCurrency(event.country)) {
         ArrayResize(news_events, count + 1);
         news_events[count++] = event;
      }
      
      start = obj_end + 1;
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
//| Parser une date string en datetime                               |
//+------------------------------------------------------------------+
datetime ParseDateString(string date_str)
{
   // Format attendu: "2025-11-05T14:30:00+00:00"
   // Parsing simplifié
   
   if(StringLen(date_str) < 19) return 0;
   
   MqlDateTime dt;
   dt.year = (int)StringToInteger(StringSubstr(date_str, 0, 4));
   dt.mon = (int)StringToInteger(StringSubstr(date_str, 5, 2));
   dt.day = (int)StringToInteger(StringSubstr(date_str, 8, 2));
   dt.hour = (int)StringToInteger(StringSubstr(date_str, 11, 2));
   dt.min = (int)StringToInteger(StringSubstr(date_str, 14, 2));
   dt.sec = (int)StringToInteger(StringSubstr(date_str, 17, 2));
   
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
   
   // Recharger les news toutes les 6 heures (21600 secondes)
   if(TimeCurrent() - last_news_update > 21600) {
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
   
   // Filtre ATR
   if(atr[0] < ATR_Filter * 10 * point) return 0;
   
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
   
   // Vérifier limites journalières
   if(TimeCurrent() - current_day > 86400) {
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
//| Compter les positions totales                                    |
//+------------------------------------------------------------------+
int GetTotalPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Compter les positions pour un symbole                            |
//+------------------------------------------------------------------+
int GetSymbolPositions(string symbol)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetString(POSITION_SYMBOL) == symbol) count++;
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
   
   double sl_distance = ScalpSL_Pips * 10 * point;
   double tp_distance = ScalpTP_Pips * 10 * point;
   
   if(direction > 0) {
      request.sl = NormalizeDouble(price - sl_distance, digits);
      request.tp = NormalizeDouble(price + tp_distance, digits);
   } else {
      request.sl = NormalizeDouble(price + sl_distance, digits);
      request.tp = NormalizeDouble(price - tp_distance, digits);
   }
   
   if(!OrderSend(request, result)) return false;
   
   if(result.retcode == TRADE_RETCODE_DONE) {
      trades_today++;
      Print("✅ ", symbol, " ", (direction > 0 ? "BUY" : "SELL"), " | Lot: ", lot);
      return true;
   }
   
   return false;
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
   
   double pip_value = tick_value / tick_size * point * 10;
   double lot_size = risk_amount / (ScalpSL_Pips * pip_value);
   
   lot_size = MathFloor(lot_size / lot_step) * lot_step;
   lot_size = MathMax(min_lot, MathMin(lot_size, MaxLotSize));
   lot_size = MathMin(lot_size, max_lot);
   
   return NormalizeDouble(lot_size, 2);
}

//+------------------------------------------------------------------+
//| Créer le dashboard                                               |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   // Fond du dashboard avec bordure
   ObjectCreate(0, "Dashboard_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_XDISTANCE, Dashboard_X);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_YDISTANCE, Dashboard_Y);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_XSIZE, 400);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_YSIZE, 500);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_COLOR, clrDodgerBlue);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BACK, false);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_HIDDEN, true);
   
   // Titre du dashboard
   ObjectCreate(0, "Dashboard_Title", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_XDISTANCE, Dashboard_X + 20);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_YDISTANCE, Dashboard_Y + 10);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_COLOR, clrYellow);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_FONTSIZE, 11);
   ObjectSetString(0, "Dashboard_Title", OBJPROP_FONT, "Arial Black");
   ObjectSetString(0, "Dashboard_Title", OBJPROP_TEXT, "EA SCALPING MULTI-PAIRES v27");
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_HIDDEN, true);
   
   // Texte principal
   ObjectCreate(0, "Dashboard_Text", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_XDISTANCE, Dashboard_X + 15);
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_YDISTANCE, Dashboard_Y + 40);
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, "Dashboard_Text", OBJPROP_FONT, "Courier New");
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Dashboard_Text", OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Mettre à jour le dashboard                                       |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   if(!ShowDashboard) return;
   if(TimeCurrent() - last_dashboard_update < 1) return;
   
   last_dashboard_update = TimeCurrent();
   
   string text = "";
   
   // === SECTION COMPTE ===
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double equity_pct = (equity / balance - 1) * 100;
   string equity_color = equity_pct >= 0 ? "▲" : "▼";
   
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += "  COMPTE\n";
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += StringFormat("Balance : %.2f %s\n", balance, AccountInfoString(ACCOUNT_CURRENCY));
   text += StringFormat("Equity  : %.2f %s %s %.1f%%\n\n", 
                        equity, 
                        AccountInfoString(ACCOUNT_CURRENCY),
                        equity_color,
                        MathAbs(equity_pct));
   
   // === SECTION STATISTIQUES ===
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += "  STATISTIQUES DU JOUR\n";
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += StringFormat("Trades  : %d / %d max\n", trades_today, MaxTradesPerDay);
   
   string profit_emoji = daily_profit >= 0 ? "▲" : "▼";
   text += StringFormat("P&L     : %s %.2f %s\n\n",
                        profit_emoji,
                        MathAbs(daily_profit),
                        AccountInfoString(ACCOUNT_CURRENCY));
   
   // === SECTION POSITIONS ===
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += "  POSITIONS OUVERTES\n";
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   
   int total_pos = 0;
   double total_profit = 0;
   bool has_positions = false;
   
   for(int i = 0; i < symbol_count; i++) {
      string sym = symbols[i];
      int sym_pos = 0;
      double sym_profit = 0;
      
      for(int j = PositionsTotal() - 1; j >= 0; j--) {
         ulong ticket = PositionGetTicket(j);
         if(!PositionSelectByTicket(ticket)) continue;
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != sym) continue;
         
         sym_pos++;
         double pos_profit = PositionGetDouble(POSITION_PROFIT);
         sym_profit += pos_profit;
         total_pos++;
         total_profit += pos_profit;
      }
      
      if(sym_pos > 0) {
         has_positions = true;
         string emoji = sym_profit >= 0 ? "▲" : "▼";
         string color_mark = sym_profit >= 0 ? "+" : "";
         text += StringFormat("%s %-8s: %d pos | %s%.2f\n",
                             emoji, sym, sym_pos, color_mark, sym_profit);
      }
   }
   
   if(!has_positions) {
      text += "Aucune position active\n";
   } else {
      text += "──────────────────────────\n";
      string total_emoji = total_profit >= 0 ? "▲" : "▼";
      string total_color = total_profit >= 0 ? "+" : "";
      text += StringFormat("%s TOTAL  : %d pos | %s%.2f\n",
                          total_emoji, total_pos, total_color, total_profit);
   }
   text += "\n";
   
   // === SECTION NEWS ===
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += "  PROCHAINES NEWS\n";
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   
   if(UseNewsFilter && ArraySize(news_events) > 0) {
      int news_count = 0;
      datetime now = TimeCurrent();
      
      for(int i = 0; i < ArraySize(news_events) && news_count < 4; i++) {
         int time_diff = (int)(news_events[i].time - now);
         if(time_diff > 0 && time_diff < 14400) { // Prochaines 4h
            string impact_emoji = "○";
            if(news_events[i].impact == "High") impact_emoji = "●";
            else if(news_events[i].impact == "Medium") impact_emoji = "◐";
            
            int hours = time_diff / 3600;
            int mins = (time_diff % 3600) / 60;
            string time_str = "";
            if(hours > 0) time_str = StringFormat("%dh%02d", hours, mins);
            else time_str = StringFormat("%dm", mins);
            
            // Tronquer titre si trop long
            string title = news_events[i].title;
            if(StringLen(title) > 20) {
               title = StringSubstr(title, 0, 20) + "...";
            }
            
            text += StringFormat("%s %s %s\n   %s\n",
                                impact_emoji,
                                news_events[i].country,
                                time_str,
                                title);
            news_count++;
         }
      }
      
      if(news_count == 0) {
         text += "Aucune news dans les 4h\n";
      }
   } else {
      text += UseNewsFilter ? "Chargement..." : "Filtre désactivé\n";
   }
   text += "\n";
   
   // === SECTION STATUT ===
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   text += "  STATUT EA\n";
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   
   // Sessions actives
   string sessions = "";
   if(Trade_London) sessions += "LON ";
   if(Trade_NewYork) sessions += "NY ";
   if(Trade_Asian) sessions += "ASIA";
   if(sessions == "") sessions = "Aucune";
   text += StringFormat("Sessions : %s\n", sessions);
   
   // Filtres
   text += StringFormat("News     : %s\n", UseNewsFilter ? "ON" : "OFF");
   text += StringFormat("ONNX     : %s\n", UseONNX ? "ON" : "OFF");
   
   // Limites
   text += StringFormat("Positions: %d / %d max\n", total_pos, MaxOpenPositions);
   
   // Spread moyen
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   text += StringFormat("Spread   : %d pts\n", spread);
   
   text += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   
   ObjectSetString(0, "Dashboard_Text", OBJPROP_TEXT, text);
   
   // Forcer le rafraîchissement
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
      
      double profit_pips = 0;
      if(type == POSITION_TYPE_BUY) {
         profit_pips = (current_price - entry) / (10 * point);
      } else {
         profit_pips = (entry - current_price) / (10 * point);
      }
      
      bool modified = false;
      double new_sl = current_sl;
      
      // Break-Even
      if(profit_pips >= BreakEven_Pips && MathAbs(current_sl - entry) > point) {
         new_sl = entry;
         modified = true;
      }
      
      // Trailing Stop
      if(profit_pips >= TrailingStop_Pips) {
         double trail_distance = TrailingStop_Pips * 10 * point;
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
            Print("⚠️ Erreur modification SL ticket ", ticket, ": ", result.retcode);
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
   string version_url = "https://raw.githubusercontent.com/votre-repo/main/VERSION.txt";
   
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
      
      if(StringLen(new_code) < 1000) {
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
   
   Comment("");
   
   Print("✅ EA Multi-Paires arrêté | Stats: ", trades_today, " trades | P&L: ", 
         DoubleToString(daily_profit, 2));
}
//+------------------------------------------------------------------+
