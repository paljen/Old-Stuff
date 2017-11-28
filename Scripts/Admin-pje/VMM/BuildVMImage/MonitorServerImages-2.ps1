
# ------------------------------------------------------------------------
# NAME: MonitorServerImages.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE: 22/10/2015
#
# KEYWORDS: VM, Copy
#
# COMMENTS: The script is monitoring specific vm's in a collection. 
# if they are Offline the vm's vhd file is copied to a specific UNC, if
# there already is a vhd in that location a backup is beeing made before
# it is over written by the new vhd
# ---------------------------------------------------------------------

#region Variables

#Set trace and status variables to defaults

# 0=Success,1=Warning,2=Error
$ErrorState = 0

# Current error message
$ErrorMessage = ""

# Last write to log
$Script:CurrentAction = ""
	
# Scriptpath set to where the script is run
$ScriptPath = "C:\logs\Orchestrator\3.4.1.1 - Build Server Images"
#split-path -parent $MyInvocation.MyCommand.Definition
#"C:\logs\Orchestrator\3.4.1.1 - Build Server Images"

#endregion
	
#region Functions

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
        $script:CurrentAction = $Message	
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

function Copy-VHDImage
{
    [CmdletBinding()]

    Param(
        
        [String[]]$VMName,
        [String]$SessionName,
        [String]$Destination = "C:\Temp",
        [String]$Backup = "C:\Temp\Backup"

    )

    if($(Test-Path $Backup) -eq $false)
    {
        New-Item -ItemType Directory -Path $Backup | Out-Null
    }

    ## Argument Array for remote session
    $args = @()
    $args += $VMName
    $args += $Destination
    $args += $Backup

    ## Backup Old VHD file and wait for the job to finish
    Write-LogFile "Copy-VHD -VMName $VMName -Target $Destination -Destination $Backup" -Trace
    Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $args -ScriptBlock {
        param($VMName,$destination,$backup)
        $target = Split-Path -Parent (Get-VM –VMName $VMName | Select-Object VMId | Get-VHD).Path
        Copy-Item "$destination\*.VHD" -Destination $backup -Force -Confirm:$false} -AsJob | Wait-Job | Out-Null
    
    ## Copy and Overwrite old VHD file
    Write-LogFile "Copy-VHD -VMName $VMName -Destination $Destination" -Trace
    Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $args -ScriptBlock {
        param($VMName,$destination,$backup)
        $target = (Get-VM –VMName $VMName | Select-Object VMId | Get-VHD).Path
        Copy-Item $target -Destination $destination -Force -Confirm:$false } -AsJob | Wait-Job | Out-Null
}

function Monitor-VMImage
{
    [CmdletBinding()]

    Param(
        
        [String[]]$VMName,
        [String]$SessionName

    )

    $args = @()
    $args += $VMName
        
    ## Declaring and Initializing arraylist with VM's to monitor
    $vmList = New-Object System.Collections.ArrayList
    
    foreach ($vm in $vmname)
    {
        $vmList.Add($vm)
    }
    
    ## Enumerate through the collection and store values in a new array
    $vm = $vmList.GetEnumerator()

    ## We need to clon the enumerated list to be able to manipulate the list
    $vmClone = $vmList.Clone()

    ## The loop will go as long as there is VM's in the cloned array
    While ($vmClone.Count -ne 0)
    {
        ## Reset the pointer
        $vm.Reset()

         ## As long as we have'nt reach the end of the collection
         While($vm.MoveNext())
        {
            ## The delete string, what ever in it will be deleted
            Write-LogFile "Get-VM -VMName $VMName | ?{`$_.state -eq 'Off'}" -Trace
            $delete = Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $vm.Current -ScriptBlock {
                        param($VMName)
                        write-host $VMName
                        return @(Get-VM -VMName $VMName | ?{$_.state -eq "Off"})}
            
            if($delete)
            {
                ## Backup old VHDImage file and overwite with New VHDImage file
                Write-LogFile "Cleaning up $($vm.Current) with status $($delete.state)"
                Copy-VHDImage -VMName $delete.name -SessionName $SessionName -ErrorAction Stop

                ## remove VM from collection
                $vmClone.Remove($($vm.Current))
            }
            
            Start-Sleep -Seconds 10
        }
    }
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
	
	  #------------------------------------------------------------
      # Declaring Variables
      #------------------------------------------------------------       
        ## Session specific variables
        $sessionHost = "dkhqvmtst02.prd.eccocorp.net"
        $sessionName = "HyperV"

        ## VM Specific variables
        $vm = "VHDBuild2012"
      
      #------------------------------------------------------------
      
        ## If session not exist create new session
        if(!((Get-PSSession | ?{$_.Name -eq $sessionName}).Availability -eq "Available"))
        {
            Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
            $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
            Invoke-Command –Session $Session {Import-Module -Name Hyper-V}
            Write-LogFile "Created Session on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"
        }

        ## Starting monitoring
        Write-LogFile "Monitor-VM -VMName $vm -SessionName $sessionName -ErrorAction Stop" -Trace
        Write-LogFile "Monitoring VM $vm"
        Monitor-VMImage -VMName $vm -SessionName $sessionName -ErrorAction Stop
        Write-LogFile "No more VM's to monitor - Finalizing script"
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

    ## return from powershell{}
    $returnArray = @()
    $returnArray += $ErrorState
    $returnArray += $ErrorMessage
    return $returnArray

}

main

$ErrorState = $Var[0]
$ErrorMessage = $var[1]