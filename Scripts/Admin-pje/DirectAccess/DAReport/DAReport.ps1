

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




#Direct Access Report
#Direct Access Servere DKHQDA01N01,DKHQDA01N02, DKHQDA01N03, DKHQDA01N04

#To export information about all connections in the last thirty days to a csv-file for further processing: 
$now = Get-Date
$start = $now.AddMonths(-1)
Get-DAMultiSite |
% { $_.DaEntryPoints.Servers } |
% { Get-RemoteAccessConnectionStatistics -ComputerName $_ -StartDateTime $start -EndDateTime ([DateTime]::Now) } |
Select * |
Export-Csv file.csv -NoTypeInformation -Encoding "UTF8" 

#To retrieve the total number of megabytes of data transferred through the Direct Access deployment since its installation:
$now = Get-Date
$bytes = 0
Get-DAMultiSite |
% { $_.DaEntryPoints.Servers } |
% { Get-RemoteAccessConnectionStatistics -ComputerName $_ -EndDateTime ([DateTime]::Now) |
        % { $bytes+= $_.TotalBytesIn + $_.TotalBytesOut }
   }

$bytes/1MB 

#To retrieve a list of all users connected in the last week:
$now = Get-Date
$start = $now.AddWeeks(-1)
Get-DAMultiSite |
% { $_.DaEntryPoints.Servers } |
% { Get-RemoteAccessConnectionStatistics -ComputerName $_ -StartDateTime $start -EndDateTime ([DateTime]::Now) } |
Select UserName | Sort-Object -Property UserName -Unique 






$((Get-QADComputer -SearchRoot "prd.eccocorp.net/Member servers").name) | Get-EccoServerInfo | New-ECCOInventoryInDatabaseRecord
#Get-EccoComputerNamesFromDatabase -query "SELECT [computername],[status] FROM [Inventory].[dbo].[Computers] WHERE [status] LIKE '%Testing%'"


