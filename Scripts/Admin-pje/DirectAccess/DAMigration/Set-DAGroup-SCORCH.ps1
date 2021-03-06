Clear-Host
# Set script parameters from runbook data bus and Orchestrator global variables

$DataBusInput1 = "DK4836"
$DataBusInput2 = "DKHQDC01"

# Initialize result and trace variables
# 	$ResultStatus provides basic success/failed indicator
# 	$ErrorMessage captures any error text generated by script
# 	$Trace is used to record a running log of actions

$ResultStatus = ""
$ErrorMessage = ""
$Trace = (Get-Date).ToString() + "`t" + "Runbook activity script started" + " `r`n"

# Create argument array for passing data bus inputs to the external script session
$argsArray = @()
$argsArray += $DataBusInput1
$argsArray += $DataBusInput2

# Establish an external session (to DC) to ensure 64bit PowerShell runtime using the latest version of PowerShell installed on the DC
$Session = New-PSSession -ComputerName DKHQDC01

# Invoke-Command used to run scriptcode in the external session. Return data are stored in the $ReturnArray variable
$ReturnArray = Invoke-Command -Session $Session -ArgumentList $argsArray  -ScriptBlock {
    
	# Define a parameter to accept each data bus input value. Recommend matching names of parameters and data bus input variables above
    Param(
        [ValidateNotNullOrEmpty()]
        [string]$DataBusInput1,

        [ValidateNotNullOrEmpty()]
        [string]$DataBusInput2
    )
	
    # Function to log activity
    function Out-Log ([string]$Message){
        $script:CurrentAction = $Message
        $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
    }
	
	function Add-ComputerToGroup
	{
		param(
			$Group,
			$ComputerName,
			$Server
		)
		
		try
		{
			Out-Log "`$Computer.OperatingSystem[$($Computer.OperatingSystem)]"
			Out-Log "Add-ADGroupMember -Identity [$Group] -Members [$ComputerName] -Server $($Server) -ErrorAction Stop"
			#Add-ADGroupMember -Identity $Group -Members $ComputerName -Server $Server -ErrorAction Stop
		}
		Catch
		{
	        $ErrorMessage = $error[0].Exception.Message
			$ResultStatus = "Failed"
	        Out-Log "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
		}
	}

	function Remove-ComputerFromGroup
	{
		param(
			$Group,
			$ComputerName,
			$Server
		)
		
		try
		{
			Out-Log "`$Computer.MemberOf[$($Group)]"
			Out-Log "Remove-ADGroupMember -Identity [$Group] -Members [$ComputerName] -Confirm:`$false -Server $($Server) -ErrorAction Stop"
			#Remove-ADGroupMember -Identity $Group -Members $ComputerName -Confirm:$false -Server $Server -ErrorAction Stop
		}
		
		Catch
		{
	        $ErrorMessage = $error[0].Exception.Message
			$ResultStatus = "Failed"
	        Out-Log "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
		}
	}

    # Set external session trace and status variables to defaults
	#region
    	$ResultStatus = ""
    	$ErrorMessage = ""
    	$script:CurrentAction = ""
    	$script:TraceLog = ""
	#endregion

    try 
	{
        # Add startup details to trace log
        Out-Log "Script now executing in external PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process"
        Out-Log "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
		
		# Import module
		Out-Log "Import-Module ActiveDirectory"
		#Import-Module ActiveDirectory
		
		# Set computer and group variables
		#region
		$Computer = Get-ADComputer $DataBusInput1 -Properties MemberOf,OperatingSystem
		$logonsrv = $DataBusInput2
		$oldGroup = "SEC-Pje-Testmailbox"
		$win7Group = "SEC-Pje-Testmailbox2"
		$win8Group = "SEC-Pje-Testmailbox3"	
		#endregion
		
		if($Computer.OperatingSystem -like "Windows 7*")
		{
			Add-ComputerToGroup -Group $win7Group -ComputerName $Computer.SamAccountName -Server $logonsrv
					
			if($($Computer.MemberOf) -match $oldGroup)
			{
				Remove-ComputerFromGroup -Group $oldGroup -ComputerName $Computer.SamAccountName -Server $logonsrv
			}
		}

		elseif($Computer.OperatingSystem -like "Windows 8*")
		{
			Add-ComputerToGroup -Group $win8Group -ComputerName $Computer.SamAccountName -Server $logonsrv
			
			if($($computer.MemberOf) -match $oldGroup)
			{
				Remove-ComputerFromGroup -Group $oldGroup -ComputerName $Computer.SamAccountName -Server $logonsrv	
			}
		}

		else
		{
			throw "`$Computer.OperatingSystem[$($Computer.OperatingSystem)]: No ation taken"
		}
		
		$ResultStatus = "Success"
    }
	
    catch
	{
        # Catch any errors thrown above here, setting the result status and recording the error message to return to the activity for data bus publishing
        $ResultStatus = "Failed"
        $ErrorMessage = $error[0].Exception.Message
        Out-Log "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
    }
	
    finally
	{
        # Adding some additional detail about the outcome to the trace log for return
        if($ErrorMessage.Length -gt 0)
		{
            Out-Log "Exiting external session with result [$ResultStatus] and error message [$ErrorMessage]"
        }
        else
		{
            Out-Log "Exiting external session with result [$ResultStatus]"
        }
    }

    # Return an array of the results.
    $resultArray = @()
    $resultArray += $ResultStatus
    $resultArray += $ErrorMessage
    $resultArray += $script:TraceLog
	return  $resultArray
	
}#End Invoke-Command

# Get the values returned from script session for publishing to data bus
$ResultStatus = $ReturnArray[0]
$ErrorMessage = $ReturnArray[1]
$Trace += $ReturnArray[2]

# Record end of activity script process
$Trace += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File c:\Scripts\tracelog.txt -InputObject $Trace

# Close the external session
Remove-PSSession $Session