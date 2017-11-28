#Load snapins
. ./Get-UserProfileShareFolderAudit.ps1

[string]$ServerInstance = "dkhqscomdwsql01"
[string]$Database = "CustomReporting"
[string]$TableName = "UserFileshares"
[string]$Username = "CustomReporters"
[string]$Password = "reports4ecco"
[Int32]$BatchSize = 50000
[Int32]$QueryTimeout = 0
[Int32]$ConnectionTimeout = 15

#Region Datatable
$Script:DTOut = New-Object system.Data.DataTable

$Script:DTOutCol1 =  New-Object system.Data.DataColumn("ServerName",([string]))
$Script:DTOutCol2 =  New-Object system.Data.DataColumn("FullPath",([string]))
$Script:DTOutCol3 =  New-Object system.Data.DataColumn("UserCN",([string]))
$Script:DTOutCol4 =  New-Object system.Data.DataColumn("UserFirstName",([string]))
$Script:DTOutCol5 =  New-Object system.Data.DataColumn("UserLastName",([string]))
$Script:DTOutCol6 =  New-Object system.Data.DataColumn("UserDisplayName",([string]))
$Script:DTOutCol7 =  New-Object system.Data.DataColumn("UserDisabled",([string]))
$Script:DTOutCol8 =  New-Object system.Data.DataColumn("UserLocked",([string]))
$Script:DTOutCol9 =  New-Object system.Data.DataColumn("UserLastLogon",([string]))
$Script:DTOutCol10 =  New-Object system.Data.DataColumn("UserADPath",([string]))
$Script:DTOutCol11 =  New-Object system.Data.DataColumn("UserProfile",([string]))
$Script:DTOutCol12 =  New-Object system.Data.DataColumn("UserStatus",([string]))
$Script:DTOutCol13 =  New-Object system.Data.DataColumn("SizeinMegaBytes",([string]))
$Script:DTOutCol14 =  New-Object system.Data.DataColumn("SizeinBytes",([string]))
$Script:DTOutCol15 =  New-Object system.Data.DataColumn("FolderContentLastModified",([string]))
$Script:DTOutCol16 =  New-Object system.Data.DataColumn("ADErrors",([string]))
$Script:DTOutCol17 =  New-Object system.Data.DataColumn("FileErrors",([string]))

$Script:DTOutCol90 =  New-Object system.Data.DataColumn("Day",([int]))
$Script:DTOutCol91 =  New-Object system.Data.DataColumn("Month",([int]))
$Script:DTOutCol92 =  New-Object system.Data.DataColumn("Year",([int]))
$Script:DTOutCol93 =  New-Object system.Data.DataColumn("Checkdate",([string]))

$Script:DTOut.columns.add($Script:DTOutCol1 )
$Script:DTOut.columns.add($Script:DTOutCol2 )
$Script:DTOut.columns.add($Script:DTOutCol3 )
$Script:DTOut.columns.add($Script:DTOutCol4 )
$Script:DTOut.columns.add($Script:DTOutCol5 )
$Script:DTOut.columns.add($Script:DTOutCol6 )
$Script:DTOut.columns.add($Script:DTOutCol7 )
$Script:DTOut.columns.add($Script:DTOutCol8 )
$Script:DTOut.columns.add($Script:DTOutCol9 )
$Script:DTOut.columns.add($Script:DTOutCol10 )
$Script:DTOut.columns.add($Script:DTOutCol11 )
$Script:DTOut.columns.add($Script:DTOutCol12 )
$Script:DTOut.columns.add($Script:DTOutCol13 )
$Script:DTOut.columns.add($Script:DTOutCol14 )
$Script:DTOut.columns.add($Script:DTOutCol15 )
$Script:DTOut.columns.add($Script:DTOutCol16 )
$Script:DTOut.columns.add($Script:DTOutCol17 )

$Script:DTOut.columns.add($Script:DTOutCol90 )
$Script:DTOut.columns.add($Script:DTOutCol91 )
$Script:DTOut.columns.add($Script:DTOutCol92 )
$Script:DTOut.columns.add($Script:DTOutCol93 )
#endregion

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
$Datetime = get-date
$Year = $Datetime.Year
$Month = $Datetime.Month
$Day = $Datetime.Day

$ServerName = $env:COMPUTERNAME

#Get shares to check
$shares = Get-Content .\Sharestocheck.txt

foreach ($share in $shares) {
	$Output = Get-UserProfileShareFolderAudit -HomeFolderPath $share
	
	foreach ($record in $Output) {
		$row = $Script:DTOut.NewRow();	
			$row.ServerName 		= $ServerName
			$row.FullPath 			= $record.FullPath
			$row.UserCN 			= $record.UserCN
			$row.UserFirstName 		= $record.UserFirstName
			$row.UserLastName 		= $record.UserLastName
			$row.UserDisplayName 	= $record.UserDisplayName
			$row.UserDisabled 		= $record.UserDisabled
			$row.UserLocked 		= $record.UserLocked
			
			if ($record.UserLastLogon) {
				if ($record.UserLastLogon -lt "1900-01-01") {
					[string]$shortdt = "{0:yyyy-MM-dd HH:mm:ss}" -f ([datetime]"1900-01-01 00:00:00")
					$row.UserLastLogon = $shortdt ;
				}
				else {
					[string]$shortdt = "{0:yyyy-MM-dd HH:mm:ss}" -f ([datetime]$record.UserLastLogon)
					$row.UserLastLogon = $shortdt;
				}
			}
			else {
				[string]$shortdt = "{0:yyyy-MM-dd HH:mm:ss}" -f ([datetime]"1900-01-01 00:00:00")
				$row.UserLastLogon = $shortdt ;
			}			
			
			$row.UserADPath 		= $record.UserADPath
			$row.UserProfile 		= $record.UserProfile
			$row.UserStatus 		= $record.UserStatus
			$row.SizeInMegabytes 	= $record.SizeInMegabytes
			$row.SizeinBytes 		= $record.SizeinBytes
			
			if ($record.FoldercontentLastModified) {
				if ($record.FolderContentLastModified -lt "1900-01-01") {
					[string]$shortdt = "{0:yyyy-MM-dd HH:mm:ss}" -f ([datetime]"1900-01-01 00:00:00")
					$row.FoldercontentLastModified = $shortdt;
				}
				else {
					[string]$shortdt = "{0:yyyy-MM-dd HH:mm:ss}" -f ([datetime]$record.FoldercontentLastModified)
					$row.FoldercontentLastModified = $shortdt;
				}
			}
			else {
				[string]$shortdt = "{0:yyyy-MM-dd HH:mm:ss}" -f ([datetime]"1900-01-01 00:00:00")
				$row.FoldercontentLastModified = $shortdt;
			}
			
			$row.ADErrors 			= $record.ADErrors
			$row.FileErrors 		= $record.FileErrors
			
			$row.day 		= $Day
			$row.month 		= $Month
			$row.year 		= $Year
			$row.checkdate 	= [string]"{0:yyyy-MM-dd HH:mm:ss}" -f ([DateTime]$Datetime)		
		$Script:DTOut.Rows.Add($row);
		
	}
}

#$Script:DTOut | export-csv .\Outdata.csv -Notypeinformation

write-datatable $Script:DTOut

