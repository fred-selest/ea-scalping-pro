# ⚙️ Configurations de Risque - EA Scalping Pro

Fichiers de configuration préconfigurés pour différents profils de risque.

---

## 🆕 NOUVEAUX PROFILS v27.56 (RECOMMANDÉS)

**Optimisés pour les nouvelles fonctionnalités** :
- ✅ Partial Close (TP1/TP2)
- ✅ Filtre Corrélations (évite double exposition)
- ✅ Volatility-Based Sizing (adapte lots à ATR)
- ✅ TP/SL Dynamiques (basés ATR)

| Fichier | Profil | Paires | Risque | Capital Min | Profit/Mois | Drawdown |
|---------|--------|--------|--------|-------------|-------------|----------|
| **EA_Scalping_v27.56_Conservative.set** | 🟢 Conservateur | 3 (EUR/JPY/CAD) | 0.3% | 1000$ | 3-7% | 5-8% |
| **EA_Scalping_v27.56_Balanced.set** | 🟡 Équilibré | 3 (EUR/JPY/AUD) | 0.5% | 2000$ | 8-15% | 8-12% |
| **EA_Scalping_v27.56_Aggressive.set** | 🔴 Agressif | 4 (EUR/GBP/JPY/AUD) | 1.0% | 5000$ | 15-30% | 15-25% |

📖 **Guide complet** : Voir `GUIDE_PROFILS_v27.56.md` pour documentation détaillée

---

## 📋 Anciens Profils (v27.53 et antérieurs)

| Fichier | Profil | Risque | Capital Min | Profit/Mois | Drawdown Max |
|---------|--------|--------|-------------|-------------|--------------|
| `EA_Scalping_Conservative.set` | 🟢 Conservateur | Faible | 1000$ | 3-8% | 5-10% |
| `EA_Scalping_Moderate.set` | 🟡 Modéré | Moyen | 2000$ | 8-15% | 10-15% |
| `EA_Scalping_Aggressive.set` | 🔴 Agressif | Élevé | 5000$ | 15-30% | 20-30% |

---

## 🟢 Configuration CONSERVATRICE

### 📊 Caractéristiques
- **Risque par trade:** 0.3%
- **Paires actives:** 2 (EURUSD, GBPUSD)
- **TP/SL:** 10/20 pips (ratio 1:2)
- **Positions max:** 2 simultanées
- **Trades/jour:** Maximum 15
- **News filter:** Strict (60 min avant, 30 min après)

### 👤 Profil Trader
- ✅ Débutants en trading automatique
- ✅ Comptes < 2000$
- ✅ Aversion au risque élevée
- ✅ Priorité : préservation capital
- ❌ Pas pour croissance rapide

### 📈 Résultats Attendus
```
Capital initial:  1000$
Profit mensuel:   3-8% (30-80$ /mois)
Drawdown max:     5-10% (50-100$)
Win rate requis:  50-60%
```

### ⚙️ Paramètres Clés
```ini
RiskPercent=0.3
MaxLotSize=0.2
MaxDailyLoss=1.5
MaxOpenPositions=2
ScalpTP_Pips=10.0
ScalpSL_Pips=20.0
```

---

## 🟡 Configuration MODÉRÉE

### 📊 Caractéristiques
- **Risque par trade:** 0.5%
- **Paires actives:** 4 (EURUSD, GBPUSD, USDJPY, AUDUSD)
- **TP/SL:** 8/15 pips (ratio ~1:1.9)
- **Positions max:** 5 simultanées (2 par symbole)
- **Trades/jour:** Maximum 50
- **News filter:** Modéré (30 min avant, 15 min après)

### 👤 Profil Trader
- ✅ Traders intermédiaires
- ✅ Comptes 2000$+
- ✅ Balance risque/récompense
- ✅ Expérience trading 6+ mois
- ✅ Surveillance régulière

### 📈 Résultats Attendus
```
Capital initial:  2000$
Profit mensuel:   8-15% (160-300$ /mois)
Drawdown max:     10-15% (200-300$)
Win rate requis:  55-65%
```

### ⚙️ Paramètres Clés
```ini
RiskPercent=0.5
MaxLotSize=1.0
MaxDailyLoss=3.0
MaxOpenPositions=5
ScalpTP_Pips=8.0
ScalpSL_Pips=15.0
```

---

## 🔴 Configuration AGRESSIVE

### 📊 Caractéristiques
- **Risque par trade:** 1.0%
- **Paires actives:** 6 (Toutes)
- **TP/SL:** 6/12 pips (ratio 1:2)
- **Positions max:** 10 simultanées (3 par symbole)
- **Trades/jour:** Maximum 100
- **News filter:** Léger (20 min avant, 10 min après)

### 👤 Profil Trader
- ✅ Traders expérimentés (2+ ans)
- ✅ Comptes 5000$+
- ✅ Tolérance drawdown élevée
- ✅ Surveillance quotidienne
- ✅ VPS recommandé
- ❌ PAS pour débutants

### 📈 Résultats Attendus
```
Capital initial:  5000$
Profit mensuel:   15-30% (750-1500$ /mois)
Drawdown max:     20-30% (1000-1500$)
Win rate requis:  60-70%
```

### ⚙️ Paramètres Clés
```ini
RiskPercent=1.0
MaxLotSize=2.0
MaxDailyLoss=5.0
MaxOpenPositions=10
ScalpTP_Pips=6.0
ScalpSL_Pips=12.0
```

### ⚠️ AVERTISSEMENTS
```
⚠️ Drawdown peut atteindre 30% (normal pour ce profil)
⚠️ Requiert VPS avec latence < 10ms
⚠️ Broker ECN recommandé (spread faible)
⚠️ Tester 3 mois en DEMO obligatoire
⚠️ Stop si drawdown > 25%
```

---

## 📥 Installation

### Méthode 1 : Depuis MT5

**1. Télécharger configuration**
```bash
# Télécharger depuis GitHub
https://github.com/fred-selest/ea-scalping-pro/tree/main/configs
```

**2. Copier fichier .set**
```
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Presets\
```

**3. Charger dans MT5**
```
1. Glisser EA sur graphique
2. Onglet "Paramètres d'entrée"
3. Bouton "Charger" (en bas)
4. Sélectionner fichier .set
5. OK
```

### Méthode 2 : Installation Automatique

**Windows:**
```powershell
# Copier vers dossier presets MT5
Copy-Item "configs\EA_Scalping_*.set" "$env:APPDATA\MetaQuotes\Terminal\[ID]\MQL5\Presets\"
```

**Linux/macOS:**
```bash
# Via Wine
cp configs/EA_Scalping_*.set ~/.wine/drive_c/users/[user]/Application\ Data/MetaQuotes/Terminal/[ID]/MQL5/Presets/
```

---

## 🧪 Test Recommandé

### Avant Compte Réel

**1. Test DEMO obligatoire**
```
Conservateur:  Minimum 1 mois
Modéré:        Minimum 2 mois
Agressif:      Minimum 3 mois
```

**2. Métriques à surveiller**
- ✅ Drawdown max < valeur attendue
- ✅ Profit mensuel dans fourchette
- ✅ Win rate acceptable
- ✅ Pas d'erreurs trading
- ✅ Spread sous MaxSpread_Points

**3. Critères validation**
```
✅ 3 mois consécutifs profit positif
✅ Drawdown < seuil attendu
✅ Comportement EA stable
✅ Pas de bugs/crashes
```

---

## 🔄 Migration entre Configurations

### Conservative → Moderate
**Quand:**
- Capital > 2000$
- 3+ mois profitables en conservateur
- Confortable avec drawdown 10-15%

**Étapes:**
1. Clôturer toutes positions
2. Attendre fin de journée trading
3. Charger nouvelle config
4. Surveiller premières 48h

### Moderate → Aggressive
**Quand:**
- Capital > 5000$
- 6+ mois profitables en modéré
- Expérience gestion drawdown 20%+

**Étapes:**
1. Clôturer toutes positions
2. Pause 24h
3. Charger config agressive
4. Surveillance quotidienne stricte

---

## 📊 Comparaison Détaillée

| Paramètre | Conservateur | Modéré | Agressif |
|-----------|--------------|--------|----------|
| **Risk per Trade** | 0.3% | 0.5% | 1.0% |
| **Max Lot Size** | 0.2 | 1.0 | 2.0 |
| **Max Daily Loss** | 1.5% | 3.0% | 5.0% |
| **Max Trades/Day** | 15 | 50 | 100 |
| **Max Positions** | 2 | 5 | 10 |
| **Positions/Symbol** | 1 | 2 | 3 |
| **Symbols Active** | 2 | 4 | 6 |
| **TP Pips** | 10 | 8 | 6 |
| **SL Pips** | 20 | 15 | 12 |
| **Max Spread** | 15 | 20 | 25 |
| **News Before** | 60 min | 30 min | 20 min |
| **News After** | 30 min | 15 min | 10 min |

---

## 🔧 Personnalisation

### Ajuster une Configuration

**1. Charger fichier .set**
```
MT5 > Glisser EA > Charger preset
```

**2. Modifier paramètres**
```
- Ajuster RiskPercent selon confort
- Activer/désactiver symboles
- Modifier TP/SL selon stratégie
```

**3. Sauvegarder nouvelle config**
```
Bouton "Enregistrer" > Nom personnalisé
```

### Paramètres Souvent Personnalisés

**RiskPercent:**
```ini
; Augmenter progressivement
Conservative: 0.3% → 0.4% → 0.5%
Moderate:     0.5% → 0.7% → 1.0%
Aggressive:   1.0% → 1.5% → 2.0%
```

**Symboles:**
```ini
; Activer uniquement spread < 1.5 pips
Trade_EURUSD=true   ; Spread ~0.5-1.0
Trade_GBPUSD=true   ; Spread ~0.8-1.5
Trade_USDJPY=true   ; Spread ~0.5-1.0
Trade_AUDUSD=false  ; Spread souvent > 1.5
```

**News Filter:**
```ini
; Session Asia (moins volatile)
MinutesBeforeNews=30  ; Réduire
MinutesAfterNews=15   ; Réduire

; Session London/NY (très volatile)
MinutesBeforeNews=60  ; Augmenter
MinutesAfterNews=30   ; Augmenter
```

---

## 📞 Support

### Problèmes Fréquents

**Q: Configuration ne se charge pas**
```
A: Vérifier emplacement fichier .set
   Path correct: Terminal\[ID]\MQL5\Presets\
```

**Q: Paramètres pas appliqués**
```
A: Fermer/réouvrir fenêtre paramètres
   OU retirer et re-attacher EA
```

**Q: Quelle config choisir ?**
```
A: Débutant:     Conservative
   Intermédiaire: Moderate
   Expert:        Aggressive (avec prudence)
```

**Q: Puis-je mixer paramètres ?**
```
A: OUI, mais garder cohérence risque
   Ex: RiskPercent faible + MaxLotSize élevé = incohérent
```

---

## 📚 Resources

- **Documentation complète:** [docs/API.md](../docs/API.md)
- **Troubleshooting:** [docs/TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)
- **Version history:** [CHANGELOG.md](../CHANGELOG.md)
- **GitHub Issues:** https://github.com/fred-selest/ea-scalping-pro/issues

---

**Version:** 1.0
**Dernière mise à jour:** 2025-11-10
**Compatible EA:** v27.52+
