
$groups = get-adgroup -SearchBase "OU=Network,OU=ADMIN ROLES,OU=CENTRALLY MANAGED,OU=Groups,dc=prd,dc=eccocorp,dc=net" -Filter * 

foreach ($g in $groups)
{
    foreach ($m in (get-adgroupmember -Identity $g.name))
    {
        $text += "$($g.name)`t$($m.name)`t$($m.objectclass)"
    }
}



