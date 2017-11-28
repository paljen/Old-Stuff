Function Get-EccoServerDriveInformation
{
    <#
    .SYNOPSIS
        Get disk information 

    .EXAMPLE 
        Get-EccoServerDriveInformation -Computername DKHQFILE01

        Get all drive information from a specific computer

    .EXAMPLE 
        Get-Content C:\servers.txt | Get-EccoServerDriveInformation

        Get all drive information from a list of computers

    .EXAMPLE 
        Get-ADComputer -Filter * -SearchBase "OU=Application,OU=Member servers,dc=prd,dc=eccocorp,dc=net").Name | Get-EccoServerDriveInformation -Filter C:

        Get drive information on drive C: for a list of computers

    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]

        [String[]]$ComputerName,

        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true)]

        [String]$Filter = "*"

    )

    process
    {
        foreach($c in $computername)
        {
            try 
            {
                gwmi win32_volume -ComputerName $c -ErrorAction Stop | Where {$_.DriveLetter -Like "$filter*"} | ForEach-Object {
                
                    $props = [Ordered]@{'Computername'=$c}
                    $props.add('Label',$_.Name)
                    $props.add('FreeSpace GB',($_.FreeSpace / 1GB -as [int]))

                    $obj = New-Object -TypeName PSObject -Property $props
                    Write-Output $obj
                }
            }

            catch
            {
                Write-Output "$c`: $($_.Exception.Message)"
                
            }
            
        }
    }  
}