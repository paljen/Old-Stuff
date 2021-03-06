 ## Add entry to trace log variable
function Write-LogFile
{
	param(
	
		[string]$Message
	)

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($(Get-Logfile), $true)
	
	$script:CurrentAction = $Message	
	$Output = "$([DateTime]::Now): $Message"

	$Log.WriteLine($Output)
	$Log.Close()
}

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope global).value
	Split-Path $Invocation.MyCommand.path
}

function Get-ModuleDirectory
{
	join-path $(Get-ScriptDirectory) "\Module\"
}

function Get-Logfile
{
	Join-Path (Get-ScriptLocation) "\TraceLog.log"	
}

#region Set trace and status variables to defaults

	# 0=Success,1=Warning,2=Error
	$ErrorState = 0
	
	# Current error message
	$ErrorMessage = ""
	
	# Last write to log
	$script:CurrentAction = ""
	
	# Delete old log file
	Join-Path (Get-ScriptLocation) "\TraceLog.log" | Remove-Item -ErrorAction SilentlyContinue
	
#endregion

## Add startup details to log
Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

try 
{
	# Import modules if any
	Write-LogFile "Loading modules..."
	#Import-Module -Name (Join-Path $(Get-ModuleDirectory) "Generic.psm1") -Verbose
	
	Write-LogFile "Logic here"
	
	<#
	
	$a = 1
	($a -eq 1)
	{
		Throw "`$a is 1"
	}
	
	#>
}

catch 
{
	$ErrorMessage = $error[0].Exception.Message
	Write-LogFile "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	$ErrorState = 2
}
	
if($ErrorState -lt 2)
{	
	Write-LogFile "[`$ErrorState:$($ErrorState)]"
	Write-LogFile "More Logic"
}

else
{
	Write-LogFile "[`$ErrorState:$($ErrorState)] - Terminating script"
	Exit 1
}