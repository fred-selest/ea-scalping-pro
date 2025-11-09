#!/bin/bash
#==============================================================================
# Script de gestion automatique des versions - EA Scalping Pro
# Usage: ./version-bump.sh [major|minor|patch] "Description du changement"
#
# Semantic Versioning: MAJOR.MINOR.PATCH
# - MAJOR: Changements incompatibles (breaking changes)
# - MINOR: Nouvelles fonctionnalités compatibles
# - PATCH: Corrections de bugs
#
# Exemples:
#   ./version-bump.sh patch "Fix: Correction erreur 10036"
#   ./version-bump.sh minor "Add: Nouveau système de cache"
#   ./version-bump.sh major "Breaking: Changement API"
#==============================================================================

set -e  # Arrêter sur erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# Vérifier les arguments
if [ "$#" -lt 2 ]; then
    print_error "Usage: ./version-bump.sh [major|minor|patch] \"Description du changement\""
fi

BUMP_TYPE=$1
DESCRIPTION=$2

# Valider le type de bump
if [[ ! "$BUMP_TYPE" =~ ^(major|minor|patch)$ ]]; then
    print_error "Type invalide. Utilisez: major, minor, ou patch"
fi

# Fichiers à mettre à jour
VERSION_FILE="VERSION.txt"
EA_FILE="EA_MultiPairs_Scalping_Pro.mq5"
CHANGELOG_FILE="CHANGELOG.md"

# Vérifier que les fichiers existent
[ ! -f "$VERSION_FILE" ] && print_error "$VERSION_FILE introuvable"
[ ! -f "$EA_FILE" ] && print_error "$EA_FILE introuvable"
[ ! -f "$CHANGELOG_FILE" ] && print_error "$CHANGELOG_FILE introuvable"

# Lire la version actuelle
CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
print_info "Version actuelle: $CURRENT_VERSION"

# Séparer MAJOR.MINOR.PATCH
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]:-0}
PATCH=${VERSION_PARTS[2]:-0}

# Calculer la nouvelle version
case $BUMP_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
print_info "Nouvelle version: $NEW_VERSION"

# Calculer format MQL5 Market (xxx.yyy)
MQL5_VERSION=$(printf "%03d.%03d" $MAJOR $((MINOR * 100 + PATCH)))
print_info "Format MQL5 Market: $MQL5_VERSION"

# Demander confirmation
read -p "Confirmer le bump de version $CURRENT_VERSION → $NEW_VERSION ? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Opération annulée"
    exit 0
fi

# ✅ Archiver la version actuelle avant le bump
print_info "Archivage de la version actuelle..."
if [ -f "./archive-version.sh" ]; then
    ./archive-version.sh
else
    print_warning "Script d'archivage introuvable (archive-version.sh)"
fi

print_info "Mise à jour des fichiers..."

# 1. Mettre à jour VERSION.txt
echo "$NEW_VERSION" > "$VERSION_FILE"
print_success "VERSION.txt mis à jour"

# 2. Mettre à jour le header de l'EA (ligne VERSION) - Format MQL5 Market
sed -i "s/^#property version.*/#property version   \"$MQL5_VERSION\"/" "$EA_FILE"
print_success "EA header mis à jour (#property version $MQL5_VERSION)"

# 3. Mettre à jour le header de l'EA (ligne //| VERSION:)
sed -i "s|^//\| VERSION:.*|//\| VERSION: $NEW_VERSION                                                   \||" "$EA_FILE"
print_success "EA header mis à jour (//| VERSION:)"

# 4. Mettre à jour le header de l'EA (ligne //| DATE:)
CURRENT_DATE=$(date +"%Y-%m-%d")
sed -i "s|^//\| DATE:.*|//\| DATE: $CURRENT_DATE                                                |" "$EA_FILE"
print_success "EA header mis à jour (//| DATE:)"

# 5. Mettre à jour CURRENT_VERSION dans le code
sed -i "s/#define CURRENT_VERSION.*/#define CURRENT_VERSION \"$NEW_VERSION\"/" "$EA_FILE"
print_success "CURRENT_VERSION mis à jour"

# 6. Mettre à jour le dashboard title
sed -i "s/ObjectSetString(0, \"Dashboard_Title\", OBJPROP_TEXT, \"EA SCALPING v[0-9.]*\");/ObjectSetString(0, \"Dashboard_Title\", OBJPROP_TEXT, \"EA SCALPING v$NEW_VERSION\");/" "$EA_FILE"
print_success "Dashboard title mis à jour"

# 7. Mettre à jour MagicNumber (format: MAJOR * 10000 + MINOR * 100 + PATCH)
NEW_MAGIC=$((MAJOR * 10000 + MINOR * 100 + PATCH))
sed -i "s/input int      MagicNumber = [0-9]*;.*$/input int      MagicNumber = $NEW_MAGIC;  \/\/ Magic number v$NEW_VERSION/" "$EA_FILE"
print_success "MagicNumber mis à jour: $NEW_MAGIC"

# 8. Ajouter entrée dans CHANGELOG.md
print_info "Mise à jour du CHANGELOG.md..."

# Déterminer le type de changement
CHANGE_TYPE="🔧 Divers"
if [[ "$DESCRIPTION" =~ ^[Ff]ix:? ]]; then
    CHANGE_TYPE="🐛 Correctif"
elif [[ "$DESCRIPTION" =~ ^[Aa]dd:?|[Ff]eat:? ]]; then
    CHANGE_TYPE="✨ Nouvelle fonctionnalité"
elif [[ "$DESCRIPTION" =~ ^[Bb]reaking:? ]]; then
    CHANGE_TYPE="💥 BREAKING CHANGE"
elif [[ "$DESCRIPTION" =~ ^[Oo]pt:?|[Pp]erf:? ]]; then
    CHANGE_TYPE="⚡ Optimisation"
elif [[ "$DESCRIPTION" =~ ^[Dd]oc:? ]]; then
    CHANGE_TYPE="📝 Documentation"
elif [[ "$DESCRIPTION" =~ ^[Rr]efactor:? ]]; then
    CHANGE_TYPE="♻️  Refactoring"
fi

# Créer l'entrée changelog dans un fichier temporaire
TEMP_CHANGELOG=$(mktemp)
cat > "$TEMP_CHANGELOG" <<EOF
## Version $NEW_VERSION ($CURRENT_DATE)

### $CHANGE_TYPE
- $DESCRIPTION

---

EOF

# Insérer après la première ligne du CHANGELOG
head -n 1 "$CHANGELOG_FILE" > "$TEMP_CHANGELOG.new"
echo "" >> "$TEMP_CHANGELOG.new"
cat "$TEMP_CHANGELOG" >> "$TEMP_CHANGELOG.new"
tail -n +2 "$CHANGELOG_FILE" >> "$TEMP_CHANGELOG.new"
mv "$TEMP_CHANGELOG.new" "$CHANGELOG_FILE"
rm -f "$TEMP_CHANGELOG"
print_success "CHANGELOG.md mis à jour"

# 9. Commit Git
print_info "Création du commit Git..."

git add "$VERSION_FILE" "$EA_FILE" "$CHANGELOG_FILE"

COMMIT_MESSAGE="$BUMP_TYPE($NEW_VERSION): $DESCRIPTION

- Version: $CURRENT_VERSION → $NEW_VERSION
- MagicNumber: $NEW_MAGIC
- Date: $CURRENT_DATE

Fichiers modifiés:
- VERSION.txt
- EA_MultiPairs_Scalping_Pro.mq5
- CHANGELOG.md"

git commit -m "$COMMIT_MESSAGE"
print_success "Commit créé"

# 10. Créer un tag Git
TAG_NAME="v$NEW_VERSION"
print_info "Création du tag Git: $TAG_NAME"

git tag -a "$TAG_NAME" -m "$BUMP_TYPE: $DESCRIPTION"
print_success "Tag $TAG_NAME créé"

# Résumé final
echo ""
echo "═══════════════════════════════════════════════════════════════"
print_success "VERSION BUMP RÉUSSI !"
echo "═══════════════════════════════════════════════════════════════"
print_info "Ancienne version:  $CURRENT_VERSION"
print_info "Nouvelle version:  $NEW_VERSION"
print_info "Magic Number:      $NEW_MAGIC"
print_info "Type:              $BUMP_TYPE"
print_info "Description:       $DESCRIPTION"
print_info "Commit:            $(git rev-parse --short HEAD)"
print_info "Tag:               $TAG_NAME"
echo "═══════════════════════════════════════════════════════════════"
echo ""

print_warning "N'oubliez pas de pousser les changements :"
echo "  git push origin $(git branch --show-current)"
echo "  git push origin $TAG_NAME"
echo ""

print_info "Pour annuler ce bump (AVANT push) :"
echo "  git reset --hard HEAD~1"
echo "  git tag -d $TAG_NAME"
