
# ------------------------------------------------------------------------
# NAME: New-EccoVM.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE: 15/09/2015
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

# Last write to log
$Script:CurrentAction = ""
	
# Scriptpath and log files
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#endregion

	
#region Functions
function Get-EccoVMHardwareProfile
{
    [CmdletBinding()]

    $title = ""
    $message = ""

    $hw1 = New-Object System.Management.Automation.Host.ChoiceDescription "&0-Small Server - 1vCPU, 2-4GB Mem, Auto IP"
    $hw2 = New-Object System.Management.Automation.Host.ChoiceDescription "&1-Small Server - 1vCPU, 2-4GB Mem, Auto IP, HA"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($hw1, $hw2)

    $result = $host.ui.PromptForChoice($title, $message, $options, -1) 

    switch ($result)
        {
            0 {$hwpro = "Small Server - 1vCPU, 2-4GB Mem, Auto IP"}
            1 {$hwpro = "Small Server - 1vCPU, 2-4GB Mem, Auto IP,HA"}
        }

    Get-SCHardwareProfile -ErrorAction Stop | where {$_.name -eq $hwpro}
}

function Get-EccoVMGuestOSProfile
{
    [CmdletBinding()]

    $title = ""
    $message = ""

    $os1 = New-Object System.Management.Automation.Host.ChoiceDescription "&0-Windows Server 2012 - Domain Joined"
    $os2 = New-Object System.Management.Automation.Host.ChoiceDescription "&1-Windows Server 2008 R2 - Domain Joined"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($os1, $os2)

    $result = $host.ui.PromptForChoice($title, $message, $options, -1) 

    switch ($result)
        {
            0 {$ospro = "Windows Server 2012 - Domain Joined"}
            1 {$ospro = "Windows Server 2008 R2 - Domain Joined"}
        }

    Get-SCGuestOSProfile -ErrorAction Stop | where {$_.name -eq $ospro}
}

function Get-EccoVMHostGroups()
{
    [CmdletBinding()]

    param(
        
        [String]$Location

    )

    filter Cluster
    {  
        ## If Hardware profile is set to be high available
        if($HWProfile.IsHighlyAvailable)
        {
            $input | where {$_.path -like "*$Location*" -and $(($_.ChildClusters).count) -gt 0}
        }

        else
        {
            $input | where {$_.path -like "*$Location*" -and $(($_.ChildClusters).count) -eq 0}
        }
    }

    ## Test on custom property prod|test

    ## Get all Host groups for the given location, Sort unique removes the parentgroup for the location
    ((Get-SCVMHostGroup -VMMServer $VMMServer -ErrorAction Stop) | Cluster ).name | Sort -Unique
}

function Get-EccoVMPreferedHost
{
    [CmdletBinding()]

    param(

        [Array]$VMHosts,
        [String]$VMName,
        [Int32]$DiskSpaceGB
    )

    ## Get host rating for host array and sort out the highest score
    $VMHostsRating = Get-SCVMHostRating -DiskSpaceGB $DiskSpaceGB -VMName $VMName -HardwareProfile $HWProfile.Name -VMHost $VMHosts
    $TopRating = $VMHostsRating | sort Rating -Descending | select -First 1
    $TopRating
}

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
        $Log = "$ScriptPath\TraceLog.log"
        $script:CurrentAction = $Message	
	    $Output = "$([DateTime]::Now): $Message"
    }

    else
    {
        $Log = "$ScriptPath\OutputLog.log"
        $output = $Message
    }

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

function Main
{
    ## Deleting old log files
    $TraceLog | Remove-Item -ErrorAction SilentlyContinue
    $OutputLog | Remove-Item -ErrorAction SilentlyContinue

    ## Initializing TraceLog
    Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace

    try 
    {
      #------------------------------------------------------------
      # Declaring Variables
      #------------------------------------------------------------       
        # User input Variables
	    $HostPath = "Bredebro"

        # VMM specific variables
        $VMMServer = "DKHQVMM02CR"
        Write-LogFile "Getting VM Hardware Profile: [Get-EccoVMHardwareProfile]" -Trace
        $HWProfile = Get-EccoVMHardwareProfile -ErrorAction Stop
        Write-LogFile "Getting VM Guest OS Profile: [Get-EccoVMGuestOSProfile]" -Trace
        $OSProfile = Get-EccoVMGuestOSProfile -ErrorAction Stop
      
      #------------------------------------------------------------       

        ## Console output
        Write-Output "`nHardware Profile:`n`t$($HWProfile.Name)"
        Write-Output "Guest OS Profile:`n`t$($OSProfile.Name)"
        Write-Output "Host Group for $($HostPath):"

        ## ResultLog output
        Write-LogFile "Hardware Profile: $($HWProfile.Name)"
        Write-LogFile "Guest OS Profile: $($OSProfile.Name)"
      
        ## Retriving All hostgroups, from the specified hostpath
        Write-LogFile "Getting VM Hostgroups: [Get-EccoVMHostGroups -Location $($HostPath)]" -Trace
        $VMHostGroups = Get-EccoVMHostGroups -Location $HostPath -ErrorAction Stop
        Write-LogFile "Host Group for $($HostPath): $($VMHostGroups -join ', ')"
                
        if($HWProfile.IsHighlyAvailable -eq $true)
        {
            Write-LogFile "High Availability for profile $($HWProfile.Name) " 
        }
        
        ## Injouring $VMHostGroups is'nt Empty
        if ($VMHostGroups.Length -eq 0){
            Throw "No Hosts in Host Group"}
        
        ## Building VMHosts array from returned host groups
        foreach ($g in $VMHostGroups)
        {
            ## Checking for blanks
            if ($g.Length -gt 0)
            { 
                ## TraceLog Variale
                $b = $VMHosts.Count

                ## Building VMHost array
                Write-LogFile "Getting VM Hosts from Hostgroups: [(Get-SCVMHost -VMHostGroup $($g)).name" -Trace
                $VMHosts += (Get-SCVMHost -VMHostGroup $g -ErrorAction Stop).name
                
                ## TraceLog Variale
                $e = $VMHosts.Count

                Write-LogFile "VM Hosts from Hostgroup $($g)).name: $($VMHosts[$b..$e] -join ', ')"
                Write-Output "`t$g"

                ## Clearing blanks
                $VMHosts = $VMHosts | ? {$_}  
            }
        }

        ## Top rated host for VM
        Write-LogFile "Populate prefered host: [Get-EccoVMPreferedHost -VMName Test123 -DiskSpaceGB 10 -VMHosts $($VMHosts -join ", ")]" -Trace
        $Rating = Get-EccoVMPreferedHost -VMName Test123 -DiskSpaceGB 10 -VMHosts $VMHosts -ErrorAction Stop
	    Write-LogFile "Prefered host calculated for: $($VMHosts -join ", ")]"

        ## Console Output    
        Write-Output "Highest Rating:`n`t$($Rating.Rating)"
        Write-Output "Host:`n`t$($Rating.name)"

        ## ResultLog Output
        Write-Logfile "Highest Rating:`t$($Rating.Rating)"
        Write-LogFile "Host: `t$($Rating.name)"
    }

    catch 
    {
	    $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught during action [$script:CurrentAction]: $ErrorMessage" -Trace
	    $ErrorState = 2
    }
	
    if($ErrorState -lt 2)
    {	
        if(!($ErrorState -eq 0))
        {
            Write-LogFile "[`$ErrorState:$($ErrorState) - Warning]" -Trace
        }

        ####################
    }

    else
    {
	    Write-LogFile "[`$ErrorState:$($ErrorState)] - Terminating script" -Trace
	    Exit 1
    }
}

#endregion

#region main

Main

#endregion