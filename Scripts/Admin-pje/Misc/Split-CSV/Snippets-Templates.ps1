$Template1 = @'
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS <Input>
  <inputs if any, otherwise state None>

.OUTPUTS Log File
  <outputs if any, otherwise state None>

.NOTES
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>

workflow Verb-Noun 
{
    Param 
    (
        # Param1 description
        [Parameter(Mandatory=$true)]
        [String]$Param1,

        # Param2 description
        [Parameter(Mandatory=$true)]
        [String]$Param2
    )

	# Stop script if an exception occour
	$ErrorActionPreference = "Stop"

    # Local credentials used on-prem (Azure Automation Credential Asset)
    $cred = Get-AutomationPSCredential -Name 'Service-SCORCHRAA'
	
	# Remote computer (Azure Automation Variable Asset)
	$dc = Get-AutomationVariable -Name 'DomainController'

	# Execute on remote computer
    $result = InlineScript
	{
		## Do Stuff
		       
    } -PSComputerName $dc -PSCredential $cred

    Write-Output $result
}
'@
New-IseSnippet -Force -Title "ECCO sTemplate (Azure Workflow - Hybrid Worker)" -Description "Runbook Azure - Hybrid Worker" -Author "Palle Jensen" -Text $Template1

$Template2 = @'
## For Orchestrator Runbook v3 encapsulate script in the following
#$var = Powershell {}

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
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>

Param(

)

## Set Error Action to Stop to catch errors 
$ErrorActionPreference = "Stop"

## User-defined Variables
$sScriptVersion = "1.0"
$sLogName = "test.log"
$sLogFile = Join-Path -Path $env:TEMP -ChildPath $sLogName

Function Write-LogFile
{
    [CmdletBinding()]

	param(

        [Parameter(Position=0)]
        [string]$Message

	)
    
    $Output = "$([DateTime]::Now): $Message"

	[System.IO.StreamWriter]$Log = New-Object System.IO.StreamWriter($sLogFile, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

Function New-FunctionName 
{
    Param (
    
    )

    Begin 
    {
        Write-LogFile "<description of what is going on>..."
    }

    Process 
    {
        Try 
        {
            ## Do Stuff
        }

        Catch 
        {
            $ErrorMessage = $error[0].Exception.Message
	        Write-LogFile "Exception caught: $ErrorMessage" -Trace
            Break
        }
    }

    End 
    {
        If ($?) #$? Contains the success/fail status of the last statement 
        {
            Write-LogFile "Completed Successfully."
        }
    }
}

Function Main
{
    ## Initializing Logs
    Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

    ## Do Stuff
}

Main
'@
New-IseSnippet -Force -Title "ECCO sTemplate (Simple w/ Logging Function)" -Description "Basic script template including logging" -Author "Palle Jensen" -Text $Template2

$Template3 = @'
## For Orchestrator Runbook v3 encapsulate script in the following
#$var = Powershell {}

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
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>


Param(

)

## Set Error Action to Stop to catch errors 
$ErrorActionPreference = "Stop"

## If module is not present use PowerShellGet, Install-Module -Name PSLogging -RequiredVersion 2.5.2 (WMF 5.0)
Import-Module PSLogging

## User-defined Variables
$sScriptVersion = "1.0"
$sLogName = "test.log"
$sLogFile = Join-Path -Path $env:TEMP -ChildPath $sLogName

Function New-FunctionName 
{
    Param (
    
    )

    Begin 
    {
        Write-LogInfo -LogPath $sLogFile -Message "<description of what is going on>..."
    }

    Process 
    {
        Try 
        {
            ## Do Stuff
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

Function Main
{
    Start-Log -LogPath $env:TEMP -LogName $sLogName -ScriptVersion $sScriptVersion
    Write-LogInfo -LogPath $sLogFile -Message "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

    ## Do Stuff
   
    Stop-Log -LogPath $sLogFile
}

Main
'@
New-IseSnippet -Force -Title "ECCO sTemplate (Simple w/ Logging Module)" -Description "Basic script template including logging" -Author "Palle Jensen" -Text $Template3

$Template4 = @'
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
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>

## Input from runbook
Param(
    
    $DataBusInput1 = "<Variable>",
    $DataBusInput2 = "<Variable>"
)

## Set Error Action to Silently Continue, this will supresses unhandled error messages
$ErrorActionPreference = "SilentlyContinue"

## User-defined Variables

## Logging information
$sScriptVersion = "1.0"
$sLogName = "<filename>.log"
$sLogFile = Join-Path -Path $env:TEMP -ChildPath $sLogName
$sLogText = (Get-Date).ToString() + "`t" + "Runbook activity script started" + " `r`n"

## Used as return data
$sResultStatus = ""
$sErrorMessage = ""

# Create argument array for passing data bus inputs to the external script session
$argsArray = @()
$argsArray += $DataBusInput1
$argsArray += $DataBusInput2

# Establish an external session (to DC) to ensure 64bit PowerShell runtime using the latest version of PowerShell installed on the DC
$session = New-PSSession -ComputerName dkhqdc01

Function Main
{
    # Invoke-Command used to run scriptcode in the external session. Return data are stored in the $ReturnArray variable
    $returnArray = Invoke-Command -Session $session -ArgumentList $argsArray  -ScriptBlock {
    
	    # Define a parameter to accept each data bus input value. Recommend matching names of parameters and data bus input variables above
        Param(
            [ValidateNotNullOrEmpty()]
            [string]$DataBusInput1,

            [ValidateNotNullOrEmpty()]
            [string]$DataBusInput2
        )
	
        # Function to log activity
        function Write-LogFile ([string]$rMessage){
            $rLogText += ((Get-Date).ToString() + "`t" + $rMessage + " `r`n")
            return $rLogText
        }

        try 
	    {
            # Add startup details to trace log
            Write-LogFile "Script now executing in external PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process"
            Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
		
            ## <code goes here>

		    $rResultStatus = "Success"
        }
	
        catch
	    {
            $rResultStatus = "Failed"
            $rErrorMessage = $error[0].Exception.Message
            Write-LogFile "Exception caught: $rErrorMessage"
        }
	
        # Return an array of the results.
        $resultArray = @()
        $resultArray += $rResultStatus
        $resultArray += $rErrorMessage
        $resultArray += $rLogText
        return $resultArray
    }

    # Get the values returned from script session for publishing to data bus
    $sResultStatus = $ReturnArray[0]
    $sErrorMessage = $ReturnArray[1]
    $sLogText += $ReturnArray[2]

    # Record end of activity script process
    $sLogText += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
    $sLogText | Out-File $sLogFile

    # Close the external session
    Remove-PSSession $Session
}

Main
'@
New-IseSnippet -Force -Title "ECCO sTemplate (Orchestrator Runbook v2 - Remote Execution)" -Description "Runbook to execute in powershell v2" -Author "Palle Jensen" -Text $Template4



