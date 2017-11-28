
$wcf = New-WebServiceProxy -Uri "http://dkhqsccm02.prd.eccocorp.net/CMLib/CMLib.svc" 
$wcf.GetDevicePrimaryUsers($((gwmi win32_computersystem).name))
if ($wcf.GetDevicePrimaryUsers('DK4841') -match "")
{
    $user = (gwmi win32_process -Filter "Name = 'explorer.exe'").getowner()
    Write-Host "Logged on user: $($user.Domain)\$($user.User)"    
}
else
{
    $wcf.GetDevicePrimaryUsers("DK4841")
    }


