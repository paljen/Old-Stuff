Import-Module ActiveDirectory

#Find all AD users with following filter:
#
#   User must be located in prd.eccocorp.net/ECCO or downwards
#   User must be enabled
#   UserPincipalName must end with *ecco.com
#   DistinguishedName must not contain Terminated
#   DistinguishedName must not contain PreStaging
#   DistinguishedName must not contain Sales
#   DistinguishedName must not contain Production

$ADusers = Get-ADUser -SearchBase "OU=ECCO,DC=PRD,DC=ECCOCORP,DC=NET" -Filter * -Properties msDS-cloudExtensionAttribute1 | Where-Object {($_.enabled -eq $True) -and ($_.UserPrincipalName -like "*ecco.com") -and ($_.DistinguishedName -notlike "*Terminated*") -and ($_.DistinguishedName -notlike "*PreStaging*") -and ($_.DistinguishedName -notlike "*Sales*") -and ($_.DistinguishedName -notlike "*Production*")}
#$count = 0
#Write E3 in the msDS-cloudExtensionAttribute1 attribute on all found users

foreach ($ADuser in $ADusers)
{
	
	#$count++
    #Write-Host $ADuser.UserPrincipalName "- Setting msDS-cloudExtensionAttribute1 to E3"
    $ADuser.'msDS-cloudExtensionAttribute1' = "E3"
    Set-ADUser -Instance $ADuser
}
