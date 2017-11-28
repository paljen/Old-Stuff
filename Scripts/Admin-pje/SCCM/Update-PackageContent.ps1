# ==============================================================================================
# 
# NAME: Update-PackageContent.ps1
# 
# AUTHOR: Palle Jensen
# DATE  : 16-11-2015
# 
# COMMENT: Force a refresh on a Package
#
#					
# ==============================================================================================

$PackageID = ""
$CMProvider = ""
$CMSiteCode = ""
$CMNamespace = $("root\sms\site_$CMSiteCode")
$Query = "Select * From SMS_DistributionPoint WHERE PackageID='$PackageID'"
$Status = "success"

try
{
    $pkgs = Get-WmiObject -ComputerName $CMProvider -Namespace $CMNamespace -Query $Query -ErrorAction Stop
        
    if ($pkgs -eq $null) 
    { 
        Throw "Package is empty"
    }

    else
    {
        foreach ($pkg in $pkgs)
        {
            $pkg.RefreshNow = $true
            [Void]$pkg.Put()
       }
    }
}

catch
{
     $Message = "Exception caught: $($error[0].Exception.Message)"
     $Status = "failed"
}