//+------------------------------------------------------------------+
//| Guide Intégration ONNX dans EA MT5                               |
//| Code à ajouter dans EA_MultiPairs_News_Dashboard_v27.mq5        |
//+------------------------------------------------------------------+

/*
============================================
ÉTAPE 1 : Ajouter Variables Globales
============================================
*/

// Après les structures existantes (ligne ~178)
long onnx_handle = INVALID_HANDLE;           // Handle du modèle ONNX
bool onnx_initialized = false;               // État initialisation

// Paramètres de normalisation (depuis scaler_params.json)
double scaler_mean[6] = {1.1, 1.1, 50.0, 0.0005, 2.0, 500.0};  // À ajuster
double scaler_scale[6] = {0.05, 0.05, 15.0, 0.0003, 0.5, 250.0}; // À ajuster

/*
============================================
ÉTAPE 2 : Modifier OnInit()
============================================
*/

// Ajouter après l'initialisation des indicateurs (ligne ~176)

int OnInit()
{
   Print("🚀 EA Multi-Paires Scalping Pro v27.0 - Initialisation...");

   // ... code existant ...

   // ===== NOUVEAU CODE ONNX =====
   if(UseONNX) {
      Log(LOG_INFO, "Chargement du modèle ONNX: " + ModelFileName);

      onnx_handle = OnnxCreateFromFile(ModelFileName, ONNX_DEFAULT);

      if(onnx_handle == INVALID_HANDLE) {
         int error = GetLastError();
         Log(LOG_ERROR, "Échec chargement ONNX - Erreur: " + IntegerToString(error));

         if(error == 5601) {
            Print("⚠️ Fichier ONNX introuvable. Vérifiez :");
            Print("   C:\\Users\\[User]\\AppData\\Roaming\\MetaQuotes\\Terminal\\[ID]\\MQL5\\Files\\", ModelFileName);
         }

         Print("⚠️ ONNX désactivé - EA fonctionnera en mode analyse technique pure");
         UseONNX = false;
         onnx_initialized = false;
      } else {
         // Tester le modèle
         if(TestOnnxModel()) {
            onnx_initialized = true;
            Log(LOG_INFO, "✅ Modèle ONNX chargé et testé avec succès");
            Print("✅ ONNX Runtime activé - Prédictions IA disponibles");
         } else {
            Log(LOG_ERROR, "Échec test modèle ONNX");
            OnnxRelease(onnx_handle);
            onnx_handle = INVALID_HANDLE;
            onnx_initialized = false;
            UseONNX = false;
         }
      }
   } else {
      Log(LOG_INFO, "ONNX désactivé - Mode analyse technique pure");
   }
   // ===== FIN NOUVEAU CODE =====

   // ... reste du code existant ...

   return(INIT_SUCCEEDED);
}

/*
============================================
ÉTAPE 3 : Fonction de Test ONNX
============================================
*/

bool TestOnnxModel()
{
   // Tester avec des données fictives
   float test_inputs[6] = {1.10f, 1.12f, 45.0f, 0.0005f, 1.5f, 600.0f};
   float test_outputs[1];

   if(OnnxRun(onnx_handle, ONNX_NO_CONVERSION, test_inputs, test_outputs)) {
      Log(LOG_DEBUG, "Test ONNX réussi - Output: " + DoubleToString(test_outputs[0], 2));
      return true;
   }

   Log(LOG_ERROR, "Échec test ONNX - GetLastError: " + IntegerToString(GetLastError()));
   return false;
}

/*
============================================
ÉTAPE 4 : Fonction de Normalisation
============================================
*/

void NormalizeFeatures(double &features[], double &normalized[])
{
   // Normalisation : (value - mean) / scale
   int size = ArraySize(features);
   ArrayResize(normalized, size);

   for(int i = 0; i < size && i < 6; i++) {
      normalized[i] = (features[i] - scaler_mean[i]) / scaler_scale[i];
   }
}

/*
============================================
ÉTAPE 5 : Fonction de Prédiction ONNX
============================================
*/

int GetOnnxPrediction(string symbol)
{
   if(!UseONNX || !onnx_initialized || onnx_handle == INVALID_HANDLE) {
      return 0;  // Pas de prédiction
   }

   // Trouver les indicateurs pour ce symbole
   int idx = -1;
   for(int i = 0; i < ArraySize(indicators); i++) {
      if(indicators[i].symbol == symbol) {
         idx = i;
         break;
      }
   }

   if(idx < 0) return 0;

   // Récupérer les valeurs des indicateurs
   double rsi[], ema_fast[], ema_slow[], atr[];

   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(ema_fast, true);
   ArraySetAsSeries(ema_slow, true);
   ArraySetAsSeries(atr, true);

   if(CopyBuffer(indicators[idx].handle_rsi, 0, 0, 1, rsi) <= 0) return 0;
   if(CopyBuffer(indicators[idx].handle_ema_fast, 0, 0, 1, ema_fast) <= 0) return 0;
   if(CopyBuffer(indicators[idx].handle_ema_slow, 0, 0, 1, ema_slow) <= 0) return 0;
   if(CopyBuffer(indicators[idx].handle_atr, 0, 0, 1, atr) <= 0) return 0;

   // Préparer les features
   double features[6];
   features[0] = ema_fast[0];
   features[1] = ema_slow[0];
   features[2] = rsi[0];
   features[3] = atr[0];
   features[4] = SymbolInfoInteger(symbol, SYMBOL_SPREAD);  // Spread
   features[5] = (double)SymbolInfoInteger(symbol, SYMBOL_VOLUME);  // Volume

   // Normaliser
   double normalized[6];
   NormalizeFeatures(features, normalized);

   // Convertir en float (ONNX utilise float32)
   float inputs[6];
   for(int i = 0; i < 6; i++) {
      inputs[i] = (float)normalized[i];
   }

   // Préparer sortie
   float outputs[1];

   // Exécuter le modèle
   if(!OnnxRun(onnx_handle, ONNX_NO_CONVERSION, inputs, outputs)) {
      Log(LOG_ERROR, "Échec OnnxRun pour " + symbol);
      return 0;
   }

   // Interpréter la sortie
   int prediction = (int)MathRound(outputs[0]);  // -1, 0, ou 1

   // Log détaillé (optionnel - niveau DEBUG)
   if(MinLogLevel <= LOG_DEBUG) {
      string signal_name = prediction == 1 ? "BUY" : (prediction == -1 ? "SELL" : "NEUTRAL");
      Log(LOG_DEBUG, "ONNX " + symbol + ": " + signal_name +
          " (EMA_fast=" + DoubleToString(ema_fast[0], 5) +
          " EMA_slow=" + DoubleToString(ema_slow[0], 5) +
          " RSI=" + DoubleToString(rsi[0], 1) + ")");
   }

   return prediction;
}

/*
============================================
ÉTAPE 6 : Modifier GetSignalForSymbol()
============================================
*/

// Remplacer la fonction existante (ligne ~761)
int GetSignalForSymbol(string symbol)
{
   // 1. Essayer prédiction ONNX d'abord
   if(UseONNX && onnx_initialized) {
      int onnx_signal = GetOnnxPrediction(symbol);

      // Si ONNX donne signal clair et confiance suffisante
      if(onnx_signal != 0) {
         Log(LOG_INFO, "🔍 ONNX Signal pour " + symbol + ": " +
             (onnx_signal == 1 ? "BUY" : "SELL"));
         return onnx_signal;
      }

      // Si ONNX retourne NEUTRAL, on continue avec analyse technique
      Log(LOG_DEBUG, "ONNX NEUTRAL pour " + symbol + " - Analyse technique");
   }

   // 2. Fallback sur analyse technique classique (code existant)
   int idx = -1;
   for(int i = 0; i < ArraySize(indicators); i++) {
      if(indicators[i].symbol == symbol) {
         idx = i;
         break;
      }
   }

   if(idx < 0 || !indicators[idx].enabled) return 0;

   // ... reste du code existant (lignes 764-810) ...
}

/*
============================================
ÉTAPE 7 : Modifier OnDeinit()
============================================
*/

// Ajouter avant la fin de OnDeinit() (ligne ~1290)
void OnDeinit(const int reason)
{
   // Libérer les indicateurs
   for(int i = 0; i < ArraySize(indicators); i++) {
      // ... code existant ...
   }

   // ===== NOUVEAU CODE ONNX =====
   // Libérer le modèle ONNX
   if(onnx_handle != INVALID_HANDLE) {
      OnnxRelease(onnx_handle);
      onnx_handle = INVALID_HANDLE;
      Log(LOG_INFO, "Modèle ONNX libéré");
   }
   // ===== FIN NOUVEAU CODE =====

   // ... reste du code existant ...
}

/*
============================================
ÉTAPE 8 : Ajuster Paramètres de Normalisation
============================================

IMPORTANT : Copier les valeurs depuis scaler_params.json
généré par le script Python !

Exemple scaler_params.json :
{
  "mean": [1.1523, 1.1487, 48.32, 0.000523, 1.8, 523.4],
  "scale": [0.0524, 0.0518, 15.23, 0.000324, 0.52, 245.8]
}

Mettre ces valeurs dans :
double scaler_mean[6] = {1.1523, 1.1487, 48.32, 0.000523, 1.8, 523.4};
double scaler_scale[6] = {0.0524, 0.0518, 15.23, 0.000324, 0.52, 245.8};
*/

/*
============================================
STATISTIQUES ET MONITORING
============================================
*/

// Ajouter dans UpdateDashboard() pour afficher stats ONNX
void UpdateDashboard()
{
   // ... code existant ...

   // Ajouter ligne ONNX
   if(UseONNX && onnx_initialized) {
      ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT,
                      "ONNX: ✅ ACTIF");
   } else {
      ObjectSetString(0, "Dash_"+IntegerToString(line++), OBJPROP_TEXT,
                      "ONNX: ⚠️ INACTIF");
   }

   // ... reste du code ...
}

//+------------------------------------------------------------------+
//| FIN DU GUIDE D'INTÉGRATION                                      |
//+------------------------------------------------------------------+

/*
RÉSUMÉ DES MODIFICATIONS :

1. ✅ Variables globales : onnx_handle, scaler_mean, scaler_scale
2. ✅ OnInit() : Charger et tester modèle ONNX
3. ✅ TestOnnxModel() : Vérifier fonctionnement
4. ✅ NormalizeFeatures() : Normalisation des données
5. ✅ GetOnnxPrediction() : Prédiction avec ONNX
6. ✅ GetSignalForSymbol() : Intégrer ONNX avec fallback
7. ✅ OnDeinit() : Libérer ressources ONNX
8. ✅ UpdateDashboard() : Afficher statut ONNX

FICHIERS NÉCESSAIRES :
- scalping_model.onnx (créé avec Python)
- scaler_params.json (pour normalisation)

PLACEMENT :
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Files\

TESTS À FAIRE :
1. Compiler sans erreur
2. Vérifier chargement modèle (Journal MT5)
3. Tester en DÉMO
4. Comparer signaux ONNX vs Analyse Technique
5. Vérifier performance (vitesse)
*/
