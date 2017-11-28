<#
.SYNOPSIS
	Set LineURI for each user in skype for business

.DESCRIPTION
	Traverse users in skype for business, get AD Employeenumber property for each of the 
    users and then set skype lineURI with the employeenumber value

.NOTES
	Version:		1.0.0
	Author:		    Admin-PJE
	Creation Date:	19/05/2016
	Purpose/Change:	Initial script development
#>

# Import Logging module
Import-Module PSLogging

# Declare log specific variables
$sVersion = "1.0.0"
$sLogName = "UCLineURI.log"
$sLogPath = "c:\windows\temp"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

# Start and initialize logfile UCLineURI.log
Start-Log -LogPath $sLogPath -LogName "$sLogName" -ScriptVersion $sVersion
Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tRunning as user $([Environment]::UserDomainName)\$([Environment]::UserName) on host $([environment]::MachineName)"

# Orchestrator credentials
$key = "60 243 190 189 12 33 209 178 246 152 202 52 81 161 122 47 88 114 64 20 159 65 34 198 26 150 61 161 40 139 23 119"
$psw = "76492d1116743f0423413b16050a5345MgB8AHAAdQBCAGwAaQBqAC8ANQBYAHQAZQBwAHQAVwBnAGUAdQBKAHIAUQBzAHcAPQA9AHwAYgA2AGUA`
        NwAzADQAMABkAGEANAA3AGMAOAAyADEANQA0ADMAMwBlAGEAOABmADEAMABkADQAYwA3AGUAYQBhAGEAYwAxADUANgA1ADgAOQAxADEAOABlADEA`
        MAA3ADgAYQA1AGIAYgBiAGUAYQBmADUAOQAzADkAYgBlAGMAZgAwADUAMwA0AGYANABiADUAOAAzAGIANwAwADAAZQA2ADkAMwBhADIAMQBmADkA`
        NwBhADgAMAA3ADAANwA5AGQA"

$pswSec = ConvertTo-SecureString -String $psw -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("prd\Service-SCORCHRAA", $pswSec)

# Proxy SkypeForBusiness module
$session = New-PSSession -ConnectionUri https://dkhquc02n01.prd.eccocorp.net/OcsPowershell -Credential $cred

# The script will hang if no variable is used here
$tmp = Import-PSSession $session

# Get skype users where lineuri has not been set and who is not enterprisevoiceenabled
(Get-CsUser | ? {$_.EnterpriseVoiceEnabled -ne $true -and $_.LineURI -eq ""}).DistinguishedName | ForEach-Object {
    try
    {
        # foreach skype user get AD property employeenumber
        Get-ADUser -Identity $_ -Properties Employeenumber | ForEach-Object {

            # Check if employeenumber is not null and employeenumber match format criteria of minimum 8 digits
            if($_.EmployeeNumber -ne $null -and $_.EmployeeNumber -match "\d{8}\d*")
            {
                #Set lineuri to the employeenumber for the given user
                #Set-CsUser -Identity $_.DistinguishedName -LineURI "tel:+00$($_.Employeenumber)"
                Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tSet-CsUser -Identity $($_.DistinguishedName) -LineURI `"tel:+00$($_.Employeenumber)`""
            }
        }
    }
    catch
    {
        $message = $_.Exception.Message
        Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tException caught: $message"
    }
}

Remove-PSSession $session
Stop-Log -LogPath $sLogFile
