

$ECCOConnectionString = "server=localhost\SQLEXPRESS;database=inventory;trusted_connection=True"

function Get-EccoComputerNamesFromDatabase 
{
    <#
        .SYNOPSIS
    #>
    
    Get-ECCODatabaseData -connectionString $ECCOConnectionString -isSQLServer -query "SELECT computername FROM computers"
}

function Set-ECCOInventoryInDatabase 
{

    <#
        .SYNOPSIS
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$True, 
                   ValueFromPipeline=$True)]

        [object[]]$inputObject
    )

    PROCESS {

        foreach ($obj in $inputobject)
        {
            $query = "UPDATE computers SET
                      osversion = '$($obj.osversion)',
                      spversion = '$($obj.spversion)',
                      manufacturer = '$($obj.manufacturer)',
                      model = '$($obj.model)'
                      WHERE computername = '$($obj.computername)'"

            Write-Verbose "Query will be $query"

            Invoke-ECCODatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}

function New-ECCOInventoryInDatabaseRecord
{

    <#
        .SYNOPSIS
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$True, 
                   ValueFromPipeline=$True)]

        [object[]]$inputObject
    )

    PROCESS {

        foreach ($obj in $inputobject)
        {
            $query = "INSERT INTO computers (Computername,osversion,spversion,manufacturer,model) VALUES
                     ('$($obj.Name)','$($obj.osversion)','$($obj.spversion)','$($obj.manufacturer)','$($obj.model)')"

            Write-Verbose "Query will be $query"

            Invoke-ECCODatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}


Get-EccoServerInfo $((Get-QADComputer *).name) | New-ECCOInventoryInDatabaseRecord


