param(
    [Parameter(Mandatory=$true)]
    [string]$Issue,

    [string]$WebRoot = 'C:\Web\bantin',
    [string]$SourceRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

if ($Issue -notmatch '^(\d{4})-(\d{2})$') {
    throw "Issue must have format YYYY-NN, e.g. 2026-01"
}

$year = $Matches[1]
$numberText = $Matches[2]
$number = [int]$numberText
$canonicalName = "so-{0}-{1}.html" -f $numberText, $year
$previewRoot = Join-Path $WebRoot 'ban-tin-moi'
$backupRoot = Join-Path $WebRoot '_preview-backup'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = Join-Path $backupRoot $timestamp

$candidates = @(
    (Join-Path $SourceRoot $canonicalName),
    (Join-Path $SourceRoot ("preview\{0}\{1}" -f $Issue, $canonicalName)),
    (Join-Path $SourceRoot ("dist\so-{0}-{1}.html" -f $number, $year)),
    (Join-Path $SourceRoot ("BT{0}-{1}-xem-thu.html" -f $numberText, $year))
)
$sourceHtml = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $sourceHtml) {
    Write-Host 'Preview source was not found. Checked:' -ForegroundColor Yellow
    $candidates | ForEach-Object { Write-Host " - $_" }
    throw "No preview artifact exists for $Issue. Nothing was changed on IIS."
}

New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
New-Item -ItemType Directory -Force -Path $previewRoot | Out-Null

$target = Join-Path $previewRoot $canonicalName
if (Test-Path $target) {
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    Copy-Item -Path $target -Destination (Join-Path $backupDir $canonicalName) -Force
}

# Preview only: deploy the canonical issue filename. Do not replace index.html.
Copy-Item -Path $sourceHtml -Destination $target -Force

if (-not (Test-Path $target)) {
    throw "Preview deployment failed: $target was not created."
}

$hash = (Get-FileHash -Algorithm SHA256 $target).Hash
Write-Host "Preview deployed: $Issue" -ForegroundColor Green
Write-Host "Source : $sourceHtml"
Write-Host "Target : $target"
Write-Host "SHA256 : $hash"
if (Test-Path $backupDir) { Write-Host "Backup : $backupDir" }
Write-Host 'index.html was not modified.' -ForegroundColor Cyan
Write-Host 'Production root was not modified.' -ForegroundColor Cyan
