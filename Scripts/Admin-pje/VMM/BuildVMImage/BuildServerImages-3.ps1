
## Variables Used within the runbook bus
$collectionId = "P0100165"
$resourceType = "0"
$primaryUser = $(whoami)
$CMMac = "00:15:4D:01:01:01"

$var = Powershell {

    # ------------------------------------------------------------------------
    # NAME: 
    # BuildServerImages-3.ps1
    #
    # AUTHOR: 
    # Palle Jensen, Ecco
    # 
    # DATE: 
    # 20/10/2015
    #
    # KEYWORDS: 
    # VM, Copy
    #
    # COMMENTS: 
    # The script is part of the runbook 3.4.1.1 Build Server Image 
    # The basics of this scripts to build a test VM
    #
    # CHANGES:
    # 04/11/2015 Version 2, Minor function based changes
    # 17/11/2015 Version 3, Minor code change, comment script, Script Analyzer
    # ---------------------------------------------------------------------

    #region Variables

    #------------------------------------------------------------
    # Declaring Variables
    #------------------------------------------------------------ 
    # Set trace and status variables to defaults
    # 0=Success,1=Warning,2=Error
      $ErrorState = 0
    #
    # Current error message
      $ErrorMessage = ""
    #
    # Last action been written to trace log
      $CurrentAction = ""
    #  
    # Path to logfile, (Split-Path -parent $MyInvocation.MyCommand.Definition)
      $LogPath = "C:\logs\Orchestrator\3.4.1.1 - Build Server Images"
    #
    # Session specific variables
      $SessionHost = "dkhqvmtst02.prd.eccocorp.net"
      $SessionName = "HyperV"
    #
    # VM Specific
      $vhdpath = "C:\ClusterStorage\SRVRM02_SAN04_VMTST02_CSVFS_01\VHDBuild2012"
      $vhdsize = 60GB
      $vmname = "VHDBuild2012"
      $vmMac = "00154D010101"
      $memory = 4GB
    #------------------------------------------------------------
    
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
            $Log = "$LogPath\Trace.log"
            $CurrentAction = $Message	
	        $Output = "$([DateTime]::Now): $Message"
        }

        else
        {
            $Log = "$LogPath\Output.log"
            $output = $Message
        }

	    [System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	    $Log.WriteLine($Output)
	    $Log.Close()
    }

    function Main
    {
        ## Initializing Logs
        Write-LogFile "--------------------------------------------BuildServerImages-----------------------------------------------"
        Write-LogFile "--------------------------------------------BuildServerImages-----------------------------------------------" -Trace
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace
        Write-LogFile "Executing commands in order.." -Trace

        try 
        {    
            ## If session not exist create new session
            if(!((Get-PSSession | ?{$_.Name -eq $sessionName}).Availability -eq "Available"))
            {
                Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
                $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
                Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name Hyper-V}
                Write-LogFile "Created Session on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"
            }
        
            if($(Test-Path -Path $vhdpath) -eq $false)
            {
                New-Item -ItemType Directory -Path $vhdpath | Out-Null
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
            } -ErrorAction Stop | Out-Null
        
            Write-LogFile "Created New Dynamic Harddrive: `r`nVHDSize: [$($vhdsize/1GB)GB]`r`nVHDPath: [$vhdpath`\$vmname.vhd]"
            Write-LogFile "New-VM -Name $vmname -VHDPath $vhdpath`\$vmname.vhd –MemoryStartupBytes $memory -BootDevice LegacyNetworkAdapter" -Trace

            ## Create Virtual Machine with 1 GB, PXE Boot and paging and snapshot in same location as VM
            Invoke-Command -Session $session -ArgumentList $args -ScriptBlock { 
                param($vhdpath,$vhdsize,$vmname,$vmMac,$memory)
                New-VM -Name $vmname -VHDPath "$vhdpath\$vmname.vhd" –MemoryStartupBytes $memory -BootDevice LegacyNetworkAdapter
            } -ErrorAction Stop | Out-Null

            Write-LogFile "`r`nCreated New Virtual Machine: `r`nVirtual Machine Name: [$vmname]`r`nMemory: [$($memory/1GB)GB]"
            Write-LogFile "Get-VM -Name $vmname | Set-VM -SmartPagingFilePath $vhdpath -SnapshotFileLocation $vhdpath" -Trace

            ## Set SmartPagingFilePath and SnapshotFileLocation to the same path as the VHD
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
        }

        catch 
        {
	        $ErrorMessage = $error[0].Exception.Message
	        Write-LogFile "Exception caught during action [$CurrentAction]: $ErrorMessage" -Trace
            $ErrorState = 1
        }

        Finally
        {
            ## Remove the open session used
            Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
            Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
            Write-LogFile "Session $($session.Name) removed - Script Finished"
        }

        ## return array from powershell{}, used in the runbook bus
        $returnArray = @()
        $returnArray += $ErrorState
        $returnArray += $ErrorMessage
        $returnArray += $vmname
        return $returnArray
    }

    #endregion

    Main
}

$ErrorState = $var[0]
$ErrorMessage = $var[1]
$ComputerName = $var[2]