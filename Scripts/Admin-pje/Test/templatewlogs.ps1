
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

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#region 

## Set Error Action to Silently Continue, this will supresses unhandled error messages
$ErrorActionPreference = "SilentlyContinue"

## Import PSLogging Module
## Install-Module -Name PSLogging -RequiredVersion 2.5.2
Import-Module PSLogging

#endregion

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#region 

## Script Version
$sScriptVersion = "1.0"

## Log File Info
$sLogPath = "C:\Temp"
$sLogName = "<filename>"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

<#
## Session Info
$SessionHost = "<FQDN>"
$SessionName = "<name>"
#>

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

Function Main
{

    Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

    Write-LogInfo -LogPath $sLogFile -Message "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

    #Script Execution goes here

    try 
    {
      <#

	  #region Credentials
        
        ## Credentials created with EncryptAutomationAccount.ps1
        $password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
        AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
        wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

        $key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
        $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
        $cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

      #endregion

      #>

      <#
            
      #region Session
            
        ## Create session using Kerberos, Use as PassThru 1 hub
        $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
        Write-LogInfo -LogPath $sLogFile -Message "New Session $($session.Name) on $($session.ComputerName) with Session Id $($session.Id)" -TimeStamp

        ## Create session using CredSSP, Use hub > 1
        $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -Credential $cred -Authentication CredSSP -ErrorAction Stop
        Write-LogInfo -LogPath $sLogFile -Message "New Session $($session.Name) on $($session.ComputerName) with Session Id $($session.Id)" -TimeStamp

        ## Import module within session
        $modulename = '<modulename>'
        Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name $Using:modulename} -ErrorAction Stop
        Write-LogInfo -LogPath $sLogFile -Message "Module $modulename Imported in Session $($session.Name)" -TimeStamp
        
      #endregion

      #>
    }

    Catch
    {
        Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully
    }

    Finally
    {
        ## Cleanup
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
        Write-LogInfo "Session $($session.Name) removed - Script Finished"
    }

    Stop-Log -LogPath $sLogFile

}

#endregion

Main
