# 🔄 Auto-Update EA Multi-Paires - Guide Rapide

## 📋 Méthodes Disponibles

Il existe **3 méthodes** pour mettre à jour automatiquement votre EA depuis GitHub :

### 1️⃣ Auto-Update Intégré MT5 (Recommandé pour débutants)

✅ **Avantages** : Simple, pas de script externe, tout dans MT5
⚠️ **Limitation** : Installation manuelle nécessaire après téléchargement

**Configuration** :
1. Dans MT5 : `Outils` → `Options` → `Expert Advisors`
2. Autoriser WebRequest pour : `https://raw.githubusercontent.com`
3. **REDÉMARRER MT5**
4. Dans paramètres EA : `EnableAutoUpdate = true`

**Fonctionnement** :
- L'EA vérifie automatiquement toutes les 24h
- Télécharge la nouvelle version dans `Common\Files\`
- Génère `UPDATE_INSTRUCTIONS.txt`
- Vous devez compiler manuellement

📖 **Guide complet** : `GUIDE_AUTO_UPDATE_GITHUB.md`

---

### 2️⃣ Script PowerShell Automatique (Recommandé pour VPS)

✅ **Avantages** : Automatisation complète, compilation automatique
⚠️ **Prérequis** : Windows, PowerShell 5.1+

**Installation** :

```powershell
# Méthode 1 : Double-clic sur le fichier
auto-update-ea.bat

# Méthode 2 : Ligne de commande
powershell -ExecutionPolicy Bypass -File auto-update-ea.ps1

# Méthode 3 : PowerShell avec options
.\auto-update-ea.ps1 -CheckOnly    # Vérifier uniquement
.\auto-update-ea.ps1 -Force        # Forcer réinstallation
```

**Fonctionnalités** :
- ✅ Vérification version automatique
- ✅ Téléchargement depuis GitHub
- ✅ Backup automatique ancienne version
- ✅ Compilation automatique avec MetaEditor
- ✅ Validation du fichier téléchargé
- ✅ Gestion des erreurs complète
- ✅ Logs détaillés

**Planification automatique** (Tâche Windows) :

```powershell
# Créer tâche qui s'exécute tous les jours à 3h du matin
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\auto-update-ea.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 3am

Register-ScheduledTask -Action $action -Trigger $trigger `
    -TaskName "EA Multi-Paires Auto-Update" `
    -Description "Mise à jour automatique EA depuis GitHub"
```

---

### 3️⃣ Manuel (Contrôle Total)

✅ **Avantages** : Contrôle total, pas de surprises
⚠️ **Inconvénient** : Doit vérifier manuellement

**Étapes** :
1. Aller sur GitHub : https://github.com/fred-selest/ea-scalping-pro
2. Télécharger `EA_MultiPairs_News_Dashboard_v27.mq5`
3. Copier dans `C:\Program Files\MetaTrader 5\MQL5\Experts\`
4. Compiler dans MetaEditor (F4 → F7)
5. Redémarrer graphiques MT5

---

## 🚀 Démarrage Rapide (Windows VPS)

### Installation Complète en 3 Commandes

```powershell
# 1. Télécharger les scripts depuis GitHub
git clone https://github.com/fred-selest/ea-scalping-pro.git
cd ea-scalping-pro

# 2. Exécuter mise à jour
.\auto-update-ea.ps1

# 3. Planifier exécution quotidienne (optionnel)
.\setup-scheduled-task.ps1
```

---

## 📊 Comparaison des Méthodes

| Critère | MT5 Intégré | Script PowerShell | Manuel |
|---------|-------------|-------------------|--------|
| **Automatisation** | 🟡 Partielle | 🟢 Complète | 🔴 Aucune |
| **Difficulté** | ⭐ Facile | ⭐⭐ Moyenne | ⭐ Facile |
| **Compilation auto** | ❌ Non | ✅ Oui | ❌ Non |
| **Backup auto** | ❌ Non | ✅ Oui | ❌ Non |
| **Validation** | 🟡 Basique | ✅ Avancée | ✅ Manuelle |
| **Planification** | ✅ 24h | ✅ Personnalisable | ❌ Non |
| **VPS** | ✅ Compatible | ✅ Idéal | ✅ Compatible |

---

## 🔧 Configuration Recommandée par Profil

### 👨‍💼 Trader Débutant (PC Local)

```
Méthode     : Auto-Update MT5 intégré
Fréquence   : 24h
Installation: Manuelle après téléchargement
Monitoring  : Vérifier Journal MT5 une fois/semaine
```

### 🏢 Trader Intermédiaire (VPS)

```
Méthode     : Script PowerShell + Tâche planifiée
Fréquence   : Quotidienne (3h du matin)
Installation: Automatique
Monitoring  : Email VPS si erreur
```

### 💼 Trader Professionnel (Multi-VPS)

```
Méthode     : Script PowerShell centralisé
Fréquence   : Quotidienne + Webhook GitHub
Installation: Automatique + Tests démo
Monitoring  : Dashboard centralisé + Alertes
```

---

## 📁 Structure des Fichiers

```
ea-scalping-pro/
├── EA_MultiPairs_News_Dashboard_v27.mq5    ← Code source EA
├── VERSION.txt                              ← Version actuelle
├── CHANGELOG.md                             ← Historique versions
│
├── 📄 Documentation
│   ├── README_GITHUB.md                     ← Documentation principale
│   ├── GUIDE_AUTO_UPDATE_GITHUB.md          ← Guide auto-update complet
│   ├── README_AUTO_UPDATE.md                ← Ce fichier (guide rapide)
│   └── GUIDE_INSTALLATION_FRED_SELEST.md    ← Installation initiale
│
└── 🔧 Scripts Auto-Update
    ├── auto-update-ea.ps1                   ← Script PowerShell principal
    ├── auto-update-ea.bat                   ← Lanceur Windows
    ├── setup-scheduled-task.ps1             ← Configuration tâche planifiée
    └── check-version.ps1                    ← Vérification rapide
```

---

## 🛠️ Utilisation du Script PowerShell

### Commandes Principales

```powershell
# Vérification + Installation si nécessaire
.\auto-update-ea.ps1

# Vérifier version uniquement (sans installer)
.\auto-update-ea.ps1 -CheckOnly

# Forcer réinstallation (même si version identique)
.\auto-update-ea.ps1 -Force

# Spécifier chemin MT5 personnalisé
.\auto-update-ea.ps1 -MT5Path "D:\Trading\MetaTrader5"

# Utiliser branche GitHub différente
.\auto-update-ea.ps1 -Branch "develop"
```

### Options Avancées

```powershell
# Combinaisons possibles
.\auto-update-ea.ps1 -MT5Path "C:\MT5" -CheckOnly
.\auto-update-ea.ps1 -Force -Branch "main"
.\auto-update-ea.ps1 -MT5Path "D:\Trading\MT5" -Force
```

---

## 📝 Logs et Monitoring

### Fichiers de Log Créés

```
C:\Program Files\MetaTrader 5\MQL5\Experts\
├── Backups\
│   └── EA_MultiPairs_v27.2_20251106_143000.mq5  ← Backup auto
├── compile.log                                   ← Log compilation
├── VERSION_LOCAL.txt                             ← Version installée
└── CHANGELOG.txt                                 ← Changelog GitHub
```

### Journal MT5

```
Onglet "Journal" (en bas de MT5) :
- Messages préfixés "EA Multi-Paires"
- Codes d'erreur détaillés
- Statut des vérifications
```

---

## 🐛 Dépannage Rapide

### Problème : "URL non autorisée" (Erreur 4060)

```
Solution :
1. Outils → Options → Expert Advisors
2. Ajouter : https://raw.githubusercontent.com
3. REDÉMARRER MT5
```

### Problème : Script PowerShell ne démarre pas

```
Solution :
1. Clic droit sur auto-update-ea.ps1
2. Propriétés → Débloquer → OK
3. Ou lancer : Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
```

### Problème : "MetaEditor introuvable"

```
Solution :
1. Vérifier installation MT5 complète
2. Spécifier chemin : -MT5Path "C:\Chemin\Vers\MT5"
3. Ou installer manuellement après téléchargement
```

### Problème : Compilation échoue

```
Solution :
1. Ouvrir MetaEditor (F4)
2. Ouvrir le fichier EA téléchargé
3. Compiler manuellement (F7)
4. Vérifier : 0 error, 0 warning
```

---

## ✅ Checklist Installation VPS

- [ ] Windows Server avec PowerShell 5.1+
- [ ] MT5 installé et fonctionnel
- [ ] Scripts téléchargés depuis GitHub
- [ ] Première exécution manuelle réussie
- [ ] Tâche planifiée créée (3h du matin)
- [ ] Test avec `-CheckOnly` fonctionne
- [ ] Backup automatique vérifié
- [ ] Notifications email VPS configurées
- [ ] Documentation sauvegardée localement

---

## 🔐 Sécurité

### Bonnes Pratiques

1. **Vérifier Code Source** :
   - Toujours consulter le code sur GitHub avant installation
   - Vérifier commits récents et auteur

2. **Tester en Démo** :
   - Nouvelle version = 24h minimum en compte démo
   - Vérifier trading, dashboard, logs

3. **Backups** :
   - Script PowerShell fait backup automatique
   - Exporter paramètres EA avant MAJ (clic droit → Sauvegarder)

4. **Monitoring** :
   - Vérifier Journal MT5 après chaque MAJ
   - Noter versions dans fichier texte

---

## 📞 Support

### Resources

- 📖 **Documentation complète** : `GUIDE_AUTO_UPDATE_GITHUB.md`
- 📝 **Changelog** : `CHANGELOG.md`
- 🐛 **Issues GitHub** : https://github.com/fred-selest/ea-scalping-pro/issues
- 💬 **Forum MQL5** : [Lien vers votre forum]

### Commandes Utiles

```powershell
# Vérifier version GitHub actuelle
(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fred-selest/ea-scalping-pro/main/VERSION.txt" -UseBasicParsing).Content

# Lister backups disponibles
Get-ChildItem "C:\Program Files\MetaTrader 5\MQL5\Experts\Backups" | Sort-Object LastWriteTime -Descending

# Restaurer backup
Copy-Item "C:\Program Files\MetaTrader 5\MQL5\Experts\Backups\EA_MultiPairs_v27.2_20251106_143000.mq5" `
          "C:\Program Files\MetaTrader 5\MQL5\Experts\EA_MultiPairs_News_Dashboard_v27.mq5" -Force
```

---

## 🎯 Prochaines Étapes

1. **Choisir votre méthode** (MT5 intégré ou PowerShell)
2. **Suivre guide installation** correspondant
3. **Tester vérification** (`-CheckOnly`)
4. **Configurer planification** (optionnel)
5. **Documenter votre setup** (versions, dates)

---

## 📈 Roadmap

Futures améliorations prévues :

- ✨ Notification Telegram lors MAJ disponible
- ✨ Dashboard web monitoring versions
- ✨ Rollback automatique si erreur détectée
- ✨ Support GitHub Releases API
- ✨ Multi-VPS sync automatique

---

**Créé le** : 06 Nov 2025
**Version Guide** : 1.0
**Auteur** : fred-selest

---

**⚠️ IMPORTANT** : Testez toujours en démo avant production. Le trading automatisé comporte des risques de perte en capital.

**✅ BON TRADING !**
