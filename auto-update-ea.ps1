#Requires -Version 5.1
<#
.SYNOPSIS
    Script d'auto-update automatique pour EA Multi-Paires depuis GitHub

.DESCRIPTION
    Ce script vérifie automatiquement les nouvelles versions sur GitHub,
    télécharge le code source, compile avec MetaEditor et installe la MAJ.

.PARAMETER CheckOnly
    Vérifier uniquement la version sans installer

.PARAMETER Force
    Forcer l'installation même si version identique

.EXAMPLE
    .\auto-update-ea.ps1
    Vérifie et installe si nouvelle version disponible

.EXAMPLE
    .\auto-update-ea.ps1 -CheckOnly
    Vérifie uniquement sans installer

.EXAMPLE
    .\auto-update-ea.ps1 -Force
    Force réinstallation de la version actuelle

.NOTES
    Author: fred-selest
    Version: 1.0
    Date: 2025-11-06
#>

param(
    [switch]$CheckOnly,
    [switch]$Force,
    [string]$MT5Path = "C:\Program Files\MetaTrader 5",
    [string]$GithubRepo = "fred-selest/ea-scalping-pro",
    [string]$Branch = "main"
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# Couleurs pour output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success($message) { Write-ColorOutput Green "✅ $message" }
function Write-Info($message) { Write-ColorOutput Cyan "ℹ️ $message" }
function Write-Warning($message) { Write-ColorOutput Yellow "⚠️ $message" }
function Write-Error($message) { Write-ColorOutput Red "❌ $message" }

# Bannière
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🚀 EA Multi-Paires - Auto Update depuis GitHub   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Chemins
$expertPath = Join-Path $MT5Path "MQL5\Experts"
$filename = "EA_MultiPairs_News_Dashboard_v27.mq5"
$localFile = Join-Path $expertPath $filename
$versionFile = Join-Path $expertPath "VERSION_LOCAL.txt"
$backupPath = Join-Path $expertPath "Backups"
$metaeditor = Join-Path $MT5Path "metaeditor64.exe"

# URLs GitHub
$baseUrl = "https://raw.githubusercontent.com/$GithubRepo/$Branch"
$versionUrl = "$baseUrl/VERSION.txt"
$sourceUrl = "$baseUrl/$filename"
$changelogUrl = "$baseUrl/CHANGELOG.md"

Write-Info "Configuration:"
Write-Host "  MT5 Path      : $MT5Path" -ForegroundColor Gray
Write-Host "  Expert Path   : $expertPath" -ForegroundColor Gray
Write-Host "  GitHub Repo   : $GithubRepo" -ForegroundColor Gray
Write-Host "  Branch        : $Branch" -ForegroundColor Gray
Write-Host ""

# Vérification pré-requis
Write-Info "Vérification des pré-requis..."

# 1. Vérifier MT5 installé
if (-not (Test-Path $MT5Path)) {
    Write-Error "MetaTrader 5 introuvable dans : $MT5Path"
    Write-Host "Spécifiez le chemin correct avec : -MT5Path 'C:\Chemin\Vers\MT5'" -ForegroundColor Yellow
    exit 1
}

# 2. Vérifier dossier Experts
if (-not (Test-Path $expertPath)) {
    Write-Error "Dossier MQL5\Experts introuvable : $expertPath"
    exit 1
}

# 3. Vérifier MetaEditor
if (-not (Test-Path $metaeditor)) {
    Write-Warning "MetaEditor introuvable : $metaeditor"
    Write-Host "Tentative de détection automatique..." -ForegroundColor Yellow

    $metaeditor32 = Join-Path $MT5Path "metaeditor.exe"
    if (Test-Path $metaeditor32) {
        $metaeditor = $metaeditor32
        Write-Success "MetaEditor 32-bit détecté"
    } else {
        Write-Error "Impossible de trouver MetaEditor"
        Write-Host "Installation manuelle nécessaire après téléchargement" -ForegroundColor Yellow
    }
}

# 4. Vérifier connexion internet
Write-Info "Test de connexion à GitHub..."
try {
    $null = Invoke-WebRequest -Uri "https://github.com" -Method Head -TimeoutSec 10 -UseBasicParsing
    Write-Success "Connexion GitHub OK"
} catch {
    Write-Error "Impossible de se connecter à GitHub"
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Récupérer version actuelle locale
$currentVersion = "unknown"
if (Test-Path $versionFile) {
    $currentVersion = Get-Content $versionFile -Raw
    $currentVersion = $currentVersion.Trim()
}

Write-Info "Version actuelle locale : $currentVersion"

# Récupérer version GitHub
Write-Info "Récupération version GitHub..."
try {
    $response = Invoke-WebRequest -Uri $versionUrl -UseBasicParsing -TimeoutSec 30
    $latestVersion = $response.Content.Trim()
    Write-Success "Version GitHub : $latestVersion"
} catch {
    Write-Error "Impossible de récupérer la version depuis GitHub"
    Write-Host "URL: $versionUrl" -ForegroundColor Gray
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Comparer versions
$needsUpdate = $false

if ($Force) {
    Write-Warning "Mode FORCE activé - Installation forcée"
    $needsUpdate = $true
} elseif ($latestVersion -eq $currentVersion) {
    Write-Success "✨ Vous utilisez déjà la dernière version ($currentVersion)"

    if ($CheckOnly) {
        exit 0
    }

    Write-Host ""
    $response = Read-Host "Voulez-vous réinstaller quand même ? (O/N)"
    if ($response -ne "O" -and $response -ne "o") {
        Write-Info "Annulation de l'installation"
        exit 0
    }
    $needsUpdate = $true
} else {
    Write-Warning "Nouvelle version disponible !"
    Write-Host "  Actuelle : $currentVersion" -ForegroundColor Yellow
    Write-Host "  Nouvelle : $latestVersion" -ForegroundColor Green
    $needsUpdate = $true
}

if ($CheckOnly) {
    Write-Info "Mode vérification uniquement (-CheckOnly)"
    exit 0
}

if (-not $needsUpdate) {
    Write-Info "Aucune mise à jour nécessaire"
    exit 0
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📥 TÉLÉCHARGEMENT ET INSTALLATION" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Créer dossier backup
if (-not (Test-Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
}

# Backup de l'ancienne version
if (Test-Path $localFile) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = Join-Path $backupPath "EA_MultiPairs_v${currentVersion}_${timestamp}.mq5"

    Write-Info "Sauvegarde de l'ancienne version..."
    Copy-Item -Path $localFile -Destination $backupFile -Force
    Write-Success "Backup créé : $(Split-Path $backupFile -Leaf)"
}

# Télécharger nouvelle version
Write-Info "Téléchargement de la nouvelle version depuis GitHub..."
Write-Host "  URL: $sourceUrl" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri $sourceUrl -UseBasicParsing -TimeoutSec 60
    $sourceCode = $response.Content

    # Validation basique
    if ($sourceCode.Length -lt 10000) {
        throw "Fichier téléchargé trop petit ($($sourceCode.Length) octets) - Probablement une erreur"
    }

    if (-not $sourceCode.Contains("#property version")) {
        throw "Le fichier téléchargé ne semble pas être un fichier MQL5 valide"
    }

    Write-Success "Téléchargement réussi ($([math]::Round($sourceCode.Length/1024, 2)) KB)"

} catch {
    Write-Error "Échec du téléchargement"
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Sauvegarder le nouveau fichier
Write-Info "Installation du nouveau code source..."
try {
    Set-Content -Path $localFile -Value $sourceCode -Encoding UTF8 -Force
    Write-Success "Fichier installé : $filename"
} catch {
    Write-Error "Impossible d'écrire le fichier"
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Compiler avec MetaEditor
if (Test-Path $metaeditor) {
    Write-Info "Compilation avec MetaEditor..."

    try {
        $logFile = Join-Path $expertPath "compile.log"

        # Lancer compilation
        $process = Start-Process -FilePath $metaeditor `
                                  -ArgumentList "/compile:`"$localFile`"", "/log:`"$logFile`"" `
                                  -Wait -PassThru -NoNewWindow

        if ($process.ExitCode -eq 0) {
            Write-Success "Compilation réussie"

            # Vérifier fichier .ex5 créé
            $ex5File = $localFile -replace '\.mq5$', '.ex5'
            if (Test-Path $ex5File) {
                $ex5Size = (Get-Item $ex5File).Length
                Write-Success "Fichier compilé créé : $([math]::Round($ex5Size/1024, 2)) KB"
            }
        } else {
            Write-Warning "La compilation a retourné le code: $($process.ExitCode)"

            if (Test-Path $logFile) {
                Write-Host ""
                Write-Host "═══ LOG DE COMPILATION ═══" -ForegroundColor Yellow
                Get-Content $logFile | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
                Write-Host "═══════════════════════════" -ForegroundColor Yellow
            }
        }

    } catch {
        Write-Warning "Erreur lors de la compilation : $($_.Exception.Message)"
        Write-Host "Vous devrez compiler manuellement avec MetaEditor" -ForegroundColor Yellow
    }
} else {
    Write-Warning "MetaEditor introuvable - Compilation manuelle nécessaire"
    Write-Host "Ouvrez MetaEditor (F4) et compilez le fichier (F7)" -ForegroundColor Yellow
}

# Sauvegarder la nouvelle version
Set-Content -Path $versionFile -Value $latestVersion -Encoding UTF8 -Force

# Télécharger changelog
Write-Host ""
Write-Info "Récupération du changelog..."
try {
    $changelog = Invoke-WebRequest -Uri $changelogUrl -UseBasicParsing -TimeoutSec 30
    $changelogPath = Join-Path $expertPath "CHANGELOG.txt"
    Set-Content -Path $changelogPath -Value $changelog.Content -Encoding UTF8 -Force
    Write-Success "Changelog sauvegardé : CHANGELOG.txt"
} catch {
    Write-Warning "Impossible de récupérer le changelog"
}

# Résumé final
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ MISE À JOUR INSTALLÉE AVEC SUCCÈS" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Success "Version installée : $latestVersion"
Write-Host ""

Write-Info "Prochaines étapes:"
Write-Host "  1. Ouvrir MetaTrader 5" -ForegroundColor White
Write-Host "  2. Fermer tous les graphiques utilisant l'ancien EA" -ForegroundColor White
Write-Host "  3. Dans Navigateur → Expert Advisors, glisser le nouvel EA" -ForegroundColor White
Write-Host "  4. Vérifier que la version affichée est : $latestVersion" -ForegroundColor White
Write-Host "  5. Tester en compte DÉMO avant production" -ForegroundColor Yellow

# Proposer redémarrage MT5
Write-Host ""
$restart = Read-Host "Voulez-vous fermer MT5 maintenant pour forcer rechargement ? (O/N)"
if ($restart -eq "O" -or $restart -eq "o") {
    Write-Info "Fermeture de MetaTrader 5..."

    Get-Process -Name "terminal64", "terminal" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Arrêt du processus MT5 (PID: $($_.Id))..." -ForegroundColor Gray
        $_.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 2
        if (!$_.HasExited) {
            $_ | Stop-Process -Force
        }
    }

    Write-Success "MT5 fermé - Redémarrez-le manuellement"
}

Write-Host ""
Write-Success "Installation terminée !"
Write-Host ""

# Créer script de vérification rapide
$quickCheckScript = @"
# Quick version check
`$version = (Invoke-WebRequest -Uri '$versionUrl' -UseBasicParsing).Content.Trim()
Write-Host "Version GitHub actuelle : `$version" -ForegroundColor Green
"@

$quickCheckPath = Join-Path $expertPath "check-version.ps1"
Set-Content -Path $quickCheckPath -Value $quickCheckScript -Encoding UTF8 -Force

Write-Info "Script de vérification rapide créé : check-version.ps1"
Write-Host "  Exécutez-le pour vérifier rapidement la version GitHub" -ForegroundColor Gray
Write-Host ""

exit 0
