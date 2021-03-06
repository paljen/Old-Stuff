 ## Add entry to trace log variable
function Out-Log ([string]$Message)
{
    $script:CurrentAction = $Message
    $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
}

function Get-ScriptLocation
{
	$Invocation = (Get-Variable MyInvocation -Scope global).value
	Split-Path $Invocation.MyCommand.path
}

## Out-File the TraceLog on Exit
function Exit-Script
{
	$script:TraceLog += (Get-Date).ToString() + "`t" + "Script Terminated with Exitcode 1" + " `r`n"
	Out-File -FilePath $script:TraceLogFile -InputObject $script:TraceLog
	Write-Host "Script Terminated, See TraceLog for more details" -ForegroundColor Red
	Exit 1
}

#region Set trace and status variables to defaults
	$ErrorState = 0 ## 0=Success,1=Warning,2=Error,3=Critical Error
	$ErrorMessage = ""
	$script:TraceLog = ""
	$script:CurrentAction = ""
	$script:TraceLogFile = Join-Path (Get-ScriptLocation) "\TraceScript.log"
#endregion

## Add startup details to trace log
$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
Out-Log "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

try 
{
	Out-Log "Logic here"
	$a = 1
	if ($a -eq 1)
	{
		Throw "`$a is not 1"
	}
}

catch 
{
	$ErrorMessage = $error[0].Exception.Message
	Out-Log "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	$ErrorState = 2
}	
	
if($ErrorState -lt 2){	
	Out-Log "More Logic"
}		

## Record end of activity script process
$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File -FilePath $script:TraceLogFile -InputObject $script:TraceLog