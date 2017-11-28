
##### Account information #####
$AdminName = "AzService-License@ecco.onmicrosoft.com"
$CredFile = "AzService-License-PowershellCreds.txt"

##Update Password file
#Read-Host -AsSecureString -Prompt "Password: " | ConvertFrom-SecureString | Out-File $CredFile

$password = get-content -path $CredFile | convertto-securestring
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName,$password
###############################

##### Other Input ######
$LicProfileFile = "LicenseProfiles.csv"
$AccountSKUidMappingFile = "AccountSKUs.csv"
########################


#Connect to MSOL Service
Connect-MsolService -Credential $Cred

#Get License Profiles and account sku mapping
$LicenseProfiles = Import-Csv -Path $LicProfileFile -Delimiter ";"
$AccountSKUMap = Import-Csv -Path $AccountSKUidMappingFile -Delimiter ";"

#Get all O365 users with licenses, check AD Account
#Deleted, disabled users?
#O365 assigned, but no license assigned in AD?
Write-Host "Processing O365 Users..." -BackgroundColor White -ForegroundColor Black
$LicensedUsers = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq 'True'}
#$LicensedUsers = Get-MsolUser -UserPrincipalName skja@ecco.com | Where-Object {$_.IsLicensed -eq 'True'}

$LicenseOverview = @()

$i = 0
Foreach ($LicensedUser in $LicensedUsers) {

    Write-Progress -Activity “Processing O365 Users” -status “Processed $i” -percentComplete ($i / $licensedusers.count*100)
    $i++

    $UPN = $LicensedUser.userprincipalname
    $ADUser = Get-ADUser -filter {UserPrincipalName -eq $UPN} -Properties msDS-cloudExtensionAttribute1, UserPrincipalName, Enabled, CanonicalName

    $tmpADFound = "False"
    $tmpADCanonicalName = ""
    $tmpADEnabled = ""
    $tmpMsDsCEA1 = ""
    
    if ($ADUser) {
        # AD User found
        $tmpADCanonicalName = $ADUser.CanonicalName
        $tmpADFound = "True"
        $tmpADEnabled = $ADUser.Enabled
        $tmpMsDsCEA1 = $ADUser."msDS-cloudExtensionAttribute1"
    }

    $TempResults = New-Object PSObject;
    
    $TempResults | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $LicensedUser.UserPrincipalName;
    $TempResults | Add-Member -MemberType NoteProperty -Name "ADCanonicalName" -Value $tmpADCanonicalName;
    $TempResults | Add-Member -MemberType NoteProperty -Name "ADFound" -Value $tmpADFound;
    $TempResults | Add-Member -MemberType NoteProperty -Name "ADEnabled" -Value $tmpADEnabled;
    
    if($ADUser) { $TempmsDSCEA1 = $ADUser."msDS-cloudExtensionAttribute1" } Else { $TempmsDSCEA1 = "N/A" }
    $TempResults | Add-Member -MemberType NoteProperty -Name "msDS-cloudExtensionAttribute1" -Value $TempmsDSCEA1;

    # Loop through User Assigned Licenses
    Foreach ($AccountSKU in $AccountSKUMap) {
        $tmpVarName = $AccountSKU.AccountSKUid + " (" + $AccountSKU.Friendlyname + ")"
        $LicRes = $LicensedUser.licenses | ? {$_.AccountSkuId -eq $AccountSKU.AccountSKUid}
        if($LicRes) {
            
            $TempResults | Add-Member -MemberType NoteProperty -Name $tmpVarName -Value 1; 
        }
        Else {
            $TempResults | Add-Member -MemberType NoteProperty -Name $tmpVarName -Value 0; 
        } 
    }
     
    $LicenseOverview += $TempResults;

}
Write-Host "Processed " $LicensedUsers.Count " O365 Users..." -BackgroundColor White -ForegroundColor Black

$LicenseOverview | select -first 10 | fl *
$LicenseOverview | Export-Csv -Path "LicenseOverview.csv" -Delimiter ";" -NoTypeInformation -Encoding Unicode -Force

