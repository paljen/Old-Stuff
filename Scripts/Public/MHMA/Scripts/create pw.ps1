Write-Host "Please enter the username, case sensitive"
Write-Host "eg: Service-XXXXxxx"

$user = Read-Host "Service Account name: "
$key = "ecc0sh0esr0ck"

C:\Powershell\Scripts\passgen.exe -g $user $key