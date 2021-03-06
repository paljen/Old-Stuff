$Error.Clear()

## Getting all DistributionsGroups from SearchBase OU
$allDL = ((Get-ADGroup -SearchBase "OU=Distribution Lists,OU=EXCHANGE,DC=prd,DC=eccocorp,DC=net" -Filter `
		 {((GroupCategory -eq "Distribution") -and (Name -notlike "*O_*") -and (Name -notlike "*N_*"))}).SamAccountName)

foreach ($dl in $allDL) {
	
	## Enumerate each DistributionsGroup (objectClass=User) and remove each user from the DistributionGroup
	(Get-ADGroupMember -Identity $dl | Where {($_.objectClass -match 'User')}) | ForEach-Object {Remove-ADGroupMember -Identity $dl -Member $_.SamAccountName -Verbose -Confirm:$false}

	## Enumerate InnerGroups (objectClass=Group,Name like O_* and N_*) and add the returning members to the DistributionGroup
	$iGroups = ((Get-ADGroupMember -Identity $dl | where {($_.name -like 'O_*' -or $_.name -like 'N_*') -and ($_.objectClass -match 'Group')}).SamAccountName)
	
	foreach ($grp in $iGroups) {
		Write-Host "Adding members from $grp to Distribution group : $dl"
		Get-ADGroupMember $grp | ForEach-Object {Add-ADGroupMember -Identity $dl -Members $_.SamAccountName -Verbose}
	}	
}