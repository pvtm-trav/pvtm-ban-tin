#requires -Version 5.1
# Run once in an elevated Windows PowerShell session.
[CmdletBinding()]
param([string]$WorkRoot='C:\BanTinAgent')
$ErrorActionPreference='Stop'
$script=Join-Path $WorkRoot 'Update-BanTin.ps1'
if(-not (Test-Path -LiteralPath $script)) { throw 'Install Update-BanTin.ps1 first' }
$credential=Get-Credential -Message 'Dedicated account with Modify on ban-tin-moi, work folders, and Log on as a batch job'
$action=New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "-NoProfile -NonInteractive -File `"$script`" -Mode Publish -WorkRoot `"$WorkRoot`""
$trigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 5)
$settings=New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 15)
# Created DISABLED: enable after a successful Check under this same account.
$settings.Enabled=$false
Register-ScheduledTask -TaskName 'BanTinAgent-Publish' -Action $action -Trigger $trigger -Settings $settings -User $credential.UserName -Password $credential.GetNetworkCredential().Password -RunLevel Limited -Description 'Publish approved GitHub releases only to C:\Web\bantin\ban-tin-moi' | Out-Null
Write-Host 'Task created DISABLED. Test Check with this account before enabling.'
