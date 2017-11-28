cls


$VMMServer = "DKHQVMM02CR"

function Get-EccoVMHostGroups()
{
    param(
        [String]$Location
    )

    ((Get-SCVMHostGroup -VMMServer $VMMServer ) | ? {$_.path -like "*$Location*"}).name | Sort -Unique
}

function Get-EccoVMPreferedHost
{
    [CmdletBinding()]

    param(

        [Array]$VMHosts,
        [String]$VMName,
        [Int32]$DiskSpaceGB
    )

    $HWProfile = Get-SCHardwareProfile | where { $_.Name -eq "Small Server - 1vCPU, 2-4GB Mem, Auto IP" }

    $VMHostsRating = Get-SCVMHostRating -DiskSpaceGB $DiskSpaceGB -VMName $VMName -HardwareProfile $HWProfile.Name -VMHost $VMHosts

    $TopRating = $VMHostsRating | sort Rating -Descending | select -First 1 
    
    ## Top rated host for VM
    "Highest Rating:`n`t$($TopRating.Rating)`nHost:`n`t$($TopRating.name)"
}

function main
{
    try
    {
        $HostPath = "Tønder"
        Write-output "Host Group for $($HostPath):"
        $VMHostGroups = Get-EccoVMHostGroups -Location $HostPath
        
        if ($VMHostGroups.Length -eq 0){
            Throw "No Hosts in Host Group"}
        
 
        foreach ($g in $VMHostGroups)
        {
            if ($g.Length -gt 0)
            {
                Write-output "`t$g"
                $VMHosts += (Get-SCVMHost -VMHostGroup $g).name
                $VMHosts = $VMHosts | ? {$_}  
            }
        }

        Get-EccoVMPreferedHost -VMName Test123 -DiskSpaceGB 10 -VMHosts $VMHosts

        #$OS = Get-SCOperatingSystem | where {$_.Name-eq"64-biteditionofWindowsServer2008R2Standard"}
        #$JobGroupID = [guid]::NewGuid()
        #New-SCVirtualDiskDrive -SCSI -Fixed -Bus 0 -Lun 2 -Size 10 -JobGroup $JobGroupID -FileName "TestDiskDrive"
    }
    catch
    {
        $_.Exception.Message
    }
}


main




