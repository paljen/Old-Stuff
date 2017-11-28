
Function Get-EcServerInformation
{
    <#
    .SYNOPSIS
	    Get server information

    .DESCRIPTION
	    Get wmi based server information from servers

    .PARAMETER Computername
        The name of the computer
    
    .EXAMPLE
       Get-EccoServerInfo -ComputerName server1

       Get information from a single server

    .EXAMPLE
       Get-EcServerInformation -ComputerName $((Get-QADComputer -SearchRoot "prd.eccocorp.net/Servers").name) | ft -autosize

       Get information from array of servers

    .EXAMPLE
       Get-Content C:\servers.txt | Get-EcServerInformation | Out-EccoHTML

       Get information from a list of servers, show in html format

    .EXAMPLE
       (Get-QADComputer -SearchRoot "prd.eccocorp.net/Servers").name | Get-EcServerInformation | Out-EccoExcel

       Get information from array of servers and output to excel

    .INPUTS
	    String

    .OUTPUTS
	    PSCustom Object

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  24/09/15
        Module Script:  func.pje.server
	    Purpose/Change: Initial function development
    #>

	[CmdletBinding()]

	param(
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
		[String[]]
        $ComputerName
	)
	
	begin
    {
		try
        {
            $Error.Clear()
		}

		catch
        {
			$_.Exception.Message
		}
	}
	
	process
    {
		foreach ($Computer in $ComputerName) 
        {
			try
            {
				if(Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop)
				{
					$cs = gwmi -ComputerName $Computer -Class Win32_ComputerSystem -ErrorAction Stop
				}

				$props = [Ordered]@{
                         'Name'=$cs.PSComputerName;
						 'Model'=$cs.model;
						 'Manufacturer'=$cs.Manufacturer;}
				
				$os = gwmi -ComputerName $Computer -Class Win32_OperatingSystem -ErrorAction Stop

                if($os.ProductType -gt 1)
                {
                    Switch -Wildcard ($os.Version) {
                            5.2* { $ver="Windows Server 2003" }
                            5.2.3* { $ver="Windows Server 2003 R2" }
                            6.0* { $ver="Windows Server 2008" }
                            6.1* { $ver="Windows Server 2008 R2" }
                            6.2* { $ver="Windows Server 2012" }
                            6.3* { $ver="Windows Server 2012 R2" }
                    }
                }
            
                $props.Add('OSVersion',$ver)
				$props.Add('SPVersion',$os.ServicePackMajorVersion)
                $props.Add('TotalMemory',($os.TotalVisibleMemorySize/1MB -as [int32]))

                $cpu = gwmi -ComputerName $computer win32_processor -ErrorAction Stop
                $status = "OK"

                $props.Add('CPUCount',($cpu.deviceid | Measure).count)
                $props.Add('CPUName',($cpu.Name | select -First 1))
                $props.Add('NumberOfCores',($cpu.NumberOfCores | select -First 1))
                $props.Add('NumberOfLogicalProcessors', ($cpu.NumberOfLogicalProcessors | select -First 1))
                $props.Add('MaxClockSpeed',($cpu.MaxClockSpeed | select -First 1))
                $props.Add('Status',$status)

				$out = New-Object -TypeName PSObject -Property $props

				Write-Output $out
			}
			
			catch
            {
                $message = ($_.Exception.Message) -replace "'","`""
                
				$props = [Ordered]@{
                         'Name'=$Computer;
						 'Model'=$null;
						 'Manufacturer'=$null;
                         'OSVersion'=$null;
                         'SPVersion'=$null;
                         'TotalMemory'=$null;
                         'CPUCount'=$null;
                         'CPUName'=$null;
                         'NumberOfCores'=$null;
                         'NumberOfLogicalProcessors'=$null;
                         'MaxClockSpeed'=$null;
                         'Status'=$message}

                $out = New-Object -TypeName PSObject -Property $props

				Write-Output $out
			}
		}		
	}
}

Function Get-EcServerLastBootTime
{
    <#
    .SYNOPSIS
	    Get Last Boot Time for one or more servers

    .PARAMETER Computername
        The name of the computer
    
    .EXAMPLE
       Get-EcServerLastBootTime -ComputerName DKHQDC01

       Get last boot time for a single server

    .EXAMPLE
       Get-Content C:\servers.txt | Get-EcServerLastBootTime

       Get last boot time from a list of servers

    .INPUTS
	    String

    .OUTPUTS
	    PSCustom Object

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  24/09/15
        Module Script:  func.pje.server
	    Purpose/Change: Initial function development
    #>

    [CmdletBinding()]

    param
    (    
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [String[]]$Computername
    )

    process
    {
        foreach ($c in $computername)
        {
            $lastBoot = [management.managementDateTimeConverter]::ToDateTime((Get-WmiObject -ComputerName $c -Class Win32_OperatingSystem).LastBootUpTime)

            $hash=@{'Computername'=$c}
            $hash.Add('LastBootTime',$lastBoot)
            
            $obj = New-Object -TypeName PSObject -Property $hash

            Write-Output $obj
        }
    }
}

Function Get-EcServerDriveInformation
{
    <#
    .SYNOPSIS
	    Get disk information

    .DESCRIPTION
	    Get disk information for one or more computers

    .PARAMETER Computername
        The name of the computer
    
    .EXAMPLE
       Get-EcServerDriveInformation -ComputerName DKHQFILE01

       Get disk information from a single server

    .EXAMPLE
       Get-Content C:\servers.txt | Get-EcServerDriveInformation

       Get disk information from a list of servers

    .INPUTS
	    String

    .OUTPUTS
	    PSCustom Object

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  24/09/15
        Module Script:  func.pje.server
	    Purpose/Change: Initial function development
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [String[]]$Computername
    )

    process
    {
        foreach($c in $computername)
        {
            gwmi win32_volume -ComputerName $c | ForEach-Object {
                
                $hash = [Ordered]@{'Computername'=$c}
                $hash.add('Labels',$_.Name)
                $hash.add('FreeSpace GB',($_.FreeSpace / 1GB -as [int]))

                $obj = New-Object -TypeName PSObject -Property $hash
                Write-Output $obj
            }
            
        }
    }
    
}

# SIG # Begin signature block
# MIIPSAYJKoZIhvcNAQcCoIIPOTCCDzUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqXvSjBUu3yuX0pJ/LLPprSoY
# 46egggyvMIIGEDCCBPigAwIBAgITMAAAACpnbAZ3NwLCSQAAAAAAKjANBgkqhkiG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXUv2Ycm1ATOVEPotkgcm3L928JwwDQYJKoZI
# hvcNAQEBBQAEggEAaWYRiUvOAS/hCpTLYvlPsm0BALZLygvO0tcU0/9GaBvtnt4a
# sCKiIfGIA0a1RaVihGFe7N3iLmd7rNUw08yCyNHCyegJP+ZCCV+3DkGRqvSl76cM
# iwJDX640/zcOIMYdSYtFeeuF6/HERT//PSnBjc6725iaZVHg5jJlFDNRdP0M0g1j
# HmXShCS4GK5SMN+J6AyrTOM5Ab2neXhX2MkaKgoVPf/zMTCq0UNjm7+nOnJ1IzQG
# 3PmxVB2sV7YCxucZzm2oTiR4ANp3dUreLdVOutTNUlBGEZK8n9ZFGQkBSEBLm6F5
# v5TtiyaZrR8XABD6S6qi/ekuxGEXI7XIzETanQ==
# SIG # End signature block
