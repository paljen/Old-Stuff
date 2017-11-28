
cls

function Get-VMM
{
    [CmdletBinding()]

    param(
    )


    process{
        
        #Get-SCVirtualHardDisk
        
        $VMTemplate =  Get-SCVMTemplate -VMMServer "DKHQVMM02CR" | where {$_.Name -eq "Windows Server 2012 R2"}
        $VMTemplate
        $VMHost = Get-SCVMHost -ComputerName "DKHQVM03N01"
        $VMHost
        #New-SCVirtualMachine -VMTemplate $VMTemplate -Name "VM02" -VMHost $VMHost -Path "C:\VirtualMachinePath" -RunAsynchronously -ComputerName "Server01" -FullName "Renee Lo" -OrgName "Contoso" -ProductKey "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
    
    
        }
    end{}

        #host details
        #vm details
        #storage details
        #network details
}

Get-VMM

