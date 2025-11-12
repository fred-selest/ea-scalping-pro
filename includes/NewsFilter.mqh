//+------------------------------------------------------------------+
//| NewsFilter.mqh - Filtre d'actualités économiques                 |
//| Module news pour EA Multi-Paires Scalping Pro v27.56            |
//|------------------------------------------------------------------|
//| CONTENU:                                                         |
//|   - Intégration calendrier ForexFactory                         |
//|   - Parsing JSON du calendrier économique                       |
//|   - Filtre de trading basé sur les news                        |
//|   - Circuit breaker pour API failures                          |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property strict

#include "Utils.mqh"

// === CONSTANTES NEWS ===
#define MIN_NEWS_UPDATE_INTERVAL 300    // Minimum 5 minutes between news API calls
#define NEWS_RELOAD_INTERVAL 21600      // Reload news every 6 hours
#define NEWS_API_MAX_FAILURES 3         // Nombre max échecs avant circuit breaker
#define NEWS_API_DISABLE_DURATION 3600  // Durée désactivation (1 heure)

// === STRUCTURES NEWS ===

// Structure pour un événement économique
struct NewsEvent {
   datetime time;
   string title;
   string country;
   string impact;
   string forecast;
   string previous;
};

// === VARIABLES GLOBALES (déclarées dans le fichier principal) ===
extern NewsEvent news_events[];
extern datetime last_news_update;
extern bool news_filter_active;
extern int news_api_failures;
extern datetime news_api_disabled_until;

// Paramètres news (définis dans le fichier principal)
extern bool UseNewsFilter;
extern int MinutesBeforeNews;
extern int MinutesAfterNews;
extern bool FilterHighImpact;
extern bool FilterMediumImpact;
extern bool FilterLowImpact;
extern string NewsCurrencies;

//+------------------------------------------------------------------+
//| ✅ v27.54: Charger calendrier avec circuit breaker              |
//| Circuit breaker: Désactive API après 3 échecs consécutifs      |
//+------------------------------------------------------------------+
void LoadNewsCalendar()
{
   // ✅ v27.54: Vérifier si circuit breaker actif
   if(news_api_disabled_until > TimeCurrent()) {
      int remaining = (int)(news_api_disabled_until - TimeCurrent());
      Log(LOG_DEBUG, "⛔ API news désactivée (circuit breaker) - " +
          IntegerToString(remaining/60) + " min restantes");
      return;
   }

   static datetime last_attempt = 0;
   if(TimeCurrent() - last_attempt < MIN_NEWS_UPDATE_INTERVAL) {
      return;
   }
   last_attempt = TimeCurrent();

   string url = "https://nfs.faireconomy.media/ff_calendar_thisweek.json";

   string cookie = NULL, referer = NULL;
   char data[], result[];
   string headers;
   int timeout = WEBQUEST_TIMEOUT_MS;

   Log(LOG_DEBUG, "📰 Téléchargement du calendrier économique...");

   int res = WebRequest("GET", url, cookie, referer, timeout, data, 0, result, headers);

   if(res == -1) {
      int error = GetLastError();
      news_api_failures++;

      Log(LOG_ERROR, "WebRequest error: " + IntegerToString(error) +
          " (échec " + IntegerToString(news_api_failures) + "/" +
          IntegerToString(NEWS_API_MAX_FAILURES) + ")");

      if(error == 4060) {
         Log(LOG_WARN, "URL non autorisée. Ajoutez dans Outils → Options → Expert Advisors → WebRequest");
         Log(LOG_WARN, "   https://nfs.faireconomy.media");
      }

      // ✅ v27.54: Activer circuit breaker après X échecs
      if(news_api_failures >= NEWS_API_MAX_FAILURES) {
         news_api_disabled_until = TimeCurrent() + NEWS_API_DISABLE_DURATION;
         Alert("⚠️ API News désactivée (circuit breaker) après " +
               IntegerToString(news_api_failures) + " échecs - réactivation dans 1 heure");
         Log(LOG_ERROR, "🔴 Circuit breaker activé - API news désactivée jusqu'à " +
             TimeToString(news_api_disabled_until));
      }
      return;
   }

   if(res == 200) {
      string json = CharArrayToString(result);
      ParseNewsJSON(json);
      last_news_update = TimeCurrent();
      // ✅ v27.54: Réinitialiser compteur d'échecs si succès
      news_api_failures = 0;
      Log(LOG_INFO, "✅ Calendrier chargé: " + IntegerToString(ArraySize(news_events)) + " événements");
   } else if(res == 429) {
      news_api_failures++;
      Log(LOG_WARN, "Limite de requêtes API atteinte (429) - échec " +
          IntegerToString(news_api_failures) + "/" + IntegerToString(NEWS_API_MAX_FAILURES));
      last_news_update = TimeCurrent();

      // ✅ v27.54: Circuit breaker pour rate limiting
      if(news_api_failures >= NEWS_API_MAX_FAILURES) {
         news_api_disabled_until = TimeCurrent() + NEWS_API_DISABLE_DURATION;
         Alert("⚠️ API News désactivée (rate limiting) - réactivation dans 1 heure");
         Log(LOG_ERROR, "🔴 Circuit breaker activé (429) - API news désactivée");
      }
   } else {
      news_api_failures++;
      Log(LOG_WARN, "HTTP Error: " + IntegerToString(res) + " - échec " +
          IntegerToString(news_api_failures) + "/" + IntegerToString(NEWS_API_MAX_FAILURES));

      if(news_api_failures >= NEWS_API_MAX_FAILURES) {
         news_api_disabled_until = TimeCurrent() + NEWS_API_DISABLE_DURATION;
         Alert("⚠️ API News désactivée - erreurs répétées");
         Log(LOG_ERROR, "🔴 Circuit breaker activé - API news désactivée");
      }
   }
}

//+------------------------------------------------------------------+
//| ✅ v27.4 FIX: Parser le JSON avec validation robuste           |
//| Correction: Pré-allocation mémoire + validation stricte        |
//+------------------------------------------------------------------+
void ParseNewsJSON(string json)
{
   ArrayResize(news_events, 0);

   if(StringLen(json) < 10) {
      Log(LOG_WARN, "JSON invalide: trop court (" + IntegerToString(StringLen(json)) + " caractères)");
      return;
   }

   if(StringFind(json, "[") < 0) {
      Log(LOG_WARN, "JSON invalide: pas de tableau détecté");
      return;
   }

   // ✅ v27.4: Pré-allocation pour performance
   NewsEvent temp_events[];
   ArrayResize(temp_events, 1000);  // Capacité estimée

   int start = 0;
   int count = 0;
   int max_events = 1000;

   while(count < max_events) {
      int obj_start = StringFind(json, "{\"title\":", start);
      if(obj_start < 0) break;

      int obj_end = StringFind(json, "},", obj_start);
      if(obj_end < 0) obj_end = StringFind(json, "}]", obj_start);
      if(obj_end < 0) break;

      string obj = StringSubstr(json, obj_start, obj_end - obj_start);

      NewsEvent event;
      event.title = ExtractField(obj, "title");
      event.country = ExtractField(obj, "country");
      event.impact = ExtractField(obj, "impact");
      event.forecast = ExtractField(obj, "forecast");
      event.previous = ExtractField(obj, "previous");

      string date_str = ExtractField(obj, "date");
      event.time = ParseDateString(date_str);

      // ✅ v27.4: Validation avant ajout
      if(event.time > 0 && StringLen(event.country) > 0) {
         if(IsRelevantCurrency(event.country)) {
            temp_events[count++] = event;
         }
      }

      start = obj_end + 1;
   }

   if(count >= max_events) {
      Log(LOG_WARN, "Limite d'événements atteinte (" + IntegerToString(max_events) + ")");
   }

   // ✅ v27.4: Une seule allocation finale
   ArrayResize(news_events, count);
   for(int i = 0; i < count; i++) {
      news_events[i] = temp_events[i];
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
//| ✅ v27.4 FIX: Parser date avec validation années bissextiles   |
//| Correction: Validation complète jours/mois                      |
//+------------------------------------------------------------------+
datetime ParseDateString(string date_str)
{
   if(StringLen(date_str) < 19) return 0;

   MqlDateTime dt;
   ZeroMemory(dt);

   dt.year = (int)StringToInteger(StringSubstr(date_str, 0, 4));
   dt.mon = (int)StringToInteger(StringSubstr(date_str, 5, 2));
   dt.day = (int)StringToInteger(StringSubstr(date_str, 8, 2));
   dt.hour = (int)StringToInteger(StringSubstr(date_str, 11, 2));
   dt.min = (int)StringToInteger(StringSubstr(date_str, 14, 2));
   dt.sec = (int)StringToInteger(StringSubstr(date_str, 17, 2));

   // Validation de base
   if(dt.year < 2000 || dt.year > 2100) return 0;
   if(dt.mon < 1 || dt.mon > 12) return 0;
   if(dt.hour > 23 || dt.min > 59 || dt.sec > 59) return 0;

   // ✅ v27.4 FIX: Validation jours selon mois ET année bissextile
   int max_day = 31;

   if(dt.mon == 2) {
      // Février : vérifier année bissextile
      bool is_leap = (dt.year % 4 == 0 && dt.year % 100 != 0) || (dt.year % 400 == 0);
      max_day = is_leap ? 29 : 28;
   }
   else if(dt.mon == 4 || dt.mon == 6 || dt.mon == 9 || dt.mon == 11) {
      // Avril, Juin, Septembre, Novembre : 30 jours
      max_day = 30;
   }

   if(dt.day < 1 || dt.day > max_day) return 0;

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

   if(TimeCurrent() - last_news_update > NEWS_RELOAD_INTERVAL) {
      LoadNewsCalendar();
   }

   datetime now = TimeCurrent();

   string base = StringSubstr(symbol, 0, 3);
   string quote = StringSubstr(symbol, 3, 3);

   for(int i = 0; i < ArraySize(news_events); i++) {
      if(news_events[i].country != base && news_events[i].country != quote) continue;

      bool filter_this = false;
      if(news_events[i].impact == "High" && FilterHighImpact) filter_this = true;
      if(news_events[i].impact == "Medium" && FilterMediumImpact) filter_this = true;
      if(news_events[i].impact == "Low" && FilterLowImpact) filter_this = true;

      if(!filter_this) continue;

      int time_diff = (int)(news_events[i].time - now);

      if(time_diff > 0 && time_diff <= MinutesBeforeNews * 60) {
         Log(LOG_DEBUG, "📰 News filter: " + symbol + " - " + news_events[i].title +
             " dans " + IntegerToString(time_diff/60) + " min");
         return true;
      }

      if(time_diff < 0 && time_diff >= -MinutesAfterNews * 60) {
         return true;
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Réinitialiser le circuit breaker (admin function)                |
//+------------------------------------------------------------------+
void ResetNewsCircuitBreaker()
{
   news_api_failures = 0;
   news_api_disabled_until = 0;
   Log(LOG_INFO, "✅ Circuit breaker news réinitialisé");
}
