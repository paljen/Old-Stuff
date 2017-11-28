#DB Connection
[string]$ServerInstance = "DKHQSCOMDWSQL01.Prd.eccocorp.net"
[string]$Database = "CustomReporting"
[string]$TableName = "MailStats"
[string]$Username = "CustomReporters"
[string]$Password = "reports4ecco"
[Int32]$BatchSize = 50000
[Int32]$QueryTimeout = 0
[Int32]$ConnectionTimeout = 15

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

function Get-ScriptPath
{     Split-Path $myInvocation.ScriptName }

$sp = get-scriptpath
$StatScript = $sp + "\" + "Man_Getstats.ps1"
$consolefile = $sp + "\exshell.psc1"

#Prep date and others for datatable
$Datetime = Get-Date
$rundate = ($Datetime)
$Year = $rundate.Year
$Month = $rundate.Month
$Day = $rundate.Day

#Data table
$output = New-Object system.Data.DataTable

$Col1 =  New-Object system.Data.DataColumn("Server",([string]))
$Col2 =  New-Object system.Data.DataColumn("TotalSentInternal",([string]))
$Col3 =  New-Object system.Data.DataColumn("TotalSentExternal",([string]))
$Col4 =  New-Object system.Data.DataColumn("TotalRecInternal",([string]))
$Col5 =  New-Object system.Data.DataColumn("TotalRecExternal",([string]))
$Col6 =  New-Object system.Data.DataColumn("TotalSentMBInternal",([string]))
$Col7 =  New-Object system.Data.DataColumn("TotalSentMBExternal",([string]))
$Col8 =  New-Object system.Data.DataColumn("TotalRecMBInternal",([string]))
$Col9 =  New-Object system.Data.DataColumn("TotalRecMBExternal",([string]))
$Col10 =  New-Object system.Data.DataColumn("Year",([string]))
$Col11 =  New-Object system.Data.DataColumn("Month",([string]))
$Col12 =  New-Object system.Data.DataColumn("Day",([string]))
$Col13 =  New-Object system.Data.DataColumn("CheckDate",([string]))

$output.columns.add($Col1 )
$output.columns.add($Col2 )
$output.columns.add($Col3 )
$output.columns.add($Col4 )
$output.columns.add($Col5 )
$output.columns.add($Col6 )
$output.columns.add($Col7 )
$output.columns.add($Col8 )
$output.columns.add($Col9 )
$output.columns.add($Col10 )
$output.columns.add($Col11 )
$output.columns.add($Col12 )
$output.columns.add($Col13 )

#Clear out old stat files
remove-item * -Include *.csv

# Get Hub transport servers
$hts = get-exchangeserver |? {$_.serverrole -match "hubtransport"} |% {$_.name}
# Run stat script for each server
foreach ($ht in $hts) {
	powershell -psconsolefile $consolefile -command $StatScript $ht
	#$StatScript $ht
}

#Generate stats per HT Server and totals
$ServerStatsCSVs = Get-ChildItem -Filter *email_stats_*.csv
$DLStatsCSVs = Get-ChildItem -Filter *dl_stats.csv

#Server Stats
Foreach ($csv in $ServerStatsCSVs) {
	#Import csv
	$tserver = $csv.Name.Split("_")
	$server = $tserver[0]
	
	$tbl = Import-Csv $csv
	
	$row = $output.NewRow();	
		$row.Server = $server;
		$row.TotalSentInternal = ($tbl | Measure-Object "Sent Internal" -Sum).Sum;
		$row.TotalSentExternal = ($tbl | Measure-Object "Sent External" -Sum).Sum;
		$row.TotalRecInternal = ($tbl | Measure-Object "Received Internal" -Sum).Sum;
		$row.TotalRecExternal = ($tbl | Measure-Object "Received External" -Sum).Sum;
		$row.TotalSentMBInternal = ($tbl | Measure-Object "Sent Internal MB" -Sum).Sum;
		$row.TotalSentMBExternal = ($tbl | Measure-Object "Sent External MB" -Sum).Sum;
		$row.TotalRecMBInternal = ($tbl | Measure-Object "Received Internal MB" -Sum).Sum;
		$row.TotalRecMBExternal = ($tbl | Measure-Object "Received External MB" -Sum).Sum;
		$row.Year = $Year;
		$row.Month = $Month;
		$row.Day = $Day;
		$row.CheckDate = $datetime;
	$output.Rows.Add($row);	
	
}

#$output | ft server, Total*

#Write Dataset to DB
#Write-DataTable $output 
$output | ft -auto