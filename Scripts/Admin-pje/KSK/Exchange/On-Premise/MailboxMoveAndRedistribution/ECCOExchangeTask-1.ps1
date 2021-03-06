#######################################################################################
## Calling the script should be done with one of the 3 following parametersets
##
## No Parameters - Checking DB Status Only:
##
##		EccoExchangeTask.ps1
##
## Parameterset 1 - Checking DB Status, If Healthy, Redistribute Active Databases
##
##		EccoExchangeTask.ps1 redist
##
## Parameterset 2 - Checking DB Status, If Healthy, Move Active Database to a specific server
##
##		EccoExchangeTask.ps1 'computername' move
##


## TraceLog function
function Out-Log ([string]$Message)
{
	$script:CurrentAction = $Message
	$script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
}

## Out-File the TraceLog on Exit
function Finish-Script
{
	param(
		[switch]$Terminate
	)
		
	if($Terminate)
	{
		$script:TraceLog += (Get-Date).ToString() + "`t" + "Script Terminated with [`$Terminate=$($Terminate)] Setting Exitcode to 1" + " `r`n"
		Out-File -FilePath $TraceLogFile -InputObject $script:TraceLog
		Write-Host "`$Terminate=$Terminate, See TraceLog for more details" -ForegroundColor Red
		Exit 1
	}
	
	$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
	Out-File -FilePath $TraceLogFile -InputObject $script:TraceLog
}

function Get-ExDatabaseAvailabilityGroup
{
	try
	{
		Out-Log "Get-DatabaseAvailabilityGroup Servers"
		(Get-DatabaseAvailabilityGroup -ErrorAction Stop).Servers
	}
	catch
	{
		$script:ErrorMessage = $error[0].Exception.Message
		Out-Log "Exception caught during action [$script:CurrentAction]: $script:ErrorMessage"
		Finish-Script -Terminate
	}
}

#region Set trace and status variables to defaults
	[int32]$eState = 1
	$ErrorMessage = ""
	$script:TraceLog = ""
	$script:CurrentAction = ""
	#$script:TraceLogFile = [Environment]::ExpandEnvironmentVariables('%TMP%') + "\Ecco-MailBoxMoveAndRedistribution.log"
	$script:TraceLogFile = "C:\Scripts\MailBoxMoveAndRedistribution.log"
#endregion

## Add startup details to trace log
$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
Out-Log "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

## Importing exchange module
if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available")
{
	Out-Log "Adding Exchange 2010 Snapin" 
    $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
    Import-PSSession $ExSession
}

## Checking what arguments the script was called with
if ($args.Count -eq 0)
{
	Out-Log "Script Called with: [$($args.Count)] arguments"
	[System.Collections.ArrayList]$ComputerName = @()
	[System.Collections.ArrayList]$ComputerName = Get-ExDatabaseAvailabilityGroup
	[String]$MoveActiveMailboxDatabase = ""
	[string]$RedistributeActiveDatabases = ""
}

elseif ($args.Count -eq 1)
{
	if ($args[0] -eq "Redist")
	{
		Out-Log "Script Called with [$($args.Count)] argument: [$($args[0])]"
		[String]$MoveActiveMailboxDatabase = ""
		[string]$RedistributeActiveDatabases = $args[0]
		[System.Collections.ArrayList]$ComputerName = Get-ExDatabaseAvailabilityGroup
	}
	
	else
	{
		Out-Log "Script called with wrong argument: $($args[0]) - expected argument: Redist"
		Finish-Script -Terminate
	}
}
else
{
	if ($args[1] -eq "Move")
	{
		Out-Log "Script Called with [$($args.Count)] arguments: [$($args[0])] , [$($args[1])] "
		[String]$ComputerName = $args[0]
		[String]$MoveActiveMailboxDatabase = $args[1]
		[string]$RedistributeActiveDatabases = ""
	}
	
	else
	{
		Out-Log "Script called with wrong argument: $($args[1]) - expected argument: Move"
		Finish-Script -Terminate
	}
}

$timeout = New-TimeSpan -Seconds 10
$sw = [diagnostics.stopwatch]::StartNew()

while (($sw.elapsed -lt $timeout) -and ($eState -eq 1))
{
    foreach ($Server in $ComputerName)
    {   
		try 
		{
			Out-Log "Get-MailboxDatabaseCopyStatus -Server $Server"
	    	$tmp = (Get-MailboxDatabaseCopyStatus -Server $Server -ErrorAction Stop | where {($_.Status -ne "Healthy" -and $_.status -ne "Mounted") -or ($_.ContentIndexState -ne "Healthy")})
		}
		catch
		{
            $script:ErrorMessage = $error[0].Exception.Message
			Out-Log "Exception caught during action [$script:CurrentAction]: $script:ErrorMessage"
			Finish-Script -Terminate
        }
		
        if ($tmp.count -gt 0)
		{
          $bad = $tmp
		  Out-Log "Get-MailboxDatabaseCopyStatus for $($Server) returned: $($bad.Count) results"
        }
    }
    
	if(!($Computername -eq $null))
	{	
		if (-not $bad)
		{
	        $eState = 0
	        Out-Log "[ErrorState: $($eState)] - Everything is healthy"
			Break;
		}

		else 
		{
	        $bad = $null
			Start-Sleep 2
	        Out-Log "[ErrorState: $($eState)] - Refreshing Status, Time Elapsed$($sw.elapsed)"
	    }
	}
	else
	{
		Out-Log "Something went wrong Computername is empty"
		Finish-Script -Terminate
	}
}

if($eState -eq 0)
{
    if ($RedistributeActiveDatabases -eq "Redist")
	{
        try
		{
        	Out-Log "RedistributeActiveDatabases -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference"
        	#Invoke-Expression "d:\Exchange\Scripts\RedistributeActiveDatabases.ps1 -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference -Confirm:`$false" -ErrorAction stop
        }
        catch
		{
            $script:ErrorMessage = $error[0].Exception.Message
			Out-Log "Exception caught during action [$script:CurrentAction]: $script:ErrorMessage"
			Finish-Script -Terminate
        }
    }
	
    if ($MoveActiveMailboxDatabase -eq "Move")
	{
		try
		{
            Out-Log "MoveActiveMailboxDatabase -Server $($ComputerName)"
			#Move-ActiveMailboxDatabase -Server $ComputerName -ErrorAction Stop
		}
		catch
		{
			$script:ErrorMessage = $error[0].Exception.Message
			Out-Log "Exception caught during action [$script:CurrentAction]: $script:ErrorMessage"
			Finish-Script -Terminate
		}
    }
}

else
{   
    Out-Log "[ErrorState: $($eState)] - DB Status NOT OK, NO ACTION TAKEN"
}

Finish-Script