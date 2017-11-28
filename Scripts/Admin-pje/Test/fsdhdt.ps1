
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
