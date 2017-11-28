
Function Connect-EcMsolService
{
    <#
    .SYNOPSIS
        Connect to MSOnline

    .DESCRIPTION
        Importing the MSOnline module and then connect to MSOnline with predefined Ecco credentials

    .EXAMPLE
        Connect-EcMsolService
        
        Connect to MSOnline

    .INPUTS
        NA

    .OUTPUTS
        NA

    .NOTES
        Version:		1.0.0
        Author:			Admin-PJE
        Creation Date:	13/06/2016
        Module Script:  func.pje.msonline
        Purpose/Change:	Initial function development
    #>

    [CmdletBinding()]

    Param()

    $ErrorActionPreference = "Stop"

    try
    {
        if(!(Get-Module MSOnline))
        {
            Import-Module MSOnline
        }

        $password = "76492d1116743f0423413b16050a5345MgB8AGsAMgBWAGEAUgBZADAATwBFAEYANgBDAGYAbABZAHYAaAAwAGMAUQByAHcAPQA9AHwAMgA1AGUAMAA3AGQANQAwAGUAZQBmADQAMgBhADYAMwA4ADcAZAA2AGIANQBkADgAOQA1ADkAYgAyADkANABjAGYAZABiADIAMQA4AGQAYQBiAGEANwBiADYAYwA5AGMAOAA1AGQAMQBkADgAMwBlADkAMwBmAGYAMQA4ADYAZgA="
        $key = "50 83 36 49 67 49 93 201 146 176 46 165 165 4 35 189 58 82 157 204 66 107 112 49 86 195 166 244 136 230 8 141"
        $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
        $cred = New-Object system.Management.Automation.PSCredential("azservice-license@ecco.onmicrosoft.com", $passwordSecure)

        $conn = Connect-MsolService -Credential $cred
    }
    catch
    {
        Write-Output $_.Exception.Message
    }
}

Function Get-EcMsolUserLicence
{
    <#
    .SYNOPSIS
        Users license plan in Office 365

    .DESCRIPTION
        Get information on what license plan is set for a given user or wich users are given a specific license plan

    .PARAMETER  UserPrincipalName
        UserPrincipalName for the given user

    .PARAMETER  LicenseType
        License plan

    .EXAMPLE
        DK4836\C:\> Get-EcMsolUserLicence -UserPrincipalName pje@ecco.com,lako@ecco.com | ft -autosize

        Return the license plan in Office 365 for a user 

        UserPrincipalName Licenses               
        ----------------- --------               
        PJE@ecco.com      {PSTN Conferencing, E5}
        LAKO@ecco.com     E5 
       
    .EXAMPLE
        DK4836\C:\> Get-EcMsolUserLicence -LicenseType E5

        Return all users with the E5 license plan in Office 365

        UserPrincipalName Licenses               
        ----------------- --------               
        SOHA@ecco.com     {Power BI Free, E5}    
        SKJA@ecco.com     {PSTN Conferencing, E5}
        PJE@ecco.com      {PSTN Conferencing, E5}
        KIJ@ecco.com      {PSTN Conferencing, ...
        KSK@ecco.com      E5                     
        LAKO@ecco.com     E5                     
        ALM@ecco.com      {Azure AD Premium, P...

    .EXAMPLE
        DK4836\C:> $lic = 'E5'

        DK4836\C:> Get-EcMsolUserLicence -LicenseType $lic | ? {$_.OnPremExtension -notcontains $lic}

        Return all users with the E5 license plan in Office 365 and not on-prem

        UserPrincipalName Licenses OnPremExtension
        ----------------- -------- ---------------
        COZ@ecco.com      E4                      
        PN@ecco.com       E4       E3             
        ROGA@ecco.com     E4       E3             
        AANI@ecco.com     E4       E3             
        BIM@ecco.com      E4       E3             
        AAB@ecco.com      E4       E3             
        DLO@ecco.com      E4       E3             
        azadmin-fastra... E4                      
        AKOC@ecco.com     E4       E3             
        PCP@ecco.com      E4       E3             
        JABO@ecco.com     E4       E3             
        FRB@ecco.com      E4                      
        FGL@ecco.com      E4                       

    .INPUTS
        String

    .OUTPUTS
        PSObject

    .NOTES
        Version:		1.0.0
        Author:			Admin-PJE
        Creation Date:	14/06/2016
        Module Script:  func.pje.msonline
        Purpose/Change:	Initial function development
    #>

    [CmdletBinding(DefaultParametersetName="P1")]

    Param 
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName="P1",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String[]]$UserPrincipalName,
        [Parameter(Mandatory=$true,
                   ParameterSetName="P2")]
        [ValidateSet("E1","E3","E4","E5","Intune","Visio_Pro","Project_Pro","Power_BI_Free",
                     "ECAL_Services","PSTN_Conferencing","Azure_AD_Premium","Global_Service Monitor",
                     "Exchange_Online_Plan_1","Exchange_Online_Archiving")]
        [String]$LicenseType
    )

    Process
    {
        $ErrorActionPreference = "Stop"

        try
        {
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
                    'ecco:EMS' {"Enterprise Mobility Suite"}
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
                    'Enterprise Mobility Suite' {"ecco:EMS"}
                    'StaffHub' {"ecco:DESKLESS"}
                    default{$in}
                } 
            }

            switch ($PsCmdlet.ParameterSetName) 
            { 
                "P1"  {$User = $UserPrincipalName | Foreach { Get-MsolUser -UserPrincipalName $_};$Type=""} 
                "P2"  {$User = Get-MsolUser -All;
                       $Type = Mapping ($($PsCmdlet.MyInvocation.BoundParameters.Values))
                } 
            }

            filter LicenseType
            {
                if($type -ne ""){$input | ? {$_.Licenses.AccountSkuId -contains $type}}
                else{$input}
            }
 
            $user | LicenseType | ForEach-Object {

                $sStatus = @()

                $license = $_.Licenses | ForEach-Object {

                    $sku = Mapping $($_.AccountSkuId)                    

                    $sStatus += $_.ServiceStatus | ForEach-Object {

                        $tmp = $(new-object -TypeName PSObject -Property @{'ServicePlan'=Mapping $($_.ServicePlan.ServiceName);
                                                                           'ProvisioningStatus'=$($_.ProvisioningStatus);
                                                                           'License'=$($sku)})

                        $tmp.PSObject.TypeNames.Insert(0,'Ecco.Online.Administration.UserLicense')
                        $tmp
                    }
                    
                    $sku
                }

                $props = [Ordered]@{}
                $props.add('UserPrincipalName',$($_.UserPrincipalName))
                $props.add('Licenses',$license)
                $props.add('ServiceStatus',$sStatus)
                $props.add('OnPremExtension',$(Get-ADUser -filter {UserPrincipalName -eq $_.UserPrincipalName} -Properties msDS-cloudExtensionAttribute1).'msDS-cloudExtensionAttribute1')
            }
        }
        catch
        {
            $props = [Ordered]@{}
            $props.add('UserPrincipalName',$null)
            $props.add('Licenses',$null)
            $props.add('ServiceStatus',$null)
            $props.add('OnPremExtension',$null)
        }
        finally
        {
            $obj = New-Object -TypeName PSObject -Property $props
            $obj.PSObject.TypeNames.Insert(0,'Ecco.Online.Administration.User')

            Write-Output $obj
        }
    }
}


# SIG # Begin signature block
# MIIPUAYJKoZIhvcNAQcCoIIPQTCCDz0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfCfrOf3NdhJKpXAG9+8pxW1u
# z2Cgggy3MIIGEDCCBPigAwIBAgITMAAAACmzBIx3JBq+BwAAAAAAKTANBgkqhkiG
# 9w0BAQUFADBGMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYI
# ZWNjb2NvcnAxFTATBgNVBAMTDEVDQ08gUm9vdCBDQTAeFw0xNjAyMDUwNzI1Mzha
# Fw0yMjAyMDUwNzM1MzhaMEsxEzARBgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJ
# k/IsZAEZFghlY2NvY29ycDEaMBgGA1UEAxMRRUNDTyBJc3N1aW5nIENBIDEwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDWXibIDP9rOAxFYpc/OY7PO/mq
# nEtErsjBDqFpLaGEipO+2KGWJCR7rzdSmI2lSmgQkimCuCNp6un9apWLfRJNyZf6
# H/kGy52diqnff4Wne4fNmDX4pLdXoT1wRm+62v3aK1fsCubyJcQQzFrMGq86reYO
# EyWgRmQd5b82HZpikTSV06YVB6F8YTh2FzWBgf3L9N0WiIMpgggS0/4dZxiRnq2y
# oB/mpQ7jfGe7jWmEe+0BDBpvXi0rFxfJZw2lGv+jZ8T20Zf3WlVLxbEI3+M3nXzA
# J02nsuQzry+LjCXBRvOtdOZr+bMLTWcX9PUZ0HljIabarphjyXWwr6VgSkGRAgMB
# AAGjggLwMIIC7DAQBgkrBgEEAYI3FQEEAwIBAzAjBgkrBgEEAYI3FQIEFgQU4P6l
# YLh6FFWT68r51z8fXNQhdMQwHQYDVR0OBBYEFLRPoAyp5CN/HpoCS8fBEfrVJJD2
# MDsGCSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCPu9RofHhWCJjyGHnMxpge+ZNnqG
# 3O00gqyKYAIBZAIBAzALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNV
# HSMEGDAWgBQ7KkBMT7g2WRcc+DDBVJS5UPWQGzCB/gYDVR0fBIH2MIHzMIHwoIHt
# oIHqhixodHRwOi8vcGtpLmVjY28uY29tL3BraS9FQ0NPJTIwUm9vdCUyMENBLmNy
# bIaBuWxkYXA6Ly8vQ049RUNDTyUyMFJvb3QlMjBDQSxDTj1ES0hRQ0EwMSxDTj1D
# RFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29u
# ZmlndXJhdGlvbixEQz1lY2NvY29ycCxEQz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0
# aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIB
# FQYIKwYBBQUHAQEEggEHMIIBAzBOBggrBgEFBQcwAoZCaHR0cDovL3BraS5lY2Nv
# LmNvbS9wa2kvREtIUUNBMDEuZWNjb2NvcnAubmV0X0VDQ08lMjBSb290JTIwQ0Eu
# Y3J0MIGwBggrBgEFBQcwAoaBo2xkYXA6Ly8vQ049RUNDTyUyMFJvb3QlMjBDQSxD
# Tj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049
# Q29uZmlndXJhdGlvbixEQz1lY2NvY29ycCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9i
# YXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwDQYJKoZIhvcN
# AQEFBQADggEBADhcYjtSLCHLCJ1625jtqpchuI2B3uZ2Rl7EAlBWU3RQk8fRyGhb
# cg4IbtCa3j5+ze2JLRfxcZ8vYPjb6yvfcFqTDPaS3cxq4Q6NQQEW/W6MifFG+bIp
# hfx+XLADj+CZtbQPfXqoZ/kEfl4RXSCjMl7MA9VibA836YveehqxznMkVhj2JmPx
# x7yoWOonngnt1bzVHfEbwZdwrK7YMtibxo4OmH8n/WRKYz09I0CxqB20HuVYASYZ
# tk809mQrqisLGNpM/tJba+McUuY+aL3Fs6mN6I1siyrmLJ8bCjbVkkFk5y/81ezX
# 4zg7p0+SRtU8fEeU/TZOgyiZWFtYF8FI/NMwggafMIIFh6ADAgECAhMWACjK2J2c
# EmeCYIFMAAMAKMrYMA0GCSqGSIb3DQEBBQUAMEsxEzARBgoJkiaJk/IsZAEZFgNu
# ZXQxGDAWBgoJkiaJk/IsZAEZFghlY2NvY29ycDEaMBgGA1UEAxMRRUNDTyBJc3N1
# aW5nIENBIDEwHhcNMTYwNjE2MDYwMzA4WhcNMTgwNjE2MDYwMzA4WjCBmzETMBEG
# CgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT8ixkARkWCGVjY29jb3JwMRMwEQYK
# CZImiZPyLGQBGRYDcHJkMQ0wCwYDVQQLEwRFQ0NPMQswCQYDVQQLEwJESzELMAkG
# A1UECxMCSFExCzAJBgNVBAsTAklUMR8wHQYDVQQDDBZTw7hyZW4gS2rDpnJodXMg
# KFNLSkEpMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwgz+pvL9LDHS
# CXYDt737jvNg6XX38BCXN0E5P5/jSih7qy4dgznbhgWbR3a+wyArPLbY6w+YZHK3
# FClWyDqbZnTqwOYRWgZ8n+kkmMHA8qxR54IKYvADu5ep7vemzTVZY4C/Jt7NuRcv
# XfyqXh61bN/fpqhriOybw8fVcHOVlgxtgq/bCgR8P9uatS83DtIKTXxVXWn4O32j
# qWXZ/9pjhNkoAt4HuYQEsqWZFn5uF2J3u6uW2lR64ddjSHBCE3al1m2xeGsw7ayd
# lwkg1qYu6wvrjKDYX2V1rt5y83q8l767eMB/0xjB4x3FwAEaqJTsEE/bNvBa3mS5
# ygKtaIosBwIDAQABo4IDKTCCAyUwOwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUI
# +71Gh8eFYImPIYeczGmB75k2eobLpxuE5NYXAgFkAgEJMBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBTbkqdbiWiOLoOP8+0/Wq4K3Zu2aDAfBgNVHSMEGDAWgBS0
# T6AMqeQjfx6aAkvHwRH61SSQ9jCCAQ4GA1UdHwSCAQUwggEBMIH+oIH7oIH4hjNo
# dHRwOi8vcGtpLmVjY28uY29tL3BraS9FQ0NPJTIwSXNzdWluZyUyMENBJTIwMS5j
# cmyGgcBsZGFwOi8vL0NOPUVDQ08lMjBJc3N1aW5nJTIwQ0ElMjAxLENOPURLSFFD
# QTAyLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNl
# cyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERDPW5ldD9jZXJ0aWZpY2F0
# ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9u
# UG9pbnQwggEmBggrBgEFBQcBAQSCARgwggEUMFgGCCsGAQUFBzAChkxodHRwOi8v
# cGtpLmVjY28uY29tL3BraS9ES0hRQ0EwMi5lY2NvY29ycC5uZXRfRUNDTyUyMElz
# c3VpbmclMjBDQSUyMDEoMykuY3J0MIG3BggrBgEFBQcwAoaBqmxkYXA6Ly8vQ049
# RUNDTyUyMElzc3VpbmclMjBDQSUyMDEsQ049QUlBLENOPVB1YmxpYyUyMEtleSUy
# MFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9ZWNjb2Nv
# cnAsREM9bmV0P2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZp
# Y2F0aW9uQXV0aG9yaXR5MCgGA1UdEQQhMB+gHQYKKwYBBAGCNxQCA6APDA1TS0pB
# QGVjY28uY29tMA0GCSqGSIb3DQEBBQUAA4IBAQCuQxLKthhtiDPwKFTBZXf3wtJJ
# JvNqTEt0fj9tEySdk+IZQ2WJzcj8wpt3V0A5aTYjC7bEgyxSmIWaT4Et2u30hpzF
# 2p3PSkdPYxziV5XVYXUWh8RiqEEtpyQmV+tRbwG+Tu6aQRxaBh+LT2EoclD8+85u
# sO9XCo5KPrj/Fu8Z79+LvMeDqEVie1xrlgwMdcQmK4KeqS40nHdHu2p2nDt2TsBv
# 8ACaQMRsWpc1F6x8AIQw4ZQBtlKzuTd4n1IGxPsFMG+4QAt0o4LqY+LIWu/TliQj
# FTmFbOJjxXd1cFBaPx8pL9JHeljRukLcT5jXR+dAHjLo0EbMwouZsNNyj57ZMYIC
# AzCCAf8CAQEwYjBLMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQB
# GRYIZWNjb2NvcnAxGjAYBgNVBAMTEUVDQ08gSXNzdWluZyBDQSAxAhMWACjK2J2c
# EmeCYIFMAAMAKMrYMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgACh
# AoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAM
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTxNMms2kfC1ZjI7TLLPXaqcB7N
# mTANBgkqhkiG9w0BAQEFAASCAQAq/omaxwk0UzbF/RwNF/kaZdvbjbQbQKERjWc2
# rteNLp48BhabRsjwPNlYyLtNJ00efQ4fhA9Dj030TVnUdWBsMCfqJnZMmMdCUIqL
# Li1Cr5jIbkAJf1rtNJ8NN+UyS94SF+lZtSm1qx4EUi+TKvvNPRcfF1FuvF6JlRVP
# NS/07YTbmdFMqNkMfBrbDv51qLFaY3/kn8S6dRWU+4XH3Vs17tJlGiYml8Q3C9nq
# WP9OKJquZf+L0jlmkAEpRvQ1e3Up+Y4mQAARZCubdVKVdCIC4T129E4raDEsDUmw
# CgsKnbYrkQ33kJAAlwF+ocNSVr6itks3Ap+S4EMBPcuHoLf0
# SIG # End signature block
