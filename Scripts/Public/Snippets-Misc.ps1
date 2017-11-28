$EncryptedAccount = @'
## Encrypted Credentials Code Generator
$path = 'c:\windows\temp\template.ps1'
New-Item -ItemType File $path -Force -ErrorAction SilentlyContinue  
  
$pwd = Read-Host 'Enter Password' -AsSecureString  
$user = Read-Host 'Enter Username'  
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 }  
$pwdencrypted = $pwd | ConvertFrom-SecureString -Key $key 
  
$private:ofs = ' '  
('$password = "{0}"' -f $pwdencrypted) | Out-File $path  
('$key = "{0}"' -f "$key") | Out-File $path -Append  
  
'$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))' | Out-File $path -Append  
('$cred = New-Object system.Management.Automation.PSCredential("{0}", $passwordSecure)' -f $user) | Out-File $path -Append  
  
ise $path
'@

New-IseSnippet -Force -Title "ECCO Collection (Splatting)" -Description "Use hashtable as properties" -Author "Palle Jensen" -Text '
#http://blogs.technet.com/b/heyscriptingguy/archive/2010/10/18/use-splatting-to-simplify-your-powershell-scripts.aspx

$usr = @{
    SamAccountName = "PJ*"
    LastName = "Jensen"
}

Get-QADUser @usr
'

New-IseSnippet -Force -Title "ECCO Comment Block" -Description "Basic Comment Block" -Author "Palle Jensen" -CaretOffset 50 -Text '
<#
.SYNOPSIS
	A brief description.

.DESCRIPTION
	A detailed description.

.PARAMETER  <Parameter-Name>
	The description of a parameter. Add a .PARAMETER keyword for each 
    parameter in the syntax.

.EXAMPLE
	A sample command , optionally followed by sample output and a description. 
    Repeat this keyword for each example.

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
'

New-IseSnippet -Force -Title "ECCO Object (String based - Selected)" -Description "Custom object, simple string" -Author "Palle Jensen" -Text '
$newObj = "" | select "Property1","Property2"
$newObj.Property1 = "Value1"
$newObj.Property2 = "Value2"

$myObj = get-service bits | select name, priority
$myObj.priority = "high"
'

New-IseSnippet -Force -Title "ECCO Object (NoteProperty)" -Description "Standard custom object" -Author "Palle Jensen" -Text '
$newObj = New-Object PSObject
$newObj | Add-Member -Type NoteProperty -Name FirstName -Value "Mike"
$newObj | Add-Member -Type NoteProperty -Name LastName -Value "Tyson"
$newObj | Add-Member -Type NoteProperty -Name Mobile -Value 01010101
'

New-IseSnippet -Force -Title "ECCO Object (Hashtable1)" -Description "Custom Object with hashtable technique 1" -Author "Palle Jensen" -Text '
$props = [Ordered]@{
         Firstname="Mike";
         LastName="Tyson";
         Mobile="01010101"}

$newObj = New-Object -TypeName PSObject –Prop $props
'

New-IseSnippet -Force -Title "ECCO Object (Hashtable2)" -Description "Custom Object with hashtable technique 2" -Author "Palle Jensen" -Text '
$props = @{}

$props.Firstname = "Mike"
$props.Lastname = "Tyson"
$props.Mobile = "01010101"

$newObj = New-Object -TypeName PSObject –Prop $props
'

New-IseSnippet -Force -Title "ECCO Session (Kerboros)" -Description "Session with Kerboros" -Author "Palle Jensen" -Text '
# Create session using Kerberos with direct remoting, number of hubs -eq 1. ex. comp1 to comp2

$session = New-PSSession -Name "<SessionName>" -ComputerName "<RemoteHost>" -Credential $cred
'

New-IseSnippet -Force -Title "ECCO Session (CredSSP)" -Description "Session with CredSSP" -Author "Palle Jensen" -Text '
# Create session using CredSSP with indirect remoting, number of hubs -gt 1. ex. remoting from comp1 to comp3 via comp2
# This approach requires that the machines are configured to allow delegate credentials, test with Get-WSManCredSSP and set with Set-WSManCredSSP

$session = New-PSSession -Name "<SessionName>" -ComputerName "<RemoteHost>" -Credential $cred -Authentication CredSSP
'

New-IseSnippet -Force -Title "ECCO Session (Invoke-command)" -Description "Import modules inside remote sessions" -Author "Palle Jensen" -Text '
## Import module within session

$mName = "<modulename>"
Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name $Using:mName}
'

New-IseSnippet -Force -Title "ECCO MyInvocation Parent Path" -Description "Get path of where you execute the script" -Author "Palle Jensen" -Text '

$parent = Split-Path -Parent $MyInvocation.MyCommand.Definition
'

#New-IseSnippet -Force -Title "ECCO Encrypted Automation Account" -Description "Encrypt Automation Account" -Author "Palle Jensen" -Text $EncryptedAccount
# SIG # Begin signature block
# MIIPSAYJKoZIhvcNAQcCoIIPOTCCDzUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpX1KPXRKJ+C+iSiEHCAFctLK
# 0k+gggyvMIIGEDCCBPigAwIBAgITMAAAACpnbAZ3NwLCSQAAAAAAKjANBgkqhkiG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKG4X2h7J64IKor1K/l1CrCXO5A0wDQYJKoZI
# hvcNAQEBBQAEggEAGSf6sNrkcvy9rz3oqGUQEewWl0zEq9uexFjvXXx+8ggIi02R
# Is6Uif/77NdxGkbLDphYU/+v/i3yjd26Yc2cGj7a1+A+U5iztur2XYpLICApTMfG
# jvDLnpTXvqRdHqgteGnc5SOyF+YrsC7NGIMeGU9BuMlS+bDcMhox9ru6VJu+ykYM
# uEHEfsqTCHOPxjYILu2MQqzHqhv0YGJeXfUulbjvRfcpILwQQjkG4VLNldJOvjN/
# 1AUGfDgYUEE7OsOmX/8Aka+6s83VnOPuvsWSuUrJv8IBDxzN4ZkPouEc6ChqgqJj
# B7c/937d+6tKhnJJhDC9KoFeT0RYCGRvJNdTIw==
# SIG # End signature block
