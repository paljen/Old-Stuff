Function Connect-EcSPOService
{
    <#
    .SYNOPSIS
        Connect to SharePoint Online

    .DESCRIPTION
        Connects to Sharepoint online

    .EXAMPLE
        Connect-EcSPOService
        
        Connect to SharePoint Online

    .INPUTS
        NA

    .OUTPUTS
        NA

    .NOTES
        Version:		1.0.0
        Author:			Admin-SKJA
        Creation Date:	07/09/2016
        Module Script:  func.skja.SharePointOnline
        Purpose/Change:	Initial function development
    #>

    [CmdletBinding()]

    Param()

    $ErrorActionPreference = "Stop"

    try
    {

        $password = "76492d1116743f0423413b16050a5345MgB8AEIAOQBuADIASgBBAEcAegA1AEEAZwA3AFIAQQBFAGIAVQAxAHUASwBvAFEAPQA9AHwAYQA5ADgAMAA3ADIAYgA2ADAAZABjADIAMgAyAGIAYQA3AGEAMAA2ADQAOABjAGEAZQBkADEANgAyADEAYQBlADIAYgAxADMAYwAyAGUANwA5ADQAYwA1ADMAOQA5ADUAMgAwAGYAOQA2AGMANQAyAGQAZgBmADUANAA5ADIANAA="
        $key = "96 99 65 89 28 45 161 230 46 154 249 65 90 196 141 173 102 56 238 28 67 178 245 110 243 137 12 179 140 175 232 137"
        $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
        $cred = New-Object system.Management.Automation.PSCredential("AzService-SPAdmin@ecco.onmicrosoft.com", $passwordSecure)


        $conn = Connect-SPOService -url https://ecco-admin.sharepoint.com -Credential $cred
    }
    catch
    {
        Write-Output $_.Exception.Message
    }
}

function Clean-EcSPSitePermissions ($siteurl) {
    # add SEC-O365-SharePoint-Admins group as sec. site col admin
    Set-SPOUser -Site $siteurl -IsSiteCollectionAdmin $true -LoginName "c:0-.f|rolemanager|s-1-5-21-3877733521-775173475-1150449512-17576433"
    # add AzService-SPAdmin@ecco.onmicrosoft.com as site col. admin
    Set-SPOUser -Site $siteurl -IsSiteCollectionAdmin $true -LoginName "AzService-SPAdmin@ecco.onmicrosoft.com"
    # remove company administrator (global admins) as site col admin
    Set-SPOUser -Site $siteurl -IsSiteCollectionAdmin $false -LoginName "c:0-.f|rolemanager|s-1-5-21-3877733521-775173475-1150449512-4996342"
    # remove Sharepoint service administrator as site col admin.
    Set-SPOUser -Site $siteurl -IsSiteCollectionAdmin $false -LoginName "c:0-.f|rolemanager|s-1-5-21-3877733521-775173475-1150449512-16858415"
}

Function New-EcSPOSite {
    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$ShortName,

	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$Title,

        #License Profile to be added
        [Parameter(Mandatory=$true)]
        [ValidateSet("TeamSite", "ProjectSite", "PublishingSite")]
        [String]$Template,


        #ATimeZone
        [Parameter(Mandatory=$true)]
        [ValidateSet("DK", "US-CentralTime")]
	    [String]$TimeZone

        #Storage assigned in GB
        #[Parameter(Mandatory=$true)]
        #[String]$StorageQuotaGB
    )

    $BaseUrl = "Https://ecco.sharepoint.com/sites/"
    $TimeZoneId = 3 #Default to DK time
    $TemplateId = "STS#0" #Default to Team site

    switch ($TimeZone) 
        { 
            "DK"              {$TimeZoneId = 3} 
            "US-CentralTime"  {$TimeZoneId = 11} 
        }
    
    switch ($Template) 
        { 
            "TeamSite"     {$TemplateId = "STS#0"} 
            "ProjectSite"  {$TemplateId = "PROJECTSITE#0"} 
            "PublishingSite" {$TemplateId = "BLANKINTERNETCONTAINER#0"}
        } 

    try
    {
        $FullUrl = "$BaseUrl$ShortName"
        [int]$StorageQuotaGB = 10
        $StorageQuotaMB = [int]$StorageQuotaGB * 1024
        New-SPOSite -Url $FullUrl -Owner "AzService-SPAdmin@ecco.onmicrosoft.com" -StorageQuota $StorageQuotaMB -Title $Title -Template $TemplateId -TimeZoneId $TimeZoneId
        
        Clean-EcSPSitePermissions -siteurl $FullUrl
    }
    catch
    {
        Write-Output $_.Exception.Message
    }
}

Function Add-EcSPOOneDriveSiteAdmin {
    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$OneDriveAccountURL,

	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$UserAccount
    )

    Set-SPOUser -Site $OneDriveAccountURL -LoginName $UserAccount -IsSiteCollectionAdmin $true
}

# SIG # Begin signature block
# MIIPUAYJKoZIhvcNAQcCoIIPQTCCDz0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK6UBILIRpo+gtM/BoQAApmcl
# IXCgggy3MIIGEDCCBPigAwIBAgITMAAAACmzBIx3JBq+BwAAAAAAKTANBgkqhkiG
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
# BgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRuF3W0r7OfOBnve0BVQYYOp2Eb
# ijANBgkqhkiG9w0BAQEFAASCAQCMjr8/PLgEZhuaK+SOqCoKkTw0m0PPDArAjGcW
# WzzKLKqGIlUGPJ4HXPUZ8PnmXZZ8OVRyXdlWPXOuLA96BQOh9y4jq3V67TNlOUaB
# 8XO0coeVb7TnJI3jSGoc2ZR/FlLSnjQe2nzMiAZi0VGeZ8XdKRQQt/sif7E1b0KJ
# inqetcPYWKtyEmIGVbDTY3DyJwCsc1fGOZO+X8GymoRyBRIQs4Qc5ad1aqmtnqyP
# wUtpkuV7Xp+iMN1jWsyXIjATSlZIS+d7RDLazsM8Qlb+NLVRrl521Mwiyb8XbKiR
# CoilX5B+sZIJFkz5902eytKHeD2HLWta2/pvJ3kmnpOY2JE8
# SIG # End signature block
