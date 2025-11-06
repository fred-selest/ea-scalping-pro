#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configure une tâche planifiée Windows pour auto-update EA

.DESCRIPTION
    Crée une tâche planifiée qui exécute le script auto-update-ea.ps1
    automatiquement tous les jours à l'heure spécifiée

.PARAMETER Hour
    Heure d'exécution (0-23, défaut: 3 pour 3h du matin)

.PARAMETER TaskName
    Nom de la tâche planifiée (défaut: EA-MultiPaires-AutoUpdate)

.EXAMPLE
    .\setup-scheduled-task.ps1
    Configure tâche à 3h du matin

.EXAMPLE
    .\setup-scheduled-task.ps1 -Hour 2
    Configure tâche à 2h du matin

.NOTES
    Author: fred-selest
    Version: 1.0
    Requires: Droits Administrateur
#>

param(
    [ValidateRange(0,23)]
    [int]$Hour = 3,

    [string]$TaskName = "EA-MultiPaires-AutoUpdate",

    [string]$ScriptPath = $PSScriptRoot
)

# Vérifier droits admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Ce script nécessite des droits Administrateur" -ForegroundColor Red
    Write-Host ""
    Write-Host "Relancez PowerShell en tant qu'Administrateur :" -ForegroundColor Yellow
    Write-Host "  1. Clic droit sur PowerShell" -ForegroundColor Gray
    Write-Host "  2. Exécuter en tant qu'administrateur" -ForegroundColor Gray
    Write-Host "  3. Relancer ce script" -ForegroundColor Gray
    exit 1
}

# Bannière
Write-Host ""
Write-Host "╔═════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🕐 Configuration Tâche Planifiée - EA Auto Update       ║" -ForegroundColor Cyan
Write-Host "╚═════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérifier script principal
$mainScript = Join-Path $ScriptPath "auto-update-ea.ps1"
if (-not (Test-Path $mainScript)) {
    Write-Host "❌ Script principal introuvable : $mainScript" -ForegroundColor Red
    Write-Host ""
    Write-Host "Assurez-vous que auto-update-ea.ps1 est dans le même dossier" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Script principal détecté : $mainScript" -ForegroundColor Green
Write-Host ""

# Configuration
Write-Host "📋 Configuration de la tâche planifiée :" -ForegroundColor Cyan
Write-Host "  Nom de la tâche    : $TaskName" -ForegroundColor White
Write-Host "  Heure d'exécution  : ${Hour}:00 (tous les jours)" -ForegroundColor White
Write-Host "  Script à exécuter  : $mainScript" -ForegroundColor White
Write-Host "  Utilisateur        : SYSTEM (exécution en arrière-plan)" -ForegroundColor White
Write-Host ""

# Confirmer
$confirm = Read-Host "Continuer avec cette configuration ? (O/N)"
if ($confirm -ne "O" -and $confirm -ne "o") {
    Write-Host "❌ Annulation de la configuration" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔧 Création de la tâche planifiée..." -ForegroundColor Cyan

# Supprimer tâche existante si présente
try {
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-Host "⚠️  Tâche existante détectée - Suppression..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "✅ Ancienne tâche supprimée" -ForegroundColor Green
    }
} catch {
    # Pas de tâche existante, continuer
}

# Créer action
$action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$mainScript`""

# Créer déclencheur (tous les jours à l'heure spécifiée)
$trigger = New-ScheduledTaskTrigger -Daily -At "${Hour}:00"

# Configuration des paramètres
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

# Créer principal (SYSTEM account pour exécution sans utilisateur connecté)
$principal = New-ScheduledTaskPrincipal `
    -UserId "SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest

# Créer description
$description = @"
Mise à jour automatique du EA Multi-Paires Scalping Pro depuis GitHub.
- Vérifie la version disponible sur GitHub
- Télécharge et installe si nouvelle version
- Compile automatiquement avec MetaEditor
- Crée des backups de l'ancienne version

Configuration:
- Heure: ${Hour}:00 (quotidien)
- Script: $mainScript
- Créé le: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

# Enregistrer la tâche
try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description $description `
        -Force | Out-Null

    Write-Host ""
    Write-Host "✅ Tâche planifiée créée avec succès !" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "❌ Erreur lors de la création de la tâche" -ForegroundColor Red
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Afficher résumé
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  📅 TÂCHE PLANIFIÉE CONFIGURÉE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Nom de la tâche       : $TaskName" -ForegroundColor White
Write-Host "Prochaine exécution   : Demain à ${Hour}:00" -ForegroundColor White
Write-Host "Fréquence             : Tous les jours" -ForegroundColor White
Write-Host "Compte d'exécution    : SYSTEM" -ForegroundColor White
Write-Host ""

# Proposer test immédiat
Write-Host "🧪 Voulez-vous tester l'exécution immédiatement ? (O/N)" -ForegroundColor Cyan
$test = Read-Host
if ($test -eq "O" -or $test -eq "o") {
    Write-Host ""
    Write-Host "⏳ Lancement du test..." -ForegroundColor Cyan
    Write-Host ""

    try {
        # Exécuter le script directement (pas la tâche planifiée)
        & $mainScript -CheckOnly

        Write-Host ""
        Write-Host "✅ Test terminé - Vérifiez les résultats ci-dessus" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors du test : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Instructions finales
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📋 INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Gestion de la tâche planifiée :" -ForegroundColor White
Write-Host ""
Write-Host "  Visualiser :" -ForegroundColor Yellow
Write-Host "    - Ouvrir 'Planificateur de tâches' Windows" -ForegroundColor Gray
Write-Host "    - Chercher : $TaskName" -ForegroundColor Gray
Write-Host ""
Write-Host "  Tester manuellement :" -ForegroundColor Yellow
Write-Host "    Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
Write-Host ""
Write-Host "  Modifier l'heure :" -ForegroundColor Yellow
Write-Host "    - Planificateur de tâches → $TaskName → Propriétés → Déclencheurs" -ForegroundColor Gray
Write-Host "    - Ou relancer ce script avec : -Hour X" -ForegroundColor Gray
Write-Host ""
Write-Host "  Désactiver temporairement :" -ForegroundColor Yellow
Write-Host "    Disable-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
Write-Host ""
Write-Host "  Réactiver :" -ForegroundColor Yellow
Write-Host "    Enable-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
Write-Host ""
Write-Host "  Supprimer :" -ForegroundColor Yellow
Write-Host "    Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false" -ForegroundColor Gray
Write-Host ""

# Afficher historique des exécutions futures
Write-Host "📊 Pour voir l'historique des exécutions :" -ForegroundColor Cyan
Write-Host "  Get-ScheduledTask -TaskName '$TaskName' | Get-ScheduledTaskInfo" -ForegroundColor Gray
Write-Host ""

# Créer script helper pour gérer la tâche
$helperScript = @"
# Helper Script - Gestion Tâche Planifiée EA Auto-Update

Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Gestion Tâche Planifiée EA Auto-Update            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Récupérer infos tâche
try {
    `$task = Get-ScheduledTask -TaskName '$TaskName' -ErrorAction Stop
    `$info = Get-ScheduledTaskInfo -TaskName '$TaskName'

    Write-Host "✅ Tâche : $TaskName" -ForegroundColor Green
    Write-Host ""
    Write-Host "État             : `$(`$task.State)" -ForegroundColor White
    Write-Host "Dernière exéc.   : `$(`$info.LastRunTime)" -ForegroundColor White
    Write-Host "Résultat dernier : `$(`$info.LastTaskResult)" -ForegroundColor White
    Write-Host "Prochaine exéc.  : `$(`$info.NextRunTime)" -ForegroundColor White
    Write-Host ""

    Write-Host "Actions disponibles :" -ForegroundColor Cyan
    Write-Host "  [1] Exécuter maintenant" -ForegroundColor White
    Write-Host "  [2] Désactiver" -ForegroundColor White
    Write-Host "  [3] Activer" -ForegroundColor White
    Write-Host "  [4] Supprimer" -ForegroundColor White
    Write-Host "  [5] Voir historique" -ForegroundColor White
    Write-Host "  [Q] Quitter" -ForegroundColor White
    Write-Host ""

    `$choice = Read-Host "Votre choix"

    switch (`$choice) {
        "1" {
            Write-Host "⏳ Exécution en cours..." -ForegroundColor Cyan
            Start-ScheduledTask -TaskName '$TaskName'
            Start-Sleep -Seconds 2
            `$newInfo = Get-ScheduledTaskInfo -TaskName '$TaskName'
            Write-Host "✅ Dernière exécution: `$(`$newInfo.LastRunTime)" -ForegroundColor Green
        }
        "2" {
            Disable-ScheduledTask -TaskName '$TaskName' | Out-Null
            Write-Host "✅ Tâche désactivée" -ForegroundColor Green
        }
        "3" {
            Enable-ScheduledTask -TaskName '$TaskName' | Out-Null
            Write-Host "✅ Tâche activée" -ForegroundColor Green
        }
        "4" {
            `$confirm = Read-Host "Confirmer suppression ? (O/N)"
            if (`$confirm -eq "O") {
                Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false
                Write-Host "✅ Tâche supprimée" -ForegroundColor Green
            }
        }
        "5" {
            Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TaskScheduler/Operational'; Id=110,102,201} |
                Where-Object { `$_.Message -like "*$TaskName*" } |
                Select-Object -First 10 TimeCreated, Message |
                Format-Table -Wrap
        }
        default {
            Write-Host "Au revoir !" -ForegroundColor Cyan
        }
    }

} catch {
    Write-Host "❌ Tâche '$TaskName' introuvable" -ForegroundColor Red
    Write-Host "Exécutez setup-scheduled-task.ps1 pour la créer" -ForegroundColor Yellow
}

Write-Host ""
"@

$helperPath = Join-Path $ScriptPath "manage-scheduled-task.ps1"
Set-Content -Path $helperPath -Value $helperScript -Encoding UTF8 -Force

Write-Host "✅ Script de gestion créé : manage-scheduled-task.ps1" -ForegroundColor Green
Write-Host "   Exécutez-le pour gérer la tâche planifiée facilement" -ForegroundColor Gray
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ CONFIGURATION TERMINÉE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Votre EA sera mis à jour automatiquement tous les jours à ${Hour}:00" -ForegroundColor White
Write-Host ""

exit 0
