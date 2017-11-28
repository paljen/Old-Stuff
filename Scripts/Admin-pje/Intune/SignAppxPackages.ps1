$InputAppx = "\\prd.eccocorp.net\it\CMSource\Mobile Device Management\Apps\ECCO Fiori\ECCOFiori_DEV_1.1.0.4_ARM.APPX"
$outputAppx = "\\prd.eccocorp.net\it\CMSource\Mobile Device Management\Apps\ECCO Fiori\ECCOFiori_DEV_1.1.0.4_Signed.APPX"
#$InputAppx = "\\prd.eccocorp.net\it\CMSource\Mobile Device Management\Apps\ECCO Fiori\ECCOFiori_TEST_1.1.0.1_ARM.APPX"
#$outputAppx = "\\prd.eccocorp.net\it\CMSource\Mobile Device Management\Apps\ECCO Fiori\ECCOFiori_TEST_1.1.0.1_Signed.APPX"

$PfxFilePath = "\\prd.eccocorp.net\it\CMSource\Toolbox\SCCM Symantec Code signing - Password.pfx"
$AetxPath = "\\prd.eccocorp.net\it\cmsource\Toolbox\AET.aetx"

$psw = "Ecc0sh0esr0ck"


& (. \\prd.eccocorp.net\it\CMSource\Toolbox\Sign-WinPhoneCompanyPortal.ps1 -InputAppx $InputAppx -OutputAppx $outputAppx -PfxFilePath $PfxFilePath -PfxPassword $psw -AetxPath $AetxPath )