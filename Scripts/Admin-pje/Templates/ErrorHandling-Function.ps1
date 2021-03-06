 # Define function to add entry to trace log variable
function AppendLog ([string]$Message)
{
    $script:CurrentAction = $Message
    $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
}

Function verb-noun
{
	[CmdletBinding()]
	
	PARAM(
	)

	## Set external session trace and status variables to defaults
	$ErrorState = 0 ## 0=Success,1=Warning,2=Error,3=Critical Error
	$ErrorMessage = ""
	$script:TraceLog = ""
	$script:CurrentAction = ""
	$LogFile = 'C:\Scripts\Output\Error.txt'
	$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"

	## Add startup details to trace log
    AppendLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

	foreach ($computer in $computername) {
	
		$ErrorState = 0 
			
		try {
			AppendLog "Doing some action"
			$os = gwmi -ComputerName $computer -Class Win32_ComputerSystem -ErrorAction Stop
		} 
		catch {
    		$ErrorMessage = $error[0].Exception.Message
    		AppendLog "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
			$ErrorState = 2
		}	
	}
			
	if($ErrorState -lt 2){	
		## rest of the code
	}		

	## Record end of activity script process
	$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
	Out-File -FilePath $LogFile -InputObject $script:TraceLog
}

verb-noun -Computername 123,Localhost

