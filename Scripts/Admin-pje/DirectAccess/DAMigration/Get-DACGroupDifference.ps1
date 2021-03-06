$group1 = (Get-ADGroupMember -Identity "SEC-Global DirectAccess Clients").name 
$group2 = (Get-ADGroupMember -Identity "SEC-Global DirectAccess HQ Access Win7 Clients").name 
$group3 = (Get-ADGroupMember -Identity "SEC-Global DirectAccess Win8 Clients").name 

if(diff -ReferenceObject $group1 -DifferenceObject $group2 -IncludeEqual -ExcludeDifferent -OutVariable diff12){
	Write-Output "Equals SEC-Global DirectAccess Clients vs. SEC-Global DirectAccess HQ Access Win7 Clients"
	$diff12
}

if(diff -ReferenceObject $group1 -DifferenceObject $group3 -IncludeEqual -ExcludeDifferent -OutVariable diff13){
	Write-Output "Equals SEC-Global DirectAccess Clients vs. SEC-Global DirectAccess Win8 Clients"
	$diff13
}

if(diff -ReferenceObject $group2 -DifferenceObject $group3 -IncludeEqual -ExcludeDifferent -OutVariable diff23){
	Write-Output "Equals SEC-Global DirectAccess HQ Access Win7 Clients vs. SEC-Global DirectAccess Win8 Clients"
	$diff23
}
