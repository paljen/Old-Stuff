$diff = New-Object System.Collections.ArrayList

$user = Get-ADUser -SearchBase "OU=Externals,DC=prd,DC=eccocorp,DC=net" -Filter * -ErrorAction Stop | Select givenname,surname,name,samaccountname
#$user = Get-ADUser -SearchBase "OU=Ecco,DC=prd,DC=eccocorp,DC=net" -Filter * -ErrorAction Stop | Select givenname,surname,name,samaccountname

ForEach ($u in $user) {

    [void]$diff.Add("$($u.Givenname) $($u.surname)")

}

$ht = @{}
$diff | foreach {$ht["$_"] += 1}
$ht.keys | where {$ht["$_"] -gt 1} | foreach {write-host "Duplicate element $_" }

$diff.clear

