cls

Add-PSSnapin Microsoft.Exch*

#Load-EccoModules

#region variables and startup details

$TraceLogFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\TraceLog-MailboxPermission.txt'
$MailboxFARestoreFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\MailboxFARestoreFile.csv'
$MailboxSARestoreFile = 'C:\Scripts\ECCO\Projects\Exchange\Output\MailboxSARestoreFile.csv'

    Remove-Item $TraceLogFile -ErrorAction SilentlyContinue
	Remove-Item "_$MailboxFARestoreFile" -ErrorAction SilentlyContinue
    Remove-Item "_$MailboxSARestoreFile" -ErrorAction SilentlyContinue

	## Add startup details to trace log
#region variables
$global:TraceLog = ""
$global:ErrorMessage = ""
$global:CurrentAction = ""
#endregion 
	$global:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"

	Out-EccoGeLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
	
#endregion

#region 

	foreach ($mailbox in $(Get-EccoExMailboxList -Filter {RecipientTypeDetails -eq 'RoomMailbox'})) 
    {
        
		$FAmember = Get-EccoExMailboxPermission -Mailbox $mailbox.Name
		
		if ($FAmember.Length -gt 0)
        {
			## Normalizing member array
			$FAmember = $FAmember.Split("\").replace("PRD","") | ? {$_}
                

			foreach ($name in $FAmember) 
            {
				if($(Test-EccoADGroupObject -groupname $name))
                {
					$tmp = @()
					
					foreach ($user in $((Get-QADGroupMember -Identity $name -Indirect -Type User).SamAccountName)) 
                    {
						if(Test-EccoADUserObject -username $user -days 90)
                        {  
							Set-EccoExMailboxPermission -mailbox $mailbox.DistinguishedName -user $user
							$tmp += $($user)
						}
					}
					
					Remove-EccoExMailboxPermission $mailbox.DistinguishedName -user $name
					
					$tmp = $tmp -join ","
					
					Out-EccoGeLog "Exporting custom object to csv file [$($MailboxFARestoreFile)]"
					"" | Select @{l="Mailbox";e={$($mailbox.Name)}},`
				       			@{l="Group";e={$($name)}},`
								@{l="User";e={$tmp}} | `
								Export-Csv $MailboxFARestoreFile -NoTypeInformation -Encoding UTF8 -Append
				}
			}
		}
		
		$SAmember = (Get-EccoADSendAsPermission -mailbox $mailbox.Name).RawIdentity
		
		if ($SAmember.Length -gt 0)
        {
			## Normalizing member array
			$SAmember = $SAmember.Split("\").replace("PRD","") | ? {$_}

			foreach ($name in $SAmember) 
            {
				if($(Test-EccoADGroupObject -groupname $name))
                {
					$tmp = @()
					                
					foreach ($user in $((Get-QADGroupMember -Identity $name -Indirect -Type User).SamAccountName)) 
                    {
						if(Test-EccoADUserObject -username $user -days 90)
                        { 
							Add-EccoADSendAsPermission -mailbox $mailbox.Name -user $user
							$tmp += $($user)
						}
					}
					
					Remove-EccoADSendAsPermission -mailbox $mailbox.Name -user $name
					
					$tmp = $tmp -join ","
					
					Out-EccoGeLog "Exporting custom object to csv file [$($MailboxSARestoreFile)]"
					"" | Select @{l="Mailbox";e={$($mailbox.Name)}},`
				       			@{l="Group";e={$($name)}},`
								@{l="User";e={$tmp}} | `
								Export-Csv $MailboxSARestoreFile -NoTypeInformation -Encoding UTF8 -Append
				}
			}
		}
	}
	
#endregion

$global:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"

Out-File -FilePath $TraceLogFile -InputObject $global:TraceLog