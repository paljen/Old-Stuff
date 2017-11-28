
if(!((Get-PSSession | ?{$_.ComputerName -eq "dkhqvmtst02.prd.eccocorp.net"}).Availability -eq "Available"))
{
    $session=New-PSSession -ComputerName DKHQVMtst02.prd.eccocorp.net
       Invoke-Command –Session $Session {Import-Module –Name Hyper-V}
       Import-PSSession -Session $session -Module Hyper-V
}

## Variables
$vhdpath = "C:\ClusterStorage\SRVRM02_SAN04_VMTST02_CSVFS_01\VHDBuild2012"
$vhdsize = 60GB

$vmname = "VHDBuild2012"
$mac = "00154D010101"

## New Virtual Harddisk
New-VHD -Path "$vhdpath\$vmname.vhd" -Dynamic -SizeBytes $vhdsize

## New Virtual Machine with 1 GB, PXE Boot and paging and snapshot in same location as VM
New-VM -Name $vmname -VHDPath "$vhdpath\$vmname.vhd" –MemoryStartupBytes 1GB -BootDevice LegacyNetworkAdapter
Set-VM -Name $vmname -SmartPagingFilePath $vhdpath -SnapshotFileLocation $vhdpath

## Remove standard network adapter and replace
Remove-VMNetworkAdapter -VMName $vmname

## Add new Legacy adapter, configured with static MAC
Add-VMNetworkAdapter -VMName $vmname -IsLegacy $true 
Set-VMNetworkAdapter -VMName $vmname -StaticMacAddress $mac

## Connect to virtual switch vSwitch0 and set VLAN Id to 1
Connect-VMNetworkAdapter -VMName $vmname –SwitchName vSwitch0
Set-VMNetworkAdapterVlan -VMName $vmname –Access –VlanId 1