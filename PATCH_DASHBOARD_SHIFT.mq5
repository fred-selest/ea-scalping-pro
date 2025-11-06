//+------------------------------------------------------------------+
//| PATCH : Décalage Automatique du Graphique pour Dashboard        |
//| À appliquer dans EA_MultiPairs_News_Dashboard_v27.mq5           |
//+------------------------------------------------------------------+

/*
OBJECTIF :
Décaler automatiquement le graphique vers la droite
pour laisser le dashboard visible en haut à gauche
sans superposition.

MODIFICATIONS NÉCESSAIRES : 4 étapes simples
*/

// ============================================
// ÉTAPE 1 : Ajouter Constantes (ligne ~46)
// ============================================

// Après les constantes existantes, AJOUTER :
#define DASHBOARD_WIDTH 380                 // Largeur dashboard + marge
#define CHART_SHIFT_PERCENT 15              // Pourcentage de décalage graphique


// ============================================
// ÉTAPE 2 : Ajouter Paramètre Input (ligne ~104)
// ============================================

// Dans la section DASHBOARD SETTINGS, AJOUTER après Dashboard_BG :
input bool     AutoShiftChart = true;       // Décaler graphique auto pour dashboard


// ============================================
// ÉTAPE 3 : Ajouter Fonction (ligne ~1042, après CreateDashboard)
// ============================================

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

   // Appliquer décalage de 15% pour faire de la place au dashboard
   ChartSetInteger(0, CHART_SHIFT_SIZE, CHART_SHIFT_PERCENT);
   ChartSetInteger(0, CHART_SHIFT, true);

   // Forcer actualisation
   ChartRedraw(0);

   Log(LOG_INFO, "✅ Graphique décalé de " + IntegerToString(CHART_SHIFT_PERCENT) + "% pour dashboard");
}


// ============================================
// ÉTAPE 4 : Appeler dans OnInit() (ligne ~300)
// ============================================

// Dans OnInit(), MODIFIER la section dashboard :

// AVANT :
/*
if(ShowDashboard) {
   CreateDashboard();
   Sleep(100);
   UpdateDashboard();
}
*/

// APRÈS :
if(ShowDashboard) {
   CreateDashboard();

   // ===== AJOUTER CES 2 LIGNES =====
   Sleep(100);
   ShiftChartForDashboard();  // ← Décaler graphique
   // ================================

   UpdateDashboard();
}


// ============================================
// ÉTAPE 5 : Restaurer dans OnDeinit() (ligne ~1290)
// ============================================

// À la fin de OnDeinit(), AVANT le dernier Print, AJOUTER :

void OnDeinit(const int reason)
{
   // ... code existant libération indicateurs ...

   // ... code existant suppression dashboard ...

   // ===== AJOUTER CETTE SECTION =====
   // Restaurer décalage graphique par défaut
   if(AutoShiftChart && ShowDashboard) {
      ChartSetInteger(0, CHART_SHIFT_SIZE, 10);  // Valeur par défaut MT5
      ChartSetInteger(0, CHART_SHIFT, true);
      ChartRedraw(0);
      Log(LOG_INFO, "Décalage graphique restauré");
   }
   // =================================

   Comment("");

   Print("✅ EA Multi-Paires arrêté | Stats: ", trades_today, " trades | P&L: ",
         DoubleToString(daily_profit, 2));
}


//+------------------------------------------------------------------+
// RÉSUMÉ DES MODIFICATIONS
//+------------------------------------------------------------------+

/*
FICHIER : EA_MultiPairs_News_Dashboard_v27.mq5

MODIFICATIONS :
1. Ligne ~46  : Ajouter 2 constantes (#define)
2. Ligne ~104 : Ajouter 1 paramètre (input bool AutoShiftChart)
3. Ligne ~1042: Ajouter fonction ShiftChartForDashboard()
4. Ligne ~300 : Appeler ShiftChartForDashboard() dans OnInit()
5. Ligne ~1290: Restaurer décalage dans OnDeinit()

TOTAL LIGNES AJOUTÉES : ~30 lignes

RÉSULTAT :
✅ Dashboard visible en haut à gauche
✅ Graphique automatiquement décalé vers la droite
✅ Plus de superposition !
✅ Paramètre pour activer/désactiver (AutoShiftChart)

UTILISATION :
- AutoShiftChart = true  : Graphique décalé (recommandé)
- AutoShiftChart = false : Position normale (dashboard superposé)
*/

//+------------------------------------------------------------------+
// TEST RAPIDE
//+------------------------------------------------------------------+

/*
Après avoir appliqué le patch :

1. Compiler l'EA (F7)
2. Attacher sur graphique
3. Vérifier Journal MT5 :
   "✅ Graphique décalé de 15% pour dashboard"
4. Observer : Le graphique devrait être décalé vers la droite
5. Dashboard visible en haut à gauche sans cacher les bougies

Si le décalage est trop important ou trop faible :
- Modifier CHART_SHIFT_PERCENT (ligne ~47)
- Tester : 10, 15, 20, 25...
*/

//+------------------------------------------------------------------+
// FIN DU PATCH
//+------------------------------------------------------------------+
