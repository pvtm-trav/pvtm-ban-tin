#requires -Version 5.1
[CmdletBinding()]
param([ValidateSet('Check','Publish')][string]$Mode='Check',
      [ValidateSet('Preview','Production')][string]$Channel='Preview',
      [string]$WorkRoot='C:\BanTinAgent', [string]$ReleaseTag)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$Target=if($Channel -eq 'Production') {'C:\Web\bantin'} else {'C:\Web\bantin\ban-tin-moi'}
$Repo='pvtm-trav/pvtm-ban-tin'
$headers=@{'User-Agent'='BanTinAgent/1.0'}
New-Item -ItemType Directory -Force -Path $WorkRoot | Out-Null
$lock=$null
try {
    $lock=[IO.File]::Open((Join-Path $WorkRoot 'agent.lock'),'OpenOrCreate','ReadWrite','None')
    foreach($folder in @('downloads','backups','logs')) { New-Item -ItemType Directory -Force -Path (Join-Path $WorkRoot $folder) | Out-Null }
    $log=Join-Path $WorkRoot ('logs\'+(Get-Date -Format 'yyyyMMdd')+'.log')
    function Log([string]$Message) { $line="$(Get-Date -Format o) $Message"; Add-Content -LiteralPath $log -Value $line; Write-Host $line }
    function Get-Json([string]$Url) { Invoke-RestMethod -Uri $Url -Headers $headers -TimeoutSec 60 }
    function Download([string]$Url,[string]$Path) {
        $u=[uri]$Url
        if($u.Scheme -ne 'https' -or $u.Host -ne 'github.com' -or -not $u.AbsolutePath.StartsWith('/'+$Repo+'/releases/download/')) { throw 'Untrusted asset URL' }
        Invoke-WebRequest -Uri $Url -Headers $headers -UseBasicParsing -TimeoutSec 180 -OutFile $Path
    }
    function Safe-Path([string]$Root,[string]$Relative) {
        if($Relative -notmatch '^[a-zA-Z0-9_./-]+$' -or $Relative -match '(^|/)\.\.?(/|$)' -or $Relative.StartsWith('/') -or $Relative.Contains('//')) { throw "Unsafe path: $Relative" }
        if([IO.Path]::GetExtension($Relative).ToLowerInvariant() -notin @('.html','.css','.js','.json','.yml','.png','.jpg','.jpeg','.gif','.svg','.webp','.ico','.pdf','.ttf','.woff','.woff2','.txt')) { throw "Blocked extension: $Relative" }
        $base=[IO.Path]::GetFullPath($Root).TrimEnd('\')+'\'
        $full=[IO.Path]::GetFullPath((Join-Path $base $Relative))
        if(-not $full.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)) { throw 'Path outside target' }
        $probe=$full
        while($probe) {
            if(Test-Path -LiteralPath $probe) {
                if((Get-Item -LiteralPath $probe -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse point blocked: $probe" }
            }
            $parent=Split-Path -Parent $probe
            if($parent -eq $probe) { break }; $probe=$parent
        }
        return $full
    }
    $endpoint='https://api.github.com/repos/'+$Repo+'/releases/latest'
    if($Channel -eq 'Preview' -and -not $ReleaseTag) { $endpoint='https://api.github.com/repos/'+$Repo+'/releases?per_page=30' }
    if($ReleaseTag) { $endpoint='https://api.github.com/repos/'+$Repo+'/releases/tags/'+[uri]::EscapeDataString($ReleaseTag) }
    $response=Get-Json $endpoint
    $release=if($Channel -eq 'Preview' -and -not $ReleaseTag) { @($response | Where-Object { -not $_.draft -and $_.prerelease -and $_.tag_name -match '^preview-[a-f0-9]{40}$' } | Select-Object -First 1)[0] } else { $response }
    if($null -eq $release) { throw 'No matching release' }
    if($Channel -eq 'Production') {
        if($release.draft -or $release.prerelease -or $release.tag_name -notmatch '^bantin-[0-9]{4}\.[0-9]+-[a-f0-9]{12}$') { throw 'Not an approved production release' }
    } elseif($release.draft -or -not $release.prerelease -or $release.tag_name -notmatch '^preview-[a-f0-9]{40}$') { throw 'Not a preview release' }
    $session=Join-Path $WorkRoot ('downloads\'+[guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $session | Out-Null
    $meta=@($release.assets | Where-Object name -eq 'release.json')
    $bundle=@($release.assets | Where-Object name -eq 'bantin-site.zip')
    if($meta.Count -ne 1 -or $bundle.Count -ne 1) { throw 'Release missing package/manifest' }
    Download $meta[0].browser_download_url (Join-Path $session 'release.json')
    $manifest=Get-Content -LiteralPath (Join-Path $session 'release.json') -Raw | ConvertFrom-Json
    $expectedChannel=if($Channel -eq 'Production') {'production'} else {'preview'}
    if($manifest.schema -ne 2 -or $manifest.channel -ne $expectedChannel -or $manifest.commit -notmatch '^[a-f0-9]{40}$' -or $manifest.tag -ne $release.tag_name -or $manifest.zip_sha256 -notmatch '^[a-f0-9]{64}$') { throw 'Invalid manifest' }
    if($Channel -eq 'Preview' -and $release.tag_name -ne ('preview-'+$manifest.commit)) { throw 'Preview commit mismatch' }
    if($Channel -eq 'Production' -and -not $release.tag_name.EndsWith($manifest.commit.Substring(0,12))) { throw 'Approval commit mismatch' }
    $zip=Join-Path $session 'site.zip'; Download $bundle[0].browser_download_url $zip
    if((Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant() -ne $manifest.zip_sha256) { throw 'ZIP checksum mismatch' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $stage=Join-Path $session 'stage'; New-Item -ItemType Directory -Path $stage | Out-Null
    $expected=@{}
    foreach($f in $manifest.files) {
        if($f.path -eq 'web.config' -or $f.path -match '^(admin|ban-tin-moi|oauth)/') { throw "Protected website path: $($f.path)" }
        $null=Safe-Path $stage $f.path
        if($expected.ContainsKey($f.path) -or $f.sha256 -notmatch '^[a-f0-9]{64}$') { throw 'Duplicate path or invalid hash' }
        $expected[$f.path]=$f
    }
    if(-not $expected.ContainsKey('index.html')) { throw 'Missing index.html' }
    $archive=[IO.Compression.ZipFile]::OpenRead($zip)
    try {
        $seen=@{}; $total=0L
        foreach($entry in $archive.Entries) {
            $relative=$entry.FullName
            if(-not $expected.ContainsKey($relative) -or $seen.ContainsKey($relative)) { throw 'Unexpected or duplicate ZIP entry' }
            $total+=$entry.Length
            if($total -gt 536870912) { throw 'Package exceeds 512 MB' }
            $dest=Safe-Path $stage $relative
            New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$dest,$false)
            if((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected[$relative].sha256) { throw "File hash mismatch: $relative" }
            $seen[$relative]=$true
        }
        if($seen.Count -ne $expected.Count) { throw 'Incomplete package' }
    } finally { $archive.Dispose() }
    $changes=@()
    foreach($f in $manifest.files) {
        $dest=Safe-Path $Target $f.path
        if(-not (Test-Path -LiteralPath $dest)) { $changes+= [pscustomobject]@{path=$f.path;action='ADD'} }
        elseif((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant() -ne $f.sha256) { $changes+=[pscustomobject]@{path=$f.path;action='UPDATE'} }
    }
    $changes | Format-Table -AutoSize
    Log "$Mode channel=$Channel commit=$($manifest.commit) tag=$($release.tag_name) changes=$($changes.Count)"
    if($Mode -eq 'Check') { Log 'Check complete. Website unchanged.'; return }
    if($changes.Count -eq 0) { Log 'Already matches release; no changes.'; return }
    $backup=Join-Path $WorkRoot ('backups\'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $backup | Out-Null
    $journal=@()
    # Back up every affected file BEFORE changing any destination.
    foreach($change in $changes) {
        $dest=Safe-Path $Target $change.path
        if($change.action -eq 'UPDATE') {
            $saved=Safe-Path $backup $change.path
            New-Item -ItemType Directory -Force -Path (Split-Path $saved -Parent) | Out-Null
            Copy-Item -LiteralPath $dest -Destination $saved
        }
        $journal+=$change
    }
    $journal | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'journal.json') -Encoding UTF8
    $applied=@()
    try {
        # Publish index last. Preserve all old files absent from this package.
        foreach($change in ($changes | Sort-Object @{Expression={if($_.path -eq 'index.html'){1}else{0}}},path)) {
            $dest=Safe-Path $Target $change.path
            New-Item -ItemType Directory -Force -Path (Split-Path $dest -Parent) | Out-Null
            $applied+=$change
            Copy-Item -LiteralPath (Safe-Path $stage $change.path) -Destination $dest -Force
        }
        foreach($f in $manifest.files) {
            if((Get-FileHash -LiteralPath (Safe-Path $Target $f.path) -Algorithm SHA256).Hash.ToLowerInvariant() -ne $f.sha256) { throw 'Post-copy checksum mismatch' }
        }
    } catch {
        $original=$_; $rollbackErrors=@()
        [array]::Reverse($applied)
        foreach($change in $applied) {
            try {
                $dest=Safe-Path $Target $change.path
                if($change.action -eq 'UPDATE') { Copy-Item -LiteralPath (Safe-Path $backup $change.path) -Destination $dest -Force }
                elseif(Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Force }
            } catch { $rollbackErrors+=$_.Exception.Message }
        }
        Log "Rollback errors: $($rollbackErrors -join '; ')"; throw $original
    }
    Log "Published $($release.tag_name). Backup=$backup"
    # HTTP availability is reported separately; a proxy failure must not undo valid files.
    try {
        $url=if($Channel -eq 'Production') {'https://bantin.trav.gov.vn/'} else {'https://bantin.trav.gov.vn/ban-tin-moi/'}
        $r=Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
        Log "HTTP check: $($r.StatusCode)"
    } catch { Log "HTTP check requires review: $($_.Exception.Message)" }
} catch { Write-Error $_; exit 1 }
finally { if($null -ne $lock) { $lock.Dispose() } }
