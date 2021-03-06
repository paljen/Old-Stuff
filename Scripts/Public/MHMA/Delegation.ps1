#	Title: ECCO Delegation Model
#	Author: Michael Hjort Madsen / MHMA@ECCO.COM / 17-Oct 2013 / EDITED 25-Sep 2015 / EDITED 02-Nov 2015
#	Purpose: Adding the groups who need to have local admin access, together with the locally delegated IT Coordinators

$ErrorActionPreference = "SilentlyContinue"
[STRING]$Client = $Env:COMPUTERNAME
[ARRAY]$Regions = "OU=SA,OU=AE","OU=SA,OU=AT","OU=SA,OU=AU","OU=SA,OU=BE","OU=SA,OU=CA","OU=SA,OU=CH","OU=FAC,OU=CN","OU=SA,OU=CN","OU=TAN,OU=CN","OU=TEC,OU=CN","OU=SA,OU=CY","OU=SA,OU=CZ","OU=SA,OU=DE","OU=SA,OU=ES","OU=SA,OU=FI","OU=SA,OU=FR","OU=SA,OU=GR","OU=SA,OU=HK","OU=FAC,OU=ID","OU=TAN,OU=ID","OU=TEC,OU=IN","OU=SA,OU=IT","OU=SA,OU=JP","OU=SA,OU=KR","OU=SA,OU=LV","OU=INNO,OU=NL","OU=SA,OU=NL","OU=TAN,OU=NL","OU=SA,OU=NO","OU=SA,OU=PL","OU=FAC,OU=PT","OU=SA,OU=RO","OU=SA,OU=SE","OU=GP,OU=SG","OU=SA,OU=SG","OU=FAC,OU=SK","OU=FAC,OU=TH","OU=FAC2,OU=TH","OU=TAN,OU=TH","OU=SA,OU=TW","OU=SA,OU=UK","OU=SA,OU=US","OU=FAC,OU=VN"

#Create Eventlog source
$Eventlog = [System.Diagnostics.EventLog]::SourceExists("Delegation") -eq $false

if ($Eventlog -eq "True")
{
	New-EventLog –LogName Application –Source “Delegation”
}

#Get Computer object from AD
$rootDSE = [System.DirectoryServices.DirectoryEntry]("LDAP://RootDSE")
[String]$RootPath = "LDAP://{0}" -f $rootDSE.defaultNamingContext.ToString()
$root = [System.DirectoryServices.DirectoryEntry]$RootPath
if ($root -ne  $null)
{
	$search = [System.DirectoryServices.DirectorySearcher] $root
	
	#Search for group
	$search.Filter = "(&(objectClass=computer)(Name=$Client))"
	
	$ComputerADObject = $search.FindOne()
}

#Find Delegated Admin Group
foreach ($Region in $Regions)
	{
		#Split content of $Region, strip of unnecessary data then rejoin
		$Split1 = $Region.split("=")
		$Split2 = $Split1[1].ToString()
		$Split3 = $Split2.Split(",")
		$Join1 = $Split1[2].ToString()
		$Join2 = $Split3[0].ToString()
		
		$Join = $Join1 + $Join2
		
		#Add delegated admin group
		if ($ComputerADObject.Path -like "*" + $Region + "*")
		{
			$DelegatedGroupName = "Admin-" + $Join + " IT Coordinators"
			break
		}
		else
		{
			$DelegatedGroupName = $null
		}
	}
	
#Computer type definition
$Production = $null
$Elevated = $null
$Generic = $null
$Type = $null

if ($ComputerADObject.Path -like "*Elevated*")
{
	$Elevated = $true
	$Type = "Elevated"
}
else
{$Elevated = $false}

if ($ComputerADObject.Path -like "*Generic*")
{
	$Generic = $true
	$Type = "Generic"
}
else
{$Generic = $false}

if ($ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=PT*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=CN*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=ID*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=SK*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=TH*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=HQ,OU=DK*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=VN*")
{
	$Production = $true
	$Type += " Production"
}
else
{$Production = $false}

if ($Elevated -eq $false -and $Generic -eq $false -and $Production -eq $false)
{$Type = "System"}

#Assign Local Groups to Objects
$GroupLocalAdmin = [ADSI]("WinNT://" + $Client + "/Administrators")
$GroupRemoteUsers = [ADSI]("WinNT://" + $Client + "/Remote Desktop Users")

#Define groups that will be added to local Administrators or Remote Desktop Users
[System.Collections.ArrayList]$DefaultGroupAdmins = "$Client/Administrator","PRD/Admin-DKHQ HELPDESK","PRD/Admin-DKHQ IT Specialists","PRD/Admin-DKHQ SAPBasis","PRD/Admin-Global IT Coordinators","PRD/Admin-Global IT Specialists","PRD/Domain Admins","PRD/Service-SMSClient","$Client/WKSAdmin"
[System.Collections.ArrayList]$DefaultGroupRDU = "PRD/Domain Users","PRD/Admin-Global IT Specialists","PRD/Admin-Global IT Coordinators","Admin-DKHQ IT Specialists","PRD/Admin-DKHQ HELPDESK"

#Set all group memberships
function SetAdmins
{
	if ($Elevated -eq $true)
	{$DefaultGroupAdmins.Add("NT AUTHORITY/INTERACTIVE")}
	if ($Production -eq $true)
	{$DefaultGroupAdmins.Add("PRD/Service-Acronis")}
	if ($DelegatedGroupName -ne $null)
	{$DefaultGroupAdmins.Add("PRD/$DelegatedGroupName")}

	#Remove current Admin Users and Add ECCO Defined Standard
	if ($Type -ne $false)
	{
        $members = @($GroupLocalAdmin.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
        foreach ($m in $members)
        {
            $GroupLocalAdmin.remove("WinNT://$m")
        }
         
		#Add Default Groups to Local Admins
		foreach ($group in $DefaultGroupAdmins)
		{
			$ToBeAdded = [ADSI]("WinNT://" + $group)
			$GroupLocalAdmin.PSBase.Invoke("Add",$ToBeAdded.PSBase.Path)
		}
		
		Write-EventLog –LogName Application –Source “Delegation” –EntryType Information –EventID 1 –Message “$Type Computer Detected - Administrators Group has been populated.”
	}

	#Remove current Remote Desktop Users and Add ECCO Defined Standard
	
	if ($Type -ne $false)
	{
		#Remove current Remote Desktop Users
        $members = @($GroupRemoteUsers.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
		foreach ($m in $members)
        {
            $GroupRemoteUsers.remove("WinNT://$m")
        }
		
		#Add Default Groups to Remote Desktop Users
		foreach ($RDUgroup in $DefaultGroupRDU)
		{
			$ToBeAdded = [ADSI]("WinNT://" + $RDUgroup)
			$GroupRemoteUsers.PSBase.Invoke("Add",$ToBeAdded.PSBase.Path)
		}
		
		Write-EventLog –LogName Application –Source “Delegation” –EntryType Information –EventID 1 –Message “$Type Computer Detected - Remote Desktop Users Group has been populated.”
	}
}

SetAdmins

# SIG # Begin signature block
# MIIPwAYJKoZIhvcNAQcCoIIPsTCCD60CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsbAbXZqsgAzM42U8NwvlItAC
# PhSggg0wMIIGiDCCBXCgAwIBAgIKGjzKqwAAAAAABjANBgkqhkiG9w0BAQUFADBG
# MRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYIZWNjb2NvcnAx
# FTATBgNVBAMTDEVDQ08gUm9vdCBDQTAeFw0wODA0MTcxMDUyNTBaFw0xNjA0MTUx
# MDUyNTBaMEsxEzARBgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJk/IsZAEZFghl
# Y2NvY29ycDEaMBgGA1UEAxMRRUNDTyBJc3N1aW5nIENBIDEwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQDWXibIDP9rOAxFYpc/OY7PO/mqnEtErsjBDqFp
# LaGEipO+2KGWJCR7rzdSmI2lSmgQkimCuCNp6un9apWLfRJNyZf6H/kGy52diqnf
# f4Wne4fNmDX4pLdXoT1wRm+62v3aK1fsCubyJcQQzFrMGq86reYOEyWgRmQd5b82
# HZpikTSV06YVB6F8YTh2FzWBgf3L9N0WiIMpgggS0/4dZxiRnq2yoB/mpQ7jfGe7
# jWmEe+0BDBpvXi0rFxfJZw2lGv+jZ8T20Zf3WlVLxbEI3+M3nXzAJ02nsuQzry+L
# jCXBRvOtdOZr+bMLTWcX9PUZ0HljIabarphjyXWwr6VgSkGRAgMBAAGjggNxMIID
# bTAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBS0T6AMqeQjfx6aAkvHwRH61SSQ
# 9jAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQAwgaAGA1UdIASBmDCB
# lTCBigYLKwYBBIHjO4N9AwEwezBUBggrBgEFBQcCAjBIHkYARQBDAEMATwAgAEMA
# ZQByAHQAaQBmAGkAYwBhAHQAZQAgAFAAcgBhAGMAdABpAGMAZQAgAFMAdABhAHQA
# ZQBtAGUAbgB0MCMGCCsGAQUFBwIBFhdodHRwOi8vcGtpLmVjY28uY29tL3BraTAG
# BgRVHSAAMDsGCSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCPu9RofHhWCJjyGHnMxp
# ge+ZNnqG3O00gqyKYAIBZAIBAzAfBgNVHSMEGDAWgBQ7KkBMT7g2WRcc+DDBVJS5
# UPWQGzCB/gYDVR0fBIH2MIHzMIHwoIHtoIHqhixodHRwOi8vcGtpLmVjY28uY29t
# L3BraS9FQ0NPJTIwUm9vdCUyMENBLmNybIaBuWxkYXA6Ly8vQ049RUNDTyUyMFJv
# b3QlMjBDQSxDTj1ES0hRQ0EwMSxDTj1DRFAsQ049UHVibGljJTIwS2V5JTIwU2Vy
# dmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29ycCxE
# Qz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNz
# PWNSTERpc3RyaWJ1dGlvblBvaW50MIIBFQYIKwYBBQUHAQEEggEHMIIBAzBOBggr
# BgEFBQcwAoZCaHR0cDovL3BraS5lY2NvLmNvbS9wa2kvREtIUUNBMDEuZWNjb2Nv
# cnAubmV0X0VDQ08lMjBSb290JTIwQ0EuY3J0MIGwBggrBgEFBQcwAoaBo2xkYXA6
# Ly8vQ049RUNDTyUyMFJvb3QlMjBDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29y
# cCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwDQYJKoZIhvcNAQEFBQADggEBACOQzVNMq83hImWDSWGM
# 4ysbGJEujR1U3z9ZL80xHOTYVBqG3mSgC6IHt/uwQIyT0hiILbjMxw8UdeQ2+k7N
# ytVOAhDc6bW4in/7J70rjUneXpaQGoqI+nSqYTWQS8P8sQ6SPLosDP5c5D8PECfl
# aovpaZUrA4gb9X2YXSlTswq28feLW0Btjp4biwnRLn7M9zYsgboPFoHJheLP+wfB
# bxJgckvEK4Aiv585VkYQcMaxRnXj2jnml1SppsWqZ3bZ6+pAP8tztv5PzYYmLlb4
# bOIvMvSdBGNfY3arVdInWeg9OiVMDY8znljjdp++bhVkGuXtyRss0V4zaOCLKLUV
# se0wggagMIIFiKADAgECAgooREfXAAAADuXzMA0GCSqGSIb3DQEBBQUAMEsxEzAR
# BgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJk/IsZAEZFghlY2NvY29ycDEaMBgG
# A1UEAxMRRUNDTyBJc3N1aW5nIENBIDEwHhcNMTQwMTE2MDY0ODQwWhcNMTYwMTE2
# MDY0ODQwWjCBoDETMBEGCgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT8ixkARkW
# CGVjY29jb3JwMRMwEQYKCZImiZPyLGQBGRYDcHJkMQ0wCwYDVQQLEwRFQ0NPMQsw
# CQYDVQQLEwJESzELMAkGA1UECxMCSFExCzAJBgNVBAsTAklUMSQwIgYDVQQDExtN
# aWNoYWVsIEhqb3J0IE1hZHNlbiAoTUhNQSkwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQCpkq1KiwJhM+EXOiybDBhxFikoannxNW0e+dQ6qEX3wPDpAaaa
# 27tIS455RDxi2oOI7GcrX/jKaZK8tbWVzg5HV12wuJkMIM3RlmzaQQum6VjX8zVY
# 8vZ6CMRRmkcYC3aCKKsxQHvppv/aNSUU3/2ZgVZyDhaaGk1n1VlLziLDgupht3OJ
# 2J0FzXVzw/1blw26LZa6J3ZqQDkbU5ZxE6x8YRTLgUdO5cA1dzDf5sMkh67UsRq8
# KSgw57RRGKP67xLiqoMivUawYo+elre9k7aCjBhkRFdmpGKxTdjSIcpkNIXB64No
# 03tfajh7OOvYiFD3ubWzbcgYd38UNG3qDP9xAgMBAAGjggMuMIIDKjA7BgkrBgEE
# AYI3FQcELjAsBiQrBgEEAYI3FQj7vUaHx4VgiY8hh5zMaYHvmTZ6hsunG4Tk1hcC
# AWQCAQMwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgeAMBsGCSsG
# AQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFLT2a2hR0vzCwTOlXFIP
# a20l4O50MB8GA1UdIwQYMBaAFLRPoAyp5CN/HpoCS8fBEfrVJJD2MIIBDgYDVR0f
# BIIBBTCCAQEwgf6ggfuggfiGM2h0dHA6Ly9wa2kuZWNjby5jb20vcGtpL0VDQ08l
# MjBJc3N1aW5nJTIwQ0ElMjAxLmNybIaBwGxkYXA6Ly8vQ049RUNDTyUyMElzc3Vp
# bmclMjBDQSUyMDEsQ049REtIUUNBMDIsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUy
# MFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9ZWNjb2Nv
# cnAsREM9bmV0P2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RD
# bGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCCASMGCCsGAQUFBwEBBIIBFTCCAREw
# VQYIKwYBBQUHMAKGSWh0dHA6Ly9wa2kuZWNjby5jb20vcGtpL0RLSFFDQTAyLmVj
# Y29jb3JwLm5ldF9FQ0NPJTIwSXNzdWluZyUyMENBJTIwMS5jcnQwgbcGCCsGAQUF
# BzAChoGqbGRhcDovLy9DTj1FQ0NPJTIwSXNzdWluZyUyMENBJTIwMSxDTj1BSUEs
# Q049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmln
# dXJhdGlvbixEQz1lY2NvY29ycCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29i
# amVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwMAYDVR0RBCkwJ6AlBgor
# BgEEAYI3FAIDoBcMFU1ITUFAUFJELkVDQ09DT1JQLk5FVDANBgkqhkiG9w0BAQUF
# AAOCAQEAdf1ycA0bmjzPh0h7IVW43bNVXKZ3NXpsTgwafhjgw/912IfGEr0Js5yW
# qUBl2TRBXt0jdU65E7XUqcdpx6qqiC5BcZ7E2iaiwb7XhlYLChE7d7np++K47Hot
# KCsPbtmlC6uS4P6tQxEaTga9FDfeMn3VFnfc8F5DcYZb0UYRK5mrCUFwJxr0c5BS
# gZZ6AUVBuw0n5tpQeYR10+1rLwEN62a5X6TUo4osPX4Gt4qhls0fiLOZsyJEbwVC
# MlrNq075XlGfS2MgAtLGZwfH08Zt9JAV+g2S3RxgfwGzODA8hxtK4k2eZMJrtzUW
# HUzVkceqOqgiT3hqx6sBgB5/vofJITGCAfowggH2AgEBMFkwSzETMBEGCgmSJomT
# 8ixkARkWA25ldDEYMBYGCgmSJomT8ixkARkWCGVjY29jb3JwMRowGAYDVQQDExFF
# Q0NPIElzc3VpbmcgQ0EgMQIKKERH1wAAAA7l8zAJBgUrDgMCGgUAoHgwGAYKKwYB
# BAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU8ZoL
# P41+bCiuwvKf9LtJJTQLqoMwDQYJKoZIhvcNAQEBBQAEggEAnp+NtfXx5CRJd+gP
# W9TxXTEMZijCIQDWM1bTsxvCn+/NKFatnPxwnLHib4vw4Ri5deHEiuU+XGcGSOwI
# 1ospuGxo2kM8eyrXv8Bnvy6iqsM+eqOm1jLSKkQRTVGzY2atScAE/WD2us2/mkbj
# RHGLhcs8XqFZMDF5D/cvApAaRn4cWrqYXQhkf86CWbn0D2CZYpYT/mlUxDnvEm7p
# 2FjjQ1wj95Afos95xek5He1jtnV/9b23/9eh81utDagnbMAKF6FNvbcq9iz3w+b3
# vq1P9ZHWiSkHe5WXLfHoUVe+GR9azqoOcP6d9Nb1CMOJcTrrkGFriwKAgM9iRzbk
# xCZmsg==
# SIG # End signature block
