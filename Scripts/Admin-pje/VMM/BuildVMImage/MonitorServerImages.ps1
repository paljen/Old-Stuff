
# ------------------------------------------------------------------------
# NAME: Untitled.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE: 01/08/2015
#
# KEYWORDS: 
#
# COMMENTS: 
# ---------------------------------------------------------------------

#region Variables

#Set trace and status variables to defaults

# 0=Success,1=Warning,2=Error
$Script:ErrorState = 0

# Current error message
$Script:ErrorMessage = ""
	
# Scriptpath set to where the script is run
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

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
        [String]$Destination = "C:\Temp"

    )

    ## Argument Array for remote session
    $args = @()
    $args += $VMName
    $args += $Destination

    ## Copy VHD file and wait for the job to finish
    Write-LogFile "Copy-VHD -VMName $VMName -Destination $Destination" -Trace
    Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $args -ScriptBlock {
        param($VMName,$destination)
        $target = Split-Path -Parent (Get-VM –VMName $VMName | Select-Object VMId | Get-VHD).Path
        Copy-Item $target -Destination $destination -Recurse} -AsJob | Wait-Job | Out-Null

}

function Delete-VMImage
{
    [CmdletBinding()]

    Param(
        
        [String[]]$VMName,
        [String]$SessionName

    )

    ## Delete vm and delete vhd
    Write-LogFile "Get-VM -VMName $VMName | Remove-VM -Confirm:`$false" -Trace
    Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $VMName -ScriptBlock {
        param($VMName)
        $target = (Get-VM –VMName $VMName | Select-Object VMId | Get-VHD).Path
        Get-VM -VMName $VMName | Remove-VM -Confirm:$false
        Remove-Item $target} | Out-Null
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
                Write-LogFile "Cleaning up $($vm.Current) with status $($delete.state)" -Trace

                ## Housekeeping, copy VHD, wait for it to finish then remove VM and delete old VHD files
                Copy-VHDImage -VMName $delete.name -SessionName $SessionName
                Delete-VMImage -VMName $delete.name -SessionName $SessionName

                ## Remove deleted VM from collection
                $vmClone.Remove($($vm.Current))
            }
            
            Start-Sleep -Seconds 10
        }
    }
}

function Main
{
    ## Session specific variables
    $sessionHost = "dkhqvmtst02.prd.eccocorp.net"
    $sessionName = "HyperV"

    ## VM Specific variables
    $vm = "VHDBuild2012"
    
    try
    {
        ## If session not exist create new session
        if(!((Get-PSSession | ?{$_.Name -eq $sessionName}).Availability -eq "Available"))
        {
            Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
            $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
            Invoke-Command –Session $Session {Import-Module -Name Hyper-V}
        }

        Write-LogFile "Monitor-VM -VMName $vm -SessionName $sessionName -ErrorAction Stop" -Trace
        Monitor-VMImage -VMName $vm -SessionName $sessionName -ErrorAction Stop
    }

    Catch
    {
        $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught: $ErrorMessage" -Trace
    }

    Finally
    {
        ## Remove open sessions
        Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
        Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
    }
}

main


