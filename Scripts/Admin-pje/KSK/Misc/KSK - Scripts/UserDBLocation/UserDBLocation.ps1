#DB Connection
[string]$ServerInstance = "DKHQSCOMDWSQL01.prd.eccocorp.net"
[string]$Database = "CustomReporting"
[string]$TableName = "UserDBLocation"
[string]$Username = "CustomReporters"
[string]$Password = "reports4ecco"
[Int32]$BatchSize = 50000
[Int32]$QueryTimeout = 0
[Int32]$ConnectionTimeout = 15

#Data table
$output = New-Object system.Data.DataTable

$Col1 =  New-Object system.Data.DataColumn("UserName",([string]))
$Col2 =  New-Object system.Data.DataColumn("Database",([string]))
$Col3 =  New-Object system.Data.DataColumn("Year",([string]))
$Col4 =  New-Object system.Data.DataColumn("Month",([string]))
$Col5 =  New-Object system.Data.DataColumn("Day",([string]))
$Col6 =  New-Object system.Data.DataColumn("CheckDate",([string]))

$output.columns.add($Col1 )
$output.columns.add($Col2 )
$output.columns.add($Col3 )
$output.columns.add($Col4 )
$output.columns.add($Col5 )
$output.columns.add($Col6 )

#Functions
function Write-DataTable ($Data)
{
    $conn=new-object System.Data.SqlClient.SQLConnection

    if ($Username)
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout }
    else
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout }

    $conn.ConnectionString=$ConnectionString

    try
    {
        $conn.Open()
        $bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
        $bulkCopy.DestinationTableName = $tableName
        $bulkCopy.BatchSize = $BatchSize
        $bulkCopy.BulkCopyTimeout = $QueryTimeOut
        $bulkCopy.WriteToServer($Data)
        $conn.Close()
    }
    catch
    {
        $ex = $_.Exception
        Write-Error "Write-DataTable  $($connectionName):$ex.Message"
        continue
    }

} #Write-DataTable

#Prep date and others for datatable
$Datetime = Get-Date
$Year = $Datetime.Year
$Month = $Datetime.Month
$Day = $Datetime.Day

#Get system data
$MBUsers = Get-Mailbox -ResultSize unlimited | Select samaccountname, Database

#Build datatable
foreach ($MB in $MBUsers) {
	$row = $output.NewRow();	
		$row.UserName = $MB.SamAccountName;
		$row.Database = $MB.Database;
		$row.Year = $Year;
		$row.Month = $Month;
		$row.Day = $Day;
		$row.CheckDate = $datetime;
	$output.Rows.Add($row);	
}
#Write Dataset to DB
Write-DataTable $output 