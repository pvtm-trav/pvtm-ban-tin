param(
    [switch]$Publish,
    [switch]$Reviewed
)
$ErrorActionPreference = 'Stop'
$packageDir = $PSScriptRoot
$manifest = Get-Content (Join-Path $packageDir 'manifest.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$allowedNames = @('so-38-2026.html', 'so-38-2026.pdf')
if ($manifest.issue -ne 'so-38-2026' -or $manifest.files.Count -ne 2) { throw 'Unexpected manifest.' }
foreach ($item in $manifest.files) {
    if ($item.name -notin $allowedNames) { throw 'Unexpected file name.' }
    $source = Join-Path $packageDir $item.name
    if ((Get-FileHash $source -Algorithm SHA256).Hash -ne $item.sha256) { throw "Hash mismatch: $($item.name)" }
}
if (-not $Publish) {
    $stage = 'C:\Apps\pvtm-ban-tin-staging\so-38-2026\' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff')
    New-Item -ItemType Directory -Path $stage | Out-Null
    foreach ($item in $manifest.files) { Copy-Item (Join-Path $packageDir $item.name) $stage }
    Copy-Item (Join-Path $packageDir 'manifest.json') $stage
    Write-Host "STAGED ONLY: $stage"
    Write-Host 'No IIS files changed. Read BAN_GIAO_BT38.md before publishing.'
    return
}
if (-not $Reviewed) { throw 'Source conflicts and missing images require review. Read BAN_GIAO_BT38.md. No publication performed.' }
Import-Module WebAdministration
$site = Get-Website -Name 'bantin.trav.gov.vn'
$webRoot = [Environment]::ExpandEnvironmentVariables($site.PhysicalPath).TrimEnd('\')
if ($webRoot -ine 'C:\Web\bantin') { throw "Unexpected IIS physical path: $webRoot" }
$backup = 'C:\Backups\BanTin\BT38_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff')
New-Item -ItemType Directory -Path $backup | Out-Null
& icacls.exe $backup /inheritance:r /grant:r '*S-1-5-32-544:(OI)(CI)F' '*S-1-5-18:(OI)(CI)F' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Backup folder ACL failed.' }
$records = @()
foreach ($item in $manifest.files) {
    $target = Join-Path $webRoot $item.name
    $existed = Test-Path -LiteralPath $target
    $oldHash = $null
    if ($existed) {
        $oldHash = (Get-FileHash $target -Algorithm SHA256).Hash
        Copy-Item -LiteralPath $target -Destination (Join-Path $backup $item.name)
        if ((Get-FileHash (Join-Path $backup $item.name) -Algorithm SHA256).Hash -ne $oldHash) { throw 'Backup verification failed.' }
    }
    $records += [PSCustomObject]@{ name=$item.name; existed=$existed; oldHash=$oldHash; deployedHash=$item.sha256; applied=$false }
}
$recordPath = Join-Path $backup 'deployment.json'
$records | ConvertTo-Json -Depth 5 | Set-Content $recordPath -Encoding UTF8
Write-Host "BACKUP: $backup"
try {
    foreach ($record in $records) {
        $target = Join-Path $webRoot $record.name
        if ($record.existed) {
            if ((Get-FileHash $target -Algorithm SHA256).Hash -ne $record.oldHash) { throw 'Target changed after backup.' }
        } elseif (Test-Path $target) { throw 'Target appeared after backup.' }
        $temp = Join-Path $webRoot ('.bt38-' + [guid]::NewGuid().ToString('N') + '.tmp')
        try {
            Copy-Item (Join-Path $packageDir $record.name) $temp
            if ((Get-FileHash $temp -Algorithm SHA256).Hash -ne $record.deployedHash) { throw 'Staged hash mismatch.' }
            Move-Item -LiteralPath $temp -Destination $target -Force
            $record.applied = $true
            $records | ConvertTo-Json -Depth 5 | Set-Content $recordPath -Encoding UTF8
        } finally {
            if (Test-Path $temp) { Remove-Item -LiteralPath $temp }
        }
        Write-Host "DEPLOYED: $target"
    }
} catch {
    Write-Warning "Deployment incomplete. Use Rollback-BT38.ps1 with backup $backup"
    throw
}
Write-Host 'No index, web.config, OAuth, firewall or issue 39 changes.'
Write-Host 'Verify HTTPS HTML/PDF and iframe before adding the issue to the index.'
