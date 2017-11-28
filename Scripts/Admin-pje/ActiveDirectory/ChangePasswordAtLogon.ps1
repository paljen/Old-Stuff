Get-ADUser -Filter * -SearchBase "OU=Ecco,dc=prd,dc=eccocorp,dc=net" -Properties passwordlastset | 
    ? {$_.passwordlastset -eq $null -and $_.enabled -eq $true} | ForEach-Object {
        Set-ADUser -Identity $_.SamAccountName -PasswordNeverExpires $false -ChangePasswordAtLogon $true -whatif
}
