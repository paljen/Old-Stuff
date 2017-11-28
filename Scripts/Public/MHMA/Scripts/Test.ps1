Push-Location
Set-Location HKLM:
[bool] $exists = Test-Path ".\Software\ECCO IT"
$Name = "DeploymentVersion"
$Path = "HKLM:\SOFTWARE\ECCO IT\"
$DeplVersion = "1"

Set-ItemProperty -Path $Path -Name "HasLocalGprs" -Value $LclGrp