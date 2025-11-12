//+------------------------------------------------------------------+
//| Indicators.mqh - Gestion des indicateurs techniques              |
//| Module indicateurs pour EA Multi-Paires Scalping Pro v27.56     |
//|------------------------------------------------------------------|
//| CONTENU:                                                         |
//|   - Structures pour indicateurs et cache                        |
//|   - Initialisation des handles d'indicateurs                    |
//|   - Cache optimisé pour réduire les calculs                    |
//|   - Historique ATR pour volatilité moyenne                      |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property strict

#include "Utils.mqh"

// === CONSTANTES INDICATEURS ===
#define INDICATOR_CACHE_SECONDS 1       // Cache indicator values for N seconds

// === STRUCTURES INDICATEURS ===

// Structure pour les handles d'indicateurs par symbole
struct SymbolIndicators {
   string symbol;
   int handle_ema_fast;
   int handle_ema_slow;
   int handle_rsi;
   int handle_atr;
   int handle_adx;
   bool enabled;
   int positions_count;
   double last_profit;
};

// ✅ v27.4: Cache indicateurs pour optimisation
struct CachedIndicators {
   double ema_fast[3];
   double ema_slow[3];
   double rsi[3];
   double atr[2];
   double adx[2];
   datetime last_update;
};

// ✅ v27.56: Cache ATR pour calcul volatilité moyenne
struct ATRHistory {
   string symbol;
   double atr_values[20];  // 20 dernières valeurs
   int count;
   datetime last_update;
};

// === VARIABLES GLOBALES (déclarées dans le fichier principal) ===
extern SymbolIndicators indicators[];
extern CachedIndicators indicators_cache[];
extern ATRHistory atr_history[];

// Paramètres des indicateurs (définis dans le fichier principal)
extern int EMA_Fast;
extern int EMA_Slow;
extern int RSI_Period;
extern int ATR_Period;
extern int ADX_Period;

//+------------------------------------------------------------------+
//| Initialiser les indicateurs pour tous les symboles              |
//+------------------------------------------------------------------+
bool InitializeIndicators(string& symbols[], int symbol_count)
{
   ArrayResize(indicators, symbol_count);

   for(int i = 0; i < symbol_count; i++) {
      indicators[i].symbol = symbols[i];
      indicators[i].enabled = true;
      indicators[i].positions_count = 0;
      indicators[i].last_profit = 0;

      indicators[i].handle_ema_fast = iMA(symbols[i], PERIOD_CURRENT, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_ema_slow = iMA(symbols[i], PERIOD_CURRENT, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_rsi = iRSI(symbols[i], PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
      indicators[i].handle_atr = iATR(symbols[i], PERIOD_CURRENT, ATR_Period);
      indicators[i].handle_adx = iADX(symbols[i], PERIOD_CURRENT, ADX_Period);

      if(indicators[i].handle_ema_fast == INVALID_HANDLE ||
         indicators[i].handle_ema_slow == INVALID_HANDLE ||
         indicators[i].handle_rsi == INVALID_HANDLE ||
         indicators[i].handle_atr == INVALID_HANDLE ||
         indicators[i].handle_adx == INVALID_HANDLE) {
         Log(LOG_ERROR, "Erreur indicateurs pour " + symbols[i]);
         return false;
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//| Initialiser le cache des indicateurs                             |
//+------------------------------------------------------------------+
void InitializeIndicatorCache(int symbol_count)
{
   ArrayResize(indicators_cache, symbol_count);
   for(int i = 0; i < symbol_count; i++) {
      indicators_cache[i].last_update = 0;
   }
}

//+------------------------------------------------------------------+
//| Initialiser le cache ATR history                                 |
//+------------------------------------------------------------------+
void InitializeATRHistory(string& symbols[], int symbol_count)
{
   ArrayResize(atr_history, symbol_count);
   for(int i = 0; i < symbol_count; i++) {
      atr_history[i].symbol = symbols[i];
      atr_history[i].count = 0;
      atr_history[i].last_update = 0;
   }
}

//+------------------------------------------------------------------+
//| ✅ v27.4 OPT: Mettre à jour cache indicateurs                   |
//| Optimisation: Cache 1 seconde pour éviter recalculs            |
//+------------------------------------------------------------------+
void UpdateIndicatorCache(int idx)
{
   // Cache for INDICATOR_CACHE_SECONDS
   if(TimeCurrent() - indicators_cache[idx].last_update < INDICATOR_CACHE_SECONDS) return;

   // Use temporary dynamic arrays for CopyBuffer (avoids static array warnings)
   double temp_ema_fast[], temp_ema_slow[], temp_rsi[], temp_atr[], temp_adx[];

   ArraySetAsSeries(temp_ema_fast, true);
   ArraySetAsSeries(temp_ema_slow, true);
   ArraySetAsSeries(temp_rsi, true);
   ArraySetAsSeries(temp_atr, true);
   ArraySetAsSeries(temp_adx, true);

   // Copy from indicators to temp arrays
   if(CopyBuffer(indicators[idx].handle_ema_fast, 0, 0, 3, temp_ema_fast) != 3) return;
   if(CopyBuffer(indicators[idx].handle_ema_slow, 0, 0, 3, temp_ema_slow) != 3) return;
   if(CopyBuffer(indicators[idx].handle_rsi, 0, 0, 3, temp_rsi) != 3) return;
   if(CopyBuffer(indicators[idx].handle_atr, 0, 0, 2, temp_atr) != 2) return;
   if(CopyBuffer(indicators[idx].handle_adx, 0, 0, 2, temp_adx) != 2) return;

   // Copy from temp arrays to cache (static arrays)
   for(int i = 0; i < 3; i++) {
      indicators_cache[idx].ema_fast[i] = temp_ema_fast[i];
      indicators_cache[idx].ema_slow[i] = temp_ema_slow[i];
      indicators_cache[idx].rsi[i] = temp_rsi[i];
   }
   for(int i = 0; i < 2; i++) {
      indicators_cache[idx].atr[i] = temp_atr[i];
      indicators_cache[idx].adx[i] = temp_adx[i];
   }

   indicators_cache[idx].last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Obtenir l'index d'un symbole dans le tableau d'indicateurs       |
//+------------------------------------------------------------------+
int GetIndicatorIndex(string symbol)
{
   for(int i = 0; i < ArraySize(indicators); i++) {
      if(indicators[i].symbol == symbol) {
         return i;
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| Obtenir la valeur ATR actuelle pour un symbole                   |
//+------------------------------------------------------------------+
double GetATRValue(string symbol)
{
   int idx = GetIndicatorIndex(symbol);
   if(idx < 0) return 0;

   UpdateIndicatorCache(idx);
   return indicators_cache[idx].atr[0];
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Mettre à jour l'historique ATR pour un symbole       |
//| Utilisé pour calculer la volatilité moyenne                     |
//+------------------------------------------------------------------+
void UpdateATRHistory(string symbol, double atr_value)
{
   int idx = -1;
   for(int i = 0; i < ArraySize(atr_history); i++) {
      if(atr_history[i].symbol == symbol) {
         idx = i;
         break;
      }
   }

   if(idx < 0) return;

   // Décaler les valeurs
   for(int i = 19; i > 0; i--) {
      atr_history[idx].atr_values[i] = atr_history[idx].atr_values[i-1];
   }

   // Ajouter la nouvelle valeur
   atr_history[idx].atr_values[0] = atr_value;

   if(atr_history[idx].count < 20) {
      atr_history[idx].count++;
   }

   atr_history[idx].last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Calculer l'ATR moyen sur N périodes                  |
//| Retourne 0 si pas assez de données                              |
//+------------------------------------------------------------------+
double GetAverageATR(string symbol, int periods = 20)
{
   int idx = -1;
   for(int i = 0; i < ArraySize(atr_history); i++) {
      if(atr_history[i].symbol == symbol) {
         idx = i;
         break;
      }
   }

   if(idx < 0 || atr_history[idx].count == 0) return 0;

   int count = MathMin(periods, atr_history[idx].count);
   double sum = 0;

   for(int i = 0; i < count; i++) {
      sum += atr_history[idx].atr_values[i];
   }

   return sum / count;
}

//+------------------------------------------------------------------+
//| Libérer les handles d'indicateurs                                |
//+------------------------------------------------------------------+
void ReleaseIndicators()
{
   for(int i = 0; i < ArraySize(indicators); i++) {
      if(indicators[i].handle_ema_fast != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_ema_fast);
      if(indicators[i].handle_ema_slow != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_ema_slow);
      if(indicators[i].handle_rsi != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_rsi);
      if(indicators[i].handle_atr != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_atr);
      if(indicators[i].handle_adx != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_adx);
   }
}
