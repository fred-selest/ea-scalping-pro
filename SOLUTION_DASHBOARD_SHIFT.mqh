//+------------------------------------------------------------------+
//| Solutions pour Décaler le Graphique MT5                         |
//| Éviter superposition Dashboard sur le graphique                 |
//+------------------------------------------------------------------+

/*
PROBLÈME :
Le dashboard se superpose au graphique, rendant la lecture difficile.

SOLUTIONS :
1. Décalage automatique du graphique (RECOMMANDÉ)
2. Réserver marge à gauche du graphique
3. Repositionner dashboard à droite

Ce fichier contient les 3 solutions avec code complet.
*/

//+------------------------------------------------------------------+
// SOLUTION 1 : DÉCALAGE AUTOMATIQUE DU GRAPHIQUE (RECOMMANDÉ)
//+------------------------------------------------------------------+

/*
Cette solution décale automatiquement tout le graphique vers la droite
pour laisser de l'espace au dashboard à gauche.

AVANTAGES :
✅ Le plus naturel visuellement
✅ Dashboard toujours visible
✅ Graphique décalé automatiquement
✅ Fonctionne avec toutes les timeframes
*/

// ===== MODIFICATIONS À APPORTER =====

// 1. Ajouter ce paramètre dans les DASHBOARD SETTINGS (après ligne 104)
input bool     AutoShiftChart = true;      // Décaler graphique auto pour dashboard

// 2. Ajouter ces constantes après les constantes existantes (après ligne 46)
#define DASHBOARD_WIDTH 380                 // Largeur dashboard + marge
#define CHART_SHIFT_PERCENT 15              // Pourcentage de décalage (15% = largeur dashboard)

// 3. Ajouter cette fonction après CreateDashboard() (ligne 1042)

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

   // Calculer décalage en pourcentage
   // Dashboard fait ~380px, on décale le graphique de 15%
   int shift_percent = CHART_SHIFT_PERCENT;

   // Appliquer le décalage
   ChartSetInteger(0, CHART_SHIFT_SIZE, shift_percent);

   // Alternative : Décaler la vue des barres
   ChartSetInteger(0, CHART_SHIFT, true);

   // Forcer actualisation
   ChartRedraw(0);

   Log(LOG_DEBUG, "Graphique décalé de " + IntegerToString(shift_percent) + "% pour dashboard");
}

// 4. Appeler cette fonction dans OnInit() après CreateDashboard()

int OnInit()
{
   // ... code existant ...

   if(ShowDashboard) {
      CreateDashboard();
      Sleep(100);
      UpdateDashboard();

      // ===== AJOUTER CETTE LIGNE =====
      ShiftChartForDashboard();
      // ===============================
   }

   // ... reste du code ...
}

// 5. Restaurer le graphique dans OnDeinit()

void OnDeinit(const int reason)
{
   // ... code existant ...

   // ===== AJOUTER CETTE SECTION AVANT LA FIN =====
   // Restaurer décalage graphique par défaut
   if(AutoShiftChart) {
      ChartSetInteger(0, CHART_SHIFT_SIZE, 10);  // Valeur par défaut MT5
      ChartRedraw(0);
   }
   // ===============================================

   // ... reste du code ...
}


//+------------------------------------------------------------------+
// SOLUTION 2 : RÉSERVER MARGE À GAUCHE (Alternative)
//+------------------------------------------------------------------+

/*
Cette solution crée une marge invisible à gauche du graphique
en utilisant un objet graphique rectangle transparent.

AVANTAGES :
✅ Plus précis visuellement
✅ Pas de décalage des barres
✅ Dashboard dans zone "vide"
*/

// Ajouter cette fonction après CreateDashboard()

//+------------------------------------------------------------------+
//| Créer marge à gauche pour dashboard                             |
//+------------------------------------------------------------------+
void CreateChartMarginForDashboard()
{
   if(!ShowDashboard) return;

   // Supprimer ancienne marge si existe
   ObjectDelete(0, "Chart_Margin_Left");

   // Créer rectangle transparent qui force la marge
   ObjectCreate(0, "Chart_Margin_Left", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_XDISTANCE, 0);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_YDISTANCE, 0);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_XSIZE, DASHBOARD_WIDTH);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_YSIZE, 600);  // Hauteur
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_BGCOLOR, clrNONE);  // Transparent
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_BACK, false);  // Au premier plan
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, "Chart_Margin_Left", OBJPROP_HIDDEN, true);

   Log(LOG_DEBUG, "Marge gauche créée pour dashboard");
}

// Appeler dans OnInit() après CreateDashboard()
// CreateChartMarginForDashboard();


//+------------------------------------------------------------------+
// SOLUTION 3 : REPOSITIONNER DASHBOARD À DROITE (Simplest)
//+------------------------------------------------------------------+

/*
Solution la plus simple : déplacer le dashboard vers la droite
pour qu'il ne cache pas les bougies principales.

AVANTAGES :
✅ Aucune modification du graphique
✅ Très simple
✅ Dashboard reste visible

INCONVÉNIENT :
⚠️ Dashboard peut cacher partie droite du graphique
*/

// Modifier les paramètres dans les inputs (ligne 101-102)
// Changez :
// input int      Dashboard_X = 20;            // Position X
// Par :
// input int      Dashboard_X = 800;           // Position X (vers la droite)

// Ou pour positionner en haut à droite automatiquement :

//+------------------------------------------------------------------+
//| Positionner dashboard automatiquement à droite                  |
//+------------------------------------------------------------------+
void PositionDashboardRight()
{
   if(!ShowDashboard) return;

   // Obtenir largeur graphique
   long chart_width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

   if(chart_width <= 0) return;

   // Positionner dashboard à 20px du bord droit
   int dashboard_width = 360;
   int right_margin = 20;
   int x_position = (int)chart_width - dashboard_width - right_margin;

   // Mettre à jour position de tous les objets
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_XDISTANCE, x_position);
   ObjectSetInteger(0, "Dashboard_Title", OBJPROP_XDISTANCE, x_position + 20);

   // Mettre à jour les labels
   for(int i = 0; i < 14; i++) {
      string objName = "Dash_" + IntegerToString(i);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x_position + 15);
   }

   ChartRedraw(0);

   Log(LOG_DEBUG, "Dashboard repositionné à droite (x=" + IntegerToString(x_position) + ")");
}

// Appeler dans OnInit() après CreateDashboard()
// PositionDashboardRight();


//+------------------------------------------------------------------+
// SOLUTION 4 : COMBINAISON (Le Plus Flexible)
//+------------------------------------------------------------------+

/*
Combine décalage graphique + positionnement intelligent du dashboard.
Détecte automatiquement la meilleure configuration.
*/

// Ajouter ce paramètre
input ENUM_DASHBOARD_POSITION DashboardPosition = DASHBOARD_LEFT_SHIFT;  // Position dashboard

// Définir l'enum avant les inputs
enum ENUM_DASHBOARD_POSITION {
   DASHBOARD_LEFT_OVERLAY,    // Gauche (superposé)
   DASHBOARD_LEFT_SHIFT,      // Gauche (graphique décalé)
   DASHBOARD_RIGHT,           // Droite
   DASHBOARD_FLOATING         // Flottant (transparent)
};

//+------------------------------------------------------------------+
//| Configuration automatique du dashboard selon position           |
//+------------------------------------------------------------------+
void ConfigureDashboardPosition()
{
   if(!ShowDashboard) return;

   switch(DashboardPosition) {
      case DASHBOARD_LEFT_OVERLAY:
         // Position normale, rien à faire
         Log(LOG_INFO, "Dashboard: Position gauche (superposé)");
         break;

      case DASHBOARD_LEFT_SHIFT:
         // Décaler le graphique
         ShiftChartForDashboard();
         Log(LOG_INFO, "Dashboard: Position gauche avec décalage graphique");
         break;

      case DASHBOARD_RIGHT:
         // Repositionner à droite
         PositionDashboardRight();
         Log(LOG_INFO, "Dashboard: Position droite");
         break;

      case DASHBOARD_FLOATING:
         // Rendre fond semi-transparent
         ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BGCOLOR, C'0,0,0,128');  // Noir semi-transparent
         ObjectSetInteger(0, "Dashboard_BG", OBJPROP_BACK, false);
         Log(LOG_INFO, "Dashboard: Mode flottant transparent");
         break;
   }

   ChartRedraw(0);
}

// Appeler dans OnInit()
// ConfigureDashboardPosition();


//+------------------------------------------------------------------+
// BONUS : DASHBOARD REDIMENSIONNABLE
//+------------------------------------------------------------------+

/*
Permet à l'utilisateur de redimensionner et déplacer le dashboard
en temps réel via la souris.
*/

//+------------------------------------------------------------------+
//| Rendre dashboard déplaçable                                      |
//+------------------------------------------------------------------+
void MakeDashboardMovable()
{
   // Rendre le fond sélectionnable et déplaçable
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_SELECTED, false);
   ObjectSetInteger(0, "Dashboard_BG", OBJPROP_HIDDEN, false);

   Log(LOG_INFO, "Dashboard déplaçable activé (cliquez-glissez le fond)");
}

// Fonction pour détecter si dashboard a été déplacé
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_DRAG && sparam == "Dashboard_BG") {
      // Dashboard a été déplacé
      int new_x = (int)ObjectGetInteger(0, "Dashboard_BG", OBJPROP_XDISTANCE);
      int new_y = (int)ObjectGetInteger(0, "Dashboard_BG", OBJPROP_YDISTANCE);

      // Mettre à jour position des autres objets
      ObjectSetInteger(0, "Dashboard_Title", OBJPROP_XDISTANCE, new_x + 20);
      ObjectSetInteger(0, "Dashboard_Title", OBJPROP_YDISTANCE, new_y + 10);

      int yPos = new_y + 40;
      for(int i = 0; i < 14; i++) {
         string objName = "Dash_" + IntegerToString(i);
         ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, new_x + 15);
         ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, yPos + (i * 18));
      }

      ChartRedraw(0);
      Log(LOG_DEBUG, "Dashboard déplacé vers (" + IntegerToString(new_x) + ", " + IntegerToString(new_y) + ")");
   }
}


//+------------------------------------------------------------------+
// RÉCAPITULATIF DES SOLUTIONS
//+------------------------------------------------------------------+

/*
┌─────────────────────────────────────────────────────────────────┐
│ SOLUTION          │ COMPLEXITÉ │ RÉSULTAT                       │
├─────────────────────────────────────────────────────────────────┤
│ 1. Décalage auto  │ ⭐⭐       │ Graphique décalé, dashboard OK │
│ 2. Marge réservée │ ⭐⭐⭐     │ Zone vide à gauche             │
│ 3. Dashboard →    │ ⭐         │ Dashboard à droite             │
│ 4. Combinaison    │ ⭐⭐⭐     │ Flexible, configurable         │
│ BONUS: Movable    │ ⭐⭐       │ Déplaçable à la souris         │
└─────────────────────────────────────────────────────────────────┘

RECOMMANDATION :
Pour votre cas (dashboard en haut à gauche, graphique décalé),
utilisez la SOLUTION 1 : Décalage automatique

C'est le plus simple et le plus naturel visuellement.

IMPLÉMENTATION RAPIDE (5 minutes) :
1. Ajouter paramètre AutoShiftChart
2. Ajouter constantes DASHBOARD_WIDTH et CHART_SHIFT_PERCENT
3. Copier fonction ShiftChartForDashboard()
4. Appeler dans OnInit() après CreateDashboard()
5. Restaurer dans OnDeinit()

CODE MINIMAL À AJOUTER : ~30 lignes
RÉSULTAT : Dashboard visible, graphique décalé automatiquement
*/

//+------------------------------------------------------------------+
// FIN DES SOLUTIONS
//+------------------------------------------------------------------+
