﻿$advFunction = @'
Function verb-noum 
{
    <#
    .SYNOPSIS
	    A brief description of the function.

    .DESCRIPTION
	    A detailed description of the function.

    .PARAMETER  <Parameter-Name>
	    The description of a parameter. Add a .PARAMETER keyword for
	    each parameter in the function syntax.

    .EXAMPLE
	    A sample command that uses the function, optionally followed
	    by sample output and a description. Repeat this keyword for each example.

    .INPUTS
	    The Microsoft .NET Framework types of objects that can be piped to the
	    function. You can also include a description of the input objects.

    .OUTPUTS
	    The .NET Framework type of the objects that the function returns. You can
	    also include a description of the returned objects.

    .NOTES
	    Version:		1.0.0
	    Author:			
	    Creation Date:	
	    Purpose/Change:	Initial function development
    #>

    [CmdletBinding(DefaultParametersetName="Parameter Set 1")]

    Param 
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName="Parameter Set 1")]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName="Parameter Set 1")]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        [int]$Param2,

        # Param3 help description
        [Parameter(ParameterSetName="Another Parameter Set")]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]$Param3
    
    )

    Begin 
    {
        
    }

    Process 
    {
        Try 
        {
            ## <code goes here>             
        }

        Catch 
        {
            $_.Exception.Message
            Break
        }
    }

    End 
    {
        
    }
}
'@
New-IseSnippet -Force -Title "ECCO Advanced Function" -Description "Advanced function" -Author "Palle Jensen" -Text $advFunction
# SIG # Begin signature block
# MIIPSAYJKoZIhvcNAQcCoIIPOTCCDzUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMGudADKlwrPaZ/aXu0/g2zt9
# wEqgggyvMIIGEDCCBPigAwIBAgITMAAAACpnbAZ3NwLCSQAAAAAAKjANBgkqhkiG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPZ47/iCAMcwSmhfD8f4n5o9hrvMwDQYJKoZI
# hvcNAQEBBQAEggEAkSkdBn3n7YzmwIGe6ZQ9lIuK6caEIrkvqNwudSKgdGxppyFl
# 8tqUA3P8OAPTgNXkJcehBTehUHPBlixbwC/4mkiiVjmfynYVt9M7Sld48KmcKmWO
# 20LUBXbnrqulSLt2DbOEmVaDIAMvIuejuRsqkkVzvFQzm0gLkfOCNE3suf0Ncinl
# HqY7L+lDjwluFYswB14ENZP2ENV0qY1W+Rpv3TQro+yoAwFgdpQEVkDly9QvqgzD
# cA7eFEakX1QlVTFZQanqNgGgG7uPHgI/kA3BKRFLC1+bOoLtCcpOh1bzurYkUTwi
# l/vknceY9kA0pDWSpQlfrQ+gjWXY/qQoHz14IQ==
# SIG # End signature block