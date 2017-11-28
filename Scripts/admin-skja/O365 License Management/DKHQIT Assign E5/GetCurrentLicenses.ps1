
##### Account information #####
$AdminName = "AzService-License@ecco.onmicrosoft.com"
$CredFile = "AzService-License-PowershellCreds.txt"

##Update Password file
#Read-Host -AsSecureString -Prompt "Password: " | ConvertFrom-SecureString | Out-File $CredFile

$password = get-content -path $CredFile | convertto-securestring
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName,$password
###############################

##### Other Input ######
$ADUsers = "LicensePlan.csv"
########################

#Connect to MSOL Service
Connect-MsolService -Credential $Cred

$ADUsers = Import-Csv $ADUsers

foreach ($ADUser in $ADUsers) {
    Try {
        $MSOLUser = Get-MsolUser -UserPrincipalName $ADUser.UserPrincipalName -ErrorAction Stop
        write-host $ADUser.UserPrincipalName
        Write-host "User: " $MSOLUser.UserPrincipalName -BackgroundColor DarkGreen -ForegroundColor White
        If (!$MSOLUser.Licenses) {
            $ADtmp = Get-ADUser -filter {UserPrincipalName -eq $MSOLUser.UserPrincipalName} -Properties msDS-cloudExtensionAttribute1, UserPrincipalName, Enabled, CanonicalName, distinguishedName
            Write-host " !! NOT LICENSED, AD Attribute: " $ADtmp."msDS-cloudExtensionAttribute1" -ForegroundColor Yellow
               #Clear the license in AD
            $ADtmp."msDS-cloudExtensionAttribute1" = $null
            Set-aduser -Instance $ADtmp        
        }

        $E3Found = $false
        $E4Found = $false
        $E5Found = $false

        $ExchangeOnlineDisabled = $true

        $disabledPlans = @()
        $disabledPlans += "EXCHANGE_S_ENTERPRISE"
        $disabledPlans += "LOCKBOX_ENTERPRISE"
        $disabledPlans += "EXCHANGE_ANALYTICS"
        $MSOLLicoptionExchDisabled = New-MsolLicenseOptions -AccountSkuId ecco:ENTERPRISEPREMIUM_NOPSTNCONF -DisabledPlans $disabledPlans
        $MSOLLicoptionExchEnabled = New-MsolLicenseOptions -AccountSkuId ecco:ENTERPRISEPREMIUM_NOPSTNCONF

        Foreach ($UserLicense in $MSOLUser.Licenses) {
            #Check if we have an E3 or E4 license
            #  ecco:ENTERPRISEPACK;E3
            #  ecco:ENTERPRISEWITHSCAL;E4
            #  ecco:ENTERPRISEPREMIUM_NOPSTNCONF;E5

            if ($UserLicense.AccountSkuID -eq "ecco:ENTERPRISEPACK") {
                $E3Found = $true
                if (($UserLicense.ServiceStatus | ? {$_.ServicePlan.ServiceName -eq "EXCHANGE_S_ENTERPRISE"}).ProvisioningStatus -eq "Disabled") {
                    Write-Host " - E3 License found with Exchange Online Disabled"
                }
                Else {
                    Write-Host " - E3 License found with Exchange Online Enabled"
                    $ExchangeOnlineDisabled = $false
                }
            }
            Elseif ($UserLicense.AccountSkuID -eq "ecco:ENTERPRISEWITHSCAL") {
                $E4Found = $true
                #Write-host "E4 License components disabled..:" -BackgroundColor White -ForegroundColor Black
                if (($UserLicense.ServiceStatus | ? {$_.ServicePlan.ServiceName -eq "EXCHANGE_S_ENTERPRISE"}).ProvisioningStatus -eq "Disabled") {
                    Write-Host " - E4 License found with Exchange Online Disabled"
                }
                Else {
                    Write-Host " - E4 License found with Exchange Online Enabled"
                    $ExchangeOnlineDisabled = $false
                }
            }
            Elseif ($UserLicense.AccountSkuID -eq "ecco:ENTERPRISEPREMIUM_NOPSTNCONF") {
                $E5Found = $true
                #Write-host "E5 License components disabled..:" -BackgroundColor White -ForegroundColor Black
                if (($UserLicense.ServiceStatus | ? {$_.ServicePlan.ServiceName -eq "EXCHANGE_S_ENTERPRISE"}).ProvisioningStatus -eq "Disabled") {
                    Write-Host " - E5 License found with Exchange Online Disabled"
                }
                Else {
                    Write-Host " - E5 License found with Exchange Online Enabled"
                    $ExchangeOnlineDisabled = $false
                }
            }
            
        }

        $Liccount = ([int]$E3Found + [int]$E4Found + [int]$E5Found) 
        if ($Liccount -gt 1) {
            Write-host "!!!!!! More licenses on one user, Handle user manually!!!!!" -BackgroundColor Red 
        }
        elseif ($Liccount -eq 0) {
            Write-Host "!!!! User has NO E3 - E5 Licenses currently" -BackgroundColor Yellow
        }
        elseif ($E5Found) {
            Write-Host "User already has an E5 license assigned, no change performed!"
            $ADtmp = Get-ADUser -filter {UserPrincipalName -eq $MSOLUser.UserPrincipalName} -Properties msDS-cloudExtensionAttribute1, UserPrincipalName, Enabled, CanonicalName, distinguishedName
            #Change to E5 in AD
            $ADtmp."msDS-cloudExtensionAttribute1" = "E5"
            Set-aduser -Instance $ADtmp    
        }
        else {
            #Only 1 license assigned and it's not E5, reassign a new license, and remove the old.

            #Which license to remove?
            if ($E3Found) {$licToRemove = "ecco:ENTERPRISEPACK"}
            if ($E4Found) {$licToRemove = "ecco:ENTERPRISEWITHSCAL"}
            
            ##Assign new license
            If ($ExchangeOnlineDisabled -eq $true) {
                #Exchange disabled on old license, keep it disabled.
                $MSOLUser | Set-MsolUserLicense -AddLicenses ecco:ENTERPRISEPREMIUM_NOPSTNCONF -LicenseOptions $MSOLLicoptionExchDisabled -RemoveLicenses $licToRemove -ErrorAction stop
                Write-Host " - Assigned E5 license with exchange DISABLED" -BackgroundColor Yellow -ForegroundColor Black
            } 
            else {
                #Exchange was enabled on old, keeping it enabled.
                $MSOLUser | Set-MsolUserLicense -AddLicenses ecco:ENTERPRISEPREMIUM_NOPSTNCONF -LicenseOptions $MSOLLicoptionExchEnabled -RemoveLicenses $licToRemove
                Write-Host " - Assigned E5 license with exchange ENABLED" -BackgroundColor Yellow -ForegroundColor Black
            }
            $ADtmp = Get-ADUser -filter {UserPrincipalName -eq $MSOLUser.UserPrincipalName} -Properties msDS-cloudExtensionAttribute1, UserPrincipalName, Enabled, CanonicalName, distinguishedName
            #Change to E5 in AD
            $ADtmp."msDS-cloudExtensionAttribute1" = "E5"
            Set-aduser -Instance $ADtmp     
        }
 
    }
    Catch {
       # $ErrorMessage = $_.Exception.Message
       # $FailedItem = $_.Exception.ItemName
       # Write-host "Error caught: $failedItem" -ForegroundColor Red
       # Write-Host $ErrorMessage -ForegroundColor Red

        echo $_.Exception|format-list -force
    }
    

}