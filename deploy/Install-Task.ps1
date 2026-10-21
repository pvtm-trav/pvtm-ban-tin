#requires -Version 5.1
# Run once in an elevated Windows PowerShell session.
[CmdletBinding()]
param([ValidateSet('Preview','Production')][string]$Channel='Preview',
      [string]$WorkRoot='C:\BanTinAgent')
$ErrorActionPreference='Stop'
$script=Join-Path $WorkRoot 'Update-BanTin.ps1'
if(-not (Test-Path -LiteralPath $script)) { throw 'Install Update-BanTin.ps1 first' }
$target=if($Channel -eq 'Production') {'C:\Web\bantin'} else {'C:\Web\bantin\ban-tin-moi'}
$credential=Get-Credential -Message "Dedicated account with Modify on $target, work folders, and Log on as a batch job"
$action=New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -NonInteractive -File `"$script`" -Mode Publish -Channel $Channel -WorkRoot `"$WorkRoot`""
$trigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5)
$settings=New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 15)
# Created DISABLED: enable after a successful Check under this same account.
$settings.Enabled=$false
$taskName="BanTinAgent-$Channel"
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -User $credential.UserName -Password $credential.GetNetworkCredential().Password -RunLevel Limited -Description "BanTin $Channel releases to $target" | Out-Null
Write-Host 'Task created DISABLED. Test Check with this account before enabling.'
