$hwpro = "Large Server - 4vCPU,8GB Mem, Auto IP"
#Get-SCHardwareProfile | where {$_.name -eq $hwpro}
$pro = Get-SCHardwareProfile | where {$_.name -eq $hwpro}
$pro.IsHighlyAvailable

function Get-EccoVMHostGroups()
{
    param(
        [String]$Location
    )

    ((Get-SCVMHostGroup -VMMServer $VMMServer ) | ? {$_.path -like "*bredebro*"}).name | Sort -Unique
}


        
        #Get-SCVMHostGroup "Tønder HA Cluster"
        #Get-SCVMHostGroup "Server Rum 3"

        
 $Location = "tønder"
 $HighAvailable = $true
 $VMMServer = "DKHQVMM02CR"
(Get-SCVMHostGroup -VMMServer $VMMServer ) | ? {$_.path -like "*$Location*"} | Sort -Unique
