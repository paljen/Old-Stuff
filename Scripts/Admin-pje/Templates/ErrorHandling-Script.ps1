 ## Add entry to trace log variable
function AppendLog ([string]$Message){
    $script:CurrentAction = $Message
    $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
}

#region Set trace and status variables to defaults
$ErrorState = 0 ## 0=Success,1=Warning,2=Error,3=Critical Error
$ErrorMessage = ""
$script:TraceLog = ""
$script:CurrentAction = ""
$LogFile = 'C:\Scripts\Output\Error.txt'
#endregion

## Add startup details to trace log
$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
AppendLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

try {
	AppendLog "Logic here"
} 
catch {
	$ErrorMessage = $error[0].Exception.Message
	AppendLog "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	$ErrorState = 2
}	
	
if($ErrorState -lt 2){	
	AppendLog "More Logic"
}		

## Record end of activity script process
$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File -FilePath $LogFile -InputObject $script:TraceLog


