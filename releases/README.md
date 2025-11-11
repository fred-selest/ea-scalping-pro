# 📦 Releases - EA Scalping Pro

Archives officielles de toutes les versions de l'EA.

---

## 🆕 Version Actuelle

### **v27.56** - 2025-11-11 🎯 PARTIAL CLOSE

**Nouveautés** :
- ✅ **Partial Close** (fermeture partielle TP1/TP2)
- ✅ Move SL to Break-Even après TP1
- ✅ Multi-TP strategy optimisée
- ✅ 3 profils de configuration optimisés

**Archives disponibles** :
- 📦 `v27.56/EA_Scalping_Pro_v27.56_MQ5_Only.zip` (23 KB) - EA seul
- 📦 `v27.56/EA_Scalping_Pro_v27.56_With_Configs.zip` (39 KB) - EA + Configs ⭐
- 📦 `v27.56/EA_Scalping_Pro_v27.56_Complete_Package.zip` (72 KB) - Package complet

📖 **Documentation** : Voir `v27.56/README.md` pour détails

---

## 📚 Historique des Versions

### **v27.55** - 2025-11-11 - Smart Risk Management
- ✅ Filtre corrélations paires
- ✅ Position sizing basé volatilité (ATR)
- ✅ Réduction drawdown (-15 à -25%)
- ✅ Amélioration Sharpe Ratio (+20 à +30%)

### **v27.54** - 2025-11-11 - AI-Enhanced Trading
- ✅ Filtre ADX (force de tendance)
- ✅ TP/SL dynamiques basés ATR
- ✅ Système retry automatique (ordres)
- ✅ Circuit breaker API news

### **v27.53 et antérieurs**
- Versions stables antérieures
- Archives dans `/versions/`

---

## 🚀 Installation Rapide

### **Choix de l'Archive**

1. **Débutants** → `v27.56/EA_Scalping_Pro_v27.56_With_Configs.zip`
   - Profils préconfigurés
   - Guide complet inclus
   - Démarrage rapide

2. **Expérimentés** → `v27.56/EA_Scalping_Pro_v27.56_Complete_Package.zip`
   - Documentation technique
   - Tous les changelogs
   - Compréhension approfondie

3. **Mise à jour** → `v27.56/EA_Scalping_Pro_v27.56_MQ5_Only.zip`
   - Fichier EA seul
   - Configuration manuelle

### **Installation**

```
1. Télécharger archive depuis releases/v27.56/
2. Extraire fichiers
3. Copier EA_MultiPairs_Scalping_Pro.mq5 → MQL5/Experts/
4. Copier configs/*.set → MQL5/Presets/ (si applicable)
5. Compiler dans MetaEditor (F7)
6. Charger profil désiré
7. Tester 30 jours DÉMO
```

---

## 📖 Documentation

Chaque version contient sa propre documentation :

- `vX.XX/README.md` - Guide de la version
- `CHANGELOG_vX.XX.md` - Détails des changements
- `configs/GUIDE_PROFILS_vX.XX.md` - Guide profils (v27.56+)

---

## 🔄 Migration

### **Depuis v27.55 → v27.56**
- Magic Number changé : 270550 → 270560
- Nouveaux paramètres partial close
- Fermer positions v27.55 avant upgrade

### **Depuis v27.54 et antérieurs**
- Utiliser profils .set recommandés
- Lire tous changelogs (v27.54, v27.55, v27.56)
- Configuration nombreux nouveaux paramètres

---

**Repository** : https://github.com/fred-selest/ea-scalping-pro
**Auteur** : fred-selest
