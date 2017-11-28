
# ------------------------------------------------------------------------
# NAME: BuildServerImages.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE: 20/10/2015
#
# KEYWORDS: VM, CM
#
# COMMENTS:
# ---------------------------------------------------------------------

#region Variables

#Set trace and status variables to defaults

# Current error message
$ErrorMessage = ""

# Current error state
$ErrorState = 0

# Last write to log
$Script:CurrentAction = ""
	
# Scriptpath set to where the script is run
$ScriptPath = "C:\logs\Orchestrator\3.4.1.1 - Build Server Images"
# split-path -parent $MyInvocation.MyCommand.Definition

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

function Main
{
    ## Initializing Logs
    Write-LogFile "---------------------------------------------------Build----------------------------------------------------"
    Write-LogFile "---------------------------------------------------Build----------------------------------------------------" -Trace
    Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace
    Write-LogFile "Executing commands in order.." -Trace

    try 
    {
	
	  #------------------------------------------------------------
      # Declaring Variables
      #------------------------------------------------------------       
        ## Session Specific
        $modulehost = "dkhqvmtst02.prd.eccocorp.net"
        $modulename = "Hyper-V"

        ## VM Specific
        $vhdpath = "C:\ClusterStorage\SRVRM02_SAN04_VMTST02_CSVFS_01\VHDBuild2012"
        $vhdsize = 60GB
        $vmname = "VHDBuild2012"
        $vmMac = "00154D010101"
        $memory = 4GB

        ## CM Specific
        $collectionId = "P0100165"
        $resourceType = "0"
        $primaryUser = $(whoami)
        $cmMac = "00:15:4D:01:01:01"
      
      #------------------------------------------------------------

        ## Create Session and Import module
        if(!((Get-PSSession | ?{$_.ComputerName -eq $modulehost}).Availability -eq "Available"))
        {
            Write-LogFile "New-PSSession -ComputerName $modulehost -ErrorAction Stop" -Trace
            $session = New-PSSession -ComputerName $modulehost -ErrorAction Stop
            Write-LogFile "Created Session on $modulehost with Session Id $($session.Id)"
            Write-LogFile "Invoke-Command –Session $Session -ArgumentList $modulename {param($modulename);Import-Module -Name $modulename}" -Trace
            Invoke-Command –Session $Session -ArgumentList $modulename {param($modulename);Import-Module -Name $modulename}
            Write-LogFile "Imported module $modulename in $session"
        }

        ## Creating Argument List
        $args = @()
        $args += $vhdpath
        $args += $vhdsize
        $args += $vmname
        $args += $vmMac
        $args += $memory
        
        
        Write-LogFile "New-VHD -Path $vhdpath`\$vmname.vhd -Dynamic -SizeBytes $vhdsize" -Trace
        
        ## Create Virtual Harddisk
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock { 
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            New-VHD -Path "$vhdpath\$vmname.vhd" -Dynamic -SizeBytes $vhdsize
        } -ErrorAction Stop
        
        Write-LogFile "Created New Dynamic Harddrive: `r`nVHDSize: [$($vhdsize/1GB)GB]`r`nVHDPath: [$vhdpath`\$vmname.vhd]"
        Write-LogFile "New-VM -Name $vmname -VHDPath $vhdpath`\$vmname.vhd –MemoryStartupBytes $memory -BootDevice LegacyNetworkAdapter" -Trace

        ## Create Virtual Machine with 1 GB, PXE Boot and paging and snapshot in same location as VM
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock { 
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            New-VM -Name $vmname -VHDPath "$vhdpath\$vmname.vhd" –MemoryStartupBytes $memory -BootDevice LegacyNetworkAdapter
        } -ErrorAction Stop

        Write-LogFile "`r`nCreated New Virtual Machine: `r`nVirtual Machine Name: [$vmname]`r`nMemory: [$($memory/1GB)GB]"
        Write-LogFile "Get-VM -Name $vmname | Set-VM -SmartPagingFilePath $vhdpath -SnapshotFileLocation $vhdpath" -Trace

        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock { 
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            Get-VM -Name $vmname | Set-VM -SmartPagingFilePath $vhdpath -SnapshotFileLocation $vhdpath
        } -ErrorAction Stop
        
        Write-LogFile "SmartPagingFilePath: [$vhdpath]`r`nSnapshotFileLocation: [$vhdpath]"
        Write-LogFile "Get-VMNetworkAdapter -VMName $vmname | Remove-VMNetworkAdapter" -Trace
        
        ## Remove standard network adapter
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock {
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            Get-VMNetworkAdapter -VMName $vmname | Remove-VMNetworkAdapter
        } -ErrorAction Stop
                
        Write-LogFile "Get-VM -VMName $vmname | Add-VMNetworkAdapter -IsLegacy $true" -Trace        

        ## Add new legacy network adapter
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock {
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            Get-VM -VMName $vmname | Add-VMNetworkAdapter -IsLegacy $true
        } -ErrorAction Stop
        
        Write-LogFile "Get-VMNetworkAdapter -VMName $vmname | Set-VMNetworkAdapter -StaticMacAddress $vmMac" -Trace

        ## Configure legacy network adapter with static mac
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock {
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            Get-VMNetworkAdapter -VMName $vmname | Set-VMNetworkAdapter -StaticMacAddress $vmMac
        } -ErrorAction Stop
        
        Write-LogFile "Static Mac Address: [$vmMac]"         
        Write-LogFile "Get-VMNetworkAdapter -VMName $vmname | Connect-VMNetworkAdapter –SwitchName vSwitch0" -Trace

        ## Connect to virtual switch vSwitch0
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock {
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            Get-VMNetworkAdapter -VMName $vmname | Connect-VMNetworkAdapter –SwitchName vSwitch0
        } -ErrorAction Stop

        Write-LogFile "NetworkAdapter connected to: [vSwitch0]"
        Write-LogFile "Get-VMNetworkAdapter -VMName $vmname | Set-VMNetworkAdapterVlan –Access –VlanId 1" -Trace
        
        ## Set VLAN Id to 1
        Invoke-Command -Session $session -ArgumentList $args -ScriptBlock {
            param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
            Get-VMNetworkAdapter -VMName $vmname | Set-VMNetworkAdapterVlan –Access –VlanId 1
        } -ErrorAction Stop

        Write-LogFile "NetworkAdapter VLAN Id: [1]"

        ## return from powershell{}
        $returnArray = @()
        $returnArray += ""
        return $returnArray
    }

    catch 
    {
	    $ErrorMessage = $error[0].Exception.Message
        $ErrorState = 1
	    Write-LogFile "Exception caught during action [$script:CurrentAction]: $ErrorMessage" -Trace
        Exit 1
    }
}

#endregion

Main