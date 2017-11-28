function get-computersystem
{
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [String[]]$ComputerName

    )

    Write-Verbose "Computername $computername"
    Write-Debug "Entering foreach"
    process
    {
        write-host "Processing"

        foreach ($c in $computername)
        {
           $c
        }
    }
    Write-Debug "exit function without error"

}


"dkhqscorch01","dkhqfile01" | get-computersystem