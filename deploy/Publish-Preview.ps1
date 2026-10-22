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
$number = [int]$Matches[2]
$previewRoot = Join-Path $WebRoot 'ban-tin-moi'
$backupRoot = Join-Path $WebRoot '_preview-backup'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = Join-Path $backupRoot $timestamp

$candidates = @(
    (Join-Path $SourceRoot ("preview\{0}\index.html" -f $Issue)),
    (Join-Path $SourceRoot ("dist\so-{0}-{1}.html" -f $number, $year)),
    (Join-Path $SourceRoot ("BT{0}-{1}-xem-thu.html" -f $Matches[2], $year))
)
$sourceHtml = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $sourceHtml) {
    Write-Host 'Preview source was not found. Checked:' -ForegroundColor Yellow
    $candidates | ForEach-Object { Write-Host " - $_" }
    throw "No preview artifact exists for $Issue. Nothing was changed on IIS."
}

New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
if (Test-Path $previewRoot) {
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
    Copy-Item -Path (Join-Path $previewRoot '*') -Destination $backupDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $previewRoot | Out-Null

# Preview only: replace index.html, leave production root/admin/oauth/web.config untouched.
$target = Join-Path $previewRoot 'index.html'
Copy-Item -Path $sourceHtml -Destination $target -Force

if (-not (Test-Path $target)) {
    throw "Preview deployment failed: $target was not created."
}

$hash = (Get-FileHash -Algorithm SHA256 $target).Hash
Write-Host "Preview deployed: $Issue" -ForegroundColor Green
Write-Host "Source : $sourceHtml"
Write-Host "Target : $target"
Write-Host "SHA256 : $hash"
Write-Host "Backup : $backupDir"
Write-Host 'Production root was not modified.' -ForegroundColor Cyan
