<#
.DESCRIPTION
  Add user to AD group and schedule a task to remove the user again aften a period of time

.INPUTS
  Group
  GrantedHours
  SamAccountName

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         Palle Jensen
  Creation Date:  29-01-2016
  Purpose/Change: 

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#region 

param(

    [String]$User,
    [String]$Group,
    [String]$ScheduledTask
)

## Set Error Action to Silently Continue, this will supress unhandled error messages
$ErrorActionPreference = "SilentlyContinue"

## Install-Module -Name PSLogging -RequiredVersion 2.5.2
Import-Module PSLogging

#endregion

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#region 

## Script Version
$sScriptVersion = "1.0"

#$sLogPath = $env:temp
$sLogName = "$ScheduledTask-Removed.log"
$sLogPath = "C:\Scripts\ECCO\Projects\ActiveDirectory\IAM"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

## Credentials created with EncryptAutomationAccount.ps1
$password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

$key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

#endregion

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#region

Function Main
{
    ## Initialize LogFile
    Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Write-LogInfo -LogPath $sLogFile -Message "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

    
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
         Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
         Break
    }

    
    Write-LogInfo -LogPath $sLogFile -Message "Script Completed Successfully"
    Stop-Log -LogPath $sLogFile
}

#endregion

Main
