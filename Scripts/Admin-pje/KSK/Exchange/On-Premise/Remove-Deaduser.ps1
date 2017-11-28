﻿
$unique = @()

foreach ($mailbox in Get-EccoExMailboxList -Filter {RecipientTypeDetails -eq 'EquipmentMailbox'})
{
    try{
        
        $unique += Get-MailboxPermission -Identity $mailbox.DistinguishedName -ErrorAction Stop | where {$_.IsInherited -eq $false -and $_.User -like '*S-1-5*'} | ForEach-Object { 
    }
    catch{
        Write-output "[$mailbox] - $_.Exception.message"
    }
}

$unique | sort user | Group user | ft name -AutoSize -wrap