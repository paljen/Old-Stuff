## Orchestrator Server
#$s = New-PSSession -ComputerName DKHQSCORCH01
##exchange Connector
$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://dkhqexc04n01.prd.eccocorp.net/powershell -Authentication Kerberos
Import-PSSession $s
#import-Module -PSSession $s -Name operations*
#Get-Module -PSSession $s -ListAvailable


#Invoke-command { import-module operations* } -session $s
#Export-PSSession -session $s -commandname *-SCOM* -outputmodule RemSCOM -allowclobber