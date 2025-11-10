#!/bin/bash
#==============================================================================
# Script de génération SHA256 pour sécurité auto-update
# Usage: ./generate-sha256.sh
#
# Génère le fichier SHA256 pour vérification de l'intégrité des téléchargements
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
HASH_FILE="${EA_FILE}.sha256"

# Vérifier que le fichier EA existe
if [ ! -f "$EA_FILE" ]; then
    echo "❌ $EA_FILE introuvable"
    exit 1
fi

print_info "Génération du hash SHA256 pour $EA_FILE..."

# Générer SHA256
if command -v sha256sum &> /dev/null; then
    # Linux
    HASH=$(sha256sum "$EA_FILE" | awk '{print $1}')
elif command -v shasum &> /dev/null; then
    # macOS
    HASH=$(shasum -a 256 "$EA_FILE" | awk '{print $1}')
else
    echo "❌ Aucun outil SHA256 trouvé (sha256sum ou shasum)"
    exit 1
fi

# Sauvegarder le hash
echo "$HASH" > "$HASH_FILE"

print_success "Hash généré : $HASH"
print_info "Fichier créé : $HASH_FILE"

# Ajouter à Git si dans un dépôt
if [ -d ".git" ]; then
    git add "$HASH_FILE" 2>/dev/null || true
    print_info "Fichier SHA256 ajouté à Git"
fi

print_success "Génération terminée"
