
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>

#region Variables, outside execution

#endregion

## Execute in Powershell v3 Process
$var = Powershell {

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#region 

## Set Error Action to Silently Continue, this will supresses unhandled error messages
$ErrorActionPreference = 'SilentlyContinue'

## Import PSLogging module
Import-Module PSLogging

#endregion

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#region 

#Set trace and status variables to defaults

# Success,Warning,Failed
$ErrorState = "Success"

# Current error message
$ErrorMessage = ""
	
## Script Version
$sScriptVersion = "1.0"

## Log File Info
$sLogPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$sLogName = "<filename>"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#endregion

#-----------------------------------------------------------[Functions]------------------------------------------------------------
#region
<#
Function <FunctionName> 
{
    Param ()

    Begin 
    {
        Write-LogInfo -LogPath $sLogFile -Message "<description of what is going on>..."
    }

    Process 
    {
        Try 
        {
            <code goes here>
        }

        Catch 
        {
            Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
            Break
        }
    }

    End 
    {
        If ($?) #$? Contains the success/fail status of the last statement 
        {
            Write-LogInfo -LogPath $sLogFile -Message "Completed Successfully."
            Write-LogInfo -LogPath $sLogFile -Message " "
        }
    }
}
#>
#endregion

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#region

function Main
{
    ## Initializing Logs
    Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    Write-LogInfo -LogPath $sLogFile -Message "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

    try 
    {
	  #region Variables

        ## Session specific variables
        $sessionHost = "dkhqvmtst02.prd.eccocorp.net"
        $sessionName = "HyperV"

        ## Other Specific variables
        $vm = "VHDBuild2012"

      #endregion
      
      #region Credentials
        
        ## Credentials created with EncryptAutomationAccount.ps1
        $password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
        AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
        wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

        $key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
        $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
        $cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

      #endregion

      #region Session
        
        ## Test if a Session with the same name is available and remove it
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession

        ## Option 1: Create session using Kerberos, Use as PassThru 1 hub
        $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
        Write-LogInfo -LogPath $sLogFile -Message "New Session $($session.Name) on $($session.ComputerName) with Session Id $($session.Id)" -TimeStamp

        ## Option 2: Create session using CredSSP, Use hub > 1
        $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -Credential $cred -Authentication CredSSP -ErrorAction Stop
        Write-LogInfo -LogPath $sLogFile -Message "New Session $($session.Name) on $($session.ComputerName) with Session Id $($session.Id)" -TimeStamp

        ## Import module within session
        $modulename = '<modulename>'
        Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name $Using:modulename} -ErrorAction Stop
        Write-LogInfo -LogPath $sLogFile -Message "Module $modulename Imported in Session $($session.Name)" -TimeStamp
        
      #endregion

      <execution code goes here>
    }

    Catch
    {
        Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
        $ErrorState = "Failed"
    }

    Finally
    {
        ## Cleanup
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
        Write-LogInfo "Session $($session.Name) removed - Script Finished"
    }

    Stop-Log -LogPath $sLogFile

    ## return array from powershell v3 process
    $returnArray = @()
    $returnArray += $ErrorState
    $returnArray += $ErrorMessage
    return $returnArray
}

#endregion

main

} ##End Powershell v3 Process

## ReturnData to the Databus
$ErrorState = $Var[0]
$ErrorMessage = $var[1]