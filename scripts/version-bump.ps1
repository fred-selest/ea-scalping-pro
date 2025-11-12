# version-bump.ps1 - Bump version in all files (PowerShell)

param(
    [Parameter(Mandatory=$true)]
    [string]$NewVersion
)

Write-Host "Bumping version to $NewVersion..."

# Update VERSION.txt
Set-Content -Path "VERSION.txt" -Value $NewVersion

# Update EA file #property version
$content = Get-Content "EA_MultiPairs_Scalping_Pro.mq5" -Raw
$content = $content -replace '#property version\s+"[^"]*"', "#property version   `"$NewVersion`""
$content = $content -replace '#define CURRENT_VERSION\s+"[^"]*"', "#define CURRENT_VERSION `"$NewVersion`""
Set-Content -Path "EA_MultiPairs_Scalping_Pro.mq5" -Value $content -NoNewline

Write-Host "✅ Version bumped to $NewVersion"
