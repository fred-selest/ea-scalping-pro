# 🔄 GUIDE AUTO-UPDATE - EA Multi-Paires v27.2

## ✨ NOUVELLE FONCTIONNALITÉ

Votre EA peut maintenant **se mettre à jour automatiquement** !

### Avantages
```
✅ Toujours la dernière version
✅ Corrections de bugs automatiques
✅ Nouvelles fonctionnalités sans effort
✅ Téléchargement depuis GitHub officiel
✅ Instructions d'installation automatiques
✅ Désactivable à tout moment
```

---

## ⚙️ CONFIGURATION

### Paramètres dans l'EA

```cpp
=== AUTO-UPDATE ===
EnableAutoUpdate = true            // Activer/désactiver
UpdateURL = "https://..."          // URL du code source
CheckUpdateEveryHours = 24         // Fréquence vérification
```

### Configuration recommandée

**Pour VPS (recommandé) :**
```
EnableAutoUpdate = true
CheckUpdateEveryHours = 24
```

**Pour trading local :**
```
EnableAutoUpdate = false  // Mettre à jour manuellement
```

---

## 🚀 FONCTIONNEMENT

### Vérification automatique

L'EA vérifie les mises à jour :
```
1. Au démarrage (OnInit)
2. Toutes les X heures (configurable)
3. Compare version actuelle vs GitHub
4. Si nouvelle version → télécharge
```

### Processus de mise à jour

```
┌─────────────────────────────────────────┐
│ 1. Vérification version                 │
│    EA v27.2 vs GitHub v27.3             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 2. Téléchargement nouveau code          │
│    EA_MultiPairs_UPDATE_v27.3.mq5       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 3. Création instructions                │
│    UPDATE_INSTRUCTIONS.txt              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 4. Alerte MT5                           │
│    "Mise à jour disponible !"           │
└─────────────────────────────────────────┘
```

---

## 📥 INSTALLATION DE LA MISE À JOUR

### Logs dans MT5 (Journal)

Quand une mise à jour est disponible :
```
🔄 Vérification des mises à jour...
✨ Mise à jour disponible : v27.3 (actuelle : v27.2)
📥 Téléchargement automatique dans 5 secondes...
📥 Téléchargement de la version 27.3...
✅ Mise à jour téléchargée : EA_MultiPairs_UPDATE_v27.3.mq5
📄 Instructions créées : UPDATE_INSTRUCTIONS.txt
```

### Alerte popup
```
╔═══════════════════════════════════╗
║ ✨ Mise à jour v27.3 téléchargée ║
║                                   ║
║ Fichier : EA_MultiPairs_UPDATE... ║
║                                   ║
║ Voir UPDATE_INSTRUCTIONS.txt      ║
║ pour installer                    ║
╚═══════════════════════════════════╝
```

---

## 📋 MÉTHODES D'INSTALLATION

### Méthode 1 : Manuelle (5 minutes)

**Étapes :**
```
1. Fermer tous graphiques utilisant l'EA
2. Ouvrir MetaEditor (F4)
3. Fichier → Ouvrir → EA_MultiPairs_UPDATE_v27.3.mq5
4. Fichier → Enregistrer sous...
5. Nom : EA_MultiPairs_News_Dashboard_v27.mq5 (écraser ancien)
6. Compiler (F7)
7. Vérifier : 0 error, 0 warning
8. Glisser nouveau EA sur graphiques
```

**Emplacement fichiers :**
```
Téléchargé dans :
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\Common\Files\

À installer dans :
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\[ID]\MQL5\Experts\
```

---

### Méthode 2 : Script PowerShell (2 minutes)

**Si vous avez Deploy-EA-VPS.ps1 :**
```powershell
1. Exécuter Deploy-EA-VPS.ps1
2. Indiquer fichier : EA_MultiPairs_UPDATE_v27.3.mq5
3. Le script copie et compile automatiquement
4. Terminer !
```

---

### Méthode 3 : Copier-Coller Rapide (3 minutes)

**Raccourci :**
```
1. Ctrl+G dans MetaEditor → Aller au dossier Experts
2. Copier EA_MultiPairs_UPDATE_v27.3.mq5
3. Coller dans le dossier
4. Renommer en EA_MultiPairs_News_Dashboard_v27.mq5
5. Compiler (F7)
```

---

## 🔧 CONFIGURATION GITHUB (Pour développeurs)

### Héberger votre fork

**Structure GitHub requise :**
```
votre-repo/
├── EA_MultiPairs_News_Dashboard_v27.mq5
├── VERSION.txt                    ← "27.2"
├── CHANGELOG.md
├── README.md
└── Deploy-EA-VPS.ps1
```

### Fichier VERSION.txt
```
27.2
```
*(Une seule ligne avec numéro de version)*

### URL à configurer dans l'EA

```cpp
// URL du code source (fichier .mq5)
UpdateURL = "https://raw.githubusercontent.com/VOTRE-USER/VOTRE-REPO/main/EA_MultiPairs_News_Dashboard_v27.mq5"

// URL de vérification version (fichier VERSION.txt)
// Codé en dur dans CheckForUpdates() ligne ~XXX
version_url = "https://raw.githubusercontent.com/VOTRE-USER/VOTRE-REPO/main/VERSION.txt"
```

### Publier une nouvelle version

```bash
# 1. Modifier le code
# 2. Incrémenter version dans #define CURRENT_VERSION "27.3"
# 3. Mettre à jour VERSION.txt → "27.3"
# 4. Mettre à jour CHANGELOG.md
# 5. Commit et push sur GitHub

git add .
git commit -m "Release v27.3 - [Description]"
git push origin main
```

---

## 🛡️ SÉCURITÉ

### Vérifications automatiques

L'EA vérifie :
```
✅ Taille fichier téléchargé (>1000 caractères)
✅ Code HTTP 200 (succès)
✅ Timeout 30 secondes max
✅ Pas d'exécution automatique
✅ Installation manuelle requise
```

### Recommandations

```
🔒 Utilisez HTTPS (pas HTTP)
🔒 Hébergez sur GitHub officiel
🔒 Ne modifiez pas UpdateURL sauf si vous savez ce que vous faites
🔒 Vérifiez manuellement le code téléchargé avant compilation
🔒 Testez en démo après chaque mise à jour
```

---

## ⚠️ LIMITATIONS

### Ce que l'auto-update FAIT
```
✅ Vérifie versions disponibles
✅ Télécharge nouveau code
✅ Crée instructions d'installation
✅ Alerte utilisateur
```

### Ce que l'auto-update NE FAIT PAS
```
❌ Installation automatique (sécurité)
❌ Compilation automatique
❌ Remplacement du fichier actif
❌ Redémarrage de MT5
❌ Modification des paramètres
```

**Pourquoi ?**
- Sécurité : Éviter exécution code malveillant
- Contrôle : Vous gardez la main
- Stabilité : Pas de perturbation du trading en cours

---

## 🐛 TROUBLESHOOTING

### Erreur : "URL non autorisée"
```
Cause : GitHub non autorisé dans WebRequest
Solution : 
1. MT5 → Outils → Options → Expert Advisors
2. WebRequest → Ajouter :
   https://raw.githubusercontent.com
3. OK → Redémarrer MT5
```

### Erreur : "HTTP 429"
```
Cause : Trop de requêtes vers GitHub
Solution : Augmenter CheckUpdateEveryHours à 48 ou 72
```

### Mise à jour ne se détecte pas
```
Vérifications :
1. EnableAutoUpdate = true ?
2. URLs WebRequest autorisées ?
3. VERSION.txt correct sur GitHub ?
4. Fichier VERSION.txt = une ligne, un nombre ?
```

### Fichier téléchargé introuvable
```
Emplacement :
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\Common\Files\

Ouvrir dans explorateur :
MT5 → Fichier → Ouvrir le dossier de données → Files
```

---

## 📊 LOGS ET MONITORING

### Logs normaux (pas de MAJ)
```
🔄 Vérification des mises à jour...
✅ Vous utilisez la dernière version (v27.2)
```

### Logs avec MAJ disponible
```
🔄 Vérification des mises à jour...
✨ Mise à jour disponible : v27.3 (actuelle : v27.2)
📥 Téléchargement automatique dans 5 secondes...
📥 Téléchargement de la version 27.3...
✅ Mise à jour téléchargée : EA_MultiPairs_UPDATE_v27.3.mq5
🔧 IMPORTANT : Recompiler le fichier avec MetaEditor (F4 → F7)
📄 Instructions créées : UPDATE_INSTRUCTIONS.txt
```

### Logs d'erreur
```
❌ Échec téléchargement mise à jour : HTTP 404
⚠️ Limite API atteinte pour vérification MAJ. Réessai dans 24h
⚠️ URL mise à jour non autorisée dans WebRequest
```

---

## 💡 BONNES PRATIQUES

### Fréquence recommandée
```
Trading actif quotidien : 24h
Trading occasionnel : 48h
Test/Démo : 12h
Production critique : Désactiver (manuel)
```

### Avant d'installer une MAJ
```
☐ Sauvegarder paramètres actuels (.set)
☐ Noter performances actuelles
☐ Lire CHANGELOG de la nouvelle version
☐ Fermer positions si MAJ majeure
☐ Tester en démo d'abord
```

### Après installation
```
☐ Vérifier compilation (0 error)
☐ Vérifier dashboard s'affiche
☐ Vérifier logs (pas d'erreur)
☐ Vérifier news filter fonctionne
☐ Tester 1h en démo minimum
```

---

## 🎓 FAQ

**Q: L'auto-update est-il obligatoire ?**
R: Non, vous pouvez le désactiver (EnableAutoUpdate = false)

**Q: Les mises à jour cassent-elles mes paramètres ?**
R: Non, vos paramètres .set sont conservés

**Q: Puis-je revenir à une version antérieure ?**
R: Oui, téléchargez l'ancienne version sur GitHub

**Q: Faut-il fermer les positions pour MAJ ?**
R: Non pour mineures (27.1→27.2), oui pour majeures (27→28)

**Q: L'EA se met à jour pendant le trading ?**
R: Non, il télécharge mais n'installe pas automatiquement

**Q: Dois-je payer pour les mises à jour ?**
R: Non, toutes les mises à jour sont gratuites

**Q: Mon VPS supporte-t-il les MAJ ?**
R: Oui si WebRequest autorisé et connexion internet OK

**Q: Quelle est la taille des téléchargements ?**
R: ~50-100 KB par mise à jour (fichier texte)

---

## 📞 SUPPORT

### En cas de problème

1. **Vérifier logs** : Journal MT5
2. **Lire instructions** : UPDATE_INSTRUCTIONS.txt
3. **Consulter CHANGELOG** : Voir nouveautés
4. **Tester en démo** : Avant réel
5. **Demander aide** : Forum MQL5 ou GitHub Issues

---

**Version du guide : 1.0**  
**Compatible avec : EA v27.2+**  
**Dernière MAJ : 05 Novembre 2025**

🎉 Profitez des mises à jour automatiques !
