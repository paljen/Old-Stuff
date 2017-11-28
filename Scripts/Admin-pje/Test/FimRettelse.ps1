﻿$dl = "PJE-TEST1"
$grp = "PJE-TEST2"

#ACTIVE

Write-Host "ActiveDirectory`n" -ForegroundColor Red
Get-ADGroupMember $grp -ErrorAction Stop | ForEach-Object {

Write-output "Adding $_.SamAccountName to All.EccoShops"}
#Add-ADGroupMember -Identity $dl -Members $_.SamAccountName -ErrorAction Stop}

#QUEST

Write-Host "Quest" -ForegroundColor Red
Get-QADGroupMember $grp -ErrorAction Stop | ForEach-Object {

Write-output "Adding $($_.DN) to $dl"
Add-QADGroupMember -Identity $dl $_.DN -ErrorAction Stop}



(Get-ADGroupMember -Identity $dl -ErrorAction Stop | Where {($_.objectClass -match 'User')}) | ForEach-Object {
    AppendLog "Removing $_.SamAccountName From $dl"
    Remove-ADGroupMember -Identity $dl -Member $_.SamAccountName -Confirm:$false -ErrorAction Stop
}