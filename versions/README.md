# 📦 Archives des versions - EA Scalping Pro

Ce dossier contient les archives automatiques des versions précédentes du fichier EA.

**📍 Accessible en ligne :** [github.com/fred-selest/ea-scalping-pro/tree/main/versions](https://github.com/fred-selest/ea-scalping-pro/tree/main/versions)

## 📋 Structure

Chaque fichier archivé suit le format :
```
EA_MultiPairs_Scalping_Pro_vX.Y_YYYYMMDD_HHMMSS.mq5
```

Exemple :
```
EA_MultiPairs_Scalping_Pro_v27.52_20251109_195000.mq5
```

## 🔄 Archivage automatique

Les archives sont créées automatiquement par le système de versioning :

1. **Avant chaque bump** : Le script `version-bump.sh` appelle automatiquement `archive-version.sh`
2. **Copie horodatée** : Une copie avec timestamp est créée dans ce dossier
3. **Nettoyage automatique** : Seules les **10 dernières versions** sont conservées

## 📊 Utilisation

### Voir les archives disponibles
```bash
ls -lh versions/
```

### Restaurer une version précédente
```bash
# Copier une archive vers le fichier principal
cp versions/EA_MultiPairs_Scalping_Pro_v27.4.2_20251109_190000.mq5 EA_MultiPairs_Scalping_Pro.mq5
```

### Comparer deux versions
```bash
# Comparer version actuelle avec une archive
diff EA_MultiPairs_Scalping_Pro.mq5 versions/EA_MultiPairs_Scalping_Pro_v27.4.2_*.mq5
```

### Archiver manuellement
```bash
# Créer une archive sans bumper la version
./archive-version.sh
```

## 🗑️ Nettoyage

Les archives anciennes sont automatiquement supprimées (max 10 versions conservées).

Pour changer cette limite, éditer `archive-version.sh` :
```bash
MAX_ARCHIVES=10  # Modifier cette valeur
```

## 📝 Notes

- Les archives sont **automatiquement commitées dans Git** et visibles sur GitHub
- Chaque nouvelle archive est ajoutée au dépôt lors du version bump
- Utiles pour **rollback rapide** en cas de problème
- Permettent de **comparer facilement** les versions
- Accessibles en ligne sur : `https://github.com/fred-selest/ea-scalping-pro/tree/main/versions`

## 🔍 Trouver une version spécifique

```bash
# Par numéro de version
ls versions/*v27.4.2*

# Par date
ls versions/*20251109*

# Dernière archive
ls -t versions/*.mq5 | head -1
```

---

**Généré automatiquement** par le système de versioning EA Scalping Pro
