$var = Powershell{

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

## Set Error Action to Silently Continue, this will supress unhandled error messages
$ErrorActionPreference = "SilentlyContinue"

## Install-Module -Name PSLogging -RequiredVersion 2.5.2
Import-Module PSLogging

## Import the module (not necessary due to the new module autoloading in PowerShell 3.0)
Import-Module PSScheduledJob

#endregion

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#region 

## Script Version
$sScriptVersion = "1.0"

## ScheduledTask to remove the user after x hours
$group = "TestGroup"
$grantedHours = 1
$samAccountName = ("pje").ToUpper()
$script = "C:\Scripts\ECCO\Projects\ActiveDirectory\IAM\RemoveGroupAccess.ps1"
$taskName = "AccessToken-$($SamAccountName)-$([guid]::NewGuid().guid.replace('-',''))"

#$sLogPath = $env:temp
$sLogName = "$TaskName.log"
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

#-----------------------------------------------------------[Functions]------------------------------------------------------------
#region

Function New-EccoScheduledTask 
{
    Param (
    
        [String]$TaskName,
        [String]$SamAccountName,
        [String]$Group,
        [Int]$Hours
    )

    Begin 
    {
        Write-LogInfo -LogPath $sLogFile -Message "Creating Scheduled Task:"
    }

    Process 
    {
        Try 
        {
            $O = New-ScheduledJobOption -RunElevated
            $T = New-JobTrigger -Daily -At $([DateTime]::Now.AddMinutes($Hours))
            Register-ScheduledJob -Name $taskName -Trigger $T -FilePath $script -ScheduledJobOption $O -Credential $cred -ArgumentList @($SamAccountName,$Group,$TaskName)

            Write-LogInfo -LogPath $sLogFile -Message "Schedule taskname - $TaskName"
            Write-LogInfo -LogPath $sLogFile -Message "Schedule trigger time - $([DateTime]::Now.AddMinutes($Hours))"
            Write-LogInfo -LogPath $sLogFile -Message "Schedule trigger action - $script"

        }

        Catch 
        {
            Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
            Break
        }
    }
}

Function Add-EccoADGroupMember 
{
    Param (
    
        [String]$SamAccountName,
        [String]$Group
    )

    Begin 
    {
        Write-LogInfo -LogPath $sLogFile -Message "Granting access to user $SamAccountName on group $Group"
    }

    Process 
    {
        $args = @()
        $args += $SamAccountName
        $args += $Group

        Try 
        {
            $result = Invoke-Command -ComputerName dkhqdc01 -Credential $cred -ArgumentList $args -ErrorAction Stop {
                Param($SamAccountName,$Group)
                if(((Get-ADGroupMember -Identity $Group).SamAccountName) -inotcontains $SamAccountName)
                {
                    Add-ADGroupMember -Identity $Group -Members $SamAccountName -ErrorAction Stop
                    return $true
                }
                else
                {
                    return $false
                }
            }

           $result      
        }

        Catch 
        {
            Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
            Break
        }
    }
}
#>
#endregion

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#region

Function Main
{
    ## Initialize LogFile
    Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Write-LogInfo -LogPath $sLogFile -Message "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

    ## Invoke groupmembership
    $member = Add-EccoADGroupMember -Group $Group -SamAccountName $SamAccountName

    if($member)
    {
        ## Schedule task for removel of groupmembership
        New-EccoScheduledTask -TaskName $TaskName -Group $Group -SamAccountName $SamAccountName -Hours $GrantedHours    
    }
    else
    {
        Write-LogError -LogPath $sLogFile -Message "The user $SamAccountName is already member of $Group"
    }
    
    Write-LogInfo -LogPath $sLogFile -Message "Script Completed Successfully"
    Stop-Log -LogPath $sLogFile
}

#endregion

Main

}