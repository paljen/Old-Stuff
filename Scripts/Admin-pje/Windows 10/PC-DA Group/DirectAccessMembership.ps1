<#
.SYNOPSIS
	Call runbook to add computer object to direct access group

.DESCRIPTION
    Call a runbook that adds the computer object to the direct access security group, 
    this script is a part of the windows 10 SCCM Task sequence

.NOTES
	Version:		1.0.0
	Author:		    Admin-PJE
	Creation Date:	24/05/2016
	Purpose/Change:	Initial script development
#>

$ErrorActionPreference = "STOP"

try
{
    $Computer = $env:COMPUTERNAME
    $rbServer = "DKHQSCORCH01.PRD.ECCOCORP.NET"
    $sPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # Import modules
    Import-Module $("$sPath\PSLogging\2.5.2\PSLogging.psm1")
    Import-Module $("$sPath\scorch\scorch.psd1")
    
    # Declare log specific variables
    $sVersion = "1.0.0"
    $sLogName = "DirectAccessMembership-$Computer.log"
    $sLogPath = $env:TEMP
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    # Start and initialize logfile
    Start-Log -LogPath $sLogPath -LogName "$sLogName" -ScriptVersion $sVersion
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tRunning as user $([Environment]::UserDomainName)\$([Environment]::UserName) on host $([environment]::MachineName)"
         
    $params = @{
        WebserverURL = $(New-SCOWebserverURL -ServerName $rbServer)
        RunbookGuid = "c47ba9ad-f377-4dfc-a8fa-e685c95c52e3" #"16863fa2-cacb-492b-8fda-dc931dbf4bf7" 
        InputParameters = @{'Computer Name'=$Computer}
        WaitForExit = $true
    }
         
    # Call Orchestrator Runbook
    $retvar = Start-SCORunbook @params

    # Write log entries
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`t$retvar.Job - $($retvar.Job.Id)"
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`t$retvar.InputParameters - $($retvar.InputParameters.Values)"   
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`t$retvar.OutputParameters - $($retvar.OutputParameters.Values)"
}
catch
{
    $message = $_.Exception.Message
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tException caught: $message"  
}
finally
{
    Stop-Log -LogPath $sLogFile
}