# global catalog search

# list global catalog servers
#(Get-ADForest).GlobalCatalogs


Get-ADGroupMember "Enterprise admins" -server DKHQPFRD01.eccocorp.net | ForEach-Object {

    "$($_.name)`t$($_.objectclass)"
}