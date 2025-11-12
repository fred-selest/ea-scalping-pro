//+------------------------------------------------------------------+
//| Utils.mqh - Fonctions utilitaires et logging                     |
//| Module utilitaire pour EA Multi-Paires Scalping Pro v27.56      |
//|------------------------------------------------------------------|
//| CONTENU:                                                         |
//|   - Énumérations et types de base                               |
//|   - Système de logging avec niveaux de sévérité                |
//|   - Gestion des erreurs de trading                             |
//|   - Fonctions helper diverses                                   |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property strict

// === CONSTANTES UTILITAIRES ===
#define PIPS_TO_POINTS_MULTIPLIER 10    // Conversion pips to points (10 for 4/5 digit brokers)
#define WEBQUEST_TIMEOUT_MS 5000        // WebRequest timeout in milliseconds
#define HOURS_TO_SECONDS 3600           // Conversion hours to seconds
// Note: SECONDS_PER_DAY est défini dans le fichier principal

// Logging levels
enum LOG_LEVEL {
   LOG_DEBUG = 0,
   LOG_INFO = 1,
   LOG_WARN = 2,
   LOG_ERROR = 3
};

// === VARIABLES GLOBALES DE LOGGING ===
// Ces variables (MinLogLevel, EnableFileLogging, MagicNumber) sont
// déclarées dans le fichier principal et accessibles directement

//+------------------------------------------------------------------+
//| Fonction de logging avec niveaux de sévérité                    |
//| ✅ v27.4: Inchangé - fonctionne bien                            |
//+------------------------------------------------------------------+
void Log(LOG_LEVEL level, string message)
{
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

   if(EnableFileLogging) {
      int file = FileOpen("EA_Scalping_v274_Log_" + IntegerToString(MagicNumber) + ".txt",
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
//| ✅ v27.4: Inchangé - mapping complet des erreurs               |
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
//| Fonction helper: Convertir pips en points                        |
//+------------------------------------------------------------------+
double PipsToPoints(double pips)
{
   return pips * PIPS_TO_POINTS_MULTIPLIER;
}

//+------------------------------------------------------------------+
//| Fonction helper: Convertir points en pips                        |
//+------------------------------------------------------------------+
double PointsToPips(double points)
{
   return points / PIPS_TO_POINTS_MULTIPLIER;
}

//+------------------------------------------------------------------+
//| Fonction helper: Normaliser le prix selon les digits du symbole  |
//+------------------------------------------------------------------+
double NormalizePrice(string symbol, double price)
{
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   return NormalizeDouble(price, digits);
}

//+------------------------------------------------------------------+
//| Fonction helper: Normaliser le volume selon les specs du symbole |
//+------------------------------------------------------------------+
double NormalizeVolume(string symbol, double volume)
{
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   // Arrondir au lot step le plus proche
   volume = MathRound(volume / lot_step) * lot_step;

   // Appliquer les limites
   if(volume < min_lot) volume = min_lot;
   if(volume > max_lot) volume = max_lot;

   return NormalizeDouble(volume, 2);
}

//+------------------------------------------------------------------+
//| Comparer deux versions (format: "27.56")                         |
//| Retourne: 1 si v1 > v2, -1 si v1 < v2, 0 si égales             |
//+------------------------------------------------------------------+
int CompareVersions(string v1, string v2)
{
   string parts1[], parts2[];
   int count1 = StringSplit(v1, '.', parts1);
   int count2 = StringSplit(v2, '.', parts2);

   int max_parts = MathMax(count1, count2);

   for(int i = 0; i < max_parts; i++) {
      int num1 = (i < count1) ? (int)StringToInteger(parts1[i]) : 0;
      int num2 = (i < count2) ? (int)StringToInteger(parts2[i]) : 0;

      if(num1 > num2) return 1;
      if(num1 < num2) return -1;
   }

   return 0;
}

//+------------------------------------------------------------------+
//| Ajouter les URLs autorisées pour WebRequest                      |
//+------------------------------------------------------------------+
bool AddWebRequestURL()
{
   string urls[] = {
      "https://nfs.faireconomy.media",
      "https://cdn-nfs.faireconomy.media",
      "https://www.forexfactory.com"
   };

   Log(LOG_INFO, "📡 Configuration WebRequest nécessaire :");
   Log(LOG_INFO, "   Outils → Options → Expert Advisors → WebRequest");
   Log(LOG_INFO, "   Ajouter les URLs suivantes :");

   for(int i = 0; i < ArraySize(urls); i++) {
      Log(LOG_INFO, "   - " + urls[i]);
   }

   return true;
}
