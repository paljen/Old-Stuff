cls

if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available"){
	$ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
	Import-PSSession $ExSession
}


function Get-MailboxList{
	Return 	$(Get-Mailbox -Filter "RecipientTypeDetails -eq 'RoomMailbox' -or `
						  		   RecipientTypeDetails -eq 'EquipmentMailbox' -or `
						      	   RecipientTypeDetails -eq 'SharedMailbox'")
}

function Get-Permissions{
	param(
		[String]$mailbox
	)
	
	Return $(Get-MailboxPermission -Identity $mailbox | where {$_.IsInherited -eq $false -and `
															   $_.User -notlike "NT AUTHORITY*" -and `
															   $_.User -notlike "PRD\ArchiveManagerServiceUsers"}).User
}

function Validate-Group {
	param(
		[String]$name
	)
	
	return $(Get-ADObject -Filter {(Name -eq $name) -and (objectClass -eq "group")})
}

function AppendLog ([string]$Message){
    $script:CurrentAction = $Message
    $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
}

## Set variables to defaults
$ErrorState = 0 ## 0=Success,1=Warning,2=Error,3=Critical Error
$ErrorMessage = ""
$script:TraceLog = ""
$script:CurrentAction = ""
$mailboxGroupSecFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\mailboxGroupSecFile.txt'
$mailboxUserSecFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\mailboxUserSecFile.csv'

## Add startup details to trace log
$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
AppendLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

foreach ($mailbox in $(Get-MailboxList)) {
	
	#$member = Get-Permissions $mailbox.Name
	
	if ($(Get-Permissions $mailbox.Name).Length -gt 0){
		$member = $(Get-Permissions $mailbox.Name).Split("\").replace("PRD","") | ? {$_}
		foreach ($name in $member) {
			if($(Validate-Group $name)){
				
			"" | Select @{l="Mailbox";e={$($mailbox.Name)}},`
		       			@{l="Group";e={$($name)}},`
			   			@{l="User";e={$((Get-QADGroupMember -Identity $name -Indirect -Type User).name)}} | `
						Export-Csv $mailboxUserSecFile -NoTypeInformation -Append
			}	
		}
	}
	
	else{"$($mailbox.name) - INGEN rettigheder" | Out-File 'C:\Scripts\ECCO\Projects\Exchange\Output\NoRights.txt' -Append}
}

$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File -FilePath $LogFile -InputObject $script:TraceLog
