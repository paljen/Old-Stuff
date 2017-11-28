#Import-module Ecco.SqlCmd2

$Script:MiralixDBServer = "DKHQSQL04DB02\PRD2"
$Script:MiralixDatabase = "MiralixGreenbox"

function Get-EcMiralixUserDBSyncSetting
{
    <#
    .SYNOPSIS
	    Gets the users current sync setting in the Miralix database

    .PARAMETER UserEmail
        In the format xxx@ecco.com, or %@ecco.com for all Ecco.com users.
    
    .EXAMPLE
        Get-EcMiralixUserDBSyncSetting -UserEmail xxx@ecco.com
        Get-EcMiralixUserDBSyncSetting -UserEmail SK%@ecco.com

    .INPUTS
	    String

    .OUTPUTS
	    System.Data.DataSet object

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-SKJA
	    Creation Date:  01/09/2016
        Module Script:  func.skja.Miralix
	    Purpose/Change: Initial function development
    #>

    [CmdletBinding()]
    
    param 
    (
        [string]$UserEmail
    )
    Process {
        
        # Stop Script if an exception occour
        $ErrorActionPreference = "Stop"

        #Get-EcDBDataset -connectionString $Script:MiralixDBConnectionString -query "select * from user_account where _emailaddress = '$UserEmail'" -isSQLServer
        $DBQuery = "Select 
	                    UA.id,
	                    UA._emailaddress,

	                    (select top 1 CSUS1._Sync_setting from calender_sync_user_setting CSUS1 where CSUS1._user_account_id = UA.id and CSUS1._calender_sync_source_id = 1) as 'Office365',
	                    (select top 1 CSUS1._Sync_setting from calender_sync_user_setting CSUS1 where CSUS1._user_account_id = UA.id and CSUS1._calender_sync_source_id = 4) as 'Exchange2013'
                      from 
	                    calender_sync_user_setting CSUS
	                    left join calender_sync_source CSS on CSS.id = CSUS._calender_sync_source_id
	                    left join user_account UA on UA.id = CSUS._user_account_id
                      where UA._emailaddress like '$UserEmail'
                      group by ua.id, ua._emailaddress"
        $MiralixDbUser = Invoke-EcSqlcmd2 -ServerInstance $Script:MiralixDBServer -Database $Script:MiralixDatabase -Query $DBQuery


        Write-Output $MiralixDbUser
    }
}

function Set-EcMiralixUserDBSyncSetting
{
    <#
    .SYNOPSIS
	    Sets the users current sync setting in the Miralix database

    .PARAMETER UserEmail
        In the format xxx@ecco.com

    .PARAMETER SourceSystem
    
    .EXAMPLE
        Set-EcMiralixUserDBSyncSetting -UserEmail xxx@ecco.com -SourceSystem Office365

    .INPUTS
	    String

    .OUTPUTS
	    System.Data.DataSet object

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-SKJA
	    Creation Date:  01/09/2016
        Module Script:  func.skja.Miralix
	    Purpose/Change: Initial function development
    #>

    [CmdletBinding()]
    
    param 
    (
        [Parameter(Mandatory=$true)]
        [string]$UserEmail,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Office365", "Exchange2013")]
        [String]$SourceSystem
    )
    Process {
        # Stop Script if an exception occour
        $ErrorActionPreference = "Stop"

        $MiralixDBUser = Get-EcMiralixUserDBSyncSetting -UserEmail $UserEmail

        if (!$MiralixDBUser) {
            Write-Output "$($UserEmail): User not found in Database"
        }
        elseif ($MiralixDBUser.Count -gt 1) {
            Write-Output "More than one user found, please revise the email address parameter"
            $MiralixDBUser
        }
        else {

            if ($SourceSystem -eq "Office365") {
                if ($MiralixDBUser.Office365 -eq "inactive") {
                    Write-Output "$($UserEmail): Enabling sync towards Office 365"
                    #Enable Office 365:
                    Invoke-EcSqlcmd2 -ServerInstance $Script:MiralixDBServer -Database $Script:MiralixDatabase -Query "update calender_sync_user_setting set _sync_setting = 'all' where _user_account_id = $($MiralixDBUser.id) and _calender_sync_source_id = 1"        

                    #Disable Exchange 2013:
                    Invoke-EcSqlcmd2 -ServerInstance $Script:MiralixDBServer -Database $Script:MiralixDatabase -Query "update calender_sync_user_setting set _sync_setting = 'inactive' where _user_account_id = $($MiralixDBUser.id) and _calender_sync_source_id = 4"     
                }
                else {
                    Write-Output "$($UserEmail): User is already syncing from Office 365, no change performed"
                }   
            }
            elseif ($SourceSystem -eq "Exchange2013") {
                if ($MiralixDBUser.Exchange2013 -eq "inactive") {
                    Write-Output "$($UserEmail): Enabling sync towards Exchange 2013"
                    #Enable Exchange 2013:
                    Invoke-EcSqlcmd2 -ServerInstance $Script:MiralixDBServer -Database $Script:MiralixDatabase -Query "update calender_sync_user_setting set _sync_setting = 'all' where _user_account_id = $($MiralixDBUser.id) and _calender_sync_source_id = 4"       

                    #Disable Office 365:
                    Invoke-EcSqlcmd2 -ServerInstance $Script:MiralixDBServer -Database $Script:MiralixDatabase -Query "update calender_sync_user_setting set _sync_setting = 'inactive' where _user_account_id = $($MiralixDBUser.id) and _calender_sync_source_id = 1"   
                }
                else {
                    Write-Output "$($UserEmail): User is already syncing from Exchange 2013, no change performed"
                }
            }
            else {
                Write-Output "Source System defined is unknown"
            }
        }

    }
}


# SIG # Begin signature block
# MIIPSAYJKoZIhvcNAQcCoIIPOTCCDzUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt9Mrpzs8PMg/vgjrr6bdJWTZ
# kWOgggyvMIIGEDCCBPigAwIBAgITMAAAACpnbAZ3NwLCSQAAAAAAKjANBgkqhkiG
# 9w0BAQUFADBGMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYI
# ZWNjb2NvcnAxFTATBgNVBAMTDEVDQ08gUm9vdCBDQTAeFw0xNjAyMDUwNzMxMzRa
# Fw0yMjAyMDUwNzQxMzRaMEsxEzARBgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJ
# k/IsZAEZFghlY2NvY29ycDEaMBgGA1UEAxMRRUNDTyBJc3N1aW5nIENBIDIwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDRip52iBQlWT8qIN+ak0QzRJ6d
# LdLikRkFKtLp2DQlx7yC/9L4l+gXa/0DEmvvVfx5hWiY38IaCFEJ5cD4LEzNAn7p
# 85F9J+RXgswlVJIYh1IZ0odEjnWN3amGySTznHtqcsmMAVeOp+YNaKoeupFBaq79
# sm8EvhE3bbwU25I57BKnZ/r72FMBqXXsvgHoLs+wBhUWDh6TEGwyCjgykA+Ve3WJ
# PimuVu1o/AMN4CP89VMitHcGe+dh9bA/WGUm7weHtCLKGm2SjSAdl5JU/8p+ElA0
# BuAg3K4ZCxJn04Ay8/OPHVXLd4Hws2qKCWQOQZJ3CIGz+kv1gWS5WC8fw75xAgMB
# AAGjggLwMIIC7DAQBgkrBgEEAYI3FQEEAwIBAjAjBgkrBgEEAYI3FQIEFgQUsEgv
# YdPesnynh6crqATvWxYCcSwwHQYDVR0OBBYEFKu4DJf1/NKT7bctI5su/7e/CuON
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
# AQEFBQADggEBAIEXlJyIDAVMqSGrleaJmrbgh+dmRssUUUwQQCvtiwTofJrzPCNy
# DWOcEtnXgor83DZW6sU4AUsMFi1opz9GAE362toR//ruyi9cF0vLIh6W60cS2m/N
# vGvgKz7bb235J4tWi0Jj9sCZQ8sFBI61uIlmYiryTEA2bOdAZ5fQX1wide0qCDMi
# CU3yNz4b9VZ7nmB95WKzJ1ZvPjVfTyHBdtK9fhRU/IiJORKzlbMyPxortpCnb0VK
# O/uLYMD4itTk2QxTxx4ZND2Vqi2uJ0dMNO79ELfZ9e9C9jaW2JfEsCxy1ooHsjki
# TpJ+9fNJO7Ws3xru/gINd+G1KdCRG1vYgpswggaXMIIFf6ADAgECAhNYACe/37gE
# fPQoHYROAAIAJ7/fMA0GCSqGSIb3DQEBBQUAMEsxEzARBgoJkiaJk/IsZAEZFgNu
# ZXQxGDAWBgoJkiaJk/IsZAEZFghlY2NvY29ycDEaMBgGA1UEAxMRRUNDTyBJc3N1
# aW5nIENBIDIwHhcNMTYwMjI5MDkzMzUzWhcNMTgwMjI4MDkzMzUzWjCBhjETMBEG
# CgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT8ixkARkWCGVjY29jb3JwMRMwEQYK
# CZImiZPyLGQBGRYDcHJkMSMwIQYDVQQLExpTZXJ2aWNlIGFuZCBBZG1pbiBBY2Nv
# dW50czEbMBkGA1UEAxMSQWRtaW4tUGFsbGUgSmVuc2VuMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAxmqcSpu1qSLe7vVysjMibrbQeaV9PHz7MMPazFm2
# 5FKRmuCylaMRRZhCfRVRX06qbEVDjujD+ZKd0NJv8SpNO45ibfh5xSguZwHNQByq
# LN3S/VVcjtpuyX5yygzKSMwEzdj/dHCUGl2Aczvg5NmU1y8RTCsLYqj+V1bokAr2
# +nwqWTkZyRd/eoqGsND2DONyIJ2ApXbFnHwcpSq9mgAbbOvMFeyTay07MPUmB+2i
# AnCvr1Uv9YNhsNf3rwDrnYBJCQsZxnRkUBLhzjbb8jfGQUSYdQcjYlFJ2SQWg4Un
# r5w/xY5Tch8gg5G0n3MEdvWLH0YCB0/3r3X4Cw4b/eXJvwIDAQABo4IDNjCCAzIw
# OwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUI+71Gh8eFYImPIYeczGmB75k2eobL
# pxuE5NYXAgFkAgEJMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIH
# gDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQwtdTxDNLj
# LTzwsstoDiLwyETyZDAfBgNVHSMEGDAWgBSruAyX9fzSk+23LSObLv+3vwrjjTCC
# AQ4GA1UdHwSCAQUwggEBMIH+oIH7oIH4hjNodHRwOi8vcGtpLmVjY28uY29tL3Br
# aS9FQ0NPJTIwSXNzdWluZyUyMENBJTIwMi5jcmyGgcBsZGFwOi8vL0NOPUVDQ08l
# MjBJc3N1aW5nJTIwQ0ElMjAyLENOPURLSFFDQTAzLENOPUNEUCxDTj1QdWJsaWMl
# MjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERD
# PWVjY29jb3JwLERDPW5ldD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/
# b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggEmBggrBgEFBQcBAQSC
# ARgwggEUMFgGCCsGAQUFBzAChkxodHRwOi8vcGtpLmVjY28uY29tL3BraS9ES0hR
# Q0EwMy5lY2NvY29ycC5uZXRfRUNDTyUyMElzc3VpbmclMjBDQSUyMDIoMikuY3J0
# MIG3BggrBgEFBQcwAoaBqmxkYXA6Ly8vQ049RUNDTyUyMElzc3VpbmclMjBDQSUy
# MDIsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2Vz
# LENOPUNvbmZpZ3VyYXRpb24sREM9ZWNjb2NvcnAsREM9bmV0P2NBQ2VydGlmaWNh
# dGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MDUGA1Ud
# EQQuMCygKgYKKwYBBAGCNxQCA6AcDBpBZG1pbi1QSkVAcHJkLmVjY29jb3JwLm5l
# dDANBgkqhkiG9w0BAQUFAAOCAQEATns0EOsQVL2xSjiETgb3or1+8QvtwV08E0eR
# pFVAwUrQLRav/a4LYobrHm0zIZ2qg5Zswk9PdQpFN3SjNKNGfBTRWOTJeqQq7GBF
# WlZeA6KCmT17KZYj3omSOOYzrAOnG1l2DaX+z14HIGwdJRZHKL23S2okPyEWumYN
# cSoyear7Tmaqxt0WrQtx+xfUB8dlURzU6cSrCzYDhh73jzrPucID8g2HsXdXgoRx
# X/TNIEY7HY7HWQxIiQxjuv9zs8NMdokowrVTbgmP6bkLOadCYb7bt9mBJNr17jBk
# +UQOIxT8vFCbgNliBl0+ZrBBjNOmnuOd9a9oZNUVdbwlBj3FpzGCAgMwggH/AgEB
# MGIwSzETMBEGCgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT8ixkARkWCGVjY29j
# b3JwMRowGAYDVQQDExFFQ0NPIElzc3VpbmcgQ0EgMgITWAAnv9+4BHz0KB2ETgAC
# ACe/3zAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUzencZXi6IJwj1ehk6Vwx86J1lXAwDQYJKoZI
# hvcNAQEBBQAEggEAhTkKWmnuSwlMkYYYchsGbLWFvMsN8O2a1G7Ko+TCltgC0Xz+
# HWuxcRDyXBaOjZ0EDBF/L0U/cy5bjUUQBDJZcG4ZwmpuRU5buSHfDYf/Wl98QHyI
# bm8I7O40cQ7TesOFG9VadvwIoCpnpsnwZKI8EKxP2RGgUfbYlEdmtw66uOdiG5ZJ
# SxFKtIZo2jUuRL/CDgJ4hc5ZdJX3TbNthJtTPF5U6vLyBK45myQ9I2GTKgAjmUDV
# YPe3Co091+TFy89oZOkYFZhRV7ULidZjcxuHJLrY1TUhs1rx+J86yt3NXqFhgdc/
# NITXXMAfseNkhhVPEf9nGhYVJF3MVkN7f58SKQ==
# SIG # End signature block
