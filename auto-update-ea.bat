@echo off
REM ============================================
REM  EA Multi-Paires - Auto Update depuis GitHub
REM  Lanceur Windows pour script PowerShell
REM ============================================

title EA Multi-Paires Auto Update

echo.
echo ========================================
echo   EA Auto Update - Lanceur
echo ========================================
echo.

REM Vérifier si PowerShell est disponible
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] PowerShell introuvable
    echo.
    echo PowerShell est requis pour ce script.
    echo Verifiez votre installation Windows.
    pause
    exit /b 1
)

REM Chemin du script PowerShell
set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%auto-update-ea.ps1

REM Vérifier si le script existe
if not exist "%PS_SCRIPT%" (
    echo [ERREUR] Script PowerShell introuvable
    echo.
    echo Fichier attendu : %PS_SCRIPT%
    pause
    exit /b 1
)

echo [INFO] Lancement du script PowerShell...
echo.

REM Exécuter le script PowerShell avec bypass de la politique d'exécution
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%"

REM Capturer le code de sortie
set EXIT_CODE=%ERRORLEVEL%

echo.
if %EXIT_CODE% EQU 0 (
    echo [SUCCESS] Script termine avec succes
) else (
    echo [AVERTISSEMENT] Le script a retourne le code: %EXIT_CODE%
)

echo.
echo Appuyez sur une touche pour fermer...
pause >nul

exit /b %EXIT_CODE%
