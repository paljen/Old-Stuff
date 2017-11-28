$password = "76492d1116743f0423413b16050a5345MgB8AEcAeQA0AGgARgA4AG0AcQBRADYAMgBjAEwASABMAFEAZwBuAGIARwBGAGcAPQA9AHwAMgAxADMAYgBkADcAOAA5ADYAZAA0AGQAYQAwAGUAZgBiAGMAMQA2AGQAMgBhADcAZgAxAGQANQAwAGEANwBhADIAZQA4AGQAYgBmADUAZgA4AGQANwA5ADkANgBiADYAZABjADIAMAA3AGUANgAwADAAYwA2AGYAZAA0ADYANAA="
$key = "247 251 152 98 50 211 127 195 213 205 183 186 165 178 211 236 57 37 139 161 223 239 216 211 103 202 90 182 122 79 137 202"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("admin-pje", $passwordSecure)

$script = "C:\Scripts\ECCO\Projects\ActiveDirectory\IAM\TestContext.ps1"

# Import the module (not necessary due to the new module autoloading in PowerShell 3.0)
Import-Module PSScheduledJob
 
$joboption = New-ScheduledJobOption -RunElevated
$triggerAdd = New-JobTrigger -Daily -At $([DateTime]::Now.AddMinutes(60))
$triggerCleanUp = New-JobTrigger -Daily -At $([DateTime]::Now.AddMinutes(90))
 
# Register the job
Register-ScheduledJob -Name PowerShell2 -Trigger $trigger -FilePath $script -ScheduledJobOption $joboption -Credential $cred -ArgumentList @("Pjetestuser","Testgroup","Powershell2")
 
