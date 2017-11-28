
#$hostnames = read-host "Exchange Server: "
$hostnames = @("dkhqexc01", "dkhqexc02", "dkhqexc03")

[string]$ServerInstance = "DKHQSCOMDWSQL01"
[string]$Database = "CustomReporting"
[string]$TableName = "ExchangeDefrag"
[string]$Username = "CustomReporters"
[string]$Password = "reports4ecco"
[Int32]$BatchSize = 50000
[Int32]$QueryTimeout = 0
[Int32]$ConnectionTimeout = 15

#Data table
$sqldata = New-Object system.Data.DataTable

$col0 =  New-Object system.Data.DataColumn("Server",([string]))
$Col1 =  New-Object system.Data.DataColumn("Name",([string]))
$Col2 =  New-Object system.Data.DataColumn("Identity",([string]))
$Col3 =  New-Object system.Data.DataColumn("EdbFilePath",([string]))

$Col4 =  New-Object system.Data.DataColumn("LastFullBackup",([datetime]))
$Col5 =  New-Object system.Data.DataColumn("LastIncrementalBackup",([datetime]))
$Col6 =  New-Object system.Data.DataColumn("StorageGroupName",([string]))
$Col7 =  New-Object system.Data.DataColumn("LogFolderPath",([string]))

$Col8 =  New-Object system.Data.DataColumn("DefragStart",([datetime]))
$Col9 =  New-Object system.Data.DataColumn("DefragEnd",([datetime]))
$Col10 =  New-Object system.Data.DataColumn("DefragDuration" ,([string]))
$Col11 =  New-Object system.Data.DataColumn("DefragInvocations",([string]))
$Col12 =  New-Object system.Data.DataColumn("DefragDays", ([string]))
$Col13 =  New-Object system.Data.DataColumn("FreeSpace", ([string]))
$Col14 =  New-Object system.Data.DataColumn("FreeSpaceDate",([datetime]))

#DBDiskFreePCT, LogDiskFreePCT, DBDiskSize, LogDiskSize, DBDiskFreeMB, LogDiskFreeMB
$Col80 =  New-Object system.Data.DataColumn("DBDiskFreePCT",([string]))
$Col81 =  New-Object system.Data.DataColumn("LogDiskFreePCT",([string]))
$Col82 =  New-Object system.Data.DataColumn("DBDiskSize",([string]))
$Col83 =  New-Object system.Data.DataColumn("LogDiskSize",([string]))
$Col84 =  New-Object system.Data.DataColumn("DBDiskFreeMB",([string]))
$Col85 =  New-Object system.Data.DataColumn("LogDiskFreeMB",([string]))

$Col96 =  New-Object system.Data.DataColumn("Year",([string]))
$Col97 =  New-Object system.Data.DataColumn("Month",([string]))
$Col98 =  New-Object system.Data.DataColumn("Day",([string]))
$Col99 =  New-Object system.Data.DataColumn("CheckDate",([datetime]))

$sqldata.columns.add($Col0 )
$sqldata.columns.add($Col1 )
$sqldata.columns.add($Col2 )
$sqldata.columns.add($Col3 )
$sqldata.columns.add($Col4 )
$sqldata.columns.add($Col5 )
$sqldata.columns.add($Col6 )
$sqldata.columns.add($Col7 )
$sqldata.columns.add($Col8 )
$sqldata.columns.add($Col9 )
$sqldata.columns.add($Col10 )
$sqldata.columns.add($Col11 )
$sqldata.columns.add($Col12 )
$sqldata.columns.add($Col13 )
$sqldata.columns.add($Col14 )

$sqldata.columns.add($Col80 )
$sqldata.columns.add($Col81 )
$sqldata.columns.add($Col82 )
$sqldata.columns.add($Col83 )
$sqldata.columns.add($Col84 )
$sqldata.columns.add($Col85 )

$sqldata.columns.add($Col96 )
$sqldata.columns.add($Col97 )
$sqldata.columns.add($Col98 )
$sqldata.columns.add($Col99 )

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
 
foreach ($hostname in $hostnames) {

   	$dbserver = $hostname
	 
	Write-Host "Server: $dbserver"
	 
	# Get the mailbox databases from the server
	$mbdatabases = Get-MailboxDatabase -Server $dbserver -Status | Sort-Object -Property Name

	# Get the public folder databases from the server
	$pfdatabases = Get-PublicFolderDatabase -Server $dbserver -Status | Sort-Object -Property Name
	  
	# Create an array for the databases
	$databases = @()
	
	# Get disks on Server
	$disks = Get-WmiObject -query "Select * from Win32_Volume" -ComputerName $dbserver | select name, Capacity, FreeSpace
	$disks = $disks | Sort-Object -Property Name
	  
	# Check if mailbox databases were found on the server
	If ($mbdatabases) {
	      # Loop through the databases
	      ForEach ($mdb in $mbdatabases) {
	             # Create an object to store information about the database
	            $db = "" | Select-Object Server, Name,Identity,EdbFilePath,DefragStart,DefragEnd, DefragDuration,DefragInvocations,DefragDays, LastFullBackup, LastIncrementalBackup, StorageGroupName, LogFolderPath, DBDiskFreePCT, LogDiskFreePCT, DBDiskSize, LogDiskSize, DBDiskFreeMB, LogDiskFreeMB
	 			
				$store = get-storagegroup -server $dbserver | where {$_.Name -eq $mdb.StorageGroupName.ToString()}
				
				#, DBDiskFreePCT, LogDiskFreePCT, DBDiskSize, LogDiskSize, DBDiskFreeMB, LogDiskFreeMB
				#Calculate DiskSpace
				$dbdisk = $disks | ? {$mdb.EdbFilePath -like "$($_.Name)*"} | select -Last 1
				$logdisk = $disks | ? {$store.LogFolderPath -like "$($_.Name)*"} | select -Last 1
				
				$dbdisk
				$logdisk
				
	            # Populate the object
				$db.Server = $mdb.Server.ToString()
	            		$db.Name = $mdb.Name.ToString()
	            		$db.Identity = $mdb.Identity.ToString()
	            		$db.EdbFilePath = $mdb.EdbFilePath.ToString()
				$db.LastFullbackup = $mdb.LastFullBackup
				$db.LastIncrementalBackup = $mdb.LastIncrementalBackup
				$db.StorageGroupName = $mdb.StorageGroupName.ToString()
				$db.LogFolderPath = $store.LogFolderPath.ToString()
				
				$db.DBDiskFreePCT = $dbdisk.FreeSpace / $dbdisk.Capacity * 100
				$db.LogDiskFreePCT = $logdisk.FreeSpace / $logdisk.Capacity * 100
				$db.DBDiskSize = [Math]::Round($dbdisk.capacity / 1MB)
				$db.LogDiskSize = [Math]::Round($logdisk.capacity / 1MB)
				$db.DBDiskFreeMB = [Math]::Round($dbdisk.FreeSpace / 1MB)
				$db.LogDiskFreeMB = [Math]::Round($logdisk.FreeSpace / 1MB)
	 
				# Add this database to the array
	            $databases = $databases + $db
	      } 
	}
	 
	# Check if public folder databases were found on the server
	If ($pfdatabases) {
		write-host "PF Found: " $pfdatabases.count
$pfdatabases
	      # Loop through the databases
	      ForEach ($pfdb in $pfdatabases) {
	            # Create an object to store information about the database
	            $db = "" | Select-Object Server,Name,Identity,EdbFilePath,DefragStart,DefragEnd, DefragDuration,DefragInvocations,DefragDays, LastFullBackup, LastIncrementalBackup, StorageGroupName, LogFolderPath, DBDiskFreePCT, LogDiskFreePCT, DBDiskSize, LogDiskSize, DBDiskFreeMB, LogDiskFreeMB
	 
	 			$store = get-storagegroup -server $dbserver | where {$_.Name -eq $mdb.StorageGroupName.ToString()}
				
				#Calculate DiskSpace
				$dbdisk = $disks | ? {$pfdb.EdbFilePath -like "$($_.Name)*"} | select -Last 1
				$logdisk = $disks | ? {$store.LogFolderPath -like "$($_.Name)*"} | select -Last 1				
				
	            # Populate the object
				$db.Server = $pfdb.Server.ToString()
	            		$db.Name = $pfdb.Name.ToString()
	            		$db.Identity = $pfdb.Identity.ToString()
	            		$db.EdbFilePath = $pfdb.EdbFilePath.ToString()
				$db.LastFullbackup = $pfdb.LastFullBackup
				$db.LastIncrementalBackup = $pfdb.LastIncrementalBackup
				$db.StorageGroupName = $pfdb.StorageGroupName.ToString()
				$db.LogFolderPath = $store.LogFolderPath.ToString()

				$db.DBDiskFreePCT = $dbdisk.FreeSpace / $dbdisk.Capacity * 100
				$db.LogDiskFreePCT = $logdisk.FreeSpace / $logdisk.Capacity * 100
				$db.DBDiskSize = [Math]::Round($dbdisk.capacity / 1MB)
				$db.LogDiskSize = [Math]::Round($logdisk.capacity / 1MB)
				$db.DBDiskFreeMB = [Math]::Round($dbdisk.FreeSpace / 1MB)
				$db.LogDiskFreeMB = [Math]::Round($logdisk.FreeSpace / 1MB)		
				
	            # Add this database to the array
	            $databases = $databases + $db
	      } 
	}
	 
	# Retrieve the events from the local Application log, filter them for ESE messages
	#$logs = Get-EventLog -LogName Application -Newest $records -ComputerName $hostname | Where {$_.Source -eq "ESE" -and $_.Category -eq "Online Defragmentation"}
	#$logs = Get-EventLog -LogName Application -After ((Get-Date).AddDays($logSearchDays)) -ComputerName $hostname | Where {$_.Source -eq "ESE" -and $_.Category -eq "Online Defragmentation"}

	$logs = Get-WinEvent -ProviderName "ESE" -ComputerName $hostname -MaxEvents 5000 |?{$_.ID -match "(700|701|703)"}
	$logsfreespace = Get-WinEvent -ProviderName "MSExchangeIS Mailbox Store" -ComputerName $hostname -MaxEvents 5000 |?{$_.ID -eq 1221}

	# Create an array for the output
	$output = @()
	 
	# Loop through each of the databases and search the event logs for relevant messages
	ForEach ($db in $databases) {
	      # Create the search string to look for in the Message property of each log entry
	      $s = "*" + $db.EdbFilePath + "*"
		  Write-Host "Searchstring: $s"
	 
	      # Search for an event 701 or 703, meaning that online defragmentation finished
	      $end = $logs | where {
	            #$_.Message -like "$s" -and ($_.InstanceID -eq 701 -or $_.InstanceID -eq 703)
				$_.Message -like "$s" -and ($_.ID -eq 701 -or $_.ID -eq 703)
	      } | select-object -First 1
	 
	      # Search for the first event 700 which preceeds the finished event
	 
	      $start = $logs | where { 
	            #$_.Message -like "$s" -and $_.InstanceID -eq 700 -and $_.Index -le $end.Index
				$_.Message -like "$s" -and $_.ID -eq 700 -and $_.TimeCreated -lt $end.TimeCreated
	      } | select-object -First 1
	 
	 	# Look through event 1221 to find freespace reported by exchange
			$s1 = "*" + $db.StorageGroupName + "\" + $db.name + "*"
	 	   $FreeSpaceEvent = $logsfreespace | where { $_.Message -like "$s1" } | Select-Object -First 1
	 
	      # Make sure we found both a start and an end message
	      if ($start -and $end) {
	            # Get the start and end times
	            $db.DefragStart = Get-Date([datetime]$start.TimeCreated)
	            $db.DefragEnd = Get-Date([datetime]$end.TimeCreated)
	 
	            # Parse the end event message for the number of seconds defragmentation ran for
	            $end.Message -match "total of .* seconds" >$null
	            $db.DefragDuration = $Matches[0].Split(" ")[2]

	            # Parse the end event message for the number of invocations and days
	            $end.Message -match "requiring .* invocations over .* days" >$null
	            $db.DefragInvocations = $Matches[0].Split(" ")[1]
	            $db.DefragDays = $Matches[0].Split(" ")[4]
				
				#Parse the freespace event    #The database "mailboxStore6\mailboxDatabase6" has 3627 megabytes of free space after online defragmentation has terminated. 	
				$FreeSpace = [DBNull]::Value
				$FreeSpaceDate = [DBNull]::Value
				if ($FreeSpaceEvent) {
					$FreeSpaceEvent.Message -match "has .* megabytes of" >$null
					$FreeSpace = $Matches[0].Split(" ")[1]
					
					$FreeSpaceDate = $FreeSpaceEvent.TimeCreated
				}
							
				$row = $sqldata.NewRow();	
					$row.Server = $db.Server;
					$row.Name = $db.Name;
					$row.Identity = $db.Identity;
					$row.EdbFilePath = $db.EdbFilePath;
					
					$row.LastFullBackup = $db.LastFullBackup;
					$row.LastIncrementalBackup = $db.LastIncrementalBackup;
					$row.StorageGroupName = $db.StorageGroupName;
					$row.LogFolderPath = $db.LogFolderPath;
					
					$row.DefragStart = [datetime]$db.DefragStart;
					$row.DefragEnd = [datetime]$db.DefragEnd;
					$row.DefragDuration = $db.DefragDuration;
					$row.DefragInvocations = $db.DefragInvocations;
					$row.DefragDays = $db.DefragDays;
					$row.FreeSpace = $FreeSpace;
					$row.FreeSpaceDate = $FreeSpaceDate;
					
					$row.DBDiskFreePCT = $db.DBDiskFreePCT;
					$row.LogDiskFreePCT = $db.LogDiskFreePCT;
					$row.DBDiskSize = $db.DBDiskSize;
					$row.LogDiskSize = $db.LogDiskSize;
					$row.DBDiskFreeMB = $db.DBDiskFreeMB;
					$row.LogDiskFreeMB = $db.LogDiskFreeMB;
			
					$row.Year = $Year;
					$row.Month = $Month;
					$row.Day = $Day;
					$row.CheckDate = [datetime]$datetime;
				$sqldata.Rows.Add($row);	

	      } else {
	            # Output a message if start and end events weren't found
	            Write-Host "Unable to find start and end events for database", $db.Identity -ForegroundColor Yellow
	            Write-Host "You probably need to increase the value of `$records." -ForegroundColor Yellow
	            Write-Host
				
				$startfound = $false
				$endfound = $false
				
				if($start) {
	            	# Get the start and end times
	            	$db.DefragStart = Get-Date([datetime]$start.TimeCreated)
					$startfound = $true
	 			}
				
				if ($end) {
					$db.DefragEnd = Get-Date([datetime]$end.TimeCreated)
					
		            # Parse the end event message for the number of seconds defragmentation ran for
		            $end.Message -match "total of .* seconds" >$null
		            $db.DefragDuration = $Matches[0].Split(" ")[2]
		
		            # Parse the end event message for the number of invocations and days
		            $end.Message -match "requiring .* invocations over .* days" >$null
		            $db.DefragInvocations = $Matches[0].Split(" ")[1]
		            $db.DefragDays = $Matches[0].Split(" ")[4]	
					
					$endfound = $true
				}			
				
				#Parse the freespace event
				$FreeSpace = [DBNull]::Value
				$FreeSpaceDate = [DBNull]::Value
				if ($FreeSpaceEvent) {
					$FreeSpaceEvent.Message -match "has .* megabytes of" >$null
					$FreeSpace = $Matches[0].Split(" ")[1]
					
					$FreeSpaceDate = $FreeSpaceEvent.TimeCreated
				}
				
				$row = $sqldata.NewRow();	
					$row.Server = $db.Server;
					$row.Name = $db.Name;
					$row.Identity = $db.Identity;
					$row.EdbFilePath = $db.EdbFilePath;

					$row.LastFullBackup = $db.LastFullBackup;
					$row.LastIncrementalBackup = $db.LastIncrementalBackup;
					$row.StorageGroupName = $db.StorageGroupName;
					$row.LogFolderPath = $db.LogFolderPath;

					if ($startfound) {
						$row.DefragStart = [datetime]$db.DefragStart;
					}
					else {
						$row.DefragStart = [DBNull]::Value ;
					}

					if ($endfound) {
						$row.DefragEnd = [datetime]$db.DefragEnd;
						$row.DefragDuration = $db.DefragDuration;
						$row.DefragInvocations = $db.DefragInvocations;
						$row.DefragDays = $db.DefragDays;
					}
					else {
						$row.DefragEnd = [DBNull]::Value ;
						$row.DefragDuration = [DBNull]::Value ;
						$row.DefragInvocations = [DBNull]::Value ;
						$row.DefragDays = [DBNull]::Value ;
					}
					
					$row.FreeSpace = $FreeSpace;
					$row.FreeSpaceDate = $FreeSpaceDate;

					$row.DBDiskFreePCT = $db.DBDiskFreePCT;
					$row.LogDiskFreePCT = $db.LogDiskFreePCT;
					$row.DBDiskSize = $db.DBDiskSize;
					$row.LogDiskSize = $db.LogDiskSize;
					$row.DBDiskFreeMB = $db.DBDiskFreeMB;
					$row.LogDiskFreeMB = $db.LogDiskFreeMB;
		
					$row.Year = $Year;
					$row.Month = $Month;
					$row.Day = $Day;
					$row.CheckDate = [datetime]$datetime;
				$sqldata.Rows.Add($row);

	      }
	      # Add the data for this database to the output
	      $output = $output + $db
	}
	# Print the output
	$output
	
}

Write-DataTable $sqldata
$sqldata | select server, name, *back* | out-string