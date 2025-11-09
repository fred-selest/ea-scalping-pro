#==============================================================================
# Script de gestion automatique des versions - EA Scalping Pro
# Usage: .\version-bump.ps1 -Type [major|minor|patch] -Description "Description"
#
# Semantic Versioning: MAJOR.MINOR.PATCH
# - MAJOR: Changements incompatibles (breaking changes)
# - MINOR: Nouvelles fonctionnalités compatibles
# - PATCH: Corrections de bugs
#
# Exemples:
#   .\version-bump.ps1 -Type patch -Description "Fix: Correction erreur 10036"
#   .\version-bump.ps1 -Type minor -Description "Add: Nouveau système de cache"
#   .\version-bump.ps1 -Type major -Description "Breaking: Changement API"
#==============================================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("major", "minor", "patch")]
    [string]$Type,

    [Parameter(Mandatory=$true)]
    [string]$Description
)

# Configuration
$ErrorActionPreference = "Stop"
$VERSION_FILE = "VERSION.txt"
$EA_FILE = "EA_MultiPairs_Scalping_Pro.mq5"
$CHANGELOG_FILE = "CHANGELOG.md"

# Fonctions d'affichage avec couleurs
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Blue }
function Write-Success { Write-Host "✅ $args" -ForegroundColor Green }
function Write-Warning-Custom { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Error-Custom { Write-Host "❌ $args" -ForegroundColor Red; exit 1 }

# Vérifier que les fichiers existent
if (-not (Test-Path $VERSION_FILE)) { Write-Error-Custom "$VERSION_FILE introuvable" }
if (-not (Test-Path $EA_FILE)) { Write-Error-Custom "$EA_FILE introuvable" }
if (-not (Test-Path $CHANGELOG_FILE)) { Write-Error-Custom "$CHANGELOG_FILE introuvable" }

# Lire la version actuelle
$CURRENT_VERSION = (Get-Content $VERSION_FILE -Raw).Trim()
Write-Info "Version actuelle: $CURRENT_VERSION"

# Séparer MAJOR.MINOR.PATCH
$versionParts = $CURRENT_VERSION.Split('.')
$MAJOR = [int]$versionParts[0]
$MINOR = if ($versionParts.Length -gt 1) { [int]$versionParts[1] } else { 0 }
$PATCH = if ($versionParts.Length -gt 2) { [int]$versionParts[2] } else { 0 }

# Calculer la nouvelle version
switch ($Type) {
    "major" {
        $MAJOR++
        $MINOR = 0
        $PATCH = 0
    }
    "minor" {
        $MINOR++
        $PATCH = 0
    }
    "patch" {
        $PATCH++
    }
}

$NEW_VERSION = "$MAJOR.$MINOR.$PATCH"
Write-Info "Nouvelle version: $NEW_VERSION"

# Calculer format MQL5 Market (xxx.yyy)
# Format: Major sans padding, Minor*100+Patch avec 3 chiffres (ex: 27.500)
$MQL5_VERSION = "{0}.{1:000}" -f $MAJOR, ($MINOR * 100 + $PATCH)
Write-Info "Format MQL5 Market: $MQL5_VERSION"

# Demander confirmation
$confirmation = Read-Host "Confirmer le bump de version $CURRENT_VERSION → $NEW_VERSION ? (y/n)"
if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
    Write-Warning-Custom "Opération annulée"
    exit 0
}

# ✅ Archiver la version actuelle avant le bump
Write-Info "Archivage de la version actuelle..."
if (Test-Path ".\archive-version.sh") {
    & bash .\archive-version.sh
} else {
    Write-Warning-Custom "Script d'archivage introuvable (archive-version.sh)"
}

Write-Info "Mise à jour des fichiers..."

# 1. Mettre à jour VERSION.txt
$NEW_VERSION | Out-File -FilePath $VERSION_FILE -Encoding UTF8 -NoNewline
Write-Success "VERSION.txt mis à jour"

# 2. Mettre à jour le fichier EA
$eaContent = Get-Content $EA_FILE -Raw

# Remplacer #property version - Format MQL5 Market
$eaContent = $eaContent -replace '#property version\s+"[\d\.]+"', "#property version   `"$MQL5_VERSION`""

# Remplacer //| VERSION:
$eaContent = $eaContent -replace '//\| VERSION:.*', "//| VERSION: $NEW_VERSION                                                   |"

# Remplacer //| DATE:
$CURRENT_DATE = Get-Date -Format "yyyy-MM-dd"
$eaContent = $eaContent -replace '//\| DATE:.*', "//| DATE: $CURRENT_DATE                                                |"

# Remplacer #define CURRENT_VERSION
$eaContent = $eaContent -replace '#define CURRENT_VERSION "[\d\.]+"', "#define CURRENT_VERSION `"$NEW_VERSION`""

# Remplacer dashboard title
$eaContent = $eaContent -replace 'ObjectSetString\(0, "Dashboard_Title", OBJPROP_TEXT, "EA SCALPING v[\d\.]+"\);', "ObjectSetString(0, `"Dashboard_Title`", OBJPROP_TEXT, `"EA SCALPING v$NEW_VERSION`");"

# Mettre à jour MagicNumber
$NEW_MAGIC = $MAJOR * 10000 + $MINOR * 100 + $PATCH
$eaContent = $eaContent -replace 'input int\s+MagicNumber = \d+;.*', "input int      MagicNumber = $NEW_MAGIC;  // Magic number v$NEW_VERSION"

$eaContent | Out-File -FilePath $EA_FILE -Encoding UTF8
Write-Success "EA mis à jour"
Write-Success "MagicNumber mis à jour: $NEW_MAGIC"

# 3. Déterminer le type de changement
$CHANGE_TYPE = "🔧 Divers"
if ($Description -match "^[Ff]ix:?") {
    $CHANGE_TYPE = "🐛 Correctif"
} elseif ($Description -match "^[Aa]dd:?|^[Ff]eat:?") {
    $CHANGE_TYPE = "✨ Nouvelle fonctionnalité"
} elseif ($Description -match "^[Bb]reaking:?") {
    $CHANGE_TYPE = "💥 BREAKING CHANGE"
} elseif ($Description -match "^[Oo]pt:?|^[Pp]erf:?") {
    $CHANGE_TYPE = "⚡ Optimisation"
} elseif ($Description -match "^[Dd]oc:?") {
    $CHANGE_TYPE = "📝 Documentation"
} elseif ($Description -match "^[Rr]efactor:?") {
    $CHANGE_TYPE = "♻️  Refactoring"
}

# 4. Mettre à jour CHANGELOG.md
Write-Info "Mise à jour du CHANGELOG.md..."

$CHANGELOG_ENTRY = @"
## Version $NEW_VERSION ($CURRENT_DATE)

### $CHANGE_TYPE
- $Description

---


"@

$changelogContent = Get-Content $CHANGELOG_FILE -Raw
# Insérer après la première ligne
$lines = $changelogContent -split "`n"
$newChangelog = $lines[0] + "`n`n" + $CHANGELOG_ENTRY + ($lines[1..($lines.Length-1)] -join "`n")
$newChangelog | Out-File -FilePath $CHANGELOG_FILE -Encoding UTF8
Write-Success "CHANGELOG.md mis à jour"

# 5. Commit Git
Write-Info "Création du commit Git..."

git add $VERSION_FILE $EA_FILE $CHANGELOG_FILE

$COMMIT_MESSAGE = @"
$Type($NEW_VERSION): $Description

- Version: $CURRENT_VERSION → $NEW_VERSION
- MagicNumber: $NEW_MAGIC
- Date: $CURRENT_DATE

Fichiers modifiés:
- VERSION.txt
- EA_MultiPairs_Scalping_Pro.mq5
- CHANGELOG.md
"@

git commit -m $COMMIT_MESSAGE
Write-Success "Commit créé"

# 6. Créer un tag Git
$TAG_NAME = "v$NEW_VERSION"
Write-Info "Création du tag Git: $TAG_NAME"

git tag -a $TAG_NAME -m "$Type`: $Description"
Write-Success "Tag $TAG_NAME créé"

# Résumé final
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Success "VERSION BUMP RÉUSSI !"
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Info "Ancienne version:  $CURRENT_VERSION"
Write-Info "Nouvelle version:  $NEW_VERSION"
Write-Info "Magic Number:      $NEW_MAGIC"
Write-Info "Type:              $Type"
Write-Info "Description:       $Description"
Write-Info "Commit:            $(git rev-parse --short HEAD)"
Write-Info "Tag:               $TAG_NAME"
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Warning-Custom "N'oubliez pas de pousser les changements :"
$currentBranch = git branch --show-current
Write-Host "  git push origin $currentBranch"
Write-Host "  git push origin $TAG_NAME"
Write-Host ""

Write-Info "Pour annuler ce bump (AVANT push) :"
Write-Host "  git reset --hard HEAD~1"
Write-Host "  git tag -d $TAG_NAME"
