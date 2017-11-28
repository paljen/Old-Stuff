<#
.SYNOPSIS
	Script to update integration services.

.DESCRIPTION
	The Script compares the local integration service version against the VMM server version. 
    If the local version is less then the VMM server version a orchestrator runbook is triggered 
    that updates the local integration services to the version on the VMM server

.NOTES
	Version:		1.0.0
	Author:			Admin-PJE
	Creation Date:	18/05/16
	Purpose/Change:	Initial Script development - UpdateIntegrationService.ps1
#>

# Stop Script if an exception occour
$ErrorActionPreference = "Stop"

try
{
    # Importing modules
    $parent = Split-Path -Parent $MyInvocation.MyCommand.Definition
    Import-Module $("$parent\scorch\scorch.psd1")
    Import-Module $("$parent\PSLogging\2.5.2\PSLogging.psd1")

    # Log specific variables
    $sVersion = "1.0.0"
    $sLogName = "UpdateIntegrationService.log"
    $sLogFile = Join-Path -Path $env:TEMP -ChildPath $sLogName 

    # Start and initialize logfile UpdateIntegrationService.log
    Start-Log -LogPath $env:TEMP -LogName "$sLogName" -ScriptVersion $sVersion
    Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tRunning as user $([Environment]::UserDomainName)\$([Environment]::UserName) on host $([environment]::MachineName)"
    
    # Check if the server is Virtual
    if($((gwmi -Class win32_computersystem).Model) -eq "Virtual Machine")
    {   
        $update = $false
        
        # Integration services version on the VMM Server
        $isVersion = "6.3.9600.17415"
        [Array]$sVer = $isVersion.Split(".")

        # Integration services version on the localhost
        [Array]$lVer = ((Get-ChildItem "C:\Windows\System32\drivers\vmbus.sys").VersionInfo.ProductVersion).Split(".") -replace " ",""

        # check each minor local version against the VMM version build
        :red for ($i = 0; $i -lt $sVer.count; $i++)
        {             
            if([int]$lver[$i] -lt [int]$sver[$i])
            {
                #Write-Output "$([int]$lver[$i]) -lt $([int]$sver[$i])"
                $update = $true
                break red
            }
            elseif([int]$lver[$i] -eq [int]$sver[$i])
            {
                # if the build is equal continue loop
                Continue
            }
            else
            {
                break red
            }
        }

        if($update)
        {
            # Declare Scorch Runbook information
	        $rbGuid = "418dab2e-1922-4532-b01b-95cc9e176b0a"
	        $rbServer = "DKHQSCORCH01.PRD.ECCOCORP.NET" #"10.129.12.64"
            $rbparams = @{'ServerName'=$env:COMPUTERNAME}
	        $rbWebURL = New-SCOWebserverURL -ServerName $rbServer
            
            Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tClient version is $($lVer -join ".") - update needed"
            Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tStarting Runbook with ID: $($rbGuid) and Parameters: $($rbParams.get_Item('ServerName'))"

            # Call Scorch Runbook and wait for the runbook to finish
            #Start-SCORunbook -webserverURL $rbWebURL -RunbookGuid $rbGuid -InputParameters $rbparams -WaitForExit
        }
        else
        {
            Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tClient version is $($lVer -join ".") - no update needed"
        }
    }

    else
    {
        Throw "System is not a Virtual Machine"
    }
}
catch
{ 
    $message = $_.Exception.Message
	Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tException caught: $message"
	Write-LogInfo -LogPath $sLogFile -Message "$((Get-Date).ToString())`tTerminating script"
}
finally
{
    ## Finalize UpdateIntegrationService.log and exit script
    Stop-Log -LogPath $sLogFile
    Exit
}

## Finalize UpdateIntegrationService.log, StdScript will finish
Stop-Log -LogPath $sLogFile -NoExit
