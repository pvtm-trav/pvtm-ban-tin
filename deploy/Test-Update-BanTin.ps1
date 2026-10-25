#requires -Version 5.1
# All writes and mocked releases stay beneath a unique TEMP directory.
[CmdletBinding()]
param([string]$AgentPath,[string]$OutputPath)
$ErrorActionPreference='Stop'
if(-not $AgentPath) { $AgentPath=Join-Path $PSScriptRoot 'Update-BanTin.ps1' }
$root=Join-Path ([IO.Path]::GetTempPath()) ('BanTinAgent-Tests-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root | Out-Null
if(-not $OutputPath) { $OutputPath=Join-Path $root 'results.json' }
$source=Get-Content -LiteralPath $AgentPath -Raw
$tokens=$null; $parseErrors=$null
$null=[Management.Automation.Language.Parser]::ParseFile($AgentPath,[ref]$tokens,[ref]$parseErrors)
if($parseErrors.Count) { throw ($parseErrors | Out-String) }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Write-Text([string]$Path,[string]$Text) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    [IO.File]::WriteAllText($Path,$Text,(New-Object Text.UTF8Encoding($false)))
}
function Assert([bool]$Condition,[string]$Message) { if(-not $Condition) { throw $Message } }
$invoke=@'
$ErrorActionPreference='Stop'
$global:fixture=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'config.json') -Raw | ConvertFrom-Json
function global:Invoke-RestMethod {
 param($Uri,$Headers,$TimeoutSec)
 Get-Content -LiteralPath (Join-Path $PSScriptRoot 'release-meta.json') -Raw | ConvertFrom-Json
}
function global:Invoke-WebRequest {
 param($Uri,$Headers,$TimeoutSec,$OutFile,$MaximumRedirection,[switch]$UseBasicParsing)
 if($OutFile) {
  $name=if($Uri.EndsWith('release.json')){'manifest.json'}else{'site.zip'}
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $OutFile
  return
 }
 $u=[uri]$Uri
 $relative=$u.AbsolutePath.TrimStart('/')
 if($relative.StartsWith('ban-tin-moi/')) {$relative=$relative.Substring(12)}
 $after=([IO.File]::ReadAllText((Join-Path $global:fixture.target 'index.html')) -eq 'new index')
 if($after -and $global:fixture.scenario -eq 'http500' -and $u.Scheme -eq 'http') {throw 'Simulated HTTP 500'}
 if($after -and $global:fixture.scenario -eq 'httpsFailure' -and $u.Scheme -eq 'https') {throw 'Simulated certificate trust failure'}
 if($after -and $global:fixture.scenario -eq 'timeout') {throw 'Simulated HTTP timeout'}
 $bytes=[IO.File]::ReadAllBytes((Join-Path $global:fixture.target $relative))
 if($after -and $global:fixture.scenario -eq 'stale200') {$bytes=[Text.Encoding]::UTF8.GetBytes('stale 200 page')}
 $stream=New-Object IO.MemoryStream
 $stream.Write($bytes,0,$bytes.Length); $stream.Position=0
 [pscustomobject]@{StatusCode=200;RawContentStream=$stream}
}
function global:curl.exe {
 $items=@($args)
 $body=$items[[array]::IndexOf($items,'--output')+1]
 $u=[uri]$items[-1]
 $relative=$u.AbsolutePath.TrimStart('/')
 if($relative.StartsWith('ban-tin-moi/')) {$relative=$relative.Substring(12)}
 $after=([IO.File]::ReadAllText((Join-Path $global:fixture.target 'index.html')) -eq 'new index')
 if($after -and $global:fixture.scenario -eq 'publicFailure') {Set-Variable LASTEXITCODE 7 -Scope 1; '000'; return}
 $bytes=[IO.File]::ReadAllBytes((Join-Path $global:fixture.target $relative))
 if($after -and $global:fixture.scenario -eq 'publicStale200') {$bytes=[Text.Encoding]::UTF8.GetBytes('stale public page')}
 [IO.File]::WriteAllBytes($body,$bytes)
 Set-Variable LASTEXITCODE 0 -Scope 1
 '200'
}
$parameters=@{Mode=$global:fixture.mode;Channel=$global:fixture.channel;WorkRoot=(Join-Path $PSScriptRoot 'work');ReleaseTag=$global:fixture.tag}
if($global:fixture.approval -ne 'none') {
 $parameters.ApprovalPhrase='DUY'+[char]0x1EC6+'T XU'+[char]0x1EA4+'T B'+[char]0x1EA2+'N'
 $parameters.ApprovedCommit=if($global:fixture.approval -eq 'mismatch'){'b'*40}else{'a'*40}
}
& (Join-Path $PSScriptRoot 'candidate.ps1') @parameters
if(-not $?){exit 1}
'@
$cases=@(
 @{name='check';scenario='normal';mode='Check';channel='Preview';approval='none';success=$true;changed=$false},
 @{name='publish';scenario='normal';mode='Publish';channel='Preview';approval='none';success=$true;changed=$true},
 @{name='rollback-http500';scenario='http500';mode='Publish';channel='Preview';approval='none';success=$false;changed=$false},
 @{name='rollback-https';scenario='httpsFailure';mode='Publish';channel='Preview';approval='none';success=$false;changed=$false},
 @{name='rollback-timeout';scenario='timeout';mode='Publish';channel='Preview';approval='none';success=$false;changed=$false},
 @{name='rollback-stale200';scenario='stale200';mode='Publish';channel='Preview';approval='none';success=$false;changed=$false},
 @{name='rollback-public';scenario='publicFailure';mode='Publish';channel='Preview';approval='none';success=$false;changed=$false},
 @{name='rollback-public-stale200';scenario='publicStale200';mode='Publish';channel='Preview';approval='none';success=$false;changed=$false},
 @{name='production-no-approval';scenario='normal';mode='Publish';channel='Production';approval='none';success=$false;changed=$false},
 @{name='production-wrong-sha';scenario='normal';mode='Publish';channel='Production';approval='mismatch';success=$false;changed=$false}
)
$results=@()
foreach($case in $cases) {
 $dir=Join-Path $root $case.name
 $site=Join-Path $dir 'website'
 $target=if($case.channel -eq 'Production'){$site}else{Join-Path $site 'ban-tin-moi'}
 New-Item -ItemType Directory -Force -Path $target | Out-Null
 Write-Text (Join-Path $site 'index.html') 'production index'
 Write-Text (Join-Path $target 'index.html') 'old index'
 Write-Text (Join-Path $site 'web.config') 'protected config'
 Write-Text (Join-Path $site 'admin/keep.txt') 'protected admin'
 Write-Text (Join-Path $target 'unmanaged.txt') 'keep unmanaged'
 $baseline=@{}
 Get-ChildItem -LiteralPath $site -Recurse -File | ForEach-Object {$baseline[$_.FullName]=Hash $_.FullName}
 $stage=Join-Path $dir 'fixture'
 Write-Text (Join-Path $stage 'index.html') 'new index'
 Write-Text (Join-Path $stage 'so-99-2026.html') 'new issue'
 Write-Text (Join-Path $stage 'assets/new.txt') 'new asset'
 $archive=[IO.Compression.ZipFile]::Open((Join-Path $dir 'site.zip'),[IO.Compression.ZipArchiveMode]::Create)
 try {
  Get-ChildItem -LiteralPath $stage -Recurse -File | ForEach-Object {
   $entryName=$_.FullName.Substring($stage.Length+1).Replace('\','/')
   $null=[IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive,$_.FullName,$entryName)
  }
 } finally {$archive.Dispose()}
 $sha='a'*40
 $tag=if($case.channel -eq 'Production'){'bantin-2026.99-'+$sha.Substring(0,12)}else{'preview-'+$sha}
 $files=@(Get-ChildItem -LiteralPath $stage -Recurse -File | ForEach-Object {[pscustomobject]@{path=$_.FullName.Substring($stage.Length+1).Replace('\','/');sha256=(Hash $_.FullName)}})
 $manifest=@{schema=2;channel=$case.channel.ToLowerInvariant();commit=$sha;tag=$tag;zip_sha256=(Hash (Join-Path $dir 'site.zip'));files=$files}
 Write-Text (Join-Path $dir 'manifest.json') ($manifest | ConvertTo-Json -Depth 5)
 $base='https://github.com/pvtm-trav/pvtm-ban-tin/releases/download/'+$tag+'/'
 $meta=@{draft=$false;prerelease=($case.channel -eq 'Preview');tag_name=$tag;assets=@(@{name='release.json';browser_download_url=$base+'release.json'},@{name='bantin-site.zip';browser_download_url=$base+'bantin-site.zip'})}
 Write-Text (Join-Path $dir 'release-meta.json') ($meta | ConvertTo-Json -Depth 5)
 Write-Text (Join-Path $dir 'config.json') (@{target=$target;scenario=$case.scenario;mode=$case.mode;channel=$case.channel;approval=$case.approval;tag=$tag} | ConvertTo-Json)
 # The only source rewrite redirects the fixed website root to this TEMP case.
 $testSource=$source.Replace("'C:\Web\bantin'",("'"+$site+"'"))
 Assert (-not $testSource.Contains("'C:\Web\bantin'")) 'Unsafe test root'
 Write-Text (Join-Path $dir 'candidate.ps1') $testSource
 Write-Text (Join-Path $dir 'invoke.ps1') $invoke
 try {
  $process=Start-Process powershell.exe -ArgumentList @('-NoProfile','-NonInteractive','-File',('"'+(Join-Path $dir 'invoke.ps1')+'"')) -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $dir 'stdout.txt') -RedirectStandardError (Join-Path $dir 'stderr.txt')
  Assert (($process.ExitCode -eq 0) -eq $case.success) ('Unexpected exit code '+$process.ExitCode+'; '+(Get-Content -LiteralPath (Join-Path $dir 'stderr.txt') -Raw))
  if($case.name -eq 'production-no-approval') {Assert ((Get-Content -LiteralPath (Join-Path $dir 'stderr.txt') -Raw).Contains('Production requires explicit approval')) 'Wrong approval rejection reason'}
  if($case.name -eq 'production-wrong-sha') {Assert ((Get-Content -LiteralPath (Join-Path $dir 'stderr.txt') -Raw).Contains('Full approved commit mismatch')) 'Wrong commit rejection reason'}
  $backups=@(Get-ChildItem -LiteralPath (Join-Path $dir 'work/backups') -Directory -ErrorAction SilentlyContinue)
  if($case.changed) {
   Assert ([IO.File]::ReadAllText((Join-Path $target 'index.html')) -eq 'new index') 'Index not published'
   Assert (Test-Path -LiteralPath (Join-Path $target 'so-99-2026.html')) 'Issue not published'
   Assert ($backups.Count -eq 1) 'Missing backup'
   Assert ([IO.File]::ReadAllText((Join-Path $backups[0].FullName 'index.html')) -eq 'old index') 'Backup changed'
  } else {
   foreach($path in $baseline.Keys){Assert ((Hash $path) -eq $baseline[$path]) ('Baseline changed: '+$path)}
   Assert (-not (Test-Path -LiteralPath (Join-Path $target 'so-99-2026.html'))) 'Added issue was not removed'
   Assert (-not (Test-Path -LiteralPath (Join-Path $target 'assets/new.txt'))) 'Added asset was not removed'
  }
  Assert ([IO.File]::ReadAllText((Join-Path $site 'web.config')) -eq 'protected config') 'Protected config changed'
  Assert ([IO.File]::ReadAllText((Join-Path $site 'admin/keep.txt')) -eq 'protected admin') 'Admin changed'
  Assert ([IO.File]::ReadAllText((Join-Path $target 'unmanaged.txt')) -eq 'keep unmanaged') 'Unmanaged file changed'
  if($case.name.StartsWith('rollback-')) {
   Assert ($backups.Count -eq 1) 'Rollback backup not retained'
   $state=Get-Content -LiteralPath (Join-Path $backups[0].FullName 'result.json') -Raw | ConvertFrom-Json
   Assert ($state.status -eq 'rolled_back') 'Rollback not recorded as complete'
   $savedSnapshot=Get-Content -LiteralPath (Join-Path $backups[0].FullName 'snapshot-files.json') -Raw | ConvertFrom-Json
   Assert ($savedSnapshot.Count -eq $baseline.Count) 'Incomplete website snapshot'
   foreach($entry in $savedSnapshot) {
    Assert ((Hash (Join-Path $backups[0].FullName ('website-snapshot/'+$entry.path))) -eq $entry.sha256) 'Snapshot file changed after rollback'
   }
  }
  $results+=[pscustomobject]@{name=$case.name;passed=$true;agent_exit_code=$process.ExitCode}
 } catch {$results+=[pscustomobject]@{name=$case.name;passed=$false;error=$_.Exception.Message}}
}
$summary=[ordered]@{agent_sha256=(Hash $AgentPath);powershell_version=$PSVersionTable.PSVersion.ToString();test_root=$root;real_website_modified=$false;passed=@($results | Where-Object passed).Count;total=$results.Count;cases=$results}
$summary | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$summary | ConvertTo-Json -Depth 8 -Compress
if($summary.passed -ne $summary.total){exit 1}
