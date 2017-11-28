<#
.SYNOPSIS
	Call runbook to move computer object

.DESCRIPTION
    Call a runbook that moves the computer object to a generic OU based on the computers chassis type, 
    this script is a part of the windows 10 SCCM Task sequence

.NOTES
	Version:		1.0.0
	Author:		    Admin-PJE
	Creation Date:	24/05/2016
	Purpose/Change:	Initial script development
#>

param(
    [String]$ComputerName = "test"
)

$ErrorActionPreference = "STOP"

$password = "76492d1116743f0423413b16050a5345MgB8AHAAdQBCAGwAaQBqAC8ANQBYAHQAZQBwAHQAVwBnAGUAdQBKAHIAUQBzAHcAPQA9AHwAYgA2AGUANwAzADQAMABkAGEANAA3AGMAOAAyADEANQA0ADMAMwBlAGEAOABmADEAMABkADQAYwA3AGUAYQBhAGEAYwAxADUANgA1ADgAOQAxADEAOABlADEAMAA3ADgAYQA1AGIAYgBiAGUAYQBmADUAOQAzADkAYgBlAGMAZgAwADUAMwA0AGYANABiADUAOAAzAGIANwAwADAAZQA2ADkAMwBhADIAMQBmADkANwBhADgAMAA3ADAANwA5AGQA"
$key = "60 243 190 189 12 33 209 178 246 152 202 52 81 161 122 47 88 114 64 20 159 65 34 198 26 150 61 161 40 139 23 119"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("prd\Service-SCORCHRAA", $passwordSecure)

try
{
    $rbServer = "DKHQSCORCH01.PRD.ECCOCORP.NET"
    $sPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # Import modules
    Import-Module $("$sPath\PSLogging\2.5.2\PSLogging.psm1")
    Import-Module $("$sPath\scorch\scorch.psd1")
    
    # Log specific variables
    $sVersion = "1.0.0"
    $sLogName = "AddDA-$ComputerName.log"
    $sLogPath = $env:TEMP
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    # Start and initialize logfile
    Start-Log -LogPath $sLogPath -LogName "$sLogName" -ScriptVersion $sVersion
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tRunning as user $([Environment]::UserDomainName)\$([Environment]::UserName) on host $([environment]::MachineName)"
          
    # Build parameters for Start-SCORunbook Cmdlet
    $params = @{
        WebserverURL = $(New-SCOWebserverURL -ServerName $rbServer)
        RunbookGuid = "c47ba9ad-f377-4dfc-a8fa-e685c95c52e3"
        InputParameters = @{'Computer Name'=$ComputerName}
    }
         
    # Call Orchestrator Runbook
    $retvar = Start-SCORunbook @params -alternateCredentials $cred

    # Write log entries
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tComputerName - $computername"
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`t$retvar.Job - $($retvar.Job.Id)"
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`t$retvar.InputParameters - $($retvar.InputParameters.Values)"   
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`t$retvar.OutputParameters - $($retvar.OutputParameters.Values)"
}
catch
{
    $message = $_.Exception.Message
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tException caught: $message"
    Stop-Log -LogPath $sLogFile
    #Exit 1
}

Stop-Log -LogPath $sLogFile