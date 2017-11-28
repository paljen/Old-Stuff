Function Set-EcMsolUserLicense {
                                                                                        <#
.SYNOPSIS
	Assigns or updates a users O365 license profile

.DESCRIPTION
	This function updates a users license profile, please note that assigning two licenses 
    with the same options can possible result in an error due to matching license options
    in the license profiles such as MCOSTANDARD in E4 and E5.
    In general a user should not have more than one license level assigned!

.PARAMETER  UserPrincipalName
    UPN of the user, format: xxxx@ecco.com

.PARAMETER LicenseType
    Choose the license profile to assign to the user.

.PARAMETER AssignIfLicensed
    If the user already has a license assigned this will control the behavior
    If $true: Will try to add an additional License
    If $false: Will not add an additional license.

    Please note: Some licenses such as visio, power bi or similiar will not interfere
    with the normal E1 - E5 licenses, in this case please use $true to add the additional license.

.PARAMETER UpdateSameLicense
    Used to add or remove components of a license allready assigned to the user.
    If $true: Changes the users licenses profile to the profile specified in <LicenseType>
    If $False: Will not update the users same license with the profile specified in <LicenseType>

.EXAMPLE
    Set-ecMSOLUserLicense -UserPrincipalName skja_retailmanager@ecco.com -LicenseType E5-NoExch -AssignIfLicensed $false -UpdateSameLicense $true

    Assigns an E5 License without exchange components to user with UPN skja_retailmanager@ecco.com.
    Will not assign if the user already has another license assigned.
    Will update the license profile if user has the same license level (E5), eg. removing exchange components.

.INPUTS
	None

.OUTPUTS
	None

.NOTES
	Version:		1.0.0
	Author:			Admin-SKJA
	Creation Date:	15-06-16
	Purpose/Change:	Initial Script development - func.skja.msonline.ps1
    #>

    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$UserPrincipalName,

        #License Profile to be added
        [Parameter(Mandatory=$true)]
        [ValidateSet("E5-Full", "E5-NoExch", "E4-Full", "E4-NoExch", "E3-Full", "E3-NoExch", "E1-Full", "EOP1", "StaffHub", "EMS")]
        [String]$LicenseType,

        #Also assign if user has a different license?
        [Parameter(Mandatory=$true)]
        [ValidateSet($true, $false)]
	    [String]$AssignIfLicensed,

        #Also assign if user has a different license?
        [Parameter(Mandatory=$true)]
        [ValidateSet($true, $false)]
	    [String]$UpdateSameLicense
    )

    Process {
    # Stop Script if an exception occour
    $ErrorActionPreference = "Stop"

   
       Try {
            #First get the MSOL user object
            $User = Get-MsolUser -UserPrincipalName $UserPrincipalName

            #Check for usage location! if missing a license cannot be assigned!
            if (!$user.UsageLocation) {
                Write-host "Usage location not set for user, unable to assign license!" -ForegroundColor Black -BackgroundColor Yellow
                Write-host "Use: Set-ecMSOLUserLocation to set UsageLocation for user"
            }

            #Get the requested license profile from the licprofilearray
            $NewLicense = Get-ecMSOLLicenseProfile -LicenseProfile $LicenseType   #$LicProfileArray | ?{$_.LicenseType -eq $LicenseType}
            If ($NewLicense.AllEnabled -eq $true) {
                #Create license options with all enabled
                $NewLicenseLO = New-MsolLicenseOptions -AccountSkuId $NewLicense.AccountSkuId
            }
            Else {
                #Create license options with disabled components
                $NewLicenseLO = New-MsolLicenseOptions -AccountSkuId $NewLicense.AccountSkuId -DisabledPlans $NewLicense.DisabledPlans
            }

            If ($user.licenses) {

                If($User.Licenses | ? {$_.AccountSkuId -eq $NewLicense.AccountSkuID}) {
                    If ($UpdateSameLicense -eq $true) {
                        Write-Host "Updating assigned license with requested profile" -ForegroundColor Black -BackgroundColor Yellow
                        ### TBD Update license ###
                        $user | Set-MsolUserLicense -LicenseOptions $NewLicenseLO
                        Update-ecMSOLUserLicenseInAD -UserPrincipalName $UserPrincipalName -LicenseProfile $LicenseType
                    }
                    Else {
                        Write-host "User already has requested license assigned and UpdateSameLicense is set to false" -ForegroundColor Black -BackgroundColor Yellow
                    }
                }
                Elseif(($user.licenses).Count -gt 0 -and $AssignIfLicensed -eq $false) {
                    #Write-Output "User has other licenses, and parameter AssignIfLicensed is set to false, will not assign license"
                    $AssignedLicenses = (Get-EcMsolUserLicence -UserPrincipalName $UserPrincipalName).Licenses -join ","
                    Throw "User has a different license and parameter AssignIfLicensed was set to false, license not assigned! `r`nAssigned licenses:  $AssignedLicenses"
                
                }
                Elseif(($user.licenses).Count -gt 0 -and $AssignIfLicensed -eq $true) {
                    Write-Output "User has other licenses, but parameter AssignIfLicensed is set to true, will assign additional license"
                    Get-EcMsolUserLicence -UserPrincipalName $UserPrincipalName
                    #Assign additional license as requested.
                    $user | Set-MsolUserLicense -AddLicenses $NewLicense.AccountSkuId -LicenseOptions $NewLicenseLO
                    Update-ecMSOLUserLicenseInAD -UserPrincipalName $UserPrincipalName -LicenseProfile $LicenseType
                }
            }
            else {
                #User has no licenses, assign as requested.
                $NewLicenseLO
                $user | Set-MsolUserLicense -AddLicenses $NewLicense.AccountSkuId -LicenseOptions $NewLicenseLO 
                Update-ecMSOLUserLicenseInAD -UserPrincipalName $UserPrincipalName -LicenseProfile $LicenseType
            }
        
        }
        Catch {
            Write-Output $_.Exception.Message
        }
    }

}

Function Set-EcMsolUserLocation {
<#
.SYNOPSIS
	Used to set the UsageLocation of an user in O365

.DESCRIPTION
	Updates the UsageLocation of a user object in O365, note that this will overwrite any current value in the UsageLocation of the user.

.PARAMETER  UserPrincipalName
    UPN of the user, format: xxxx@ecco.com

.PARAMETER UsageLocation
    The location of the user where services are consumed. Must be a 
    two-letter country code.

.EXAMPLE
    Set-ecMSOLUserLocation -UserPrincipalName TestUser@Ecco.com -UsageLocation DK

.INPUTS
    None

.OUTPUTS
    None

.NOTES
	Version:		1.0.0
	Author:			Admin-SKJA
	Creation Date:	15-06-16
	Purpose/Change:	Initial Script development - func.skja.msonline.ps1
    #>

    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$UserPrincipalName,

        #License Profile to be added
        [Parameter(Mandatory=$true)]
        [String]$UsageLocation

    )

    Process {
    # Stop Script if an exception occour
    $ErrorActionPreference = "Stop"

       Try {
            #First get the MSOL user object
            $User = Get-MsolUser -UserPrincipalName $UserPrincipalName

            if ($user) {
                Write-Output "Setting user usage location to: $UsageLocation" 
                $user | Set-MsolUser -UsageLocation $UsageLocation
            }
        
        }
        Catch {
            Write-Output $_.Exception.Message
        }
    }

}

Function Update-EcMsolUserLicenseInAD {
<#
.SYNOPSIS
	Updates the user licenses in AD, 
    sets msDS-cloudExtensionAttribute1 to the value returned by Get-ecMSOLUserLicense
    sets msDS-cloudExtensionAttribute2 to the license profile specified in $LicenseProfile parameter

.DESCRIPTION
	Updates the UsageLocation of a user object in O365, note that this will overwrite any current value in the UsageLocation of the user.

.PARAMETER  UserPrincipalName
    UPN of the user, format: xxxx@ecco.com

.PARAMETER LicenseProfile
    The license profile to be added to the AD user object in msDS-cloudExtensionAttribute2

.EXAMPLE
    Set-ecMSOLUserLicenseInAD -UserPrincipalName TestUser@Ecco.com -LicenseProfile E5-Full

.INPUTS
    None

.OUTPUTS
    None

.NOTES
	Version:		1.0.0
	Author:			Admin-SKJA
	Creation Date:	15-06-16
	Purpose/Change:	Initial Script development - func.skja.msonline.ps1
    #>

    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$UserPrincipalName,

        #License Profile to be added
        [Parameter(Mandatory=$false)]
        [String]$LicenseProfile

    )

    Process {
    # Stop Script if an exception occour
    $ErrorActionPreference = "Stop"

        Try {
            $ADUser = Get-ADUser -filter {UserPrincipalName -eq $UserPrincipalName} -Properties msDS-cloudExtensionAttribute1, msDS-cloudExtensionAttribute2, UserPrincipalName, Enabled, CanonicalName

            $MSOLUser = Get-EcMsolUserLicence -UserPrincipalName $UserPrincipalName

            if ($MSOLUser.Licenses) {
                $ADUser."msDS-cloudExtensionAttribute1" = $MSOLUser.Licenses -join ","
            }
            else {
                $ADUser."msDS-cloudExtensionAttribute1" = $null
                $ADUser."msDS-cloudExtensionAttribute2" = $null
            }

            if ($LicenseProfile) {
                $ADUser."msDS-cloudExtensionAttribute2" = $LicenseProfile
            }

            Set-aduser -Instance $ADUser
        }
        Catch {
            Write-Output $_.Exception.Message
        }
    }

}

Function Get-EcMsolLicenseProfile {

    [CmdletBinding(DefaultParametersetName="P1")]
    Param
    (
        #License Profile to return
        [Parameter(Mandatory=$false, ParameterSetName="P1")]
        [ValidateSet("E5-Full", "E5-NoExch", "E4-Full", "E4-NoExch", "E3-Full", "E3-NoExch", "E1-Full", "EOP1", "StaffHub", "EMS")]
        [String]$LicenseProfile,

        #License Profile to return
        [Parameter(Mandatory=$false, ParameterSetName="P2")]
        [String]$LicenseSKU
    )

    Process {
    # Stop Script if an exception occour
    $ErrorActionPreference = "Stop"

#region Profiles
        #Define License Profiles:
        $LicProfileArray = @()

        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E5-Full"
            AccountSkuId = "ecco:ENTERPRISEPREMIUM_NOPSTNCONF"
            AllEnabled = $true
            DisabledPlans = $null }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E5-NoExch"
            AccountSkuId = "ecco:ENTERPRISEPREMIUM_NOPSTNCONF"
            AllEnabled = $false
            DisabledPlans = @("EXCHANGE_S_ENTERPRISE", "LOCKBOX_ENTERPRISE", "EXCHANGE_ANALYTICS") }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E4-Full"
            AccountSkuId = "ecco:ENTERPRISEWITHSCAL"
            AllEnabled = $true
            DisabledPlans = $null }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E4-NoExch"
            AccountSkuId = "ecco:ENTERPRISEWITHSCAL"
            AllEnabled = $false
            DisabledPlans = @("EXCHANGE_S_ENTERPRISE") }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E3-Full"
            AccountSkuId = "ecco:ENTERPRISEPACK"
            AllEnabled = $true
            DisabledPlans = $null }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E3-NoExch"
            AccountSkuId = "ecco:ENTERPRISEPACK"
            AllEnabled = $false
            DisabledPlans = @("EXCHANGE_S_ENTERPRISE") }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "E1-Full"
            AccountSkuId = "ecco:STANDARDPACK"
            AllEnabled = $true
            DisabledPlans = $null }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "EOP1"
            AccountSkuId = "ecco:EXCHANGESTANDARD"
            AllEnabled = $true
            DisabledPlans = $null }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "StaffHub"
            AccountSkuId = "ecco:DESKLESS"
            AllEnabled = $true
            DisabledPlans = $null }
        $LicProfileArray += New-Object psobject -Property @{
            LicenseType = "EMS"
            AccountSkuId = "ecco:EMS"
            AllEnabled = $true
            DisabledPlans = $null }
#endregion

#region Shortnames
    ## Mapping table 
    function Mapping($in)
    {
        switch ($in)
        {
            'ecco:STANDARDPACK' {"E1"}
            'ecco:ENTERPRISEPACK' {"E3"}
            'ecco:ENTERPRISEWITHSCAL' {"E4"}
            'ecco:ENTERPRISEPREMIUM_NOPSTNCONF' {"E5"}
            'ecco:EXCHANGESTANDARD' {"Exchange Online Plan 1"}
            'ecco:EXCHANGEARCHIVE' {"Exchange Online Archiving"}
            'ecco:VISIOCLIENT' {"Visio Pro"}
            'ecco:PROJECTCLIENT' {"Project Pro"}
            'ecco:POWER_BI_STANDARD' {"Power BI Free"}
            'ecco:ECAL_SERVICES' {"ECAL Services"}
            'ecco:MCOMEETADV' {"PSTN Conferencing"}
            'ecco:INTUNE_A_VL' {"Intune"}
            'ecco:AAD_PREMIUM' {"Azure AD Premium"}
            'ecco:GLOBAL_SERVICE_MONITOR' {"Global Service Monitor"}
            'ecco:DESKLESSPACK' {"K1"}
            'ecco:EMS' {"EMS"}
            'ecco:DESKLESS' {"StaffHub"}
            'MCOMEETADV' {"MCOMEETADV"}
            'ADALLOM_S_O365' {"Office 365 Advanced Security Management"}
            'EQUIVIO_ANALYTICS' {"eDiscovery"}
            'LOCKBOX_ENTERPRISE' {"Customer Lockbox"}
            'EXCHANGE_ANALYTICS' {"Delve Analytics"}
            'SWAY' {"Sway"}
            'ATP_ENTERPRISE' {"Exchange Online Advanced Threat Protection"}
            'MCOEV' {"Skype for Business Cloud PBX"}
            'BI_AZURE_P2' {"Power BI Pro"}
            'INTUNE_O365' {"Intune"}
            'PROJECTWORKMANAGEMENT' {"Planner"}
            'RMS_S_ENTERPRISE' {"Azure Active Directory Rights Management"}
            'YAMMER_ENTERPRISE' {"Yammer"}
            'OFFICESUBSCRIPTION' {"Office ProPlus"}
            'MCOSTANDARD' {"Skype for Business Online (Plan 2)"}
            'EXCHANGE_S_ENTERPRISE' {"Exchange Online (Plan 2)"}
            'SHAREPOINTENTERPRISE' {"SharePoint Online (Plan 2)"}
            'SHAREPOINTWAC' {"Office Online"}
            'MCOVOICECONF' {"Skype for Business Online (Plan 3)"}
            'SHAREPOINTSTANDARD' {"SharePoint Online (Plan 1)"}
            'EXCHANGE_S_STANDARD' {"Exchange Online (Plan 1)"}
            'E1'{"ecco:STANDARDPACK"}
            'E4' {"ecco:ENTERPRISEWITHSCAL"}
            'E5' {"ecco:ENTERPRISEPREMIUM_NOPSTNCONF"}
            'Intune' {"ecco:INTUNE_A_VL"}
            'Visio_Pro' {"ecco:VISIOCLIENT"}
            'Project_Pro' {"ecco:PROJECTCLIENT"}
            'Power_BI_Free' {"ecco:POWER_BI_STANDARD"}
            'ECAL_Services' {"ecco:ECAL_SERVICES"}
            'PSTN_Conferencing' {"ecco:MCOMEETADV"}
            'Azure_AD_Premium' {"ecco:AAD_PREMIUM"}
            'Global_Service_Monitor' {"ecco:GLOBAL_SERVICE_MONITOR"}
            'Exchange_Online_Plan_1' {"ecco:EXCHANGESTANDARD"}
            'Exchange_Online_Archiving' {"ecco:EXCHANGEARCHIVE"}
            'K1' {"ecco:DESKLESSPACK"}
            'EMS' {"ecco:EMS"}
            'StaffHub' {"ecco:DESKLESS"}
            default{"SKU Not found: $in"}
        } 
    }    
#endregion

        if ($LicenseSKU){
            $tmp = Mapping $LicenseSKU
            Write-Output $tmp
        }

        if ($LicenseProfile) {
            $tmp = $LicProfileArray | ? {$_.LicenseType -eq $LicenseProfile}
            write-output $tmp
        }
    }

}

Function Remove-EcMsolUserLicense {

    [CmdletBinding(DefaultParametersetName="P1")]
    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true, ParameterSetName="P1")]
        [Parameter(Mandatory=$true, ParameterSetName="P2")]
	    [String]$UserPrincipalName,

        #License Profile to be removed
        [Parameter(Mandatory=$true, ParameterSetName="P1")]
        #[ValidateSet("E5-Full", "E5-NoExch", "E4-Full", "E4-NoExch", "E3-Full", "E3-NoExch", "E1-Full", "EOP1")]
        [String]$License,

        #License Profile to be removed
        [Parameter(Mandatory=$true, ParameterSetName="P2")]
        [ValidateSet($true, $false)]
        [String]$RemoveAll
    )

    Process {
    # Stop Script if an exception occour
    $ErrorActionPreference = "Stop"
    
        try {
            $msoluser = Get-MsolUser -UserPrincipalName $UserPrincipalName
            if ($msoluser) {
                if ($License -contains ":") {
                    #Provided license is in account sku format
                    $LicSKU = $License
                }
                else {
                    #License is not in account sku format
                    $LicSKU = Get-ecMSOLLicenseProfile -LicenseSKU $License
                }

                if ($RemoveAll) {
                    #Remove all licenses assigned to user
                    foreach ($UserLicense in $msoluser.licenses) {
                        $translatedlic = Get-ecMSOLLicenseProfile -LicenseSKU $UserLicense.AccountSkuId
                        Write-Output "Removing license: $($UserLicense.AccountSkuId) ($translatedlic)"
                        $msoluser | Set-MsolUserLicense -RemoveLicenses $UserLicense.AccountSkuId
                    }
                }
                Else {
                    $UserLicense = $msoluser.Licenses | ? {$_.AccountSKUId -eq $LicSKU}
                    if ($UserLicense) {
                        $translatedlic = Get-ecMSOLLicenseProfile -LicenseSKU $UserLicense.AccountSkuId
                        Write-Output "License found: $($UserLicense.AccountSkuId) ($translatedlic)"
                        $msoluser | Set-MsolUserLicense -RemoveLicenses $UserLicense.AccountSkuId
                
                    }
                    else {
                        Write-Output "No licenses found for user: $UserPrincipalName"
                    }
                }
                Update-ecMSOLUserLicenseInAD -UserPrincipalName $UserPrincipalName
            }
            else {
                Write-Output "User not found: $UserPrincipalName"
            }
            
        }
        Catch {
            Write-Output $_.Exception.Message
        }
    
    }
}

Function Get-EcMsolAccountSku {

    Process {
        try {
            $Accountsku = Get-MsolAccountSku

            $AccountSkuOverview = @()

            foreach ($sku in $Accountsku) {
                $TempResults = New-Object PSObject;
    
                $TempResults | Add-Member -MemberType NoteProperty -Name "AccountSkuId" -Value $sku.AccountSkuId;
                $TempResults | Add-Member -MemberType NoteProperty -Name "FriendlyName" -Value (Get-EcMsolLicenseProfile -LicenseSKU $sku.AccountSkuId);
                $TempResults | Add-Member -MemberType NoteProperty -Name "ActiveUnits" -Value $sku.ActiveUnits;
                $TempResults | Add-Member -MemberType NoteProperty -Name "WarningUnits" -Value $sku.WarningUnits;
                $TempResults | Add-Member -MemberType NoteProperty -Name "ConsumedUnits" -Value $sku.ConsumedUnits;
                $TempResults | Add-Member -MemberType NoteProperty -Name "RemainingUnits" -Value ($sku.ActiveUnits - $sku.ConsumedUnits);

                $AccountSkuOverview += $TempResults
            }

            Write-Output $AccountSkuOverview
        
        }
        catch {
            Write-Output $_.Exception.Message
        }

    }

}


# SIG # Begin signature block
# MIITxQYJKoZIhvcNAQcCoIITtjCCE7ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpqklMXuNoXHztb12s7+JcAec
# sR2gghAZMIIHiDCCBXCgAwIBAgITIgAAAAR+s2mH1OhLhwAAAAAABDANBgkqhkiG
# 9w0BAQsFADAVMRMwEQYDVQQDEwpFQ0NPUm9vdENBMB4XDTE2MTIyMjEwMjQwM1oX
# DTI0MTIyMjEwMzQwM1owXjETMBEGCgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT
# 8ixkARkWCGVjY29jb3JwMRMwEQYKCZImiZPyLGQBGRYDcHJkMRgwFgYDVQQDEw9F
# Q0NPSXNzdWluZ0NBMDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCP
# uOGk33IgLqvcPllj/vbsqISe0S1VGQacC/IEeiPxtuhvVA7U4WyJxeZoKPsHcN6+
# cpDYKov34VOBCshSYAYpefqodOCw4zE8ipGO/f7zM7b7ydKAEMU4c+VV/Xwzizza
# FGt93Rhavxv/1bO4Fh6hgmOFM7OvSNDnRglXmMsjYfV9givwcXZyJ/e6M7ErvJAl
# BrrbiQJC8PrjR0EZfrovuK8cLlu0H4VbgySCWbsv7wIRc5VfqOb6tCOQhdULmeCD
# cKQ0ZXAdPeRBNrb6Q+rBm8uOghrGDQrn/mzZYaSVv3rPBL5UbJpDool3oEggd30j
# ayi+BCwR1cvPipcTgqdnsZAR0Xs84LElYnVRA61BMNvoe0Fjlu8vqYKq2p3NUiSt
# EEOFIIz/CRtbP3zbekmt2/NcTwiu/9LJgQSy1Vczx/fu5Xx67CH06hQ7NfTBNvhK
# MYoJiRr6GEsFhoh7yNf7KNvdtY24N7qqs7yrKsR8r+DfW4UH3NuuKc/huLSMDvaJ
# RrsA9tQgoYWqIHbLzMH7jCbnxuu93N3eKGK2DzFlRF/o7zA4i82KXvptMdJ2Biby
# UCl+0nClObPXo5/WBg2oF5DT5xNG1DSvoTf2SSyR8lThOsPuWdbPZWqqWQd0TugC
# Dyrg1HKCYLnEFhihbfnGYZzDMKSeH5B0YqVqfku70wIDAQABo4IChjCCAoIwEAYJ
# KwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNJVEMp5fcoirx3xIciKItWld94gMDsG
# CSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCPu9RofHhWCJjyGHnMxpge+ZNnqG3O00
# gqyKYAIBZAIBAzALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
# GDAWgBQIoYBnds5rmr8Js4sKRn8KGnUTbjCB4gYDVR0fBIHaMIHXMIHUoIHRoIHO
# hiJodHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3JshoGnbGRhcDovLy9D
# Tj1FQ0NPUm9vdENBLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
# Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERDPW5ldD9j
# ZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlz
# dHJpYnV0aW9uUG9pbnQwge0GCCsGAQUFBwEBBIHgMIHdMC4GCCsGAQUFBzAChiJo
# dHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3J0MIGqBggrBgEFBQcwAoaB
# nWxkYXA6Ly8vQ049RUNDT1Jvb3RDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29y
# cCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwDQYJKoZIhvcNAQELBQADggIBAEXsS0mN57SbxXvzep4M
# C3tCBnkS1j51OKNC/ttGyLRlATF/OZrrsVbnqVtHZUyiUfBmx1ynOzjb44Cp/lAP
# ldJSe/zFpFVIIUyEDeP+I4H3cMoNDI1aKoDdhlJ9A3JyKKYQbVra4iF0u22pNv8X
# jUN5k8Uuyl7N817t7ji1UAhK4ikf+9Ad6u4b5w6WX9QRl1tsj5jw1zO5WQ0lQhN+
# t2axajDDvnUfw3lqJiQzhg0UMyrAovzDMksXw7qR3SeiEfxKzAmMrPs5taHFN2PU
# zU8osto5RGBx99BKDPWw/QL339Pvsu9bGVqgZ5Bi1L8Iv1XsY4jkRupXsPY1qw3l
# ToREuuE2Ti/IhJb/EZchTtqDfmJUH/TYweTu2wDoAzXwonTQNWpHBHf4ftmiRNWw
# i4fUWi4oJchH4CQ0NTJE1hTkRCJum/CS70Dm/8iIickPCw89figUqnK3D9CnRkpL
# cMyPgCstOrOLyyUntRMEzPXBUT2Ah8RBNZ248kTfeRvQgfXMKISJopRKqv7RDItD
# cJl9ThlujbwJoJtWxWm6NgXIXzFIqKB5SioJ3DXy56UylI7O1XygGAR+mqBJQ35A
# IR7fD1YPjD5sv6Ag3ccs5YbU5nrIaAcO6xtmofbtiD8tPyChKkkdcPZVBXImvUM8
# UUa2uTj7CPSTqDcTXFhPfGoXMIIIiTCCBnGgAwIBAgITSwAABaD8SNQO0C7mNAAA
# AAAFoDANBgkqhkiG9w0BAQsFADBeMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYK
# CZImiZPyLGQBGRYIZWNjb2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxGDAWBgNV
# BAMTD0VDQ09Jc3N1aW5nQ0EwMjAeFw0xNzAxMDUwNzAzMjZaFw0xOTAxMDUwNzAz
# MjZaMIGbMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYIZWNj
# b2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxDTALBgNVBAsTBEVDQ08xCzAJBgNV
# BAsTAkRLMQswCQYDVQQLEwJIUTELMAkGA1UECxMCSVQxHzAdBgNVBAMMFlPDuHJl
# biBLasOmcmh1cyAoU0tKQSkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDISpdeD0ivvCdBBH6C98u8aXy+015e9uVTrCrUfLtu//rMuE8XN880is209XAq
# 2Ei9o0EikkQX8MAcQj2lqHf0SIrmG67dRbyBpUrxrU7oZ0tRs0L9dM7NsCMajSBZ
# wBptK89+HEzXAfmN2qWqhrh6WhtXV4WRbaWSjaK3f92vd0GBe5wSn+FdeVd7R+DU
# Z9ZC3cwmdbbHeGXChyxn44+fjhBvFBafL7NiCBORG8dFpBgRi8uUvwuARPss1pe5
# CO/G2JXyoIqyPU0p8q2LMX1MVnOkQSfl/X/8Cq/B7sqrbEbvMNX/9D4FByX1tWNs
# H3qrVn06MEzqOgffjwFwnXF86q6QF5tEFsQ5lS6+dFZis46xs1sXeXfpVE3LahKd
# fNwdTivxYuBayWp3BoFWmbPwO59bLa72P3rsYRKrMFW/F3r8o5zUbiTBVVxVfWF9
# 5f2mxbTdcmiX6MBAEDuCZbpcFbHfY8G7KzpOclwDXx1Aw5WABtC/NVxtkoEX9z9V
# goPJxIOYh/vRqs8ZxKrAIpdrXVnDG/jTPfyxdfBXBC4p6IdHVh4SXzGCeRvtT3yT
# cFTRp8uvff4wCxLVx8GoUpQEjHcdq1vpn0c8LBP+MNVyzErfeObozLox8OTDouBr
# EvrS6g3f7jW/ETIVfKQ6taopeukqsu/f80PGfA5P5eKHAwIDAQABo4IDADCCAvww
# OwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUI+71Gh8eFYImPIYeczGmB75k2eoXL
# zWOF3IFDAgFkAgEkMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIH
# gDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBSixtshpuX+
# WRBzAk9AbylcyxXM5jAfBgNVHSMEGDAWgBTSVRDKeX3KIq8d8SHIiiLVpXfeIDCB
# 7AYDVR0fBIHkMIHhMIHeoIHboIHYhidodHRwOi8vY2RwLmVjY28uY29tL0VDQ09J
# c3N1aW5nQ0EwMi5jcmyGgaxsZGFwOi8vL0NOPUVDQ09Jc3N1aW5nQ0EwMixDTj1D
# RFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29u
# ZmlndXJhdGlvbixEQz1lY2NvY29ycCxEQz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0
# aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIB
# IAYIKwYBBQUHAQEEggESMIIBDjAzBggrBgEFBQcwAoYnaHR0cDovL2NkcC5lY2Nv
# LmNvbS9FQ0NPSXNzdWluZ0NBMDIuY3J0MIGvBggrBgEFBQcwAoaBomxkYXA6Ly8v
# Q049RUNDT0lzc3VpbmdDQTAyLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERD
# PW5ldD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlv
# bkF1dGhvcml0eTAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AuZWNjby5jb20vb2Nz
# cDAoBgNVHREEITAfoB0GCisGAQQBgjcUAgOgDwwNU0tKQUBlY2NvLmNvbTANBgkq
# hkiG9w0BAQsFAAOCAgEAZD1JZLl5RVTYv3QtrHeQMMQU8Ds61uDE5n4Si1pROneR
# nSSUN9/QJI6pyHno0U3GCdIJ4fJr8ZhNeQi0/wLHJ3otEIGTlkYPChhTIRs1Ea7Z
# UiD5ps84RDXm13GYYESwVnmJNX3G6jRetUdChMx6a1FjYrmgD0di/hh7Mwe5tFUz
# Km2lK8jwHscgCMTL/nJ4UdWxcGw16xjEG3wcp+UX+UaegJguYTB6saEoDYojiwyq
# 3zA8Csux6IiMzwg9946PeHo/h5Eokh6LmREjzN7tLvcBRsjmnOjawmpOlcV5uGaS
# BQWWyvcz5dhExw6yEOj8XWf2FGNTfIpgd/P3741YkXA4TDd6JhjBZEXwTceChvLB
# G7UCWnzmKhNJ/d2ny9nUTLXWqYybmgdf3gIo/xioP5tf2Z8K4+SruoeoJl5vgFyf
# PRevaHIuoo+ODscAxrlFRiO/M66NK3UgszXQ9U4cdJ4yfTp9yveGq2wno5qqtOaG
# bTytpYYwRWkdzl7c0KY7fvwfDv2D+a2AH+cSr85SQnzTyE449qgim3MzO8T/hkUg
# 7Uo0Oesn9V2/iNE6rQc890VU1e/1VC69703XGDZMz3yI3sh9AvD5Y6ItiAfZQ/Uc
# F97p3+/Upvwmd4s9nec03bt4pO78fe66L8oOwQ6AHVLS+13YPGi3JRzlrLssYagx
# ggMWMIIDEgIBATB1MF4xEzARBgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJk/Is
# ZAEZFghlY2NvY29ycDETMBEGCgmSJomT8ixkARkWA3ByZDEYMBYGA1UEAxMPRUND
# T0lzc3VpbmdDQTAyAhNLAAAFoPxI1A7QLuY0AAAAAAWgMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBS/LbMKCYwyAzXePUHewYxBQn30NjANBgkqhkiG9w0BAQEFAASCAgASH12+AGAl
# o7PUn5hQ/IdyUmNb+M6N0uSIqj0hQXwPDkr0ptPIrxcpy/0m7D0CeIAoyzk9S/Ca
# VPVhxZ1B3OCD1JkwG9Pz2fjk3zHn0TAafcWNwUJPTff7LMri+tqWMcrJjDAGrOfw
# M9DheGjb00AtNb1Do8WF8cuZ/VlUDbA3gVB1dm6u0d4t2RP2QmUU4ipytnHveRkc
# AGGPddpD33Ou6q+QS3EyYTHDAmgul8QzEtK449PjZqo//quRSObmqqZlp/Pa+Md1
# 75e0FE23C43O5lvM2SkB2IA9VRWn+5XOLYV3faklz2sOnc++CLO2bvAlju1IlDjb
# QhFhzAfUMpmGlKA98x4kK+0rbSXla7EZW9RRKC7W+Pc99ZWAfMsfeDs0LMPo+fg8
# mv8+zz6D+fBflimYZkO6Mz4k7VbN91g8bJ/cIMK6baFe4XMckFyKCPoscG0Y3/yT
# 0nhNUcaLuNxfNslk+qClzfuxxJlUbZ6vLSqGwOfx9F/gco3t/epo560Rf7mwz2Jc
# DbUn57dTormamX4jIPemzVbFAvu994L3GwtRmGBk9soQA7Cx0+XmPHEbgXHah9U7
# BWi7WJ17wWhGGzxBMF7h8xhI+bwlHQJmcNzIPOQ8w3oZe+xYB0FXsyaz0/CMv7AR
# hMy+XWPRNZfYK6x6PwwKpaVNnVgkrZIpvw==
# SIG # End signature block
