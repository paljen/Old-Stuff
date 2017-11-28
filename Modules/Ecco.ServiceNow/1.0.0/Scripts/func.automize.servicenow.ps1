
Function Get-SNObject {
<#
.Synopsis
   Author Automize / Flemming Rohde & René Falkenberg
   Version 1.0
   
   PowerShell module for integration with ServiceNow

.DESCRIPTION
   The Get-SNObject funtion will retrieve an object from SericeNow

.EXAMPLE
   Get-SNObject -InstanceName "dev12345" -TableName "cmdb_ci_computer" -SNFieldName "name" -Credentials $Cred -SNObjectName "test123"

.PARAMETER InstaceName
   name of the ServiceNow Instance to use

.PARAMETER TableName
   name of the table to use in ServiceNow

.PARAMETER SNFieldName
   name of the field to use in ServiceNow

.PARAMETER Credentials
   PSCredential with permissions in ServiceNow

.OUTPUTS
   Outputs objects from ServiceNow in JSON format

.FUNCTIONALITY
   Retrieve objects from a given ServiceNow instance
#>

param
(
  [String]
  [Parameter(Mandatory=$true)]
  $InstanceName,

  [string]
  [Parameter(Mandatory=$true)]
  $TableName,

  [string]
  [parameter(Mandatory=$false)]
  $SNFieldName,

  [string]
  [Parameter(Mandatory=$false)]
  $SNObjectName,

  [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credentials
)

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credentials.UserName, $Credentials.GetNetworkCredential().Password)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')

# Return singleobject 
    # Specify endpoint uri
    $uri = "https://$InstanceName.service-now.com/api/now/table/$TableName`?sysparm_query=$SNFieldName%3D$SNObjectName"
    Write-Verbose "URI is set to: $uri"

# Specify HTTP method
$method = "get"
Write-Verbose "HTTP method is: $method"


#{request.body ? "$body = \"" :""}"}

# Send HTTP request
try{
    $response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri 
}
catch{

}

# Print response
$JSON = $response | ConvertFrom-Json 

if($JSON.result -eq '0'){
    Write-Output '0 results returned.'
}
else
{
    $JSON.result
}
}#End of Function Get-SNObject

Function New-SNObject {
<#
.Synopsis
   Author Automize / Flemming Rohde & René Falkenberg
   Version 1.0
   
   PowerShell module for integration with ServiceNow

.DESCRIPTION
   The New-SNObject funtion will create a new object in SericeNow

.EXAMPLE
   New-SNObject -InstanceName "dev12345" -TableName "cmdb_ci_computer" -Content @{'fqdn' = "test123.test.local"; 'name' = "test123"; 'install_status' = "1"} -Credentials $Cred -Verbose

.PARAMETER InstaceName
   name of the ServiceNow Instance to use

.PARAMETER TableName
   name of the table to use in ServiceNow

.PARAMETER Content
   hashtable with values to set at ServiceNow

.PARAMETER Credentials
   PSCredential with permissions in ServiceNow

.OUTPUTS
   Outputs object from ServiceNow in JSON format

.FUNCTIONALITY
   create a new object in a ServiceNow instance
#>

 Param(
   [Parameter(Mandatory=$true)][string]$InstanceName,
   [Parameter(Mandatory=$true)][string]$TableName,
   [Parameter(Mandatory=$true)][Hashtable]$Content,
   [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credentials
   )

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credentials.UserName, $Credentials.GetNetworkCredential().Password)))

# Set proper headers for new ServiceNow Object
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
$uri = "https://$InstanceName.service-now.com/api/now/table/$TableName"

# Specify HTTP method
$method = "post"

# Specify request body
$body = $Content | ConvertTo-Json

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $body -Verbose

$JSON = $response | ConvertFrom-Json

$JSON.result

}#End of Function New-SNObject

Function Update-SNObject {
<#
.Synopsis
   Author Automize / Flemming Rohde & René Falkenberg
   Version 1.0
   
   PowerShell module for integration with ServiceNow

.DESCRIPTION
   The Update-SNObject funtion will update a specific object in SericeNow

.EXAMPLE
   Update-SNObject -InstanceName "dev12152" -TableName "cmdb_ci_computer" -Content @{'install_status' = "3"} -SysID "c4b2d2434f002200b816b4a18110c71b" -Credentials $Cred -Verbose

.PARAMETER InstaceName
   name of the ServiceNow Instance to use

.PARAMETER TableName
   name of the table to use in ServiceNow

.PARAMETER Content
   hashtable with values to set at ServiceNow

.PARAMETER SysID
    SysID of the ServiceNow object about to be updated - can be retrived by using Get-SNObject CMDLet

.PARAMETER Credentials
   PSCredential with permissions in ServiceNow

.OUTPUTS
   Outputs object from ServiceNow in JSON format

.FUNCTIONALITY
   update a specific object in a ServiceNow instance

#>

 Param(
   [Parameter(Mandatory=$true)][string]$InstanceName,
   [Parameter(Mandatory=$true)][string]$TableName,
   [Parameter(Mandatory=$true)][Hashtable]$Content,
   [Parameter(Mandatory=$true)][string]$SysID,
   [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credentials
   )

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credentials.UserName, $Credentials.GetNetworkCredential().Password)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
$uri = "https://$InstanceName.service-now.com/api/now/table/$TableName/$SysID"

# Specify HTTP method
$method = "put"

# Specify request body
$body = $Content | ConvertTo-Json

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $body -Verbose

$JSON = $response | ConvertFrom-Json

$JSON.result

}#End of Function Update-SNObject

Function Remove-SNObject {
<#
.Synopsis
   Author Automize / Flemming Rohde & René Falkenberg
   Version 1.0
   
   PowerShell module for integration with ServiceNow

.DESCRIPTION
   The Remove-SNObject funtion will remove a specific object in SericeNow

.EXAMPLE
   Remove-SNObject -InstanceName "dev12345" -TableName "cmdb_ci_computer" -SysID "c4b2d2434f002200b816b4a18110c71b" -Credentials $Cred

.PARAMETER InstaceName
   name of the ServiceNow Instance to use

.PARAMETER TableName
   name of the table to use in ServiceNow

.PARAMETER SysID
    SysID of the ServiceNow object about to be removed - can be retrived by using Get-SNObject CMDLet

.PARAMETER Credentials
   PSCredential with permissions in ServiceNow

.OUTPUTS
   Outputs object from ServiceNow in JSON format

.FUNCTIONALITY
   update a specific object in a ServiceNow instance
#>

 Param(
   [Parameter(Mandatory=$true)][string]$InstanceName,
   [Parameter(Mandatory=$true)][string]$TableName,
   [Parameter(Mandatory=$true)][string]$SysID,
   [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credentials
   )

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Credentials.UserName, $Credentials.GetNetworkCredential().Password)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
$headers.Add('Accept','application/json')
$headers.Add('Content-Type','application/json')

# Specify endpoint uri
$uri = "https://$InstanceName.service-now.com/api/now/table/$TableName/$SysID"

# Specify HTTP method
$method = "delete"

# Send HTTP request
$response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Verbose

# Print response
return $response.RawContent

}#End of Function Remove-SNObject


# SIG # Begin signature block
# MIIPSAYJKoZIhvcNAQcCoIIPOTCCDzUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWem9M3r7gTBn6ea9EXabdcUQ
# WaGgggyvMIIGEDCCBPigAwIBAgITMAAAACpnbAZ3NwLCSQAAAAAAKjANBgkqhkiG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUaEx0PhGMCbQ3oqUKwtRU6ZS7cW4wDQYJKoZI
# hvcNAQEBBQAEggEAR9KnwGgpsJcOyqHU57iK/cJtIyenZODe6MC4ltXJnApJRrSk
# Pl3iIN+Xe7m2EqBcRFQSv1LcvIYLkOOtnYTdCNdbRzCvv7XI7WplpDKgwwO2AKQs
# oXyieATilpfixmT+xtF2Bw5V+opX5kgvlcgVSNNNbX4w/6Q4U/utrGq6ftfE1Ef4
# 2+YeSyM4mjkaEbQE7xLrLEfDnodx6Jdx+8+s7p4LYdMV2KnfpPyuqjbFyQ5BJ60G
# sewn2mEwhnXJPx6wL4XZknLmco04dTVVuUgTQirQi/KZLoABuj5ryiUlWsrhz4xu
# KTjF+e1xdVQDI4JGOPMUYtgWtMkRYkPax6IRuA==
# SIG # End signature block
