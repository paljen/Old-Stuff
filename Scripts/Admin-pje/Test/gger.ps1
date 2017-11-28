# Script to configure language settings for each user

# Import 'International' module to Powershell session
 #Import-Module International

# Set regional format (date/time etc.) to English (Australia) - this applies to all users
 #Set-Culture en-US

# Set the language list for the user, forcing English (Australia) to be the only language
 #Set-WinUserLanguageList en-US -Force

$user = "dnk"

 $test = (Get-Date).addyears(-2)
 $test
 

# Script specific Variables
$dc = "dkhqdc01.prd.eccocorp.net"
$exportPath = "\\dkhqBackup04\Exchange-PST-Export$"


New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "Received -lt '$test'" -FilePath "$exportPath\$user-1.pst" -confirm:$false
