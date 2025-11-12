//+------------------------------------------------------------------+
//| Indicators.mqh - Gestion des indicateurs techniques              |
//| Module indicateurs pour EA Multi-Paires Scalping Pro v27.56     |
//|------------------------------------------------------------------|
//| CONTENU:                                                         |
//|   - Initialisation des handles d'indicateurs                    |
//|   - Cache optimisé pour réduire les calculs                    |
//|   - Historique ATR pour volatilité moyenne                      |
//|                                                                  |
//| NOTE: Les structures (SymbolIndicators, CachedIndicators, etc.) |
//|       sont définies dans le fichier principal                   |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property strict

// === CONSTANTES INDICATEURS ===
#define INDICATOR_CACHE_SECONDS 1       // Cache indicator values for N seconds

//+------------------------------------------------------------------+
//| Initialiser les indicateurs pour tous les symboles              |
//| Note: Utilise les variables globales du fichier principal       |
//+------------------------------------------------------------------+
bool InitializeIndicators(string& sym[], int sym_count)
{
   ArrayResize(indicators, sym_count);

   for(int i = 0; i < sym_count; i++) {
      indicators[i].symbol = sym[i];
      indicators[i].enabled = true;
      indicators[i].positions_count = 0;
      indicators[i].last_profit = 0;

      indicators[i].handle_ema_fast = iMA(sym[i], PERIOD_CURRENT, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_ema_slow = iMA(sym[i], PERIOD_CURRENT, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_rsi = iRSI(sym[i], PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
      indicators[i].handle_atr = iATR(sym[i], PERIOD_CURRENT, ATR_Period);
      indicators[i].handle_adx = iADX(sym[i], PERIOD_CURRENT, ADX_Period);

      // ✅ v27.59 PHASE 2: Initialiser indicateurs H1 pour filtre multi-timeframe
      indicators[i].handle_h1_ema_fast = iMA(sym[i], PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      indicators[i].handle_h1_ema_slow = iMA(sym[i], PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);

      if(indicators[i].handle_ema_fast == INVALID_HANDLE ||
         indicators[i].handle_ema_slow == INVALID_HANDLE ||
         indicators[i].handle_rsi == INVALID_HANDLE ||
         indicators[i].handle_atr == INVALID_HANDLE ||
         indicators[i].handle_adx == INVALID_HANDLE ||
         indicators[i].handle_h1_ema_fast == INVALID_HANDLE ||
         indicators[i].handle_h1_ema_slow == INVALID_HANDLE) {
         Log(LOG_ERROR, "Erreur indicateurs pour " + sym[i]);
         return false;
      }
   }

   return true;
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
   // ✅ v27.59 PHASE 2: Ajouter arrays H1
   double temp_h1_ema_fast[], temp_h1_ema_slow[];

   ArraySetAsSeries(temp_ema_fast, true);
   ArraySetAsSeries(temp_ema_slow, true);
   ArraySetAsSeries(temp_rsi, true);
   ArraySetAsSeries(temp_atr, true);
   ArraySetAsSeries(temp_adx, true);
   ArraySetAsSeries(temp_h1_ema_fast, true);
   ArraySetAsSeries(temp_h1_ema_slow, true);

   // Copy from indicators to temp arrays
   if(CopyBuffer(indicators[idx].handle_ema_fast, 0, 0, 3, temp_ema_fast) != 3) return;
   if(CopyBuffer(indicators[idx].handle_ema_slow, 0, 0, 3, temp_ema_slow) != 3) return;
   if(CopyBuffer(indicators[idx].handle_rsi, 0, 0, 3, temp_rsi) != 3) return;
   if(CopyBuffer(indicators[idx].handle_atr, 0, 0, 2, temp_atr) != 2) return;
   if(CopyBuffer(indicators[idx].handle_adx, 0, 0, 2, temp_adx) != 2) return;
   // ✅ v27.59 PHASE 2: Copier données H1
   if(CopyBuffer(indicators[idx].handle_h1_ema_fast, 0, 0, 2, temp_h1_ema_fast) != 2) return;
   if(CopyBuffer(indicators[idx].handle_h1_ema_slow, 0, 0, 2, temp_h1_ema_slow) != 2) return;

   // Copy from temp arrays to cache (static arrays)
   for(int i = 0; i < 3; i++) {
      indicators_cache[idx].ema_fast[i] = temp_ema_fast[i];
      indicators_cache[idx].ema_slow[i] = temp_ema_slow[i];
      indicators_cache[idx].rsi[i] = temp_rsi[i];
   }
   for(int i = 0; i < 2; i++) {
      indicators_cache[idx].atr[i] = temp_atr[i];
      indicators_cache[idx].adx[i] = temp_adx[i];
      // ✅ v27.59 PHASE 2: Copier dans cache H1
      indicators_cache[idx].h1_ema_fast[i] = temp_h1_ema_fast[i];
      indicators_cache[idx].h1_ema_slow[i] = temp_h1_ema_slow[i];
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
      // ✅ v27.59 PHASE 2: Libérer handles H1
      if(indicators[i].handle_h1_ema_fast != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_h1_ema_fast);
      if(indicators[i].handle_h1_ema_slow != INVALID_HANDLE)
         IndicatorRelease(indicators[i].handle_h1_ema_slow);
   }
}
