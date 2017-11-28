
New-IseSnippet -Force -Title "ECCO Basic Script" -Description "Basic script template including logging" -Author "Palle Jensen" -CaretOffset 100 -Text '
# ------------------------------------------------------------------------
# NAME: 
# Untitled
#
# AUTHOR: 
# Name, Ecco Shoes A/S
# 
# DATE: 
# 01/08/2015
#
# COMMENTS: 
# Descripe the basics of the script
#
# CHANGES:
# 02/08/2015, Version 2, Minor function based changes etc. 
#
# ---------------------------------------------------------------------

#region Variables

#------------------------------------------------------------
# Declaring Variables
#------------------------------------------------------------
#
# Path to logfile set to where the script i called
$LogPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
#
# Session specific variables
$SessionHost = "dkhqvmtst02.prd.eccocorp.net"
$SessionName = "HyperV"
#
# Other Specific variables
#
#------------------------------------------------------------

#endregion
	
#region Functions

## Write-Logfile, Used with -Trace switch - writes to a tracelog
function Write-LogFile
{
    [CmdletBinding()]

	param(

        [Parameter(Position=0)]
        [string]$Message,
        [Switch]$Trace
		
	)
    
    if($Trace)
    {
        $Log = "$LogPath\Trace.log"
	    $Output = "$([DateTime]::Now): $Message"
    }

    else
    {
        $Log = "$LogPath\Output.log"
        $output = $Message
    }

	[System.IO.StreamWriter]$Log = New-Object System.IO.StreamWriter($Log, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

function Main
{
    ## Initializing Logs
    Write-LogFile "-------------------------------------------------Execution---------------------------------------------------"
    Write-LogFile "-------------------------------------------------Execution---------------------------------------------------" -Trace
    Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace
    Write-LogFile "Executing commands in order.." -Trace

    try 
    {
	  #region Credentials
        
        ## Credentials created with EncryptAutomationAccount.ps1
        $password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
        AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
        wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

        $key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
        $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
        $cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

      #endregion
      
      #region Session

        ## Test if a Session with the same name is available and remove it
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
            
        ## Create session on with kerberos
        Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
        $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
        Write-LogFile "Session Created on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"

        ## Get active cluster node from session
        $clusterNode = Invoke-Command –Session $session -ScriptBlock {(Get-WmiObject -Class win32_computersystem).Name}

        ## Remove cluster session 
        Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
        Write-LogFile "Session $($session.Name) removed - Script Finished"
                
        ## Overwriting session string with active cluster node
        $sessionHost = "$clusterNode.prd.eccocorp.net"

        ## Create new session with Authentication CredSSP
        Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
        $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -Credential $cred -Authentication CredSSP -ErrorAction Stop
        Write-LogFile "Session created on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"

        ## Import Hyper-V module within session
        Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name Hyper-V}

      #endregion

      #region Logic
        ## Starting monitoring
        Write-LogFile "Monitor-VM -VMName $vm -SessionName $sessionName -ErrorAction Stop" -Trace
        Write-LogFile "Monitoring VM $vm"
        #Monitor-VMImage -VMName $vm -SessionName $sessionName -ErrorAction Stop
        Write-LogFile "No more VMs to monitor - Finalizing script"
      #endregion
    }

    Catch
    {
        $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught: $ErrorMessage" -Trace
    }

    Finally
    {
        ## Remove the open session used
        Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
        Write-LogFile "Session $($session.Name) removed - Script Finished"
    }
}

#endregion

main
'

New-IseSnippet -Force -Title "ECCO Runbook Script v2" -Description "Runbook to execute in powershell v2" -Author "Palle Jensen" -CaretOffset 120 -Text '
# ------------------------------------------------------------------------
# NAME: Untitled.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE: 01/08/2015
#
# KEYWORDS: 
#
# COMMENTS: 
# ---------------------------------------------------------------------

# Set script parameters from runbook data bus and Orchestrator global variables

$DataBusInput1 = "123"
$DataBusInput2 = "Localhost"

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
$Session = New-PSSession -ComputerName dkhqdc01

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
    function Write-LogFile ([string]$Message){
        $script:CurrentAction = $Message
        $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
    }

    # Set external session trace and status variables to defaults
    $ResultStatus = ""
    $ErrorMessage = ""
    $script:CurrentAction = ""
    $script:TraceLog = ""

    try 
	{
        # Add startup details to trace log
        Write-LogFile "Script now executing in external PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process"
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
		
        # Do-Stuff
		# Import module
		# Simulate a possible error
        if($DataBusInput1 -ilike "*bad stuff*")
        {
            throw "ERROR: Encountered bad stuff in the parameter input"
        }
		
		$ResultStatus = "Success"
    }
	
    catch
	{
        # Catch any errors thrown above here, setting the result status and recording the error message to return to the activity for data bus publishing
        $ResultStatus = "Failed"
        $ErrorMessage = $error[0].Exception.Message
        Write-LogFile "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
    }
	
    finally
	{
        # Adding some additional detail about the outcome to the trace log for return
        if($ErrorMessage.Length -gt 0)
		{
            Write-LogFile "Exiting external session with result [$ResultStatus] and error message [$ErrorMessage]"
        }
        else
		{
            Write-LogFile "Exiting external session with result [$ResultStatus]"
        }
    }

    # Return an array of the results.
    $resultArray = @()
    $resultArray += $ResultStatus
    $resultArray += $ErrorMessage
    $resultArray += $script:TraceLog 
	
}#End Invoke-Command

# Get the values returned from script session for publishing to data bus
$ResultStatus = $ReturnArray[0]
$ErrorMessage = $ReturnArray[1]
$Trace += $ReturnArray[2]

# Record end of activity script process
$Trace += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File c:\Scripts\Test\Output\tracelog.txt -InputObject $Trace

# Close the external session
Remove-PSSession $Session'

New-IseSnippet -Force -Title "ECCO Runbook Script v3" -Description "Runbook to execute in powershell v3" -Author "Palle Jensen" -CaretOffset 120 -Text '
# ------------------------------------------------------------------------
# NAME: Untitled.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE: 22/10/2015
#
# KEYWORDS: 
#
# COMMENTS: 
#
# ---------------------------------------------------------------------

#region Global Variables
#endregion

## Execute in Powershell v3 Process
$var = Powershell {

#region Script Variables

#Set trace and status variables to defaults

# 0=Success,1=Warning,2=Error
$ErrorState = 0

# Current error message
$ErrorMessage = ""
	
# Scriptpath set to where the script is run
$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
#"C:\logs\Orchestrator\3.4.1.1 - Build Server Images"

#endregion
	
#region Functions

## Write-Logfile, Used with -Trace switch writes to a tracelog
function Write-LogFile
{
    [CmdletBinding()]

	param(

        [Parameter(Position=0)]
        [string]$Message,
        [Switch]$Trace
		
	)
    
    if($Trace)
    {
        $Log = "$ScriptPath\Trace.log"
	    $Output = "$([DateTime]::Now): $Message"
    }

    else
    {
        $Log = "$ScriptPath\Output.log"
        $output = $Message
    }

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

function Main
{
    ## Initializing Logs
    Write-LogFile "--------------------------------------------------Monitor---------------------------------------------------"
    Write-LogFile "--------------------------------------------------Monitor---------------------------------------------------" -Trace
    Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace
    Write-LogFile "Executing commands in order.." -Trace

    try 
    {
	  #region Variables

        ## Session specific variables
        $sessionHost = "dkhqvmtst02.prd.eccocorp.net"
        $sessionName = "HyperV"

        ## Other Specific variables
        $vm = "VHDBuild2012"

      #endregion
      
      #region Session

        ## If session not exist create new session
        if(!((Get-PSSession | ?{$_.Name -eq $sessionName}).Availability -eq "Available"))
        {
            Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
            $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
            Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name Hyper-V}
            Write-LogFile "Created Session on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"
        }

      #endregion

        ## ---Logic Here---
        ## Starting monitoring
        Write-LogFile "Monitor-VM -VMName $vm -SessionName $sessionName -ErrorAction Stop" -Trace
        Write-LogFile "Monitoring VM $vm"
        #Monitor-VMImage -VMName $vm -SessionName $sessionName -ErrorAction Stop
        Write-LogFile "No more VMs to monitor - Finalizing script"
    }

    Catch
    {
        $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught: $ErrorMessage" -Trace
        $ErrorState = 1
    }

    Finally
    {
        ## Remove open sessions
        Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
        Write-LogFile "Session $($session.Name) removed - Script Finished"
    }

    ## return array from powershell v3 process
    $returnArray = @()
    $returnArray += $ErrorState
    $returnArray += $ErrorMessage
    return $returnArray
}

#endregion

main

} ##End Powershell v3 Process

## ReturnData for the Databus
$ErrorState = $Var[0]
$ErrorMessage = $var[1]'	