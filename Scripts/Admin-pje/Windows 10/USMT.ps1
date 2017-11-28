Import-Module EccoDB -ErrorAction SilentlyContinue

$ECCOConnectionString = "server=DKHQSCCM02;database=USMT_Inventory;trusted_connection=True"

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


function Get-ComputerData
{
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$True)]
        [Int]$USMTSize
    )
    $cn = (Get-WmiObject -Class Win32_ComputerSystem).name
    $wcf = New-WebServiceProxy -Uri "http://dkhqsccm02.prd.eccocorp.net/CMLib/CMLib.svc" 
    $pu = $wcf.GetDevicePrimaryUsers($cn)

    $props = @{
               'ComputerName'=$cn;
               'PrimaryUser'=$pu;
               'USMTSize'=$USMTSize / 1MB;
               'Date'=Get-Date;
    }

    $out = New-Object -TypeName PSObject -Property $props
    Write-Output $out
}

function New-EccoInventoryInDatabaseRecord
{

    <#
        .SYNOPSIS
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$False, 
                   ValueFromPipeline=$True)]

        [object[]]$inputObject
    )

    PROCESS {

        $query = "INSERT INTO USMTData (Computername,PrimaryUser,USMTSize,Date) VALUES ('DK4836','PJE',10,'$(Get-Date)')"

            Write-Verbose "Query will be $query"

            Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query

        foreach ($obj in $inputobject)
        {
            $query = "INSERT INTO USMTData (Computername,PrimaryUser,USMTSize,Date) VALUES ('DK4836','PJE',10,'$(Get-Date)')"

            Write-Verbose "Query will be $query"

            Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}

#$((Get-QADComputer -SearchRoot "prd.eccocorp.net/Member servers").name) | Get-EccoServerInfo | New-ECCOInventoryInDatabaseRecord
Get-EccoComputerNamesFromDatabase -query "SELECT [computername],[PrimaryUser] FROM [USMT_Inventory].[dbo].[USMTData]"

#New-EccoInventoryInDatabaseRecord -Verbose
