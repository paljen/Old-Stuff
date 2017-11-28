
param(
    [String]$User,
    [String]$Group,
    [String]$ScheduledTask
)

$logfile = "C:\Scripts\ECCO\Projects\ActiveDirectory\IAM\DidRun-RemoveFromGroup.txt"
$User | Out-File $logfile
$Group | Out-File $logfile -Append
$ScheduledTask | Out-File $logfile -Append

## Credentials created with EncryptAutomationAccount.ps1
$password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

$key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

try
{
    ## Argument Array for remote session
    $args = @()
    $args += $User
    $args += $Group

    Invoke-Command -ComputerName dkhqdc01 -Credential $cred -ArgumentList $args -ErrorAction Stop {
        Param($User,$Group)
        Remove-ADGroupMember -Identity $Group -Members $User -ErrorAction Stop -Confirm:$false
    }
}

catch
{
    $_.exception.message | Out-File $logfile -Append
}