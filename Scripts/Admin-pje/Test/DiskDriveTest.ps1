#Create a drive report tool that shows you drive utilization on a server’s drives.

function Get-EccoServerDriveInformation
{
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]

        [String[]]$Computername
    )

    process
    {
        foreach($c in $computername)
        {
            gwmi win32_volume -ComputerName $c | ForEach-Object {
            
                $hash = [Ordered]@{'Computername'=$c}
                $hash.add('Labels',$_.Name)
                $hash.add('FreeSpace GB',($_.FreeSpace / 1GB -as [int]))

                $out = New-Object -TypeName PSObject -Property $hash

                Write-Output $out
            }
            
        }
    }
    
}
 
Get-EccoServerDriveInformation -Computername dkhqfile01