cls

Add-EccoGeQADSnapin;Import-EccoGeADModule;Import-EccoGeExchSession

#region variables and startup details

	$TraceLogFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\TraceLog-MailboxPermission.txt'
	$MailboxFARestoreFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\MailboxFARestoreFile.csv'
	$MailboxSARestoreFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\MailboxSARestoreFile.csv'


	if($MailboxRestoreFile){
		Remove-Item $MailboxRestoreFile}

	## Add startup details to trace log
	$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
	Out-EccoGeLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
	
#endregion

#region Set FullAccess Permission

	foreach ($mailbox in $(Get-EccoExMailboxList)) {
		$member = Get-EccoExMailboxPermission -mailbox $mailbox.Name
		
		if ($member.Length -gt 0){
			## Normalizing member array
			$member = $member.Split("\").replace("PRD","") | ? {$_}

			foreach ($name in $member) {
				if($(Test-EccoADGroupObject -groupname $name)){
				
					$tmp = @()
					
					foreach ($user in $((Get-QADGroupMember -Identity $name -Indirect -Type User).SamAccountName)) {
					
						if(Test-EccoADUserObject -username $user -days 90){  
							Set-EccoExMailboxPermission -mailbox $mailbox -user $user
							$tmp += $($user)
						}
					}
					
					#Remove-EccoExMailboxPermission $mailbox -user $name
					
					$tmp = $tmp -join ","
					
					Out-EccoGeLog "Exporting custom object to csv file [$($MailboxRestoreFile)]"
					"" | Select @{l="Mailbox";e={$($mailbox.Name)}},`
				       			@{l="Group";e={$($name)}},`
								@{l="User";e={$tmp}} | `
								Export-Csv $MailboxFARestoreFile -NoTypeInformation -Encoding UTF8 -Append
				}
			}
		}
		
		else{
			Continue
		}
	}
	
#endregion

#region Set Send-As Permission

foreach ($mailbox in $(Get-EccoExMailboxList)) {
	$member = Get-EccoExMailboxPermission -mailbox $mailbox.Name
	
	if ($member.Length -gt 0){
		## Normalizing member array
		$member = $member.Split("\").replace("PRD","") | ? {$_}

		foreach ($name in $member) {
			if($(Test-EccoADGroupObject -groupname $name)){
			
				$tmp = @()
				
				foreach ($user in $((Get-QADGroupMember -Identity $name -Indirect -Type User).SamAccountName)) {
				
					if(Test-EccoADUserObject -username $user -days 90){  
						Set-EccoExMailboxPermission -mailbox $mailbox -user $user
						$tmp += $($user)
					}
				}
				
				#Remove-EccoExMailboxPermission $mailbox -user $name
				
				$tmp = $tmp -join ","
				
				Out-EccoGeLog "Exporting custom object to csv file [$($MailboxRestoreFile)]"
				"" | Select @{l="Mailbox";e={$($mailbox.Name)}},`
			       			@{l="Group";e={$($name)}},`
							@{l="User";e={$tmp}} | `
							Export-Csv $MailboxRestoreFile -NoTypeInformation -Encoding UTF8 -Append
			}
		}
	}
	
	else{
		Continue
	}
}

#endregion

$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File -FilePath $TraceLogFile -InputObject $script:TraceLog