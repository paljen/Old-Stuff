function Out-EccoGeWriteToLog
{
    <#
		.SYNOPSIS
			write text to logfile
	
		.DESCRIPTION
			writes normal text to predefined logfile
	
		.EXAMPLE
			Out-EccoGeWriteToLog "Writing to log"
	
	#>

	param([string]$Message)

	$LogFile =  [Environment]::ExpandEnvironmentVariables('%TMP%') + "\eSPTScript.log"
	

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($LogFile, $true)
	
	$Output = "$([DateTime]::Now): $Message"
	
	Write-Host $Output
	
	$Log.WriteLine($Output)
	$Log.Close()

}

function test
{

    $Logfile = (Get-Variable MyInvocation -Scope 1 -ValueOnly).MyCommand.Source -replace ".ps1",".log"
    $logfile

}

test