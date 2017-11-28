Function Get-PrimaryUser1
{
    # Get computername
    $cn = (Get-WmiObject -Class Win32_ComputerSystem).name

    # Collect primary user information
    $wcf = New-WebServiceProxy -Uri "http://dkhqsccm02.prd.eccocorp.net/CMLib/CMLib.svc"

    ## If no primary user is defined set primary user to nothing
    if($wcf.GetDevicePrimaryUsers($cn) -ne "")
    {
        $pu = $wcf.GetDevicePrimaryUsers($cn)
    }
    else
    {
        $pu = ""
    }

    $pu
}

Get-PrimaryUser1