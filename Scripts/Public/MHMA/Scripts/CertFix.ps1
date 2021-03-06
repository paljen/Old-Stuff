#Create string based on Computername
$CertSub = "CN="+$Env:COMPUTERNAME+".prd.eccocorp.net"
$LogPath = "\\DKHQFILE01\DKHQ-Common\DA\"+$Env:COMPUTERNAME+".txt"

#Change to Cert Store
Set-Location Cert:\LocalMachine\My

#Find Cert
$Cert = Get-ChildItem | where {$_.Subject -eq $CertSub}
$FullPath = "cert:\LocalMachine\My\"+$Cert.Thumbprint

if ($Cert.Issuer -like "CN=ECCOIssuingCA01, DC=prd, DC=eccocorp, DC=net")
{
	#Delete the Certificate
	Remove-Item $FullPath

	#Dirty fix, sleep 15 seconds, and update GPI
	sleep -Seconds 15
	gpupdate /force
	
	cd C:
	New-Item $LogPath -ItemType File
}

if ($Cert.Issuer -like "CN=ECCOIssuingCA02, DC=prd, DC=eccocorp, DC=net")
{
	#Delete the Certificate
	Remove-Item $FullPath

	#Dirty fix, sleep 15 seconds, and update GPI
	sleep -Seconds 15
	gpupdate /force
	
	cd C:
	New-Item $LogPath -ItemType File
}