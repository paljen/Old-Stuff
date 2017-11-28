
Get-ADUser -Filter * -Properties Telephonenumber | ForEach-Object {
    if($_.Telephonenumber -ne $null -and $_.Telephonenumber -match "[+]\d{2}0\d*" -and $_.Enabled -eq $true)
    {
        "$($_.Name),$($_.SAMAccountName),$($_.Telephonenumber)" | Out-File "$env:temp\TLFRegex.txt" -Append
    }
}
