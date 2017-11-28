
Import-Module EccoToolBox -ErrorAction SilentlyContinue
Import-Module EccoDB -ErrorAction SilentlyContinue

$ECCOConnectionString = "server=localhost\SQLEXPRESS;database=inventory;trusted_connection=True"

function Get-EccoComputerNamesFromDatabase 
{
    <#
        .SYNOPSIS
    #>
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$True, 
                   ValueFromPipeline=$True)]

        [String]$query
    )
        
    Get-EccoDatabaseData -connectionString $ECCOConnectionString -isSQLServer -query $query 
}

function Set-EccoInventoryInDatabase 
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

            Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}

function New-EccoInventoryInDatabaseRecord
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
            $query = "INSERT INTO computers (Computername,osversion,spversion,manufacturer,model,totalmemory,`
                      cpucount,cpuname,numberofcores,numberoflogicalprocessors,maxclockspeed,status) VALUES
                     ('$($obj.name)','$($obj.osversion)','$($obj.spversion)','$($obj.manufacturer)',`
                     '$($obj.model)','$($obj.totalmemory)','$($obj.cpucount)','$($obj.cpuname)',`
                     '$($obj.numberofcores)','$($obj.numberoflogicalprocessors)','$($obj.maxclockspeed)','$($obj.status)')"

            Write-Verbose "Query will be $query"

            Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}

$((Get-QADComputer -SearchRoot "prd.eccocorp.net/Member servers").name) | Get-EccoServerInfo | New-ECCOInventoryInDatabaseRecord
#Get-EccoComputerNamesFromDatabase -query "SELECT [computername],[status] FROM [Inventory].[dbo].[Computers] WHERE [status] LIKE '%Testing%'"


