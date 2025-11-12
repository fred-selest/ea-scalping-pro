//+------------------------------------------------------------------+
//| PositionManager.mqh - Gestion des positions ouvertes             |
//| Module positions pour EA Multi-Paires Scalping Pro v27.56       |
//|------------------------------------------------------------------|
//| CONTENU:                                                         |
//|   - Trailing stop et break-even automatiques                    |
//|   - Clôture partielle des positions (TP1/TP2)                   |
//|   - Throttling des modifications SL                             |
//|   - Tracking des positions partiellement fermées                |
//+------------------------------------------------------------------+
#property copyright "fred-selest"
#property link      "https://github.com/fred-selest/ea-scalping-pro"
#property strict

#include "Utils.mqh"

// === CONSTANTES POSITION MANAGEMENT ===
#define MIN_SL_MODIFICATION_INTERVAL_SEC 5    // Délai minimum entre 2 modifications (5 secondes)
#define MIN_SL_CHANGE_POINTS 5                 // Changement minimum pour modifier (5 points)

// === STRUCTURES POSITIONS ===

// Structure pour throttling des modifications SL
struct LastModification {
   ulong ticket;
   datetime last_time;
   double last_sl;
};

// ✅ v27.56: Partial Close - Tracker positions partiellement fermées
struct PartiallyClosedPosition {
   ulong ticket;
   double initial_volume;      // Volume initial
   double remaining_volume;    // Volume restant
   double tp1_level;          // Niveau TP1
   double tp2_level;          // Niveau TP2
   bool tp1_reached;          // TP1 atteint ?
   bool sl_moved_to_be;       // SL déplacé à BE ?
   datetime tp1_time;         // Heure atteinte TP1
};

// === VARIABLES GLOBALES (déclarées dans le fichier principal) ===
extern LastModification last_modifications[];
extern int last_mod_count;
extern PartiallyClosedPosition partially_closed[];
extern int partial_close_count;
extern int total_partial_closes;
extern double total_partial_profit;

// Paramètres (définis dans le fichier principal)
extern bool UsePartialClose;
extern double PartialClosePercent;
extern bool MoveSLToBreakEvenAfterTP1;
extern double TrailingStop_Pips;
extern double BreakEven_Pips;
extern int MagicNumber;

//+------------------------------------------------------------------+
//| ✅ FIX: Throttling - Vérifier si modification SL autorisée      |
//| Évite erreur 4756 (modifications trop fréquentes)              |
//+------------------------------------------------------------------+
bool CanModifySL(ulong ticket, double new_sl, double point)
{
   datetime now = TimeCurrent();

   // Chercher si on a déjà modifié ce ticket récemment
   for(int i = 0; i < last_mod_count; i++) {
      if(last_modifications[i].ticket == ticket) {
         // Vérifier le délai minimum
         if((now - last_modifications[i].last_time) < MIN_SL_MODIFICATION_INTERVAL_SEC) {
            Log(LOG_DEBUG, "⏸️ Throttling: Ticket #" + IntegerToString(ticket) +
                " - Dernière modif il y a " + IntegerToString(now - last_modifications[i].last_time) + "s");
            return false;
         }

         // Vérifier le changement minimum
         double sl_change_points = MathAbs(new_sl - last_modifications[i].last_sl) / point;
         if(sl_change_points < MIN_SL_CHANGE_POINTS) {
            Log(LOG_DEBUG, "⏸️ Throttling: Ticket #" + IntegerToString(ticket) +
                " - Changement trop petit (" + DoubleToString(sl_change_points, 1) + " pts < " +
                IntegerToString(MIN_SL_CHANGE_POINTS) + " pts)");
            return false;
         }

         return true;
      }
   }

   // Premier enregistrement pour ce ticket
   return true;
}

//+------------------------------------------------------------------+
//| ✅ FIX: Enregistrer modification SL                             |
//+------------------------------------------------------------------+
void RecordSLModification(ulong ticket, double new_sl)
{
   datetime now = TimeCurrent();
   bool found = false;

   // Mettre à jour si existe
   for(int i = 0; i < last_mod_count; i++) {
      if(last_modifications[i].ticket == ticket) {
         last_modifications[i].last_time = now;
         last_modifications[i].last_sl = new_sl;
         found = true;
         break;
      }
   }

   // Ajouter nouveau si n'existe pas
   if(!found) {
      ArrayResize(last_modifications, last_mod_count + 1);
      last_modifications[last_mod_count].ticket = ticket;
      last_modifications[last_mod_count].last_time = now;
      last_modifications[last_mod_count].last_sl = new_sl;
      last_mod_count++;
   }

   // Nettoyer les vieux enregistrements (> 1 heure)
   if(last_mod_count > 50) {
      int cleaned = 0;
      for(int i = last_mod_count - 1; i >= 0; i--) {
         if((now - last_modifications[i].last_time) > 3600) {
            // Supprimer cet élément
            for(int j = i; j < last_mod_count - 1; j++) {
               last_modifications[j] = last_modifications[j + 1];
            }
            last_mod_count--;
            cleaned++;
         }
      }
      if(cleaned > 0) {
         ArrayResize(last_modifications, last_mod_count);
         Log(LOG_DEBUG, "🧹 Nettoyage throttling: " + IntegerToString(cleaned) + " entrées supprimées");
      }
   }
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Fermer partiellement une position                    |
//+------------------------------------------------------------------+
bool PartialClosePosition(ulong ticket, double close_percent)
{
   if(!PositionSelectByTicket(ticket)) {
      Log(LOG_ERROR, "Partial Close: Position #" + IntegerToString(ticket) + " non trouvée");
      return false;
   }

   string symbol = PositionGetString(POSITION_SYMBOL);
   double current_volume = PositionGetDouble(POSITION_VOLUME);
   double volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double min_volume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);

   // Calculer volume à fermer
   double close_volume = current_volume * (close_percent / 100.0);

   // Arrondir au lot step
   close_volume = MathFloor(close_volume / volume_step) * volume_step;
   close_volume = NormalizeDouble(close_volume, 2);

   // Vérifier qu'on a assez de volume
   double remaining_volume = current_volume - close_volume;

   if(close_volume < min_volume) {
      Log(LOG_WARN, "Partial Close: Volume trop petit (" + DoubleToString(close_volume, 2) + ")");
      return false;
   }

   if(remaining_volume < min_volume) {
      Log(LOG_WARN, "Partial Close: Volume restant trop petit, fermeture totale");
      close_volume = current_volume;  // Fermer tout
   }

   // Préparer requête de fermeture partielle
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);

   request.action = TRADE_ACTION_DEAL;
   request.position = ticket;
   request.symbol = symbol;
   request.volume = close_volume;
   request.deviation = 3;
   request.magic = MagicNumber;
   request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   request.price = (request.type == ORDER_TYPE_SELL) ? SymbolInfoDouble(symbol, SYMBOL_BID) : SymbolInfoDouble(symbol, SYMBOL_ASK);
   request.type_filling = ORDER_FILLING_IOC;

   if(!OrderSend(request, result)) {
      int err = GetLastError();
      Log(LOG_ERROR, "Partial Close FAILED: Ticket #" + IntegerToString(ticket) +
          " | Volume: " + DoubleToString(close_volume, 2) +
          " | Error: " + IntegerToString(err));
      return false;
   }

   if(result.retcode == TRADE_RETCODE_DONE) {
      // Calculer profit de la partie fermée
      double close_price = result.price;
      double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
      int position_type = (int)PositionGetInteger(POSITION_TYPE);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

      double profit_pips = 0;
      if(position_type == POSITION_TYPE_BUY) {
         profit_pips = (close_price - open_price) / point / PIPS_TO_POINTS_MULTIPLIER;
      } else {
         profit_pips = (open_price - close_price) / point / PIPS_TO_POINTS_MULTIPLIER;
      }

      total_partial_closes++;

      Log(LOG_INFO, "✅ Partial Close: " + symbol + " #" + IntegerToString(ticket) +
          " | Fermé: " + DoubleToString(close_volume, 2) + "/" + DoubleToString(current_volume, 2) +
          " lots (" + DoubleToString(close_percent, 0) + "%) " +
          " | Profit: " + DoubleToString(profit_pips, 1) + " pips" +
          " | Restant: " + DoubleToString(remaining_volume, 2) + " lots");

      return true;
   } else {
      Log(LOG_ERROR, "Partial Close REJECTED: Retcode " + IntegerToString(result.retcode));
      return false;
   }
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Trouver position dans tableau partial close          |
//+------------------------------------------------------------------+
int FindPartialPosition(ulong ticket)
{
   for(int i = 0; i < partial_close_count; i++) {
      if(partially_closed[i].ticket == ticket) {
         return i;
      }
   }
   return -1;
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Ajouter position au tracker partial close            |
//+------------------------------------------------------------------+
void AddPartialPosition(ulong ticket, double initial_volume, double tp1_level, double tp2_level)
{
   int idx = FindPartialPosition(ticket);

   if(idx >= 0) {
      // Déjà existante, mettre à jour
      partially_closed[idx].remaining_volume = initial_volume;
      return;
   }

   // Ajouter nouvelle entrée
   ArrayResize(partially_closed, partial_close_count + 1);

   partially_closed[partial_close_count].ticket = ticket;
   partially_closed[partial_close_count].initial_volume = initial_volume;
   partially_closed[partial_close_count].remaining_volume = initial_volume;
   partially_closed[partial_close_count].tp1_level = tp1_level;
   partially_closed[partial_close_count].tp2_level = tp2_level;
   partially_closed[partial_close_count].tp1_reached = false;
   partially_closed[partial_close_count].sl_moved_to_be = false;
   partially_closed[partial_close_count].tp1_time = 0;

   partial_close_count++;
}

//+------------------------------------------------------------------+
//| ✅ v27.56: Supprimer position du tracker                        |
//+------------------------------------------------------------------+
void RemovePartialPosition(ulong ticket)
{
   int idx = FindPartialPosition(ticket);
   if(idx < 0) return;

   // Décaler les éléments
   for(int i = idx; i < partial_close_count - 1; i++) {
      partially_closed[i] = partially_closed[i + 1];
   }

   partial_close_count--;
   ArrayResize(partially_closed, partial_close_count);
}

//+------------------------------------------------------------------+
//| Nettoyer les positions fermées du tracker                        |
//+------------------------------------------------------------------+
void CleanupClosedPositions()
{
   for(int i = partial_close_count - 1; i >= 0; i--) {
      ulong ticket = partially_closed[i].ticket;

      // Vérifier si la position existe toujours
      if(!PositionSelectByTicket(ticket)) {
         // Position fermée, la supprimer du tracker
         RemovePartialPosition(ticket);
      }
   }
}
