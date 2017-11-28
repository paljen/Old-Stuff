$ErrorActionPreference = "Stop"

$vm = Get-SCVirtualMachine | select Name,ComputerName,VMHost

foreach ($v in $vm)
{
    try
    {
        $props = [Ordered]@{}
        $props.Add('Name',$v.name)
        $props.Add('ComputerName',$v.computername)
        $props.Add('VMHost',$v.vmhost)

        $comp = Get-ADComputer -Identity $(($v.vmhost).Split("."))[0] -Properties OperatingSystem | select OperatingSystem

        $props.Add('OperatingSystem',$($comp.OperatingSystem))
    }
    catch
    {
        $props.Add('OperatingSystem',$_)
    }
    
    $obj = New-Object -TypeName PSObject -Property $props
    Export-Csv -InputObject $obj -Path c:\script\vmm.csv -Encoding UTF8 -Append -NoTypeInformation
}
