cls

Add-PSSnapin Microsoft.Exch*

#Load-EccoModules

$TraceLogFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\TraceLog-RevertMailboxPermission.txt'
$MailboxFARestoreFile = Import-Csv c:\Scripts\ECCO\Projects\Exchange\Output\MailboxFARestoreFile.csv
$MailboxSARestoreFile = Import-Csv c:\Scripts\ECCO\Projects\Exchange\Output\MailboxSARestoreFile.csv

## Add startup details to trace log
$global:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"

Out-EccoGeLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

foreach ($item in $MailboxFARestoreFile) 
{	
	$user = $($item.user).Split(",") | ? {$_}
	
	foreach ($usr in $user) 
	{
		Remove-EccoExMailboxPermission $item.Mailbox $usr
	}
	
	Set-EccoExMailboxPermission $item.Mailbox $item.Group
}

foreach ($item in $MailboxSARestoreFile) 
{	
	$user = $($item.user).Split(",") | ? {$_}
	
	foreach ($usr in $user) 
	{
		Remove-EccoADSendAsPermission -mailbox $item.mailbox -user $usr	
	}
	
	Add-EccoADSendAsPermission -mailbox $item.mailbox -user $item.Group
}

$global:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"

Out-File -FilePath $TraceLogFile -InputObject $global:TraceLog

Rename-Item -Path c:\Scripts\ECCO\Projects\Exchange\Output\MailboxFARestoreFile.csv -NewName _MailboxFARestoreFile.csv
Rename-Item -Path c:\Scripts\ECCO\Projects\Exchange\Output\MailboxSARestoreFile.csv -NewName _MailboxSARestoreFile.csv