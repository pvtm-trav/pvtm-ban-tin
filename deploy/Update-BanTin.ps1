#requires -Version 5.1
[CmdletBinding()]
param([ValidateSet('Check','Publish')][string]$Mode='Check',
      [ValidateSet('Preview','Production')][string]$Channel='Preview',
      [string]$WorkRoot='C:\BanTinAgent', [string]$ReleaseTag,
      [string]$ApprovedCommit, [string]$ApprovalPhrase,
      [string]$HealthHost='bantin.trav.gov.vn',
      [ValidateRange(1,65535)][int]$HealthHttpsPort=8443,
      [string]$PublicAddress='113.164.228.22')
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
# Exact user approval is required for each production write, including task runs.
# Construct the Vietnamese phrase without relying on a UTF-8 BOM in PowerShell 5.1.
$requiredApproval='DUY'+[char]0x1EC6+'T XU'+[char]0x1EA4+'T B'+[char]0x1EA2+'N'
if($Mode -eq 'Publish' -and $Channel -eq 'Production') {
    if($ApprovalPhrase -cne $requiredApproval -or $ApprovedCommit -cnotmatch '^[a-f0-9]{40}$' -or -not $ReleaseTag) {
        throw 'Production requires explicit approval phrase, full ApprovedCommit, and ReleaseTag.'
    }
}
if($HealthHost -notmatch '^[a-zA-Z0-9.-]+$') { throw 'Invalid health hostname' }
$parsedAddress=$null
if(-not [Net.IPAddress]::TryParse($PublicAddress,[ref]$parsedAddress) -or $parsedAddress.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetwork) { throw 'Invalid public IPv4 address' }
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$WebRoot='C:\Web\bantin'
$Target=if($Channel -eq 'Production') {$WebRoot} else {Join-Path $WebRoot 'ban-tin-moi'}
$webBase=[IO.Path]::GetFullPath($WebRoot).TrimEnd('\')+'\'
$workBase=[IO.Path]::GetFullPath($WorkRoot).TrimEnd('\')+'\'
if($workBase.StartsWith($webBase,[StringComparison]::OrdinalIgnoreCase)) { throw 'WorkRoot must be outside the website' }
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
    function Test-WebsiteFile([string]$Relative,[string]$ExpectedHash) {
        $prefix=if($Channel -eq 'Production') {'/'} else {'/ban-tin-moi/'}
        $path=$prefix+$Relative+'?bantin_verify='+[guid]::NewGuid().ToString('N')
        foreach($endpoint in @("http://${HealthHost}:80","https://${HealthHost}:$HealthHttpsPort")) {
            $url=$endpoint+$path
            $response=Invoke-WebRequest -Uri $url -UseBasicParsing -MaximumRedirection 0 -Headers @{'Cache-Control'='no-cache';'Accept-Encoding'='identity'} -TimeoutSec 15
            if([int]$response.StatusCode -ne 200) { throw "Health status failed: $url" }
            $stream=$response.RawContentStream; $stream.Position=0
            $sha=[Security.Cryptography.SHA256]::Create()
            try { $actual=([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','').ToLowerInvariant() }
            finally { $sha.Dispose(); $stream.Dispose() }
            if($actual -ne $ExpectedHash) { throw "Health content mismatch: $url" }
            Log "Health OK status=200 sha256=$actual url=$url"
        }
        # A per-request connection override preserves the hostname/SNI and normal
        # certificate validation. It does not edit hosts, DNS, SSL, or IIS bindings.
        $body=Join-Path $session ([guid]::NewGuid().ToString('N')+'.health-body')
        $url='https://'+$HealthHost+$path
        $resolve=$HealthHost+':443:'+$PublicAddress
        $status=(& curl.exe --noproxy '*' --resolve $resolve --connect-timeout 5 --max-time 20 --silent --show-error --fail --header 'Accept-Encoding: identity' --header 'Cache-Control: no-cache' --output $body --write-out '%{http_code}' $url 2>&1 | Out-String).Trim()
        if($LASTEXITCODE -ne 0 -or $status -ne '200') { throw "Public HTTPS failed: $url status=$status" }
        if((Get-FileHash -LiteralPath $body -Algorithm SHA256).Hash.ToLowerInvariant() -ne $ExpectedHash) { throw "Public HTTPS content mismatch: $url" }
        Log "Public HTTPS OK status=200 url=$url"
    }
    function Test-PublishedWebsite {
        foreach($file in @($manifest.files | Where-Object {$_.path -match '^[a-zA-Z0-9_-]+\.html$'})) {
            Test-WebsiteFile $file.path $file.sha256
        }
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
    if($Mode -eq 'Publish' -and $Channel -eq 'Production' -and $ApprovedCommit -cne $manifest.commit) { throw 'Full approved commit mismatch' }
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
    # Detect an unhealthy endpoint before changing any website file.
    $currentIndex=Join-Path $Target 'index.html'
    if(Test-Path -LiteralPath $currentIndex) { Test-WebsiteFile 'index.html' ((Get-FileHash -LiteralPath $currentIndex -Algorithm SHA256).Hash.ToLowerInvariant()) }
    if($Mode -eq 'Check') { Log 'Check complete. Website unchanged; current index health verified.'; return }
    if($changes.Count -eq 0) { Test-PublishedWebsite; Log 'Already matches release; website health verified.'; return }
    $backup=Join-Path $WorkRoot ('backups\'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $backup | Out-Null
    # Preserve and verify the complete website, including protected server files.
    # Rollback below restores only files changed by this particular transaction.
    $snapshot=Join-Path $backup 'website-snapshot'
    New-Item -ItemType Directory -Path $snapshot | Out-Null
    $websiteItems=@(Get-ChildItem -LiteralPath $WebRoot -Recurse -Force)
    if(@($websiteItems | Where-Object {$_.Attributes -band [IO.FileAttributes]::ReparsePoint}).Count) { throw 'Website snapshot contains reparse points' }
    $snapshotFiles=@()
    foreach($item in @($websiteItems | Where-Object {-not $_.PSIsContainer})) {
        $relative=$item.FullName.Substring($WebRoot.TrimEnd('\').Length+1)
        $saved=Join-Path $snapshot $relative
        $hash=(Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $saved) | Out-Null
        Copy-Item -LiteralPath $item.FullName -Destination $saved
        if((Get-FileHash -LiteralPath $saved -Algorithm SHA256).Hash.ToLowerInvariant() -ne $hash) { throw "Snapshot checksum mismatch: $relative" }
        $snapshotFiles+=[pscustomobject]@{path=$relative;sha256=$hash}
    }
    $snapshotFiles | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'snapshot-files.json') -Encoding UTF8
    $journal=@()
    $restoreHashes=@{}
    # Back up every affected file BEFORE changing any destination.
    foreach($change in $changes) {
        $dest=Safe-Path $Target $change.path
        if($change.action -eq 'UPDATE') {
            $restoreHashes[$change.path]=(Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant()
            $saved=Safe-Path $backup $change.path
            New-Item -ItemType Directory -Force -Path (Split-Path $saved -Parent) | Out-Null
            Copy-Item -LiteralPath $dest -Destination $saved
            if((Get-FileHash -LiteralPath $saved -Algorithm SHA256).Hash.ToLowerInvariant() -ne $restoreHashes[$change.path]) { throw "Backup checksum mismatch: $($change.path)" }
        }
        $journal+=$change
    }
    $journal | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'journal.json') -Encoding UTF8
    $restoreHashes | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $backup 'restore-hashes.json') -Encoding UTF8
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
        # Health checks belong to the transaction: any failure triggers rollback.
        Test-PublishedWebsite
    } catch {
        $original=$_; $rollbackErrors=@()
        [array]::Reverse($applied)
        foreach($change in $applied) {
            try {
                $dest=Safe-Path $Target $change.path
                if($change.action -eq 'UPDATE') {
                    Copy-Item -LiteralPath (Safe-Path $backup $change.path) -Destination $dest -Force
                    if((Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash.ToLowerInvariant() -ne $restoreHashes[$change.path]) { throw "Rollback checksum mismatch: $($change.path)" }
                }
                elseif(Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Force }
            } catch { $rollbackErrors+=$_.Exception.Message }
        }
        $result=[ordered]@{status=if($rollbackErrors.Count){'rollback_failed'}else{'rolled_back'};commit=$manifest.commit;tag=$release.tag_name;channel=$Channel;target=$Target;failure=$original.Exception.Message;rollback_errors=$rollbackErrors;time_utc=[DateTime]::UtcNow.ToString('o')}
        $result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'result.json') -Encoding UTF8
        Log "Rollback status=$($result.status) errors=$($rollbackErrors -join '; ')"; throw $original
    }
    Log "Published $($release.tag_name). Backup=$backup"
    [ordered]@{status='published';commit=$manifest.commit;tag=$release.tag_name;channel=$Channel;target=$Target;time_utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $backup 'result.json') -Encoding UTF8
} catch { Write-Error $_; exit 1 }
finally { if($null -ne $lock) { $lock.Dispose() } }
