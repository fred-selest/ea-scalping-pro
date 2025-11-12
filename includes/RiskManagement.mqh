//+------------------------------------------------------------------+
//| RiskManagement.mqh - Gestion du risque et du capital             |
//| Module risk management pour EA Multi-Paires Scalping Pro v27.56 |
//|------------------------------------------------------------------|
//| CONTENU:                                                         |
//|   - Calcul de taille de position (lot sizing)                   |
//|   - Position sizing basé sur volatilité (ATR)                   |
//|   - Filtre de corrélation entre paires                          |
//|   - Limites journalières (pertes, trades)                       |
//|   - Comptage de positions                                       |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property strict

#include "Utils.mqh"
#include "Indicators.mqh"

// === CONSTANTES RISK MANAGEMENT ===
#define MIN_TP_PIPS_LIMIT 1.0           // Minimum realistic Take Profit in pips
#define MIN_SL_PIPS_LIMIT 2.0           // Minimum realistic Stop Loss in pips

// === STRUCTURES RISQUE ===

// Structure pour les paires corrélées
struct CorrelationPair {
   string symbol1;
   string symbol2;
   double correlation;  // -1 à 1 (négatif = inverse, positif = direct)
};

// === VARIABLES GLOBALES (déclarées dans le fichier principal) ===
extern CorrelationPair correlations[];
extern int trades_today;
extern double daily_profit;
extern datetime current_day;
extern datetime last_daily_check;

// Paramètres de risque (définis dans le fichier principal)
extern double RiskPercent;
extern double MaxLotSize;
extern double MaxDailyLoss;
extern int MaxTradesPerDay;
extern int MaxOpenPositions;
extern int MaxPositionsPerSymbol;
extern bool UseCorrelationFilter;
extern double MaxCorrelation;
extern bool UseVolatilityBasedSizing;
extern double MaxVolatilityMultiplier;
extern bool UseDynamicTPSL;
extern double ATR_SL_Multiplier;
extern double ScalpSL_Pips;
extern int MagicNumber;

//+------------------------------------------------------------------+
//| ✅ v27.54: Support TP/SL dynamiques pour calcul risque           |
//| ✅ v27.56: Position sizing basé sur volatilité (ATR)             |
//+------------------------------------------------------------------+
double CalculateLotSize(string symbol)
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double base_risk_percent = RiskPercent;

   // ✅ v27.56: Ajuster risque selon volatilité
   if(UseVolatilityBasedSizing) {
      // Calculer ratio de volatilité (ATR actuel vs moyenne)
      double current_atr = 0;
      double average_atr = GetAverageATR(symbol, 20);

      // Obtenir l'index du symbole
      int idx = GetIndicatorIndex(symbol);

      if(idx >= 0 && average_atr > 0) {
         UpdateIndicatorCache(idx);
         current_atr = indicators_cache[idx].atr[0];
         double volatility_ratio = current_atr / average_atr;

         // Ajuster risque inversement à la volatilité
         // Volatilité haute (ratio > 1) → risque réduit
         // Volatilité basse (ratio < 1) → risque augmenté
         double adjusted_risk = RiskPercent / volatility_ratio;

         // Limiter l'ajustement selon MaxVolatilityMultiplier
         adjusted_risk = MathMin(adjusted_risk, RiskPercent * MaxVolatilityMultiplier);
         adjusted_risk = MathMax(adjusted_risk, RiskPercent / MaxVolatilityMultiplier);

         Log(LOG_DEBUG, symbol + " - Volatility sizing: ATR=" + DoubleToString(current_atr/SymbolInfoDouble(symbol, SYMBOL_POINT), 1) +
             " | AvgATR=" + DoubleToString(average_atr/SymbolInfoDouble(symbol, SYMBOL_POINT), 1) +
             " | Ratio=" + DoubleToString(volatility_ratio, 2) +
             " | Risk: " + DoubleToString(RiskPercent, 2) + "% → " + DoubleToString(adjusted_risk, 2) + "%");

         base_risk_percent = adjusted_risk;
      }
   }

   double risk_amount = balance * base_risk_percent / 100.0;

   double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

   // ✅ v27.54: Calculer SL effectif (dynamique ou fixe)
   double effective_sl_pips = ScalpSL_Pips;

   if(UseDynamicTPSL) {
      int idx = GetIndicatorIndex(symbol);

      if(idx >= 0) {
         UpdateIndicatorCache(idx);
         double atr_points = indicators_cache[idx].atr[0] / point;
         effective_sl_pips = (atr_points / PIPS_TO_POINTS_MULTIPLIER) * ATR_SL_Multiplier;
         effective_sl_pips = MathMax(effective_sl_pips, MIN_SL_PIPS_LIMIT);
      }
   }

   double pip_value = tick_value / tick_size * point * PIPS_TO_POINTS_MULTIPLIER;
   double lot_size = risk_amount / (effective_sl_pips * pip_value);

   lot_size = MathFloor(lot_size / lot_step) * lot_step;
   lot_size = MathMax(min_lot, MathMin(lot_size, MaxLotSize));
   lot_size = MathMin(lot_size, max_lot);

   return NormalizeDouble(lot_size, 2);
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Vérifier si position corrélée existe                 |
//| Évite double exposition sur paires corrélées                    |
//+------------------------------------------------------------------+
bool HasCorrelatedPosition(string symbol)
{
   if(!UseCorrelationFilter) return false;

   for(int i = 0; i < ArraySize(correlations); i++) {
      // Vérifier si le symbole est dans cette paire de corrélation
      bool is_symbol1 = (correlations[i].symbol1 == symbol);
      bool is_symbol2 = (correlations[i].symbol2 == symbol);

      if(!is_symbol1 && !is_symbol2) continue;

      // Vérifier si corrélation dépasse le seuil
      if(MathAbs(correlations[i].correlation) > MaxCorrelation) {
         // Identifier le symbole corrélé
         string correlated_symbol = is_symbol1 ? correlations[i].symbol2 : correlations[i].symbol1;

         // Vérifier si une position existe sur le symbole corrélé
         int positions = GetSymbolPositions(correlated_symbol);

         if(positions > 0) {
            Log(LOG_DEBUG, "🔗 " + symbol + " bloqué - Position corrélée sur " + correlated_symbol +
                " (corr=" + DoubleToString(correlations[i].correlation, 2) + ")");
            return true;
         }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
//| Vérifier reset journalier                                        |
//+------------------------------------------------------------------+
void CheckDailyReset()
{
   datetime now = TimeCurrent();

   // ✅ v27.4 FIX: Vérifier seulement toutes les 5 minutes
   if(now - last_daily_check < 300) return;
   last_daily_check = now;

   // Utiliser MqlDateTime pour comparaison précise
   MqlDateTime dt_current, dt_day;
   TimeToStruct(current_day, dt_day);
   TimeToStruct(now, dt_current);

   // Comparer année, mois, jour
   if(dt_current.year != dt_day.year ||
      dt_current.mon != dt_day.mon ||
      dt_current.day != dt_day.day) {

      Log(LOG_INFO, "═══════════════════════════════════════════════");
      Log(LOG_INFO, "📅 NOUVEAU JOUR - Reset compteurs");
      Log(LOG_INFO, "   Trades aujourd'hui: " + IntegerToString(trades_today) +
          " | P&L: " + DoubleToString(daily_profit, 2));

      trades_today = 0;
      daily_profit = 0;
      current_day = TimeCurrent();

      Log(LOG_INFO, "   Nouveau jour: " + TimeToString(current_day, TIME_DATE));
   }
}

//+------------------------------------------------------------------+
//| ✅ REFACTOR: Helper function to count positions (DRY principle) |
//| Avoids code duplication between GetTotalPositions and GetSymbolPositions |
//+------------------------------------------------------------------+
int CountPositions(string symbol_filter = "", int max_count = 0)
{
   int count = 0;
   int total = PositionsTotal();

   // If max_count not specified, use a very high number
   if(max_count == 0) max_count = 999999;

   for(int i = total - 1; i >= 0; i--) {
      // Early exit optimization
      if(count >= max_count) break;

      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;

      // Check magic number
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;

      // If symbol filter specified, check it
      if(symbol_filter != "" && PositionGetString(POSITION_SYMBOL) != symbol_filter) continue;

      count++;
   }

   return count;
}

//+------------------------------------------------------------------+
//| ✅ v27.4 OPT: Compter positions totales avec sortie anticipée  |
//| ✅ REFACTOR: Uses CountPositions helper (no duplication)       |
//+------------------------------------------------------------------+
int GetTotalPositions()
{
   return CountPositions("", MaxOpenPositions);
}

//+------------------------------------------------------------------+
//| ✅ v27.4 OPT: Compter positions symbole avec sortie anticipée  |
//| ✅ REFACTOR: Uses CountPositions helper (no duplication)       |
//+------------------------------------------------------------------+
int GetSymbolPositions(string symbol)
{
   return CountPositions(symbol, MaxPositionsPerSymbol);
}

//+------------------------------------------------------------------+
//| Vérifier si on peut trader (toutes les conditions)               |
//+------------------------------------------------------------------+
bool CanTrade(string symbol)
{
   // Vérifier spread
   long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   extern int MaxSpread_Points;
   if(spread > MaxSpread_Points) return false;

   // Vérifier session
   extern bool Trade_Asian, Trade_London, Trade_NewYork;
   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   int hour = time.hour;

   bool in_session = false;
   if(Trade_Asian && hour >= 0 && hour < 9) in_session = true;
   if(Trade_London && hour >= 8 && hour < 17) in_session = true;
   if(Trade_NewYork && hour >= 14 && hour < 23) in_session = true;

   if(!in_session) return false;

   // Vérifier news (fonction externe dans NewsFilter.mqh)
   extern bool IsNewsTime(string);
   if(IsNewsTime(symbol)) return false;

   // ✅ v27.4: Vérifier reset journalier
   CheckDailyReset();

   // Vérifier limites journalières
   if(trades_today >= MaxTradesPerDay) return false;

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(daily_profit < -(balance * MaxDailyLoss / 100)) return false;

   // Vérifier limites de positions
   if(GetTotalPositions() >= MaxOpenPositions) return false;
   if(GetSymbolPositions(symbol) >= MaxPositionsPerSymbol) return false;

   // ✅ v27.56: Vérifier corrélations
   if(HasCorrelatedPosition(symbol)) return false;

   return true;
}

//+------------------------------------------------------------------+
//| Mettre à jour les statistiques après un trade                    |
//+------------------------------------------------------------------+
void UpdateTradeStatistics(double profit)
{
   trades_today++;
   daily_profit += profit;
}

//+------------------------------------------------------------------+
//| Obtenir les statistiques de risque actuelles                     |
//+------------------------------------------------------------------+
string GetRiskStatistics()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double daily_loss_pct = (daily_profit / balance) * 100.0;
   double daily_limit_pct = -MaxDailyLoss;

   string stats = StringFormat(
      "Risk Stats:\n" +
      "  Trades today: %d/%d\n" +
      "  Daily P&L: %.2f (%.2f%%)\n" +
      "  Daily limit: %.2f%%\n" +
      "  Open positions: %d/%d",
      trades_today, MaxTradesPerDay,
      daily_profit, daily_loss_pct,
      daily_limit_pct,
      GetTotalPositions(), MaxOpenPositions
   );

   return stats;
}
