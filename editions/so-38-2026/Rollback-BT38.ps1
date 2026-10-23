param([Parameter(Mandatory=$true)][string]$BackupDir)
$ErrorActionPreference = 'Stop'
$records = @(Get-Content (Join-Path $BackupDir 'deployment.json') -Raw -Encoding UTF8 | ConvertFrom-Json)
$webRoot = 'C:\Web\bantin'
$allowedNames = @('so-38-2026.html', 'so-38-2026.pdf')
foreach ($r in $records) {
    if ($r.name -notin $allowedNames) { throw 'Unexpected file name in backup record.' }
    if (-not $r.applied) { continue }
    $target = Join-Path $webRoot $r.name
    if (-not (Test-Path $target)) { throw "Target missing, inspect before rollback: $target" }
    if ((Get-FileHash $target -Algorithm SHA256).Hash -ne $r.deployedHash) { throw "Target changed since deployment: $target" }
    if ($r.existed) {
        $source = Join-Path $BackupDir $r.name
        if ((Get-FileHash $source -Algorithm SHA256).Hash -ne $r.oldHash) { throw 'Backup hash mismatch.' }
    }
}
foreach ($r in $records) {
    if (-not $r.applied) { continue }
    $target = Join-Path $webRoot $r.name
    if ($r.existed) {
        Copy-Item -LiteralPath (Join-Path $BackupDir $r.name) -Destination $target -Force
    } else {
        Remove-Item -LiteralPath $target
    }
    Write-Host "ROLLED BACK: $target"
}
Write-Host 'Only issue 38 HTML/PDF handled. No IIS configuration restored.'
