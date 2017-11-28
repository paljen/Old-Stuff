#############################################################################################################
# Name: 	Run.ps1																						   	#
# Author: 	edgemo a/s																						#
# Version:	1.0																								#
# Change History:																							#
#############################################################################################################
# Date:			Author:						Change:														   	#
#############################################################################################################
# 25022013 		Kristian F. Thomsen			1.0 Initial version											   	#
#############################################################################################################
$ErrorActionPreference = "SilentlyContinue"
$Error.Clear()

function Get-JobNode
{
	param($JobName)
	
	return $XmlDoc.SelectSingleNode("//Instruction//Execution//Jobs//Job[@Name='" + $JobName + "']")
}

function Execute-Job
{
	param($JobName)

	StartExecution $(Get-JobNode $JobName)
	
}

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
  	Split-Path $Invocation.MyCommand.Path
}

function Get-MediaDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
 	Return "$(Split-path (Split-Path $Invocation.MyCommand.Path) -Parent)\Media"
}

function Get-ResourcesDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
 	Return "$(Split-path (Split-Path $Invocation.MyCommand.Path) -Parent)\Resources"
}

function Get-AssembiliesDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
 	Return "$(Split-path (Split-Path $Invocation.MyCommand.Path) -Parent)\Assemblies"
}


function GetGlobalProperties
{
	$XmlDoc.SelectNodes("/Instruction/Globals/Property") | ForEach-Object {
		
		New-Variable -Name $_.Name -Value $_.Value -Scope "Global"
		Write-LogFile "Add Global Property: $($_.Name) = $($_.Value)"
	}
}

function ExpandParameterString
{
	param([String]$Parameter)
	
	if ($PSVersionTable.PSVersion.Major -lt 3)
	{
		$Parameter = $Parameter -replace '"','`"'
	}
	
	$Output = $ExecutionContext.InvokeCommand.ExpandString($Parameter)
	$Output = [environment]::ExpandEnvironmentVariables($Output)
	
	return "'$Output'" 
}

function Write-LogFile
{
	param([string]$Message)

	$LogFile =  [Environment]::ExpandEnvironmentVariables('%TMP%') + "\eSPTScript.log"
	

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($LogFile, $true)
	
	$Output = "$([DateTime]::Now): $Message"
	
	Write-Host $Output
	
	$Log.WriteLine($Output)
	$Log.Close()
	
}

function Get-ConditionFunction
{
	param($XmlElement)
	
	$FncElement = $XmlElement.SelectNodes("Condition")
	
	return $FncElement
}

function Execute-ConditionFunction
{
	param($ConditionNode)
	
	Write-LogFile "		Condition Function Name: $($ConditionNode.Name)"
	Write-LogFile "		Condition Function Value: $($ConditionNode.Value)"
	Write-LogFile "		Condition Operator: $($ConditionNode.Operator)"

	# Execute function
	$FunctionName = $ConditionNode.Name
	$Parameters = $null
	
	$ConditionNode.SelectNodes("Parameter") | ForEach-Object {
		
		$Param = ExpandParameterString $_.Value
		
		if ($Parameters -eq $null)
		{
			$Parameters = $Param
		}
		else
		{
			$Parameters = $Parameters + " $Param" 
		}
	}
	
	Write-LogFile "		Executing Condition Function: $FunctionName"
	Write-LogFile "		Parameters: $Parameters"
	Write-LogFile "		Invoke expression: $FunctionName $Parameters"
	
	$Output = Invoke-Expression "$FunctionName $Parameters"
	
	$Returnval = $true
	
	$ConditionVal = $ConditionNode.Value
	$Output = $Output.toString()
	
	Write-Logfile "		Returned from expression: $Output"

	switch ($ConditionNode.Operator.ToUpper())
	{
		"EQUALS"
		{
			if ($Output -ne $ConditionVal)
			{
				$Returnval = $false
				break
			}
		}
		
		"NOT EQUAL TO"
		{
			if ($Output -eq $ConditionVal)
			{
				$Returnval = $false
				break
			}
		}
		
		"IS LESS THAN"
		{
			if ($Output -gt $ConditionVal)
			{
				$Returnval = $false
				break
			}
		}
		
		"IS MORE THAN"
		{
			if ($Output -ilt $ConditionVal)
			{
				$Returnval = $false
				break
			}
		}
		
		"CONTAINS"
		{
			if ($Output -notmatch $ConditionVal)
			{
				$Returnval = $false
				break
			}
		}
		
		"DOES NOT CONTAIN"
		{
			if ($Output -match $ConditionVal)
			{
				$Returnval = $false
				break
			}
		}
		
	}

	return $Returnval

}

function Execute-Function
{
	param($FunctionNode)
	
	$FunctionName = $FunctionNode.Name
	$Parameters = $null
	
	$FunctionNode.SelectNodes("Parameter") | ForEach-Object {
		
		$Param = ExpandParameterString $_.Value
		
		if ($Parameters -eq $null)
		{
			$Parameters = $Param
		}
		else
		{
			$Parameters = $Parameters + " $Param" 
		}
	}
	
	Write-LogFile "Executing Function: $FunctionName"
	Write-LogFile "Parameters: $Parameters"
	Write-LogFile "Invoke expression: $FunctionName $Parameters"
	
	return Invoke-Expression "$FunctionName $Parameters"
}

function StartExecution
{
	param($ParentXmlNode)
	
	$GlobalContinueOnError = $false
	
	if ($ParentXmlNode.LocalName -ne "Job")
	{
		# Is this group Enabled ?
		Write-LogFile "$($ParentXmlNode.LocalName) Enabled: $($ParentXmlNode.Enabled)"
		if ($ParentXmlNode.Enabled.ToUpper() -eq "FALSE") 
		{
			Write-LogFile "$($ParentXmlNode.LocalName) ($($ParentXmlNode.Name)) is not enabled. Skip."
			return
		}
	
		# Do group have a condition ?
		$Condition = Get-ConditionFunction -XmlElement $ParentXmlNode
		if ($Condition -ne $null) {
			Write-LogFile "$($ParentXmlNode.LocalName) Condition: Yes"
			
			$CondtionOutput = Execute-ConditionFunction -ConditionNode $Condition 
			
			If ($Error -ne $null) {
				Write-LogFile "Failed to execute condition function. Error is: $Error"
				$Error.Clear()
				#break
				if (($ParentXmlNode.ContinueOnError.ToUpper() -eq "FALSE") -and ($GlobalContinueOnError -eq $false))
				{
					break
				}
				
			}
			
			# Evaluate conditon return value
			if ($CondtionOutput -eq $false) {
				Write-LogFile "$($ParentXmlNode.LocalName) Conditon is evaluated to: $CondtionOutput. Skip this Group."
				return
			}
			else {
				Write-LogFile "$($ParentXmlNode.LocalName) Conditon is evaluated to: $CondtionOutput. Continue execution."
			}
			
		}
		else {
			Write-LogFile "$($ParentXmlNode.LocalName) Condition: No"
		}
		
		# Verify Global Group ContinueOnError
		Write-LogFile "$($ParentXmlNode.LocalName) Continue On Error: $($ParentXmlNode.ContinueOnError)"
		if ($ParentXmlNode.ContinueOnError.ToUpper() -eq "TRUE")
		{
			$GlobalContinueOnError = $true
		}
	}

	foreach ($ChildNode in $ParentXmlNode.SelectNodes("Group|Function"))
	{
		Write-LogFile "Step Type: $($ChildNode.LocalName)"
		Write-LogFile "$($ChildNode.LocalName) Name: $($ChildNode.Name)"
		
		if ($ChildNode.LocalName.ToUpper() -eq "GROUP")
		{
			StartExecution -ParentXmlNode $ChildNode
		}
		else
		{
		
			# Is this item Enabled ?
			Write-LogFile "$($ChildNode.LocalName) Enabled: $($ChildNode.Enabled)"
			if ($ChildNode.Enabled.ToUpper() -eq "FALSE") 
			{
				Write-LogFile "$($ChildNode.LocalName) ($($ChildNode.Name)) is not enabled. Skip."
			}
			else 
			{
				# Do item have a condition ?
				$Condition = Get-ConditionFunction -XmlElement $ChildNode
				if ($Condition -ne $null) 
				{
					Write-LogFile "$($ChildNode.LocalName) Condition: Yes"
					
					$CondtionOutput = Execute-ConditionFunction -ConditionNode $Condition
		
					if ($Error -ne $null) 
					{
						Write-LogFile "Failed to execute condition function. Error is: $Error"
						$Error.Clear()
						
						if (($ChildNode.ContinueOnError.ToUpper() -eq "FALSE") -and ($GlobalContinueOnError -eq $false))
						{
							break
						}
						
					}
					
					# Evaluate conditon return value
					if ($CondtionOutput -eq $false) 
					{
						Write-LogFile "$($ChildNode.LocalName) Conditon is evaluated to: $CondtionOutput. Skip this $($ChildNode.LocalName)."
					}
					else 
					{
						Write-LogFile "$($ChildNode.LocalName) Conditon is evaluated to: $CondtionOutput. Continue execution."
						
						# Execute function
						$FunctionOutput = Execute-Function -FunctionNode $ChildNode
						Set-Variable -Name $ChildNode.ReturnVariable -Value $FunctionOutput -Scope "Global"
						$VariableName = $ChildNode.ReturnVariable.ToString()
						Write-LogFile "Return Variable Name is: $VariableName"
						Write-LogFile "$VariableName is now: $(Get-Variable -Name "$VariableName" -ValueOnly)"
						
						# Check for errors
						if (($Error -ne $null) -or ($MainRC -ne 0)) 
						{
							Write-LogFile "Error executing function: $Error"
				
							$Error.Clear()
							
							if (($ChildNode.ContinueOnError.ToUpper() -eq "FALSE") -and ($GlobalContinueOnError -eq $false))
							{
								If ($MainRC -eq 0)
								{
									Set-MainRC 1
								}
								
								Write-LogFile "Exit Script due to an error"
								Write-LogFile "MainRC is: $MainRC"
								exit $($MainRC)
							}
						
						}
						
					}
				}
				else 
				{
					Write-LogFile "$($ChildNode.LocalName) Condition: No. Continue execution"
					
					# Execute function
					$FunctionOutput = Execute-Function -FunctionNode $ChildNode
					Set-Variable -Name $ChildNode.ReturnVariable -Value $FunctionOutput -Scope "Global"
					$VariableName = $ChildNode.ReturnVariable.ToString()
					Write-LogFile "Return Variable Name is: $VariableName"
					Write-LogFile "$VariableName is now: $(Get-Variable -Name "$VariableName" -ValueOnly)"
					
					# Check for errors
					if (($Error -ne $null) -or ($MainRC -ne 0))
					{
						Write-LogFile "Error executing function: $Error"
						$Error.Clear()
						
						if (($ChildNode.ContinueOnError.ToUpper() -eq "FALSE") -and ($GlobalContinueOnError -eq $false))
						{
							If ($MainRC -eq 0)
							{
								Set-MainRC 1
							}
						
							Write-LogFile "Exit Script due to an error"
							Write-LogFile "MainRC is: $MainRC"
							exit $($MainRC)
						}
					
					}
				}
			
			}
		
		}

	}
		
}

#Clear screen
Clear-Host

Write-LogFile "--------------------- Execution started ---------------------"

Write-LogFile "Loading modules..."
Import-Module -Name ($(Get-ScriptDirectory) + "\Generic.psm1") -Verbose
Import-Module -Name ($(Get-ScriptDirectory) + "\Specific.psm1") -Verbose

Set-MainRC 0

# Verify that only one argument has been specified
if ($args.Count -ne 1)
{
	Write-LogFile "Only 1 parameter (Job Name) must be specified. Quit (87)"
	Set-MainRC 87
	exit $($MainRC)
}
else
{
	[string]$JobName = $args[0]
	Write-LogFile "JobName specified is '$JobName'"
}

# Load instruction XML file
$XmlFile = (Get-ScriptDirectory) + "\Instruction.xml"
if ((Test-Path -Path $XmlFile) -eq $false)
{
	Write-LogFile "Could not find instruction file '$XmlFile'. Quit (2)"
	Set-MainRC 2
	exit $($MainRC)
}

	Write-LogFile "Loading instruction file '$XmlFile'"
	[xml]$XmlDoc = Get-Content -Path $XmlFile
	
	if ($XmlDoc -eq $null) {
		Write-LogFile "Could not read the content of instruction file. Quit (13)"
		Set-MainRC 13
		exit $($MainRC)
	}
		
	# Get and log package meta data
	$AppVendor = $XmlDoc.Instruction.AppVendor
	$AppName = $XmlDoc.Instruction.AppName
	$AppVersion = $XmlDoc.Instruction.AppVersion
	$AppLang = $XmlDoc.Instruction.AppLanguage
	$PackageVersion = $XmlDoc.Instruction.PackageVersion
	$LastChange = $XmlDoc.Instruction.LastChangeDate
	Write-LogFile -Message "Package metadata: AppVendor: $AppVendor, AppName: $AppName, AppVersion: $AppVersion, AppLanguage: $AppLang, PackageVersion: $PackageVersion, LastChangeDate: $LastChange"
	
	# Load global properties
	Write-LogFile "Loading Global Properties"
	GetGlobalProperties
	
	# Set global package variables
	Set-Variable -Name "SCRIPTSFOLDER" -Value $(Get-ScriptDirectory) -Scope "Global"
	Set-Variable -Name "MEDIAFOLDER" -Value $(Get-MediaDirectory) -Scope "Global"
	Set-Variable -Name "RESOURCESFOLDER" -Value $(Get-ResourcesDirectory) -Scope "Global"
	Set-Variable -Name "ASSEMBILESFOLDER" -Value $(Get-AssembiliesDirectory) -Scope "Global"
	
	Write-LogFile "SCRIPTSFOLDER is: $SCRIPTSFOLDER"
	Write-LogFile "MEDIAFOLDER is: $MEDIAFOLDER"
	Write-LogFile "RESOURCESFOLDER is: $RESOURCESFOLDER"
	Write-LogFile "ASSEMBILESFOLDER is: $ASSEMBILESFOLDER"
	
	Write-LogFile "Retrieving Job node named '$JobName'"
	$XmlJobNode =  (Get-JobNode $JobName)
	
	if ($XmlJobNode -eq $null) {
		Write-LogFile "The Job node with the name of '$JobName' could not be trieved from instruction file. Quit (13)"
		Set-MainRC 13
		exit $($MainRC)
	}

	Write-LogFile "Executing instruction steps in job"
	StartExecution -ParentXmlNode $XmlJobNode
	
	Write-LogFile "MainRC is: $MainRC"
	Write-LogFile "--------------------- Execution ended ---------------------"
	
	exit $($MainRC) 

# SIG # Begin signature block
# MIIVSgYJKoZIhvcNAQcCoIIVOzCCFTcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFyovjhb0f/NXDhbyXPMfpWxI
# F9WgghABMIIEkzCCA3ugAwIBAgIQR4qO+1nh2D8M4ULSoocHvjANBgkqhkiG9w0B
# AQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0
# IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYD
# VQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VS
# Rmlyc3QtT2JqZWN0MB4XDTEwMDUxMDAwMDAwMFoXDTE1MDUxMDIzNTk1OVowfjEL
# MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UE
# BxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxJDAiBgNVBAMT
# G0NPTU9ETyBUaW1lIFN0YW1waW5nIFNpZ25lcjCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALw1oDZwIoERw7KDudMoxjbNJWupe7Ic9ptRnO819O0Ijl44
# CPh3PApC4PNw3KPXyvVMC8//IpwKfmjWCaIqhHumnbSpwTPi7x8XSMo6zUbmxap3
# veN3mvpHU0AoWUOT8aSB6u+AtU+nCM66brzKdgyXZFmGJLs9gpCoVbGS06CnBayf
# UyUIEEeZzZjeaOW0UHijrwHMWUNY5HZufqzH4p4fT7BHLcgMo0kngHWMuwaRZQ+Q
# m/S60YHIXGrsFOklCb8jFvSVRkBAIbuDlv2GH3rIDRCOovgZB1h/n703AmDypOmd
# RD8wBeSncJlRmugX8VXKsmGJZUanavJYRn6qoAcCAwEAAaOB9DCB8TAfBgNVHSME
# GDAWgBTa7WR0FJwUPKvdmam9WyhNizzJ2DAdBgNVHQ4EFgQULi2wCkRK04fAAgfO
# l31QYiD9D4MwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
# BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2NybC51c2Vy
# dHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0LmNybDA1BggrBgEFBQcBAQQp
# MCcwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZI
# hvcNAQEFBQADggEBAMj7Y/gLdXUsOvHyE6cttqManK0BB9M0jnfgwm6uAl1IT6TS
# IbY2/So1Q3xr34CHCxXwdjIAtM61Z6QvLyAbnFSegz8fXxSVYoIPIkEiH3Cz8/dC
# 3mxRzUv4IaybO4yx5eYoj84qivmqUk2MW3e6TVpY27tqBMxSHp3iKDcOu+cOkcf4
# 2/GBmOvNN7MOq2XTYuw6pXbrE6g1k8kuCgHswOjMPX626+LB7NMUkoJmh1Dc/VCX
# rLNKdnMGxIYROrNfQwRSb+qz0HQ2TMrxG3mEN3BjrXS5qg7zmLCGCOvb4B+MEPI5
# ZJuuTwoskopPGLWR5Y0ak18frvGm8C6X0NL2KzwwggVYMIIEQKADAgECAhBcPvke
# G4Rqv7OVKEaBH3nzMA0GCSqGSIb3DQEBBQUAMIG0MQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRydXN0IE5l
# dHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3dy52ZXJp
# c2lnbi5jb20vcnBhIChjKTEwMS4wLAYDVQQDEyVWZXJpU2lnbiBDbGFzcyAzIENv
# ZGUgU2lnbmluZyAyMDEwIENBMB4XDTEzMDkwNTAwMDAwMFoXDTE1MDkwNTIzNTk1
# OVowgZsxCzAJBgNVBAYTAkRLMQ8wDQYDVQQIEwZBYXJodXMxETAPBgNVBAcTCEhp
# bm5lcnVwMRMwEQYDVQQKFAplZGdlbW8gQS9TMT4wPAYDVQQLEzVEaWdpdGFsIElE
# IENsYXNzIDMgLSBNaWNyb3NvZnQgU29mdHdhcmUgVmFsaWRhdGlvbiB2MjETMBEG
# A1UEAxQKZWRnZW1vIEEvUzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# ALp5j6J+nl5d5CTP+16cFiUbq10KemN/DIOfy6lBeYNkr2qpJZ/dHQfbhhnPD2gd
# bN2PN0oWPSUvdIpJl8Qw187rxy4aKFtv17FW56mj351Bazcfix80mDEytrmy8cGr
# GfjRkWzu4en1PLL6S4dEMjd39kkWUgDxXxDcju+TArnDOnTlEEnc1mgbViIGg7Lo
# wEe9P0CZgbq+i8SVK3FEFkeBPCMpdroSdhK1n8gTiOsp4Brune5gbE0Lrd2eC36s
# KOf9/vBKOqz7tXX6KaUaVV9/zfJQot7b/xRpx1I55hNv4CDJ9uspW8c54J50+L6m
# o9HNWUriZfalbyGWzWIW/okCAwEAAaOCAXswggF3MAkGA1UdEwQCMAAwDgYDVR0P
# AQH/BAQDAgeAMEAGA1UdHwQ5MDcwNaAzoDGGL2h0dHA6Ly9jc2MzLTIwMTAtY3Js
# LnZlcmlzaWduLmNvbS9DU0MzLTIwMTAuY3JsMEQGA1UdIAQ9MDswOQYLYIZIAYb4
# RQEHFwMwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3Jw
# YTATBgNVHSUEDDAKBggrBgEFBQcDAzBxBggrBgEFBQcBAQRlMGMwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLnZlcmlzaWduLmNvbTA7BggrBgEFBQcwAoYvaHR0cDov
# L2NzYzMtMjAxMC1haWEudmVyaXNpZ24uY29tL0NTQzMtMjAxMC5jZXIwHwYDVR0j
# BBgwFoAUz5mp6nsm9EvJjo/X8AUm7+PSp50wEQYJYIZIAYb4QgEBBAQDAgQQMBYG
# CisGAQQBgjcCARsECDAGAQEAAQH/MA0GCSqGSIb3DQEBBQUAA4IBAQDeYqKEy6yn
# eZ54bXRECM/Fbxd8g0HHMp264ZPdCvPBoAsNXD6BtthkIT9UE2AORs7qgjASglKw
# zWuKL1Xb2HGbRd0voM3lirj63GklItN8r+rYazJiWOhGOfQHHNXUZ2QooF49qWpK
# shpBqg+QKn9yY2NW7j/zazZwMF2XNFC0InqbvaxHYPachReyvNCKBNqKYtwYz6vF
# L7AdmHlLRt+0YPuSnkxu32KOYkL5KCL1E4PfPWB2UKdl9DmONH8xGnWWtfjROI3o
# lFFzVwZ+qxWLaDNjcSHsntQ2mdniAnjdo6qgmlXWL05SB6h+HM6ZF/lr66RxRPIT
# gHUFuNxjyqJtMIIGCjCCBPKgAwIBAgIQUgDlqiVW/BqG7ZbJ1EszxzANBgkqhkiG
# 9w0BAQUFADCByjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMu
# MR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykg
# MjAwNiBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUw
# QwYDVQQDEzxWZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmlj
# YXRpb24gQXV0aG9yaXR5IC0gRzUwHhcNMTAwMjA4MDAwMDAwWhcNMjAwMjA3MjM1
# OTU5WjCBtDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8w
# HQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBv
# ZiB1c2UgYXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYykxMDEuMCwG
# A1UEAxMlVmVyaVNpZ24gQ2xhc3MgMyBDb2RlIFNpZ25pbmcgMjAxMCBDQTCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPUjS16l14q7MunUV/fv5Mcmfq0Z
# mP6onX2U9jZrENd1gTB/BGh/yyt1Hs0dCIzfaZSnN6Oce4DgmeHuN01fzjsU7obU
# 0PUnNbwlCzinjGOdF6MIpauw+81qYoJM1SHaG9nx44Q7iipPhVuQAU/Jp3YQfycD
# fL6ufn3B3fkFvBtInGnnwKQ8PEEAPt+W5cXklHHWVQHHACZKQDy1oSapDKdtgI6Q
# JXvPvz8c6y+W+uWHd8a1VrJ6O1QwUxvfYjT/HtH0WpMoheVMF05+W/2kk5l/383v
# pHXv7xX2R+f4GXLYLjQaprSnTH69u08MPVfxMNamNo7WgHbXGS6lzX40LYkCAwEA
# AaOCAf4wggH6MBIGA1UdEwEB/wQIMAYBAf8CAQAwcAYDVR0gBGkwZzBlBgtghkgB
# hvhFAQcXAzBWMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20v
# Y3BzMCoGCCsGAQUFBwICMB4aHGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEw
# DgYDVR0PAQH/BAQDAgEGMG0GCCsGAQUFBwEMBGEwX6FdoFswWTBXMFUWCWltYWdl
# L2dpZjAhMB8wBwYFKw4DAhoEFI/l0xqGrI2Oa8PPgGrUSBgsexkuMCUWI2h0dHA6
# Ly9sb2dvLnZlcmlzaWduLmNvbS92c2xvZ28uZ2lmMDQGA1UdHwQtMCswKaAnoCWG
# I2h0dHA6Ly9jcmwudmVyaXNpZ24uY29tL3BjYTMtZzUuY3JsMDQGCCsGAQUFBwEB
# BCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AudmVyaXNpZ24uY29tMB0GA1Ud
# JQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDAzAoBgNVHREEITAfpB0wGzEZMBcGA1UE
# AxMQVmVyaVNpZ25NUEtJLTItODAdBgNVHQ4EFgQUz5mp6nsm9EvJjo/X8AUm7+PS
# p50wHwYDVR0jBBgwFoAUf9Nlp8Ld7LvwMAnzQzn6Aq8zMTMwDQYJKoZIhvcNAQEF
# BQADggEBAFYi5jSkxGHLSLkBrVaoZA/ZjJHEu8wM5a16oCJ/30c4Si1s0X9xGnzs
# cKmx8E/kDwxT+hVe/nSYSSSFgSYckRRHsExjjLuhNNTGRegNhSZzA9CpjGRt3HGS
# 5kUFYBVZUTn8WBRr/tSk7XlrCAxBcuc3IgYJviPpP0SaHulhncyxkFz8PdKNrEI9
# ZTbUtD1AKI+bEM8jJsxLIMuQH12MTDTKPNjlN9ZvpSC9NOsm2a4N58Wa96G0IZEz
# b4boWLslfHQOWP51G2M/zjF8m48blp7FU3aEW5ytkfqs7ZO6XcghU8KCU2OvEg1Q
# hxEbPVRSloosnD2SGgiaBS7Hk6VIkdMxggSzMIIErwIBATCByTCBtDELMAkGA1UE
# BhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2ln
# biBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6
# Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYykxMDEuMCwGA1UEAxMlVmVyaVNpZ24g
# Q2xhc3MgMyBDb2RlIFNpZ25pbmcgMjAxMCBDQQIQXD75HhuEar+zlShGgR958zAJ
# BgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQUnVFT5adAzYHz00aFNDv86dq82LQwDQYJKoZIhvcNAQEB
# BQAEggEAbJByRw5ypxEwz0V6+zS8TKbFW0migi4mZE+W9rmf1o5KDPcu9huA5KmE
# AMWvwMFxThtb0rOugtwdkQv7my16gYvT5c3oIG/CW6lIr7bunB3fv64XcVVzMrHt
# hO9sjTTrGTNUHfUtfft8FEsf5DMzBNgf2q/aAHMp1mpCeKDaGfYBTOW09hLzEq2G
# x1O3gZaDLntPhqH7UbKRbxMXGqiuhvQQ0VQp0Zo2gavv4hiswEOQFnCRFcwyY/+Q
# 0WOMIXxpqv5QUcLfa38/hIdXI5dV5/g8K3fa9Or4ECYNA5PYdqutgINZPYRlewhe
# HQ5c8zAT+yxNKwMjY4Zbgt+R9lKFfqGCAkQwggJABgkqhkiG9w0BCQYxggIxMIIC
# LQIBADCBqjCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5T
# YWx0IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEw
# HwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1V
# U0VSRmlyc3QtT2JqZWN0AhBHio77WeHYPwzhQtKihwe+MAkGBSsOAwIaBQCgXTAY
# BgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDA0MDIx
# MjA4MDFaMCMGCSqGSIb3DQEJBDEWBBTUJXtJ6SxMpykB01MSjkGmQK2h/jANBgkq
# hkiG9w0BAQEFAASCAQBk3JLFaUC76OIdN3lx0RA2kHQuiQ9WeRpauVAXh9nkwtyB
# E0G8UZm1julJ++ugkWnRykQ3SzzCAh/J7WmzgkNKdmcuBOCGXedIBmJkWY2JHOV1
# 1hHRDT3w4XGxNGcgL+CT+uzowutcRByN/ijYKMrxWHl73IGGD1noHsM8PVp/EmlA
# CnArAOlGy/YUUH4TuVbcXeOck+DDBLdlgSp/U+Uy3Ljcw06d3UMlPk4BuL4LgRBe
# IIKim/lAvfbH7KvyBkq2rvPVYXLym9E3o6mFKfaruQanUKmkZquJuCAt+CT1alo7
# dPxM1d0zc0UOCTG8c0GpM/UwhWLblx5aZh2bs/PX
# SIG # End signature block
