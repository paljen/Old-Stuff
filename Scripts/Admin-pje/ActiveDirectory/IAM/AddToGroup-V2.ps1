## Credentials
$password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

$key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

$scriptAdd = "C:\Scripts\ECCO\Projects\ActiveDirectory\IAM\RemoveFromGroup.ps1"
#$scriptCleanUp = "C:\Scripts\ECCO\Projects\ActiveDirectory\IAM\CleanUpTasks.ps1"

# Import the module (not necessary due to the new module autoloading in PowerShell 3.0)
Import-Module PSScheduledJob
 
$joboption = New-ScheduledJobOption -RunElevated
$triggerAdd = New-JobTrigger -Daily -At $([DateTime]::Now.AddMinutes(60))
$triggerCleanUp = New-JobTrigger -Daily -At $([DateTime]::Now.AddMinutes(90))

$taskname = 
 
# Register the job
Register-ScheduledJob -Name PowerShellRemove4 -Trigger $triggerAdd -FilePath $scriptAdd -ScheduledJobOption $joboption -Credential $cred -ArgumentList @("Pjetestuser","Testgroup","remove")
#Register-ScheduledJob -Name PowerShellClean4 -Trigger $triggerCleanUp -FilePath $scriptCleanUp -ScheduledJobOption $joboption -Credential $cred -ArgumentList @()

 
