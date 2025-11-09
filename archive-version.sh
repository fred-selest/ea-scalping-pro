#!/bin/bash
#==============================================================================
# Script d'archivage automatique des versions - EA Scalping Pro
# Usage: ./archive-version.sh
#
# Ce script archive la version actuelle du fichier EA avant de bumper
# Crée une copie horodatée dans le dossier versions/
#==============================================================================

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }

# Configuration
EA_FILE="EA_MultiPairs_Scalping_Pro.mq5"
VERSION_FILE="VERSION.txt"
VERSIONS_DIR="versions"

# Vérifier que les fichiers existent
if [ ! -f "$EA_FILE" ]; then
    echo "❌ $EA_FILE introuvable"
    exit 1
fi

if [ ! -f "$VERSION_FILE" ]; then
    echo "❌ $VERSION_FILE introuvable"
    exit 1
fi

# Créer le dossier versions s'il n'existe pas
mkdir -p "$VERSIONS_DIR"

# Lire la version actuelle
CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')

# Créer le nom d'archive avec timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="EA_MultiPairs_Scalping_Pro_v${CURRENT_VERSION}_${TIMESTAMP}.mq5"

# Copier le fichier
cp "$EA_FILE" "$VERSIONS_DIR/$ARCHIVE_NAME"

print_success "Version archivée : $ARCHIVE_NAME"
print_info "Emplacement : $VERSIONS_DIR/$ARCHIVE_NAME"

# Afficher le nombre total d'archives
ARCHIVE_COUNT=$(ls -1 "$VERSIONS_DIR"/*.mq5 2>/dev/null | wc -l)
print_info "Total archives : $ARCHIVE_COUNT versions"

# Optionnel : limiter le nombre d'archives (garder les 10 dernières)
MAX_ARCHIVES=10
if [ "$ARCHIVE_COUNT" -gt "$MAX_ARCHIVES" ]; then
    print_info "Nettoyage : suppression des anciennes archives (max $MAX_ARCHIVES)"
    ls -t "$VERSIONS_DIR"/*.mq5 | tail -n +$((MAX_ARCHIVES + 1)) | xargs -r rm -f
    print_success "Archives nettoyées"
fi
