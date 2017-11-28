Import-Module \\prd.eccocorp.net\it\Automation\Repository\Modules\Ecco.MSOnline\Ecco.MSOnline.psd1

remove-aduser -Identity usstore124@ecco.com
Remove-EcMsolUserLicense -UserPrincipalName usstore124@ecco.com -RemoveAll True
Disable-Mailbox -Identity usstore124@ecco.com -PermanentlyDisable
remove-msoluser -UserPrincipalName usstore124@ecco.com
remove-msoluser -UserPrincipalName usstore124@ecco.com -RemoveFromRecycleBin
get-msoluser -all | ?{$_.userprincipalname -like "usstore1*"}