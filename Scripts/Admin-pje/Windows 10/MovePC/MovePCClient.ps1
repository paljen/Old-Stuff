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

$ErrorActionPreference = "STOP"

try
{
    $Computer = $env:COMPUTERNAME
    $rbServer = "DKHQSCORCH01.PRD.ECCOCORP.NET"
    $sPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # Import modules
    Import-Module $("$sPath\PSLogging\2.5.2\PSLogging.psm1")
    Import-Module $("$sPath\scorch\scorch.psd1")
    
    # Log specific variables
    $sVersion = "1.0.0"
    $sLogName = "MovePC-$Computer.log"
    $sLogPath = $env:TEMP
    $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

    # Start and initialize logfile
    Start-Log -LogPath $sLogPath -LogName "$sLogName" -ScriptVersion $sVersion
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tRunning as user $([Environment]::UserDomainName)\$([Environment]::UserName) on host $([environment]::MachineName)"
       
    # Declare Where to move computer objects
    $OUDNDesktop = "OU=DESKTOP GENERIC,OU=COMPUTERS,OU=IT,OU=HQ,OU=DK,OU=ECCO,DC=prd,DC=eccocorp,DC=net"
    $OUDNLaptop = "OU=LAPTOPS GENERIC,OU=COMPUTERS,OU=IT,OU=HQ,OU=DK,OU=ECCO,DC=prd,DC=eccocorp,DC=net"

    Switch ($((Get-WmiObject Win32_SystemEnclosure).ChassisTypes))
    {
        1 {$type = "Desktop"}   # Other, VM
        3 {$type = "Desktop"}   # Desktop (Virtual as well)
        4 {$type = "Desktop"}   # Low Profile Desktop
        6 {$type = "Desktop"}   # Mini Tower
        7 {$type = "Desktop"}   # Tower
        8 {$type = "Notebook"}  # Portable
        9 {$type = "Notebook"}  # Laptop
        10 {$type = "Notebook"} # Notebook
        12 {$type = "Notebook"} # Docking Station
        13 {$type = "Desktop"}  # All in One
        14 {$type = "Notebook"} # Sub Notebook
        21 {$type = "Notebook"} # Peripheral Chassis
        24 {$type = "Desktop"}  # Sealed-Case PC
        default {$type = "Desktop"}
    }

    # Set OUDN String
    Switch ($type)
    {
        Notebook {$OUDN = $OUDNLaptop}
        Desktop {$OUDN = $OUDNDesktop}
    }
   
    # Build parameters for Start-SCORunbook Cmdlet
    $params = @{
        WebserverURL = $(New-SCOWebserverURL -ServerName $rbServer)
        RunbookGuid = "51846fbe-c316-4c2a-91fd-9ae9336ea08c" #"16863fa2-cacb-492b-8fda-dc931dbf4bf7"
        InputParameters = @{'Computer'=$Computer;'NewOUDN'=$OUDN}
        WaitForExit = $true
    }
         
    # Call Orchestrator Runbook
    $retvar = Start-SCORunbook @params

    # Write log entries
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tComputer Chassis type - $type"
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tOrganizational Unit - $OUDN"
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