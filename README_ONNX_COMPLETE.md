# 🧠 Guide Complet ONNX pour EA MetaTrader 5

## 📋 Réponse à Votre Question

**Question** : Est-ce que https://github.com/onnx/onnx fonctionnerait pour mon EA ?

**Réponse** :
- ✅ **OUI** : Le **format ONNX** fonctionne avec MT5
- ❌ **NON** : Vous n'utilisez **pas directement** cette bibliothèque GitHub
- ✅ **MT5 a déjà un runtime ONNX intégré** !

---

## 🎯 Comment Ça Fonctionne

```
┌──────────────┐      ┌─────────────┐      ┌──────────────┐
│   PYTHON     │      │  FICHIER    │      │    MT5       │
│              │─────▶│   .onnx     │─────▶│   (MQL5)     │
│ Créer Modèle │      │  (format)   │      │ Runtime ONNX │
└──────────────┘      └─────────────┘      └──────────────┘

  scikit-learn         scalping_model        OnnxCreate()
  TensorFlow               .onnx              OnnxRun()
  PyTorch                                     OnnxRelease()
```

---

## 🔄 Workflow Complet (3 Phases)

### **Phase 1 : Créer le Modèle (Python)** 🐍

```python
# 1. Installer bibliothèques
pip install numpy pandas scikit-learn onnx skl2onnx

# 2. Préparer données historiques MT5
# 3. Entraîner modèle Machine Learning
# 4. Convertir en format ONNX
# 5. Tester le modèle

# Voir : create_onnx_model.py (fourni)
```

**Fichiers créés** :
- ✅ `scalping_model.onnx` (modèle)
- ✅ `scaler_params.json` (normalisation)

---

### **Phase 2 : Copier vers MT5** 📁

```bash
# Copier scalping_model.onnx vers :
C:\Users\[VotreNom]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Files\
```

**Chemin complet exemple** :
```
C:\Users\John\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\scalping_model.onnx
```

**Astuce** : Dans MT5, menu `Fichier` → `Ouvrir le dossier de données` → `MQL5\Files\`

---

### **Phase 3 : Intégrer dans EA (MQL5)** 🎯

```mql5
// 1. Déclarer variables globales
long onnx_handle = INVALID_HANDLE;

// 2. Dans OnInit() : Charger modèle
onnx_handle = OnnxCreateFromFile("scalping_model.onnx", ONNX_DEFAULT);

// 3. Préparer données (6 features)
float inputs[6] = {ema_fast, ema_slow, rsi, atr, spread, volume};

// 4. Exécuter prédiction
float outputs[1];
OnnxRun(onnx_handle, ONNX_NO_CONVERSION, inputs, outputs);

// 5. Interpréter résultat
int signal = (int)outputs[0];  // -1=SELL, 0=NEUTRAL, 1=BUY

// 6. Dans OnDeinit() : Libérer
OnnxRelease(onnx_handle);
```

**Voir** : `ONNX_INTEGRATION_GUIDE.mqh` (code complet fourni)

---

## 📊 Comparaison : Bibliothèques vs MT5

| Aspect | github.com/onnx/onnx | MT5 Runtime ONNX |
|--------|----------------------|------------------|
| **Type** | Bibliothèque Python/C++ | Runtime intégré |
| **Usage** | Créer/convertir modèles | Exécuter modèles |
| **Installation** | `pip install onnx` | Aucune (déjà dans MT5) |
| **Langage** | Python, C++ | MQL5 |
| **Fonctions** | Conversion, optimisation | OnnxCreate, OnnxRun |
| **Où ?** | Sur votre PC dev | Dans MT5 |

**Analogie** :
- `github.com/onnx/onnx` = Usine de fabrication de CD
- `MT5 Runtime` = Lecteur CD dans votre voiture

---

## ✅ Ce Dont Vous Avez VRAIMENT Besoin

### **Pour Créer le Modèle** (Python - Sur votre PC)

```bash
# Bibliothèques
pip install numpy pandas scikit-learn onnx skl2onnx

# Ou avec TensorFlow
pip install tensorflow tf2onnx

# Ou avec PyTorch
pip install torch onnxruntime
```

### **Pour Utiliser dans MT5** (MQL5 - Déjà intégré)

```mql5
// Fonctions natives MT5 (pas besoin d'installer quoi que ce soit)
OnnxCreate()        // Créer handle depuis buffer mémoire
OnnxCreateFromFile()  // Charger depuis fichier .onnx
OnnxRun()           // Exécuter inférence
OnnxRelease()       // Libérer ressources
```

**Documentation officielle** :
https://www.mql5.com/en/docs/standardlibrary/onnx

---

## 🚀 Guide Pratique Étape par Étape

### **Étape 1 : Préparer Données d'Entraînement** 📊

```python
# Exporter données depuis MT5
# Features : EMA_Fast, EMA_Slow, RSI, ATR, Spread, Volume
# Labels : -1 (SELL), 0 (NEUTRAL), 1 (BUY)

import pandas as pd

# Charger historique
data = pd.read_csv("mt5_historical_data.csv")

# Features
X = data[['ema_fast', 'ema_slow', 'rsi', 'atr', 'spread', 'volume']]

# Labels (à créer depuis vos règles de trading)
y = data['signal']  # -1, 0, ou 1
```

**Comment obtenir les données ?**
- Exporter depuis MT5 (Ctrl+B → Sélectionner période → Clic droit → Copier)
- Ou utiliser script Python avec `MetaTrader5` package

### **Étape 2 : Entraîner avec scikit-learn** 🧠

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

# Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Normaliser
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Entraîner
model = RandomForestClassifier(n_estimators=100)
model.fit(X_train_scaled, y_train)

# Évaluer
score = model.score(X_test_scaled, y_test)
print(f"Précision : {score:.2%}")
```

### **Étape 3 : Convertir en ONNX** 🔄

```python
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

# Définir input shape
initial_type = [('float_input', FloatTensorType([None, 6]))]

# Convertir
onnx_model = convert_sklearn(model, initial_types=initial_type)

# Sauvegarder
with open("scalping_model.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())

# Sauvegarder aussi les paramètres du scaler
import json
scaler_params = {
    "mean": scaler.mean_.tolist(),
    "scale": scaler.scale_.tolist()
}
with open("scaler_params.json", "w") as f:
    json.dump(scaler_params, f)
```

### **Étape 4 : Copier vers MT5** 📁

```bash
# Ouvrir explorateur Windows
# Aller vers :
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\

# Trouver votre dossier terminal (nom aléatoire)
# Exemple : D0E8209F77C8CF37AD8BF550E51FF075

# Copier dans :
\MQL5\Files\scalping_model.onnx
```

**Vérification** :
```mql5
// Dans MT5, test rapide
bool file_exists = FileIsExist("scalping_model.onnx", FILE_COMMON);
Print("Fichier existe : ", file_exists);
```

### **Étape 5 : Intégrer dans EA** 💻

Voir le fichier `ONNX_INTEGRATION_GUIDE.mqh` pour le code complet.

**Résumé du code** :
```mql5
// OnInit()
onnx_handle = OnnxCreateFromFile("scalping_model.onnx", ONNX_DEFAULT);

// GetSignalForSymbol()
float inputs[6] = {ema_fast, ema_slow, rsi, atr, spread, volume};
// Normaliser inputs avec scaler_mean et scaler_scale
float outputs[1];
OnnxRun(onnx_handle, ONNX_NO_CONVERSION, inputs, outputs);
int signal = (int)outputs[0];

// OnDeinit()
OnnxRelease(onnx_handle);
```

---

## 🧪 Tests et Validation

### **Test 1 : Vérifier Chargement** ✅

```mql5
// Dans OnInit(), après OnnxCreateFromFile()
if(onnx_handle != INVALID_HANDLE) {
    Print("✅ ONNX chargé avec succès");
} else {
    Print("❌ Erreur chargement ONNX : ", GetLastError());
}
```

**Codes d'erreur courants** :
- `5601` : Fichier introuvable
- `5604` : Format ONNX invalide
- `5605` : Version ONNX incompatible

### **Test 2 : Prédiction Simple** 🔍

```mql5
// Test avec données fictives
float test_input[6] = {1.10f, 1.12f, 45.0f, 0.0005f, 2.0f, 500.0f};
float test_output[1];

if(OnnxRun(onnx_handle, ONNX_NO_CONVERSION, test_input, test_output)) {
    Print("✅ Prédiction test : ", test_output[0]);
} else {
    Print("❌ Échec prédiction : ", GetLastError());
}
```

### **Test 3 : Performance** ⚡

```mql5
// Mesurer temps d'exécution
uint start = GetTickCount();

for(int i = 0; i < 1000; i++) {
    OnnxRun(onnx_handle, ONNX_NO_CONVERSION, inputs, outputs);
}

uint duration = GetTickCount() - start;
Print("1000 prédictions en ", duration, " ms (", duration/1000.0, " ms/prédiction)");
```

**Performance attendue** : < 1 ms par prédiction

---

## 📊 Frameworks Supportés

### **scikit-learn** ✅ (Recommandé pour débutants)

```python
from sklearn.ensemble import RandomForestClassifier
from skl2onnx import convert_sklearn

model = RandomForestClassifier()
# ... entraîner ...

onnx_model = convert_sklearn(model, initial_types=...)
```

**Avantages** :
- ✅ Simple à utiliser
- ✅ Conversion ONNX facile
- ✅ Rapide

### **TensorFlow/Keras** ✅ (Deep Learning)

```python
import tensorflow as tf
import tf2onnx

model = tf.keras.Sequential([...])
# ... entraîner ...

onnx_model, _ = tf2onnx.convert.from_keras(model)
```

**Avantages** :
- ✅ Réseaux de neurones puissants
- ✅ Beaucoup de documentation

### **PyTorch** ✅ (Recherche avancée)

```python
import torch

model = MyNeuralNet()
# ... entraîner ...

torch.onnx.export(model, dummy_input, "model.onnx")
```

**Avantages** :
- ✅ Très flexible
- ✅ Populaire en recherche

---

## ⚠️ Points d'Attention

### **1. Normalisation** ⚠️

**CRITIQUE** : MT5 doit normaliser **exactement pareil** que Python !

```python
# Python : Entraînement
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
```

```mql5
// MQL5 : Production (utiliser MÊMES paramètres)
double NormalizeValue(double value, double mean, double scale) {
    return (value - mean) / scale;
}
```

**Sauvegarder les paramètres** :
```json
{
  "mean": [1.1523, 1.1487, 48.32, 0.000523, 1.8, 523.4],
  "scale": [0.0524, 0.0518, 15.23, 0.000324, 0.52, 245.8]
}
```

### **2. Version ONNX** 📌

MT5 supporte **ONNX opset 12+**

```python
# Spécifier version lors conversion
onnx_model = convert_sklearn(
    model,
    initial_types=initial_type,
    target_opset=12  # ← Important
)
```

### **3. Types de Données** 🔢

ONNX utilise **float32**, pas double :

```mql5
float inputs[6];  // ✅ Correct (float32)
// PAS double inputs[6]; ❌
```

### **4. Ordre des Features** 📑

L'ordre DOIT être **identique** entre Python et MQL5 :

```
Position 0 : EMA_Fast
Position 1 : EMA_Slow
Position 2 : RSI
Position 3 : ATR
Position 4 : Spread
Position 5 : Volume
```

### **5. Gestion Mémoire** 💾

Toujours libérer les ressources :

```mql5
void OnDeinit(const int reason) {
    if(onnx_handle != INVALID_HANDLE) {
        OnnxRelease(onnx_handle);
        onnx_handle = INVALID_HANDLE;
    }
}
```

---

## 🎯 Exemple Complet de Workflow

### **1. Export Données MT5** (Script Python)

```python
import MetaTrader5 as mt5
import pandas as pd

mt5.initialize()
rates = mt5.copy_rates_from_pos("EURUSD", mt5.TIMEFRAME_M5, 0, 10000)
df = pd.DataFrame(rates)
df.to_csv("mt5_data.csv")
```

### **2. Créer Features** (Python)

```python
import ta  # Technical Analysis library

df['ema_fast'] = ta.trend.ema_indicator(df['close'], window=8)
df['ema_slow'] = ta.trend.ema_indicator(df['close'], window=21)
df['rsi'] = ta.momentum.rsi(df['close'], window=9)
df['atr'] = ta.volatility.average_true_range(df['high'], df['low'], df['close'])
```

### **3. Créer Labels** (Logique de trading)

```python
# Exemple : Label basé sur performance future
df['future_return'] = df['close'].shift(-10) / df['close'] - 1

# BUY si gain > 0.1%, SELL si perte > 0.1%, sinon NEUTRAL
df['signal'] = 0
df.loc[df['future_return'] > 0.001, 'signal'] = 1   # BUY
df.loc[df['future_return'] < -0.001, 'signal'] = -1  # SELL
```

### **4. Entraîner et Exporter** (Python)

```python
# Utiliser create_onnx_model.py fourni
python create_onnx_model.py
```

### **5. Intégrer dans EA** (MQL5)

```mql5
// Utiliser ONNX_INTEGRATION_GUIDE.mqh fourni
#include "ONNX_INTEGRATION_GUIDE.mqh"
```

### **6. Tester** (MT5 Demo)

```
1. Compiler EA
2. Attacher sur graphique EURUSD M5
3. Vérifier Journal : "✅ ONNX chargé"
4. Observer signaux : "🔍 ONNX Signal: BUY"
5. Comparer performance avec/sans ONNX
```

---

## 📈 Performance Attendue

| Métrique | Sans ONNX | Avec ONNX (bien entraîné) |
|----------|-----------|---------------------------|
| **Précision signaux** | ~60-65% | ~70-80% |
| **Vitesse** | < 1 ms | < 2 ms |
| **Faux positifs** | Modéré | Réduit |
| **Adaptabilité** | Fixe | Peut réapprendre |

**Important** : ONNX n'est pas magique ! La qualité dépend de :
- ✅ Qualité des données d'entraînement
- ✅ Choix des features
- ✅ Hyperparamètres du modèle
- ✅ Validation rigoureuse

---

## 🔧 Dépannage

### **Erreur : "Fichier ONNX introuvable"**

```
❌ GetLastError() = 5601
```

**Solutions** :
1. Vérifier emplacement fichier
2. Vérifier nom exact (sensible à la casse)
3. Utiliser `FILE_COMMON` si dans dossier partagé

```mql5
onnx_handle = OnnxCreateFromFile("scalping_model.onnx", FILE_COMMON);
```

### **Erreur : "Format ONNX invalide"**

```
❌ GetLastError() = 5604
```

**Solutions** :
1. Vérifier version ONNX (opset 12+)
2. Recompiler modèle avec `target_opset=12`
3. Tester modèle avec onnxruntime en Python

### **Erreur : "Prédiction incohérente"**

```
Sortie toujours identique ou valeurs bizarres
```

**Solutions** :
1. Vérifier normalisation (mean/scale corrects)
2. Vérifier ordre des features
3. Vérifier types (float32)
4. Tester modèle en Python d'abord

---

## 📚 Ressources

### **Documentation Officielle**
- **MT5 ONNX** : https://www.mql5.com/en/docs/standardlibrary/onnx
- **ONNX Format** : https://onnx.ai/
- **scikit-learn to ONNX** : https://onnx.ai/sklearn-onnx/

### **Tutoriels**
- **ONNX ML in MT5** : https://www.mql5.com/en/articles/8268
- **Creating Trading Robot with ML** : https://www.mql5.com/en/articles/10028

### **Outils**
- **Netron** (Visualiser modèles ONNX) : https://netron.app/
- **ONNX Runtime** : https://onnxruntime.ai/

---

## ✅ Checklist Complète

- [ ] Python installé (3.8+)
- [ ] Bibliothèques installées (`scikit-learn`, `onnx`, `skl2onnx`)
- [ ] Données historiques MT5 exportées
- [ ] Features calculées (EMA, RSI, ATR, etc.)
- [ ] Labels créés (BUY/SELL/NEUTRAL)
- [ ] Modèle entraîné et testé (précision > 65%)
- [ ] Modèle converti en ONNX
- [ ] Paramètres scaler sauvegardés (`scaler_params.json`)
- [ ] Fichier `.onnx` copié dans `MQL5\Files\`
- [ ] Code ONNX intégré dans EA
- [ ] EA compilé sans erreur
- [ ] Test chargement ONNX réussi
- [ ] Test prédiction simple réussi
- [ ] Test en compte DÉMO
- [ ] Performance mesurée et validée

---

## 🎉 Conclusion

**Réponse finale** à votre question :

✅ **OUI**, ONNX fonctionne avec MT5, mais :
1. Vous créez le modèle avec **Python** (scikit-learn, TensorFlow, PyTorch)
2. Vous le convertissez au **format ONNX** (.onnx)
3. MT5 l'exécute avec son **runtime ONNX intégré**

**Vous n'avez PAS besoin** de `github.com/onnx/onnx` dans MT5 directement.

**Vous AVEZ besoin** de :
- ✅ Python + bibliothèques ML
- ✅ Conversion vers format .onnx
- ✅ Fonctions natives MT5 (OnnxCreate, OnnxRun)

**Fichiers fournis** :
- ✅ `create_onnx_model.py` - Script Python complet
- ✅ `ONNX_INTEGRATION_GUIDE.mqh` - Code MQL5 complet
- ✅ `README_ONNX_COMPLETE.md` - Ce guide

---

**Prêt à implémenter ONNX dans votre EA !** 🚀

Pour toute question, consultez la documentation MT5 ONNX officielle.

**BON TRADING AVEC IA !** 🧠📈
