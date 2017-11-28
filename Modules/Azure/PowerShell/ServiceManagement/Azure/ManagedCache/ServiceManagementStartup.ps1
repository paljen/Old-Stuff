﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------

$script:aliases = @{
    # Profile aliases
    "Get-WAPackPublishSettingsFile" = "Get-AzurePublishSettingsFile";
    "Get-WAPackSubscription" = "Get-AzureSubscription";
    "Import-WAPackPublishSettingsFile" = "Import-AzurePublishSettingsFile";
    "Remove-WAPackSubscription" = "Remove-AzureSubscription";
    "Select-WAPackSubscription" = "Select-AzureSubscription";
    "Set-WAPackSubscription" = "Set-AzureSubscription";
    "Show-WAPackPortal" = "Show-AzurePortal";
    "Test-WAPackName" = "Test-AzureName";
    "Get-WAPackEnvironment" = "Get-AzureEnvironment";
    "Add-WAPackEnvironment" = "Add-AzureEnvironment";
    "Set-WAPackEnvironment" = "Set-AzureEnvironment";
    "Remove-WAPackEnvironment" = "Remove-AzureEnvironment";

    # Websites aliases
    "New-WAPackWebsite" = "New-AzureWebsite";
    "Get-WAPackWebsite" = "Get-AzureWebsite";
    "Set-WAPackWebsite" = "Set-AzureWebsite";
    "Remove-WAPackWebsite" = "Remove-AzureWebsite";
    "Start-WAPackWebsite" = "Start-AzureWebsite";
    "Stop-WAPackWebsite" = "Stop-AzureWebsite";
    "Restart-WAPackWebsite" = "Restart-AzureWebsite";
    "Show-WAPackWebsite" = "Show-AzureWebsite";
    "Get-WAPackWebsiteLog" = "Get-AzureWebsiteLog";
    "Save-WAPackWebsiteLog" = "Save-AzureWebsiteLog";
    "Get-WAPackWebsiteLocation" = "Get-AzureWebsiteLocation";
    "Get-WAPackWebsiteDeployment" = "Get-AzureWebsiteDeployment";
    "Restore-WAPackWebsiteDeployment" = "Restore-AzureWebsiteDeployment";
    "Enable-WAPackWebsiteApplicationDiagnositc" = "Enable-AzureWebsiteApplicationDiagnostic";
    "Disable-WAPackWebsiteApplicationDiagnostic" = "Disable-AzureWebsiteApplicationDiagnostic";

    # Service Bus aliases
    "Get-WAPackSBLocation" = "Get-AzureSBLocation";
    "Get-WAPackSBNamespace" = "Get-AzureSBNamespace";
    "New-WAPackSBNamespace" = "New-AzureSBNamespace";
    "Remove-WAPackSBNamespace" = "Remove-AzureSBNamespace";

    # Storage aliases
    "Get-AzureStorageContainerAcl" = "Get-AzureStorageContainer";
    "Start-CopyAzureStorageBlob" = "Start-AzureStorageBlobCopy";
    "Stop-CopyAzureStorageBlob" = "Stop-AzureStorageBlobCopy";

    # Compute aliases
    "New-AzureDns" = "New-AzureDnsConfig";
    
    # HDInsight aliases
    "Invoke-Hive" = "Invoke-AzureHDInsightHiveJob";
    "hive" = "Invoke-AzureHDInsightHiveJob";

    #StorSimple aliases
    "Get-SSAccessControlRecord" = "Get-AzureStorSimpleAccessControlRecord" ;
    "Get-SSDevice"= "Get-AzureStorSimpleDevice" ;
    "Get-SSDeviceBackup" = "Get-AzureStorSimpleDeviceBackup" ;
    "Get-SSDeviceBackupPolicy" = "Get-AzureStorSimpleDeviceBackupPolicy" ;
    "Get-SSDeviceConnectedInitiator" = "Get-AzureStorSimpleDeviceConnectedInitiator" ;
    "Get-SSDeviceVolume" = "Get-AzureStorSimpleDeviceVolume" ;
    "Get-SSDeviceVolumeContainer" = "Get-AzureStorSimpleDeviceVolumeContainer" ;
    "Get-SSFailoverVolumeContainers" = "Get-AzureStorSimpleFailoverVolumeContainers" ;
    "Get-SSJob" = "Get-AzureStorSimpleJob" ;
    "Get-SSResource" = "Get-AzureStorSimpleResource" ;
    "Get-SSResourceContext" = "Get-AzureStorSimpleResourceContext" ;
    "Get-SSStorageAccountCredential" = "Get-AzureStorSimpleStorageAccountCredential" ;
    "Get-SSTask" = "Get-AzureStorSimpleTask" ;
    "New-SSAccessControlRecord" = "New-AzureStorSimpleAccessControlRecord" ;
    "New-SSDeviceBackupPolicy" = "New-AzureStorSimpleDeviceBackupPolicy" ;
    "New-SSDeviceBackupScheduleAddConfig" = "New-AzureStorSimpleDeviceBackupScheduleAddConfig" ;
    "New-SSDeviceBackupScheduleUpdateConfig" = "New-AzureStorSimpleDeviceBackupScheduleUpdateConfig" ;
    "New-SSDeviceVolume" = "New-AzureStorSimpleDeviceVolume";
    "New-SSDeviceVolumeContainer" = "New-AzureStorSimpleDeviceVolumeContainer" ;
    "New-SSInlineStorageAccountCredential" = "New-AzureStorSimpleInlineStorageAccountCredential" ;
    "New-SSNetworkConfig" = "New-AzureStorSimpleNetworkConfig";
    "New-SSStorageAccountCredential" = "New-AzureStorSimpleStorageAccountCredential";
    "New-SSVirtualDevice" = "New-AzureStorSimpleVirtualDevice";
    "Remove-SSAccessControlRecord" = "Remove-AzureStorSimpleAccessControlRecord";
    "Remove-SSDeviceBackup" = "Remove-AzureStorSimpleDeviceBackup";
    "Remove-SSDeviceBackupPolicy" = "Remove-AzureStorSimpleDeviceBackupPolicy";
    "Remove-SSDeviceVolume" = "Remove-AzureStorSimpleDeviceVolume";
    "Remove-SSDeviceVolumeContainer" = "Remove-AzureStorSimpleDeviceVolumeContainer";
    "Remove-SSStorageAccountCredential" = "Remove-AzureStorSimpleStorageAccountCredential";
    "Select-SSResource" = "Select-AzureStorSimpleResource";
    "Set-SSAccessControlRecord" = "Set-AzureStorSimpleAccessControlRecord";
    "Set-SSDevice" = "Set-AzureStorSimpleDevice";
    "Set-SSDeviceBackupPolicy" = "Set-AzureStorSimpleDeviceBackupPolicy";
    "Set-SSDeviceVolume" = "Set-AzureStorSimpleDeviceVolume";
    "Set-SSStorageAccountCredential" = "Set-AzureStorSimpleStorageAccountCredential";
    "Set-SSVirtualDevice" = "Set-AzureStorSimpleVirtualDevice";
    "Start-SSBackupCloneJob" = "Start-AzureStorSimpleBackupCloneJob";
    "Start-SSDeviceBackupJob" = "Start-AzureStorSimpleDeviceBackupJob";
    "Start-SSDeviceBackupRestoreJob" = "Start-AzureStorSimpleDeviceBackupRestoreJob";
    "Start-SSDeviceFailoverJob" = "Start-AzureStorSimpleDeviceFailoverJob";
    "Stop-SSJob" = "Stop-AzureStorSimpleJob";	
    "Confirm-SSLegacyVolumeContainerStatus" = "Confirm-AzureStorSimpleLegacyVolumeContainerStatus";
    "Get-SSLegacyVolumeContainerConfirmStatus" = "Get-AzureStorSimpleLegacyVolumeContainerConfirmStatus";
    "Get-SSLegacyVolumeContainerMigrationPlan" = "Get-AzureStorSimpleLegacyVolumeContainerMigrationPlan";
    "Get-SSLegacyVolumeContainerStatus" = "Get-AzureStorSimpleLegacyVolumeContainerStatus";
    "Import-SSLegacyApplianceConfig" = "Import-AzureStorSimpleLegacyApplianceConfig";
    "Import-SSLegacyVolumeContainer" = "Import-AzureStorSimpleLegacyVolumeContainer";
    "Start-SSLegacyVolumeContainerMigrationPlan" = "Start-AzureStorSimpleLegacyVolumeContainerMigrationPlan";
}

$aliases.GetEnumerator() | Select @{Name='Name'; Expression={$_.Key}}, @{Name='Value'; Expression={$_.Value}} | New-Alias -Description "AzureAlias"

# SIG # Begin signature block
# MIIavwYJKoZIhvcNAQcCoIIasDCCGqwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWApNhG08LikSKjLxacNoZzM+
# GY6gghWCMIIEwzCCA6ugAwIBAgITMwAAAIgVUlHPFzd7VQAAAAAAiDANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTUxMDA3MTgxNDAx
# WhcNMTcwMTA3MTgxNDAxWjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OjdBRkEtRTQxQy1FMTQyMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyBEjpkOcrwAm
# 9WRMNBv90OUqsqL7/17OvrhGMWgwAsx3sZD0cMoNxrlfHwNfCNopwH0z7EI3s5gQ
# Z4Pkrdl9GjQ9/FZ5uzV24xfhdq/u5T2zrCXC7rob9FfhBtyTI84B67SDynCN0G0W
# hJaBW2AFx0Dn2XhgYzpvvzk4NKZl1NYi0mHlHSjWfaqbeaKmVzp9JSfmeaW9lC6s
# IgqKo0FFZb49DYUVdfbJI9ECTyFEtUaLWGchkBwj9oz62u9Kg6sh3+UslWTY4XW+
# 7bBsN3zC430p0X7qLMwQf+0oX7liUDuszCp828HsDb4pu/RRyv+KOehVKx91UNcr
# Dc9Z7isNeQIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFJQRxg5HoMTIdSZj1v3l1GjM
# 6KEMMB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAHoudDDxFsg2z0Y+GhQ91SQW1rdmWBxJOI5OpoPzI7P7X2dU
# ouvkmQnysdipDYER0xxkCf5VAz+dDnSkUQeTn4woryjzXBe3g30lWh8IGMmGPWhq
# L1+dpjkxKbIk9spZRdVH0qGXbi8tqemmEYJUW07wn76C+wCZlbJnZF7W2+5g9MZs
# RT4MAxpQRw+8s1cflfmLC5a+upyNO3zBEY2gaBs1til9O7UaUD4OWE4zPuz79AJH
# 9cGBQo8GnD2uNFYqLZRx3T2X+AVt/sgIHoUSK06fqVMXn1RFSZT3jRL2w/tD5uef
# 4ta/wRmAStRMbrMWYnXAeCJTIbWuE2lboA3IEHIwggTsMIID1KADAgECAhMzAAAB
# Cix5rtd5e6asAAEAAAEKMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTE1MDYwNDE3NDI0NVoXDTE2MDkwNDE3NDI0NVowgYMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJL8bza74QO5KNZG0aJhuqVG+2MWPi75R9LH7O3HmbEm
# UXW92swPBhQRpGwZnsBfTVSJ5E1Q2I3NoWGldxOaHKftDXT3p1Z56Cj3U9KxemPg
# 9ZSXt+zZR/hsPfMliLO8CsUEp458hUh2HGFGqhnEemKLwcI1qvtYb8VjC5NJMIEb
# e99/fE+0R21feByvtveWE1LvudFNOeVz3khOPBSqlw05zItR4VzRO/COZ+owYKlN
# Wp1DvdsjusAP10sQnZxN8FGihKrknKc91qPvChhIqPqxTqWYDku/8BTzAMiwSNZb
# /jjXiREtBbpDAk8iAJYlrX01boRoqyAYOCj+HKIQsaUCAwEAAaOCAWAwggFcMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBSJ/gox6ibN5m3HkZG5lIyiGGE3
# NDBRBgNVHREESjBIpEYwRDENMAsGA1UECxMETU9QUjEzMDEGA1UEBRMqMzE1OTUr
# MDQwNzkzNTAtMTZmYS00YzYwLWI2YmYtOWQyYjFjZDA1OTg0MB8GA1UdIwQYMBaA
# FMsR6MrStBZYAck3LjMWFrlMmgofMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8w
# OC0zMS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMx
# LTIwMTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCmqFOR3zsB/mFdBlrrZvAM2PfZ
# hNMAUQ4Q0aTRFyjnjDM4K9hDxgOLdeszkvSp4mf9AtulHU5DRV0bSePgTxbwfo/w
# iBHKgq2k+6apX/WXYMh7xL98m2ntH4LB8c2OeEti9dcNHNdTEtaWUu81vRmOoECT
# oQqlLRacwkZ0COvb9NilSTZUEhFVA7N7FvtH/vto/MBFXOI/Enkzou+Cxd5AGQfu
# FcUKm1kFQanQl56BngNb/ErjGi4FrFBHL4z6edgeIPgF+ylrGBT6cgS3C6eaZOwR
# XU9FSY0pGi370LYJU180lOAWxLnqczXoV+/h6xbDGMcGszvPYYTitkSJlKOGMIIF
# vDCCA6SgAwIBAgIKYTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZIm
# iZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQD
# EyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
# MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBC
# mXZTbD4b1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1VwqJyq4gSfTw
# aKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNEf9eB2/O98jakyVxF3K+tPeAoaJcap6Vy
# c1bxF5Tk/TWUcqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2L1TdFDBZ
# +NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049oDI9kM2hOAaFXE5WgigqBTK3S9dP
# Y+fSLWLxRT3nrAgA9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzBrAlf
# A9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMsR6MrS
# tBZYAck3LjMWFrlMmgofMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+mPLzYLTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnk
# pDBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+
# fyZGr+tvQLEytWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAhXaw9L0y6
# oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6WcIC36C1DEVs0t40rSvHDnqA2iA6VW
# 4LiKS1fylUKc8fPv7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WRTsgb
# 0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZEolHN+emjWFbdmwJFRC9f9Nqu
# 1IIybvyklRPk62nnqaIsvsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
# NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxPbQ4TTj18KUicctHzbMrB
# 7HCjV5JXfZSNoBtIA1r3z6NnCnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDord
# EN5k9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7B2BHZWBATrBC7E7t
# s3Z52Ao0CW0cgDEf4g5U3eWh++VHEK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jsh
# rg1cnPCiroZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONxPdcAfmJH0c6I
# ybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3UAjWwz0wggYHMIID76ADAgECAgphFmg0
# AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAX
# BgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMx
# MzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
# BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn
# 0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0
# Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4n
# rIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YR
# JylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54
# QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsG
# A1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJg
# QFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcG
# CgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
# Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJ
# MEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYB
# BQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# BQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1i
# uFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+r
# kuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGct
# xVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/F
# NSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbo
# nXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
# NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPp
# K+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2J
# oXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0
# eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng
# 9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj/TGCBKcwggSj
# AgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBAhMzAAABCix5rtd5e6as
# AAEAAAEKMAkGBSsOAwIaBQCggcAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFBi2
# f4UcEV6s6L7FTnNX62zS06FGMGAGCisGAQQBgjcCAQwxUjBQoDaANABNAGkAYwBy
# AG8AcwBvAGYAdAAgAEEAegB1AHIAZQAgAFAAbwB3AGUAcgBTAGgAZQBsAGyhFoAU
# aHR0cDovL0NvZGVTaWduSW5mbyAwDQYJKoZIhvcNAQEBBQAEggEAJNRnUpyWoad4
# sBKHDqzUW2DF2uDPzZdBItDB6hwZAYoZQcaFb63B80jKa63OetVXsSWrE0ihXdLn
# CmjkNKofmARxCP/LwLhRXs7enO97Sx5fOAEDfNKSXzYpu1tybQLPhXexLvpOcwRd
# MlYT3nbg5EYZTZzWSc2Me4uMLJvOaZGaOxVI5DAtAXQAEB+fHNjs6qJSr/cJoyaE
# uXwXG2fGYGL4AdDZRQTjK/oQ5P4mYwIZ5PuK/pqGiMWoro92/PXlrDcxoJin3i4e
# CFRKBluxRRRb+btKer61B5lUAs7sW8xf45nLVVVg8vKODQm7GYJmob947rIDYzjj
# I1W/svH906GCAigwggIkBgkqhkiG9w0BCQYxggIVMIICEQIBATCBjjB3MQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBQQ0ECEzMAAACIFVJRzxc3e1UAAAAAAIgwCQYFKw4DAhoF
# AKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTEwNzAxMjUyNFowIwYJKoZIhvcNAQkEMRYEFC0xstyCyDm97THqElpKx584+0rK
# MA0GCSqGSIb3DQEBBQUABIIBAHuYAjOW+aY3eGbyRhQ0Tu3HQ8A+bbxcSEgUS7kA
# i+aNO/xg5D05DBKTGydVc5fa47tKag7PtfFxPv1bN1CV8DbX56j+i1IYt8XyILWt
# yK3N6jvfDUAxIZXdIwCJg6OQxAeDt66APauur4LmPA0zjGiO4Ik77n29sUluYnNZ
# WoYHJv5NY581Y/TzAGieHeGrMdJpYvGFUADbxar/OMWhWKnsHsKFUNxPVoXvhS+6
# kZ4SD4kdTPO5pe+g47a952H+zpOH4BWO1larLDm7A6WocI6aoxexpgQOCjNmHftg
# wZ1k2Wp7HQTLTWIDI/0IEjnXYgXEdDv/pQUghAuiGmf4uRs=
# SIG # End signature block
