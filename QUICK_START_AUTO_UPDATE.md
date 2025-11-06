# 🚀 Démarrage Rapide - Auto-Update en 5 Minutes

## 🎯 Objectif

Configurer votre EA pour qu'il se mette à jour **automatiquement** depuis GitHub, sans intervention manuelle.

---

## ⚡ Méthode Express (Recommandée pour VPS)

### Windows VPS - 100% Automatique

```powershell
# 1️⃣ Ouvrir PowerShell en ADMINISTRATEUR
# Clic droit → Exécuter en tant qu'administrateur

# 2️⃣ Aller dans le dossier des scripts
cd "C:\Path\To\ea-scalping-pro"

# 3️⃣ Lancer configuration auto
.\setup-scheduled-task.ps1

# ✅ C'EST TOUT !
# L'EA se mettra à jour tous les jours à 3h du matin
```

**Résultat** :
- ✅ Vérification quotidienne automatique
- ✅ Téléchargement si nouvelle version
- ✅ Compilation automatique
- ✅ Backup de l'ancienne version
- ✅ Fonctionne même si vous êtes déconnecté

---

## 🖱️ Méthode Simple (PC Local)

### Configuration MT5 - 2 Minutes

**Étape 1** : Dans MT5, menu `Outils` → `Options` → `Expert Advisors`

**Étape 2** : Cocher `Autoriser WebRequest pour les URL suivantes`

**Étape 3** : Ajouter cette URL :
```
https://raw.githubusercontent.com
```

**Étape 4** : Cliquer `OK` et **REDÉMARRER MT5**

**Étape 5** : Dans les paramètres de l'EA :
```
EnableAutoUpdate = true ✅
CheckUpdateEveryHours = 24
```

**Résultat** :
- ✅ Vérification toutes les 24h
- ⚠️ Vous devez compiler manuellement après téléchargement
- ⚠️ MT5 doit rester ouvert

---

## 📊 Comparaison Rapide

| | VPS Auto | PC Simple | Manuel |
|---|:---:|:---:|:---:|
| **Setup** | 5 min | 2 min | 30 sec |
| **Automatique** | ✅ 100% | 🟡 50% | ❌ 0% |
| **Compilation** | ✅ Auto | ❌ Manuelle | ❌ Manuelle |
| **VPS** | ✅ Idéal | 🟡 OK | ✅ OK |
| **Backup** | ✅ Auto | ❌ Non | ❌ Non |

---

## 🧪 Test Rapide

### Vérifier que ça fonctionne

**Méthode VPS (PowerShell)** :
```powershell
.\auto-update-ea.ps1 -CheckOnly
```

**Méthode MT5** :
- Ouvrir Journal MT5 (onglet en bas)
- Chercher : "Vérification des mises à jour"
- Devrait voir : "✅ Vous utilisez la dernière version"

---

## 🔧 Commandes Utiles

### Test manuel
```powershell
.\auto-update-ea.ps1          # Vérifier + Installer si besoin
.\auto-update-ea.ps1 -CheckOnly   # Juste vérifier
.\auto-update-ea.ps1 -Force       # Forcer réinstallation
```

### Gérer la tâche planifiée
```powershell
.\manage-scheduled-task.ps1   # Interface de gestion
```

### Double-clic Windows
```
auto-update-ea.bat    ← Double-cliquez !
```

---

## 🐛 Problème Courant #1

**"URL non autorisée" (Erreur 4060)**

→ **Solution** :
1. Outils → Options → Expert Advisors
2. Ajouter : `https://raw.githubusercontent.com`
3. **REDÉMARRER MT5** (obligatoire !)

---

## 🐛 Problème Courant #2

**Script PowerShell ne démarre pas**

→ **Solution** :
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

Ou clic droit sur `auto-update-ea.ps1` → Propriétés → Débloquer → OK

---

## 📁 Structure des Fichiers

```
ea-scalping-pro/
│
├── 📘 Pour comprendre (documentation)
│   ├── README_AUTO_UPDATE.md           ← Guide rapide
│   ├── GUIDE_AUTO_UPDATE_GITHUB.md     ← Guide complet
│   └── QUICK_START_AUTO_UPDATE.md      ← Ce fichier
│
├── ⚙️ Pour VPS/Auto (scripts PowerShell)
│   ├── auto-update-ea.ps1              ← Script principal
│   ├── auto-update-ea.bat              ← Double-clic Windows
│   ├── setup-scheduled-task.ps1        ← Configuration auto
│   └── manage-scheduled-task.ps1       ← Gestion (créé auto)
│
└── 📊 Code source EA
    ├── EA_MultiPairs_News_Dashboard_v27.mq5
    ├── VERSION.txt
    └── CHANGELOG.md
```

---

## 🎯 Choisir Votre Méthode

### Vous avez un VPS Windows ?
→ **Utilisez la Méthode VPS Auto** (100% automatique)
```powershell
.\setup-scheduled-task.ps1
```

### Vous tradez depuis votre PC ?
→ **Utilisez la Méthode MT5 Simple** (semi-auto)
1. Configurer WebRequest dans MT5
2. `EnableAutoUpdate = true`

### Vous voulez le contrôle total ?
→ **Téléchargez manuellement depuis GitHub**

---

## ✅ Checklist Installation VPS

- [ ] PowerShell ouvert en **ADMINISTRATEUR**
- [ ] Scripts téléchargés depuis GitHub
- [ ] Exécuté `.\setup-scheduled-task.ps1`
- [ ] Testé avec `.\auto-update-ea.ps1 -CheckOnly`
- [ ] Vérifié tâche dans Planificateur Windows
- [ ] Test compilation réussi

**Temps total** : ~5 minutes

---

## ✅ Checklist Installation PC

- [ ] MT5 → Options → Expert Advisors → WebRequest
- [ ] Ajouté `https://raw.githubusercontent.com`
- [ ] **REDÉMARRÉ MT5**
- [ ] Paramètres EA : `EnableAutoUpdate = true`
- [ ] Testé : Vérifié Journal MT5
- [ ] Backup paramètres EA fait

**Temps total** : ~2 minutes

---

## 📞 Besoin d'Aide ?

### Documentation Complète
📖 `GUIDE_AUTO_UPDATE_GITHUB.md` - Tout est expliqué en détail

### Test de Connexion
```powershell
# Vérifier que GitHub est accessible
Invoke-WebRequest "https://github.com" -UseBasicParsing
```

### Voir Version Actuelle GitHub
```powershell
(Invoke-WebRequest "https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/VERSION.txt" -UseBasicParsing).Content
```

---

## 🎉 Prochaines Étapes

1. **Configuré ?** → Testez avec `-CheckOnly`
2. **Fonctionne ?** → Attendez 24h ou lancez manuellement
3. **Nouvelle version ?** → Sera installée automatiquement
4. **Testez en DÉMO** avant production !

---

## ⚠️ Important

- **Toujours tester en DÉMO** les nouvelles versions pendant 24h minimum
- **Sauvegarder vos paramètres EA** avant MAJ (clic droit → Sauvegarder)
- **Le trading comporte des risques** - surveillez vos positions

---

**🚀 Bon trading automatisé !**

---

*Créé le 06 Nov 2025 - Version 1.0*
