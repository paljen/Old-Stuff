cls

$root = "OU=Temp-KFT,DC=prd,DC=eccocorp,DC=net"
$path = Split-Path -Parent $MyInvocation.MyCommand.Definition
$cont = import-csv "$path\final.csv"
$man = "ALM"

foreach ($c in $cont)
{
    if($c.Name -ne "Ecco Services")
    {
        $path = "$($c.OU),$root"
        New-ADOrganizationalUnit -Path $path -Name $c.Name -ProtectedFromAccidentalDeletion $false -ManagedBy $man -Description $c.Description

        if ($c.Name -ne "Technical Services"-and $c.Name -ne "Business Services")
        {
            $path = "OU=$($c.Name),$($c.OU),$root"
            New-ADOrganizationalUnit -Path $path -Name "Servers" -ProtectedFromAccidentalDeletion $false -ManagedBy $man
            New-ADOrganizationalUnit -Path $path -Name "Groups" -ProtectedFromAccidentalDeletion $false -ManagedBy $man
            New-ADOrganizationalUnit -Path $path -Name "Service Accounts" -ProtectedFromAccidentalDeletion $false -ManagedBy $man
        }
    }

    else
    {
        $path = $root
        New-ADOrganizationalUnit -Path $path -Name $c.Name -ProtectedFromAccidentalDeletion $false -ManagedBy $man
    }   
}
