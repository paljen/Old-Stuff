#Data table
$output = New-Object system.Data.DataTable

$Col1 =  New-Object system.Data.DataColumn("User",([string]))
$Col2 =  New-Object system.Data.DataColumn("Database",([string]))
$Col3 =  New-Object system.Data.DataColumn("Size",([string]))
$Col4 =  New-Object system.Data.DataColumn("Year",([string]))
$Col5 =  New-Object system.Data.DataColumn("Month",([string]))
$Col6 =  New-Object system.Data.DataColumn("Day",([string]))
$Col7 =  New-Object system.Data.DataColumn("CheckDate",([string]))

$output.columns.add($Col1 )
$output.columns.add($Col2 )
$output.columns.add($Col3 )
$output.columns.add($Col4 )
$output.columns.add($Col5 )
$output.columns.add($Col6 )
$output.columns.add($Col7 )


#Prep date and others for datatable
$Datetime = Get-Date
$Year = $Datetime.Year
$Month = $Datetime.Month
$Day = $Datetime.Day


#Get Users in CNSA
$cnsausers = get-user -resultsize unlimited | where {$_.Identity -match "prd.eccocorp.net/ECCO/CN/SA*"}
$cnsamailboxes = $cnsausers | Get-Mailbox

#Get system data
$databases = Get-MailboxDatabase
$Counter = 1
foreach($db in $databases)
{
     #$mailboxes = Get-Mailbox -Database $database -resultsize unlimited
	 #$mailboxes = Get-MailboxDatabase $db | Get-MailboxStatistics | where {$_.ObjectClass –eq “Mailbox”} | Select Database, TotalItemSize, TotalDeletedItemSize, identity, displayname
     $mailboxes = Get-MailboxDatabase $db | Get-MailboxStatistics | Select Database, TotalItemSize, TotalDeletedItemSize, identity, displayname
     
	 foreach($mailbox in $mailboxes)
     {
       	$SAM = $null
		$SamAccountName =  get-user -identity $mailbox.Identity.ToString() |select-object SamAccountName
		$AccountStatus = get-user -identity $mailbox.Identity.ToString() |select-object UserAccountControl
		$AccountType = get-user -identity $mailbox.Identity.ToString() |select-object RecipientTypeDetails
		
      #  $mailbox | fl *
      #  $cnsamailboxes[0] | fl *
        
        if ($cnsamailboxes.samaccountname -contains $SamAccountName) {
            write-host "Found a mailbox"        
    		if ($AccountStatus -match "AccountDisabled" -and $AccountType -match "UserMailbox" ) {}
    		else {
    			if ($SamAccountName -eq $null) {
    				$SAM = $mailbox.displayname
    			}
    			else {
    				$SAM = $SamAccountName.SamAccountName
    			}
    		
    					
    			$totsize = ($mailbox.TotalItemSize.Value.ToMB() + $mailbox.TotalDeletedItemSize.Value.ToMB())
    			$row = $output.NewRow();
    				$row.User = $SAM;
    				$row.Database = $mailbox.Database;
    				$row.Size = $totsize;
    				$row.Year = $Year;
    				$row.Month = $Month;
    				$row.Day = $Day;
    				$row.CheckDate = $datetime;
    			$output.Rows.Add($row);		
    			$row | ft
    		}
         }
     }
	 $tot =  $databases.count
	 Write-Host "Done with: $db ($counter/$tot)"
	 $counter = $Counter + 1
}

#Write Dataset to DB
#Write-DataTable $output 

$output