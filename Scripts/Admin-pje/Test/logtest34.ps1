
function int_LogFile
{
    <#
		.SYNOPSIS
			internal function
	
		.DESCRIPTION
			internal function
	
	#>
    
    $Invocation = Get-Variable MyInvocation -Scope 2 -ValueOnly
    $($Invocation.MyCommand.Source -replace ".ps1",".log")
}


function Out-EccoGeWriteToLog
{
     <#
		.SYNOPSIS
			Writes text to logfile
	
		.DESCRIPTION
			Writes normal text to a logfile with the same name in the same location as the calling script
	
		.EXAMPLE
			Out-EccoGeWriteToLog "Writing to log"
	
	#>

	param(

		[string]$Message
	)

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($(int_LogFile), $true)

	$script:CurrentAction = $Message	
	$Output = "$([DateTime]::Now): $Message"
	$Log.WriteLine($Output)
	$Log.Close()
}
	
