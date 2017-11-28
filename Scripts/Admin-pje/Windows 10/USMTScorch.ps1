param(

    $cn = $args[0],
    $pu = $args[0],
    $USMTSize = $args[0]
)

Import-Module EccoDB -ErrorAction SilentlyContinue

$ECCOConnectionString = "server=DKHQSCCM02;database=USMT_Inventory;trusted_connection=True"

function Get-EccoComputerNamesFromInventory 
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

    Process {

        foreach ($obj in $inputObject)
        {
            $query = "UPDATE USMTData SET
                      ComputerName = '$($Obj.ComputerName)',
                      PrimaryUser = '$($Obj.PrimaryUser)',
                      USMTSize = '$($Obj.USMTSize)',
                      Date = '$(Get-Date)'
                      WHERE computername = '$($obj.computername)'"

            Write-Verbose "Query will be $query"

            Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}

function New-EccoComputerDataObject
{
    <#
        .SYNOPSIS
    #>

    [CmdletBinding()]

    param(

    )

    $props = @{
               'ComputerName'=$cn;
               'PrimaryUser'=$pu;
               'USMTSize'=$USMTSize;
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

        [Object[]]$inputObject
    )

    Process {

        $query = "INSERT INTO USMTData (Computername,PrimaryUser,USMTSize,Date) VALUES 
                 ('$($inputObject.ComputerName)','$($inputObject.PrimaryUser)',$($inputObject.USMTSize),'$(Get-Date)')"

        Write-Verbose "Query will be $query"

        Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
    }
}

function Set-EccoUSMTInventory
{
    param(
        [Parameter(Mandatory=$False, 
                   ValueFromPipeline=$True)]

        [Object[]]$cObj
    )
    
   if (Get-EccoComputerNamesFromInventory -query "SELECT [computername] FROM [USMT_Inventory].[dbo].[USMTData] WHERE [computername]='$($cObj.computername)'")
   {
        Write-Verbose "Set-EccoInventoryInDatabase -inputObject $($cObj)"
        Set-EccoInventoryInDatabase -inputObject $cObj
   }
   else
   {
        Write-Verbose "New-EccoInventoryInDatabaseRecord -inputObject $($cObj)"
        New-EccoInventoryInDatabaseRecord -inputObject $cObj
   }
    
   Get-EccoComputerNamesFromInventory -query "SELECT [computername],[USMTSize] FROM [USMT_Inventory].[dbo].[USMTData]"
}

New-EccoComputerDataObject | Set-EccoUSMTInventory
