
Function New-EcSCCMAppxPackageSigning
{
    <#
     .SYNOPSIS
        This script signs an .appx file for Windows Phone 8.1 sideloading using a Symantec Enterprise Mobile Code Signing Certificate.

     .DESCRIPTION
        This script signs an .appx file for Windows Phone 8.1 sideloading using a Symantec Enterprise Mobile Code Signing Certificate.
        This script requires the Windows SDK for Windows 8.1 be installed on the host computer.
        This script also requires an Application Enrollment Token (.aetx) file that is generated using your Symantec Enterprise Mobile Code Signing Certificate.
 
    .PARAMETER AppxFile
        The path to where the source appx file is located.

    .PARAMETER PfxFile
        The path to Symantec Enterprise Mobile Code Signing Certificate (.PFX) file.

    .PARAMETER AetxFile	
        The path to the .aetx file which is used for reading the enterprise ID if the 'EnterpriseId' argument is not defined. Either this argument or EnterpriseId must be provided.

    .PARAMETER SdkPath
        The path to the root folder of the Windows SDK for Windows 8.1. This argument is optional and defaults to ${env:ProgramFiles(x86)}\Windows Kits\8.1

    .PARAMETER PfxPassword
        The password of the Symantec Enterprise Mobile Code Signing Certificate.

    .LINK
        To download Windows SDK for Windows 8.1, visit http://go.microsoft.com/fwlink/?LinkId=613525

    .LINK
        For more information on Symantec Enterprise Mobile Code Signing Certificates and signing process visit http://go.microsoft.com/fwlink/?LinkId=613524
    
    .LINK
	    For more information on how to generate an AETX file, visit http://go.microsoft.com/fwlink/?LinkId=615047.

    .EXAMPLE
        DK4836\C:\Windows\system32> New-EcSCCMAppxPackageSigning2 -PfxFile CodeSigning.pfx -AetxFile AET.aetx -AppxFile ECCOFiori_PROD_1.1.0.1_ARM.APPX -PfxPassword Ecc0sh0esr0ck
        
        Done Adding Additional Store
        Successfully signed: \\prd.eccocorp.net\it\CMSource\Mobile Device Management\Apps\Signed\ECCOFiori_PROD_1.1.0.1_ARM _Signed.APPX

        Package signed for Windows Phone sideloading.
    #>

    [CmdletBinding()]

    Param(
        [Parameter(Mandatory=$true)] 
        [String]$PfxPassword
    )

    DynamicParam {

        # Set the dynamic parameters' name
        $PfxFile = 'PfxFile'
        $AetxFile = 'AetxFile'
        $AppxFile = 'AppxFile'
            
        # Create dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
                        
        # Create and set parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true

        # Create collection of attributes
        $PfxAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AetxAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AppxAttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
        # Add the attributes to the attributes collection
        $PfxAttributeCollection.Add($ParameterAttribute)
        $AetxAttributeCollection.Add($ParameterAttribute)
        $AppxAttributeCollection.Add($ParameterAttribute)

        # Global paths
        $CMSource = "\\prd.eccocorp.net\it\CMSource\Mobile Device Management\Apps"
        $Global:Staging = "$CMSource\Staging"
        $Global:Signing = "$CMSource\Staging\Signing"
        $Global:Signed = "$CMSource\Signed"
        
        # Generate and set the ValidateSet 
        $arrSetPfx = Get-ChildItem -Path $Global:Signing -Depth 1 | Where {$_.Name -like "*.pfx"} | Select-Object -ExpandProperty Name
        $arrSetAetx = Get-ChildItem -Path $Global:Signing -Depth 1 | Where {$_.Name -like "*.aetx"} | Select-Object -ExpandProperty Name
        $arrSetInput = Get-ChildItem -Path $Global:Staging -Depth 1 | Where {$_.Name -like "*.appx"} | Select-Object -ExpandProperty Name

        $PfxValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSetPfx)
        $AetxValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSetAetx)
        $AppxValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSetInput)

        # Add the ValidateSet to the attributes collection
        $PfxAttributeCollection.Add($PfxValidateSetAttribute)
        $AetxAttributeCollection.Add($AetxValidateSetAttribute)
        $AppxAttributeCollection.Add($AppxValidateSetAttribute)

        # Create and return the dynamic parameter
        $PfxRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($PfxFile, [string], $PfxAttributeCollection)
        $AetxRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($AetxFile, [string], $AetxAttributeCollection)
        $AppxRuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($AppxFile, [string], $AppxAttributeCollection)
        $RuntimeParameterDictionary.Add($PfxFile, $PfxRuntimeParameter)
        $RuntimeParameterDictionary.Add($AetxFile, $AetxRuntimeParameter)
        $RuntimeParameterDictionary.Add($AppxFile, $AppxRuntimeParameter)
        return $RuntimeParameterDictionary
    }

    begin 
    {
        # Bind the parameter to a friendly variable       
        $PfxFilePath = $PsBoundParameters[$PfxFile]
        $AetxFile = $PsBoundParameters[$AetxFile]
        $InputAppx = $PsBoundParameters[$AppxFile]
        $OutputAppx = $InputAppx -split ".APPX"
        $OutputAppx = "$($OutputAppx)_Signed.APPX"
    }

    process 
    {        
        # Stop execution on the first error since it doesn't make sense to continue.
        $ErrorActionPreference = 'Stop'

        $SdkPath = "${env:ProgramFiles(x86)}\Windows Kits\8.1"

        if((Get-ChildItem "$SdkPath\bin" -Depth 1 -Directory).Name -contains "x86"){
            $MakeAppxFile = "$SdkPath\bin\x86\MakeAppx.exe"
            $SignToolPath = "$SdkPath\bin\x86\SignTool.exe"}
        else{
            $MakeAppxFile = "$SdkPath\bin\x64\MakeAppx.exe"
            $SignToolPath = "$SdkPath\bin\x64\SignTool.exe"}

        Add-Type -AssemblyName System.Security

        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

        try
        {
            $cert.Import("$Global:signing\$PfxFilePath", $PfxPassword, 'DefaultKeySet')
            $PublisherId = $cert.Subject
        }
        catch [System.Security.Cryptography.CryptographicException]
        {
            Throw "Failed to read signing certificate: $_"
        }

        $aetxContent = [xml](get-content "$Global:signing\$AetxFile")
    
        # Read enterprise ID from EnterpriseAppManagement node
        $enterpriseIdAetx = $aetxContent.SelectSingleNode('/wap-provisioningdoc/characteristic[@type="EnterpriseAppManagement"]/characteristic/@type').value
    
        # Read enterprise ID from the inner EnrollmentToken node
        $enrollmentToken = $aetxContent.SelectSingleNode('/wap-provisioningdoc/characteristic[@type="EnterpriseAppManagement"]/characteristic/parm[@datatype="string" and @name="EnrollmentToken"]/@value').value
        $aetXml = [xml]([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($enrollmentToken)))
        $enterpriseIdAet = [uint32]($aetXml.AET.EnterpriseId.Value)

        # Validate that the two IDs match
        if($enterpriseIdAetx -ne $enterpriseIdAet)
        {
            Throw "The Enterprise IDs read from AETX file are not consistent."
        }
    
        $EnterpriseId = [uint32]$enterpriseIdAetx

        Write-Verbose "Enterprise ID read from the AETX: $EnterpriseId"

        # Create the phone publisher ID GUID based on enterprise ID.
        $PhonePublisherId = New-Object Guid($EnterpriseId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        Write-Verbose "The phone publisher ID to use in app manifest: $PhonePublisherId"

        # Use a temp folder to unpack the AppX file.
        $appxTempFolder = [IO.Path]::Combine([IO.Path]::GetTempPath(), [Guid]::NewGuid())

        Write-Verbose "Extracting Appx '$Global:staging\$InputAppx' to temp folder '$appxTempFolder'"
        &"$MakeAppxFile" unpack /l /p "$Global:staging\$InputAppx" /d "$appxTempFolder" | Out-Null

        if(!$?)
        {
            Throw "Failed to unpack the appx file."
        }
        
        # Edit AppxManifest.xml.
        $appxManifestFile = [IO.Path]::Combine($appxTempFolder, "AppxManifest.xml")
        $appxManifest = [xml](get-content $appxManifestFile)

        $appxManifest.Package.Identity.Publisher = $PublisherId
        Write-Verbose "Publisher is set to: $PublisherId"

        $appxManifest.Package.PhoneIdentity.PhonePublisherId = [string]$PhonePublisherId
        Write-Verbose "PhonePublisherId is set to: $PhonePublisherId"

        Write-Verbose 'Saving changes to AppxManifest.xml'
        $appxManifest.Save($appxManifestFile)

        # Create the final appx file
        &"$MakeAppxFile" pack /l /d "$appxTempFolder" /p "$Global:signed\$OutputAppx" /o | Out-Null

        if(!$?)
        {
            Throw "Failed to repack the appx file."
        }

        # Sign the appx with the Symantec Enterprise Mobile Code Signing Certificate.
        &"$SignToolPath" sign /fd sha256 /f "$Global:signing\$PfxFilePath" /p "$PfxPassword" "$Global:signed\$OutputAppx"

        if(!$?)
        {
            Throw "Failed to sign the appx file."
        }

        Write-Verbose 'Deleting the temp folder.'
        Remove-Item -Recurse -Force $appxTempFolder

        Write-Host 'Package signed for Windows Phone sideloading.'
    }
}

Function New-EcSCCMMACExclude
{
    <#
    .SYNOPSIS
	    Add MAC Address to multivalue subkey

    .DESCRIPTION
	    This function adds a MAC Address to the ExcludeMACAddresses subkey, this MAC Address will then be ignored by SCCM

    .PARAMETER  CMProvider
	    The primary management point 

    .PARAMETER  CMSiteCode
	    The primary site code

    .PARAMETER  MACAddress
	    The Macadress that should be excluded

    .EXAMPLE
	    New-EcSCCMMACExclude -CMProvider dkhqsccm02 -CMSiteCode p01 -MACAddress "00:15:5D:06:35:25","00:15:5D:C5:9C:0A"
    
    .EXAMPLE
	    "00:15:5D:06:35:25","00:15:5D:C5:9C:0A" | New-EcSCCMMACExclude -CMProvider dkhqsccm02 -CMSiteCode p01
        
        This example uses the pipeline

    .INPUTS
	    System.String[]

    .OUTPUTS
	    None

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  14/09/16
        Module Script:  func.pje.sccm
	    Purpose/Change: Initial function development
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true)]
        [String]$CMProvider,
        [Parameter(Mandatory=$true)]
        [String]$CMSiteCode,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateScript({if($_ -match "\b(?:[A-Fa-f0-9]{2}[:]){5}(?:[A-Fa-f0-9]{2})\b"){$true} else {Throw "$_ is not valid"}})]
        [String[]]$MACAddress
    )

    Process
    {
        foreach($mac in $MACAddress)
        { 
            $subkey = "Software\Microsoft\SMS\Components\SMS_DISCOVERY_DATA_MANAGER"
            $name  = "ExcludeMACAddress"
            $CMNamespace = $("root\sms\site_$CMSiteCode")

            $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $CMProvider)
            $key = $reg.OpenSubKey($subkey, $true)
            $arr = $key.GetValue($name)

            if ($arr -notcontains $mac) 
            {
                $device = gwmi -ComputerName $CMProvider -Namespace $CMNamespace -Class "SMS_R_System" -Filter "MacAddresses='$mac'"
                
                If ($device) 
                {
                    $device.Delete()
                }

                $arr += $mac
                $key.SetValue($name, [string[]]$arr, 'MultiString')
            }
            else
            {
                Throw "$mac already excluded on $server"
            }
        }
    }
}

Function Get-EcSCCMMACExclude
{
    <#
    .SYNOPSIS
	    Get excluded MAC Address from sccm server

    .DESCRIPTION
	    This function gets all the MAC Addresses from the ExcludeMACAddresses subkey

    .PARAMETER  CMProvider
	    The primary management point 

    .EXAMPLE
	    DK4836\C:\Windows\system32> Get-EcSCCMMACExclude -CMProvider dkhqsccm02
        00:15:5D:06:35:25
        00:15:5D:C5:9C:0A
        00:15:5D:C6:9C:11
        00:15:5D:C6:9C:12
        00:15:5D:C6:9C:13
        00:15:5D:C6:9C:14
        00:15:5D:C6:9C:15

        Returns all excluded mac addresses on provider dkhqsccm02
    
    .EXAMPLE
	    DK4836\C:\Windows\system32> Get-EcSCCMMACExclude -CMProvider dkhqsccm02 | Where {$_ -like "*C6:9C*"}
        00:15:5D:C6:9C:11
        00:15:5D:C6:9C:12
        00:15:5D:C6:9C:13
        00:15:5D:C6:9C:14
        00:15:5D:C6:9C:15

        Returns a filtered result where mac addresses are like "*C6:9C*"

    .INPUTS
	    System.String

    .OUTPUTS
	    System.String

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  15/09/16
        Module Script:  func.pje.sccm
	    Purpose/Change: Initial function development
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$true)]
        [String]$CMProvider
    )

    $subkey = "Software\Microsoft\SMS\Components\SMS_DISCOVERY_DATA_MANAGER"
    $name  = "ExcludeMACAddress"
   
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $CMProvider)
    $key = $reg.OpenSubKey($subkey, $true)
    
    Write-output $($key.GetValue($name))
}


# SIG # Begin signature block
# MIIPSAYJKoZIhvcNAQcCoIIPOTCCDzUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfD4B4qu9tETOAPBgYWq+ROSh
# A2ugggyvMIIGEDCCBPigAwIBAgITMAAAACpnbAZ3NwLCSQAAAAAAKjANBgkqhkiG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU4fWv2MffrJ7J1PgKHG+BJczNwfUwDQYJKoZI
# hvcNAQEBBQAEggEAY8cBfTkv6/Qly6h7t7Xw+YtrcnzUFpQ0mTl/10eTaHw1OQFz
# scznr4A9xuv9p0u2bNAb3WtPGsoXJUoKDowIkeDNwu/Fbjjwkby8/IQ8Fp+0DbRB
# 2lRIQxzz+gz8Si9p4PA76OVg8tel656ey++eRvvmnxgSajZHe9PsOK2LhlZsYjTY
# HaPgWOd3ZRhaVX7RKR9vE/zTb9u/h88FPcxlksQXwrTHj8nX5r8qZL51fNpahwU8
# 8EzkqybVo2kflzuGwuht5D70qXaD7fJ21FL09om7rLyNH8DmaCqCDSZwXroakAI4
# jBnZYggFQoEcDkDvJDTO6fpWqrz/Q5lAvSAYnQ==
# SIG # End signature block
