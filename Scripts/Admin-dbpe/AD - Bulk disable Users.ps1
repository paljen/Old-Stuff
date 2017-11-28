Import-Module activedirectory

$list = Import-CSV D:\Users.csv

forEach ($item in $list) {

$samAccountName = $item.user

Disable-ADAccount -Identity $samAccountName
}