#Add-PSSnapin Quest.ActiveRoles.ADManagement
Import-Module MSOnline
Import-Module MSOnlineExtended

$pwdfile = "C:\Powershell\Password.txt"
$pass = get-content $pwdfile | convertto-securestring
$MSOLogin = New-Object System.Management.Automation.PSCredential ("AzService-AADSync@ecco.onmicrosoft.com", $pass)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $MSOLogin -Authentication Basic -AllowRedirection
Set-ExecutionPolicy Unrestricted -force
Import-PSSession $Session
Connect-MsolService -Credential $MSOLogin

Get-Mailboxsearch
