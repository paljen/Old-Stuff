<#
Get-ADUser -Filter {(Enabled -eq $true)} | ForEach-Object {
    
    Get-Mailbox $_.SamAccountName -ErrorAction SilentlyContinue | 
    Where {$_.RecipientTypedetails -eq "Usermailbox"} | 
    Select Samaccountname, OrganizationalUnit, Displayname} | 
    Out-EccoExcel
#>


Get-ADUser -Filter {(Enabled -eq $false)} | ForEach-Object {
    
    Get-Mailbox $_.SamAccountName -ErrorAction SilentlyContinue | 
    Where {$_.RecipientTypedetails -eq "Usermailbox"} | 
    Select Samaccountname, OrganizationalUnit, Displayname} | 
    Out-EccoExcel


#$time = (get-date).AddDays(-90)
#(Get-ADUser -Filter {(Enabled -eq $false)}).count
#(Get-ADUser -Filter {(Enabled -eq $false -and Lastlogondate -lt $time)}).count
#(Get-ADUser -Filter {(Enabled -eq $false)} | % {Get-Mailbox $_.SamAccountName -ErrorAction SilentlyContinue | Where {$_.RecipientTypedetails -eq "Usermailbox"}}).count
