param(
    [string]$Artifact = (Join-Path (Split-Path -Parent $PSScriptRoot) 'so-01-2026.html')
)
$ErrorActionPreference = 'Stop'
$Expected = 'eab389daebf52de2fef60f05465ee20ac931a43048579a3e88916806be79ebbd'
if (-not (Test-Path $Artifact)) { throw "Missing artifact: $Artifact" }
$Actual = (Get-FileHash -Algorithm SHA256 $Artifact).Hash.ToLowerInvariant()
Write-Host "Expected: $Expected"
Write-Host "Actual  : $Actual"
if ($Actual -ne $Expected) { throw 'BT01 preview artifact SHA256 mismatch. Do not publish.' }
Write-Host 'BT01 preview artifact checksum PASS.' -ForegroundColor Green
