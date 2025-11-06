"""
Guide Complet : Créer un Modèle ONNX pour EA MetaTrader 5
==========================================================

Ce guide montre comment créer un modèle ONNX compatible MT5
pour prédire les signaux de trading (BUY/SELL/NEUTRAL).
"""

# ============================================
# ÉTAPE 1 : Installation des bibliothèques
# ============================================

"""
pip install numpy pandas scikit-learn onnx skl2onnx tensorflow

Ou pour PyTorch :
pip install torch onnxruntime
"""

# ============================================
# ÉTAPE 2 : Préparer les Données
# ============================================

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

# Exemple : Données d'entraînement
# Features : [EMA_Fast, EMA_Slow, RSI, ATR, Spread, Volume]
# Labels : -1 (SELL), 0 (NEUTRAL), 1 (BUY)

# Simuler des données (remplacer par vos vraies données MT5)
np.random.seed(42)
n_samples = 10000

# Générer features
ema_fast = np.random.uniform(1.0, 1.2, n_samples)
ema_slow = np.random.uniform(1.0, 1.2, n_samples)
rsi = np.random.uniform(20, 80, n_samples)
atr = np.random.uniform(0.0001, 0.0010, n_samples)
spread = np.random.uniform(1, 3, n_samples)
volume = np.random.uniform(100, 1000, n_samples)

X = np.column_stack([ema_fast, ema_slow, rsi, atr, spread, volume])

# Générer labels (simplifié - remplacer par logique réelle)
y = np.zeros(n_samples)
# BUY si EMA_Fast > EMA_Slow et RSI < 40
y[(ema_fast > ema_slow) & (rsi < 40)] = 1
# SELL si EMA_Fast < EMA_Slow et RSI > 60
y[(ema_fast < ema_slow) & (rsi > 60)] = -1

print(f"📊 Dataset créé : {n_samples} échantillons")
print(f"   Features : {X.shape[1]}")
print(f"   Distribution labels : BUY={np.sum(y==1)}, SELL={np.sum(y==-1)}, NEUTRAL={np.sum(y==0)}")

# ============================================
# ÉTAPE 3 : Entraîner le Modèle
# ============================================

# Split train/test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Normalisation (IMPORTANT pour performance)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Entraîner modèle
print("🧠 Entraînement du modèle...")
model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    random_state=42
)
model.fit(X_train_scaled, y_train)

# Évaluation
train_score = model.score(X_train_scaled, y_train)
test_score = model.score(X_test_scaled, y_test)

print(f"✅ Modèle entraîné")
print(f"   Précision train : {train_score:.2%}")
print(f"   Précision test  : {test_score:.2%}")

# ============================================
# ÉTAPE 4 : Convertir en ONNX
# ============================================

print("🔄 Conversion en format ONNX...")

# Définir le type d'entrée (6 features float32)
initial_type = [('float_input', FloatTensorType([None, 6]))]

# Convertir
onnx_model = convert_sklearn(
    model,
    initial_types=initial_type,
    target_opset=12  # Version ONNX (MT5 supporte 12+)
)

# Sauvegarder
output_path = "scalping_model.onnx"
with open(output_path, "wb") as f:
    f.write(onnx_model.SerializeToString())

print(f"✅ Modèle ONNX sauvegardé : {output_path}")
print(f"   Taille : {len(onnx_model.SerializeToString())/1024:.2f} KB")

# ============================================
# ÉTAPE 5 : Tester le Modèle ONNX
# ============================================

import onnxruntime as ort

print("\n🧪 Test du modèle ONNX...")

# Charger modèle
session = ort.InferenceSession(output_path)

# Tester prédiction
test_input = X_test_scaled[:5]  # 5 premiers échantillons
predictions = session.run(None, {'float_input': test_input.astype(np.float32)})[0]

print("Prédictions test :")
for i, pred in enumerate(predictions[:5]):
    actual = y_test.iloc[i] if isinstance(y_test, pd.Series) else y_test[i]
    signal = "BUY" if pred == 1 else "SELL" if pred == -1 else "NEUTRAL"
    print(f"   Échantillon {i+1}: {signal} (réel: {actual})")

# ============================================
# ÉTAPE 6 : Sauvegarder aussi le Scaler
# ============================================

# Important : MT5 doit normaliser les données de la même façon !
# Sauvegarder les paramètres du scaler

import json

scaler_params = {
    "mean": scaler.mean_.tolist(),
    "scale": scaler.scale_.tolist(),
    "n_features": X.shape[1]
}

with open("scaler_params.json", "w") as f:
    json.dump(scaler_params, f, indent=2)

print(f"\n✅ Paramètres scaler sauvegardés : scaler_params.json")

# ============================================
# ÉTAPE 7 : Informations pour MT5
# ============================================

print("\n" + "="*60)
print("📋 INFORMATIONS POUR INTÉGRATION MT5")
print("="*60)
print(f"1. Copier {output_path} vers :")
print(f"   C:\\Users\\[User]\\AppData\\Roaming\\MetaQuotes\\Terminal\\[ID]\\MQL5\\Files\\")
print()
print("2. Features attendues (dans cet ordre) :")
print("   [0] EMA_Fast")
print("   [1] EMA_Slow")
print("   [2] RSI")
print("   [3] ATR")
print("   [4] Spread")
print("   [5] Volume")
print()
print("3. Normalisation (utiliser scaler_params.json) :")
print(f"   Mean  : {scaler.mean_}")
print(f"   Scale : {scaler.scale_}")
print()
print("4. Sortie du modèle :")
print("   -1 = SELL, 0 = NEUTRAL, 1 = BUY")
print()
print("5. Précision attendue :")
print(f"   ~{test_score:.1%} sur données de test")
print("="*60)

# ============================================
# BONUS : Version TensorFlow/Keras
# ============================================

"""
Alternative avec TensorFlow/Keras :

import tensorflow as tf
from tensorflow import keras

# Créer modèle
model = keras.Sequential([
    keras.layers.Dense(64, activation='relu', input_shape=(6,)),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(32, activation='relu'),
    keras.layers.Dense(3, activation='softmax')  # 3 classes
])

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Entraîner
model.fit(X_train_scaled, y_train + 1, epochs=50, validation_split=0.2)

# Convertir en ONNX
import tf2onnx

onnx_model, _ = tf2onnx.convert.from_keras(
    model,
    input_signature=[tf.TensorSpec(shape=[None, 6], dtype=tf.float32)]
)

with open("scalping_model_keras.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())
"""

# ============================================
# BONUS : Version PyTorch
# ============================================

"""
Alternative avec PyTorch :

import torch
import torch.nn as nn

class ScalpingModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(6, 64)
        self.fc2 = nn.Linear(64, 32)
        self.fc3 = nn.Linear(32, 3)
        self.dropout = nn.Dropout(0.2)

    def forward(self, x):
        x = torch.relu(self.fc1(x))
        x = self.dropout(x)
        x = torch.relu(self.fc2(x))
        x = self.fc3(x)
        return x

model = ScalpingModel()

# Entraîner (code d'entraînement ici)

# Convertir en ONNX
dummy_input = torch.randn(1, 6)
torch.onnx.export(
    model,
    dummy_input,
    "scalping_model_pytorch.onnx",
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={'input': {0: 'batch_size'}}
)
"""

print("\n✅ Script terminé ! Fichiers créés :")
print("   - scalping_model.onnx")
print("   - scaler_params.json")
print("\nPrêt pour intégration dans MT5 !")
