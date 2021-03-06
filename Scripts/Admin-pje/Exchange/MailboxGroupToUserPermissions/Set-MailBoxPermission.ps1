cls

if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available"){
	$ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
	Import-PSSession $ExSession
}


function Get-MailboxList{

	AppendLog "Creating MailboxList...."
	Return 	$(Get-Mailbox -Filter "RecipientTypeDetails -eq 'RoomMailbox' -or `
						  		   RecipientTypeDetails -eq 'EquipmentMailbox' -or `
						      	   RecipientTypeDetails -eq 'SharedMailbox'")
}

function Get-Permissions{
	param(
		[String]$mailbox
	)
	
	AppendLog "Getting MailboxPermission on Mailbox [$($mailbox)]"
	Return $(Get-MailboxPermission -Identity $mailbox | where {$_.IsInherited -eq $false -and `
															   $_.User -notlike "NT AUTHORITY*" -and `
															   $_.User -notlike "PRD\ArchiveManagerServiceUsers"}).User
}

function Validate-Group {
	param(
		[String]$name
	)
	
	AppendLog "Validating Group [$($Name)]"
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
$TraceLogFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\TraceLog.txt'
$mailboxUserSecFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\mailboxUserSecFile.csv'

## Add startup details to trace log
$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
AppendLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

try {

	foreach ($mailbox in $(Get-MailboxList)) {
		
		if ($(Get-Permissions $mailbox.Name).Length -gt 0){
		
			$member = $(Get-Permissions $mailbox.Name).Split("\").replace("PRD","") | ? {$_}
			
			foreach ($name in $member) {
			
				if($(Validate-Group $name)){
				
				AppendLog "Exporting custom object to csv file [$($mailboxUserSecFile)]"
				"" | Select @{l="Mailbox";e={$($mailbox.Name)}},`
			       			@{l="Group";e={$($name)}},`
				   			@{l="User";e={$((Get-QADGroupMember -Identity $name -Indirect -Type User).name)}} | `
							Export-Csv $mailboxUserSecFile -NoTypeInformation -Append
				}	
			}
		}
		
		else{
		
			Continue
		}
	}
}

catch {
	$ErrorMessage = $error[0].Exception.Message
	AppendLog "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
}

$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File -FilePath $TraceLogFile -InputObject $script:TraceLog




