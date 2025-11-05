# 🚀 GUIDE INSTALLATION - fred-selest/ea-scalping-pro

## ✅ VOTRE CONFIGURATION

**Repository GitHub :** https://github.com/fred-selest/ea-scalping-pro

**URLs configurées dans l'EA :**
- Code source : `https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/EA_MultiPairs_News_Dashboard_v27.mq5`
- Version : `https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/VERSION.txt`

---

## 📤 ÉTAPE 1 : UPLOADER LES FICHIERS SUR GITHUB (5 minutes)

### Télécharger les fichiers

Tous les fichiers sont disponibles via les liens `computer://` que je vous ai donnés.

**Fichiers à télécharger :**

1. ✅ **EA_MultiPairs_News_Dashboard_v27.mq5** (le code de l'EA)
2. ✅ **VERSION.txt** (contient juste "27.2")
3. ✅ **README_GITHUB.md** (à renommer en README.md)
4. ✅ **CHANGELOG.md**
5. ⭐ **GUIDE_AUTO_UPDATE.md**
6. ⭐ **GUIDE_DASHBOARD_v27.2.md**
7. ⭐ **GUIDE_RAPIDE_MULTIPAIRES.md**
8. ⭐ **PARAMETRES_OPTIMISES_FXPRO.md**
9. ⭐ **Deploy-EA-VPS.ps1**
10. ⭐ Tous les autres guides .md

### Uploader sur GitHub

**1. Aller sur votre repo**
```
https://github.com/fred-selest/ea-scalping-pro
```

**2. Cliquer sur "Add file" → "Upload files"**

**3. Glisser-déposer tous les fichiers téléchargés**

Ou cliquer "choose your files" et les sélectionner

**4. En bas de la page, écrire :**
```
Initial release v27.2
```

**5. Cliquer "Commit changes" (bouton vert)**

⏱️ **Temps : 2-3 minutes**

---

## ✅ ÉTAPE 2 : VÉRIFIER QUE ÇA FONCTIONNE

### Test 1 : VERSION.txt

**Ouvrir dans navigateur :**
```
https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/VERSION.txt
```

**Vous devriez voir :**
```
27.2
```

✅ **Si vous voyez "27.2" → Parfait !**

❌ **Si erreur 404 → Le fichier n'est pas encore uploadé**

---

### Test 2 : Code EA

**Ouvrir dans navigateur :**
```
https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/EA_MultiPairs_News_Dashboard_v27.mq5
```

**Vous devriez voir le code source complet de l'EA**

✅ **Si le code s'affiche → Excellent !**

---

## ⚙️ ÉTAPE 3 : CONFIGURER MT5 (3 minutes)

### 1. Autoriser GitHub dans WebRequest

```
MT5 → Outils → Options → Expert Advisors
Onglet "Expert Advisors"
Section "WebRequest"

Cliquer sur "Ajouter"
Entrer : https://raw.githubusercontent.com
Cliquer OK
```

**URLs à avoir (total 4) :**
```
✅ https://nfs.faireconomy.media
✅ https://cdn-nfs.faireconomy.media
✅ https://www.forexfactory.com
✅ https://raw.githubusercontent.com
```

**Cliquer OK → Redémarrer MT5**

---

### 2. Installer l'EA pré-configuré

**L'EA que je viens de créer a VOS URLs déjà configurées !**

**Télécharger :**
- `EA_MultiPairs_News_Dashboard_v27.mq5` (version avec vos URLs)

**Copier dans MT5 :**
```
1. Ouvrir explorateur : 
   C:\Users\[VotreNom]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Experts\

2. Coller : EA_MultiPairs_News_Dashboard_v27.mq5

3. Ouvrir MetaEditor (F4 dans MT5)

4. Compiler (F7)

5. Vérifier : 0 error, 0 warning
```

---

### 3. Activer l'EA sur graphique

**1. Glisser l'EA sur graphique M5 EUR/USD**

**2. Onglet "Paramètres d'entrée"**

Vérifier que vous voyez :
```
=== AUTO-UPDATE ===
EnableAutoUpdate = false          ← Laisser false pour l'instant
UpdateURL = https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/...
CheckUpdateEveryHours = 24
```

✅ **L'URL doit contenir "fred-selest" !**

**3. Configurer le reste selon votre niveau :**

**DÉBUTANT :**
```
=== TRADING SYMBOLS ===
Trade_EURUSD = true
Trade_GBPUSD = false
Trade_USDJPY = false

=== RISK MANAGEMENT ===
RiskPercent = 0.25
MaxOpenPositions = 1

=== NEWS FILTER ===
UseNewsFilter = true
MinutesBeforeNews = 60
```

**4. Cliquer OK**

---

## 🔍 ÉTAPE 4 : VÉRIFIER LES LOGS

**Dans MT5, onglet "Journal" (Ctrl+T) :**

**Vous devriez voir :**
```
✅ EA initialisé avec succès
📊 Symboles actifs: 1
   EURUSD
```

**Si EnableAutoUpdate était sur true, vous verriez aussi :**
```
🔄 Vérification des mises à jour...
✅ Vous utilisez la dernière version (v27.2)
```

---

## 🔄 ÉTAPE 5 : ACTIVER AUTO-UPDATE (Optionnel)

**Une fois que tout fonctionne en démo :**

**1. Clic droit sur l'EA dans le graphique**

**2. "Propriétés EA"**

**3. Onglet "Paramètres d'entrée"**

**4. Changer :**
```
EnableAutoUpdate = false  →  true
```

**5. OK**

**6. Regarder les logs :**
```
🔄 Vérification des mises à jour...
✅ Vous utilisez la dernière version (v27.2)
```

✅ **Si vous voyez ça → Auto-update fonctionne !**

---

## 🧪 TESTER UNE MISE À JOUR

Pour vérifier que l'auto-update fonctionne vraiment :

**Sur GitHub :**

1. Aller sur votre repo : https://github.com/fred-selest/ea-scalping-pro
2. Cliquer sur `VERSION.txt`
3. Cliquer sur l'icône "✏️" (Edit)
4. Changer `27.2` en `27.3`
5. Commit changes

**Dans MT5 :**

6. Redémarrer l'EA (ou attendre 24h)
7. Regarder les logs

**Vous devriez voir :**
```
🔄 Vérification des mises à jour...
✨ Mise à jour disponible : v27.3 (actuelle : v27.2)
📥 Téléchargement automatique dans 5 secondes...
📥 Téléchargement de la version 27.3...
✅ Mise à jour téléchargée : EA_MultiPairs_UPDATE_v27.3.mq5
📄 Instructions créées : UPDATE_INSTRUCTIONS.txt
```

**8. Remettre VERSION.txt à `27.2` après le test**

---

## 📊 DASHBOARD

Le dashboard devrait s'afficher automatiquement :

```
╔════════════════════════════════════╗
║  EA SCALPING MULTI-PAIRES v27     ║
╠════════════════════════════════════╣
║ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━    ║
║   COMPTE                           ║
║ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━    ║
║ Balance : XXXX.XX EUR              ║
║ Equity  : XXXX.XX EUR ▲ X.X%       ║
║                                    ║
║ [... reste du dashboard ...]       ║
╚════════════════════════════════════╝
```

---

## 🎯 CHECKLIST FINALE

### Installation de base
- [ ] Fichiers uploadés sur GitHub
- [ ] VERSION.txt accessible (test URL)
- [ ] EA.mq5 accessible (test URL)
- [ ] EA copié dans MQL5\Experts\
- [ ] EA compilé sans erreur (F7)
- [ ] WebRequest GitHub autorisé

### Configuration MT5
- [ ] EA glissé sur graphique M5
- [ ] UpdateURL contient "fred-selest"
- [ ] Dashboard visible
- [ ] Logs propres (pas d'erreur)

### Auto-Update (optionnel)
- [ ] EnableAutoUpdate = true
- [ ] Logs montrent "version (v27.2)"
- [ ] Test mise à jour réussi

---

## 🆘 SI PROBLÈME

### Erreur : "URL non autorisée"
```
Solution :
MT5 → Outils → Options → Expert Advisors → WebRequest
Ajouter : https://raw.githubusercontent.com
```

### Erreur : VERSION.txt 404
```
Solution :
Le fichier n'est pas sur GitHub
→ Uploader VERSION.txt avec contenu "27.2"
```

### EA ne trouve pas la mise à jour
```
Vérifications :
1. EnableAutoUpdate = true ?
2. URL dans paramètres contient "fred-selest" ?
3. GitHub WebRequest autorisé ?
4. VERSION.txt accessible dans navigateur ?
```

### Dashboard ne s'affiche pas
```
Solution :
1. ShowDashboard = true
2. Changer timeframe (M1 → M5 → H1)
3. Redémarrer MT5
```

---

## 📞 PROCHAINES ÉTAPES

### Phase 1 : Test (1 mois)
```
1. Laisser tourner en DÉMO
2. Observer dashboard quotidiennement
3. Analyser performances
4. Noter problèmes éventuels
```

### Phase 2 : Optimisation
```
1. Ajuster paramètres selon résultats
2. Ajouter paires si OK
3. Augmenter RiskPercent prudemment
```

### Phase 3 : Production
```
1. Si démo positive (Win Rate >55%, Drawdown <15%)
2. Passer en RÉEL avec micro-lots (0.01)
3. Augmenter progressivement
```

---

## ✅ RÉCAPITULATIF

**Votre EA est maintenant :**
- ✅ Pré-configuré avec vos URLs GitHub
- ✅ Prêt pour auto-update
- ✅ Optimisé pour FxPro
- ✅ Dashboard professionnel
- ✅ Filtre news intégré

**Il ne reste plus qu'à :**
1. Uploader fichiers sur GitHub (5 min)
2. Tester URLs dans navigateur (1 min)
3. Compiler dans MT5 (1 min)
4. Tester en démo (1 mois)

---

**Votre repo : https://github.com/fred-selest/ea-scalping-pro**

🎉 **Vous êtes prêt à lancer votre EA !**

Besoin d'aide pour une étape ? Dites-moi où vous bloquez !
