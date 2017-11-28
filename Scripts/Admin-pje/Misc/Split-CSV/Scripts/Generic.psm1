#############################################################################################################
# Name: 	Generic.psm1																				   	#
# Author: 	edgemo a/s																						#
# Version:	1.1																								#
# Change History:																							#
#############################################################################################################
# Date:			Author:						Change:														   	#
#############################################################################################################
# 25022013 		Kristian F. Thomsen			1.0 Initial version											   	#
# 19042013		Kristian F. Thomsen			1.1 Bug fixes													#
#############################################################################################################

function ShowProgressUI
{
	param($SetupUIConfigFile, $RtfDoc, $WaitExit)

	# Verify the defined files exist
	if ((Test-Path $RtfDoc) -eq $false)
	{
		return $false
	}
	
	if ((Test-Path $SetupUIConfigFile) -eq $false)
	{	
		return $false
	}
	
	# Run UI
	$UIProcess = Get-WmiObject -Namespace "root\cimv2" -Query "Select * from win32_process where Name = 'edgemo.soft2go.package.installprogressui.exe'"	
	if ($UIProcess -eq $null)
	{
	
		$psi = new-object "Diagnostics.ProcessStartInfo"
		
		if ((Test-Path $($RESOURCESFOLDER + "\edgemo.soft2go.package.installprogressui.exe")) -eq $true)
		{
			$exec = $($RESOURCESFOLDER + "\edgemo.soft2go.package.installprogressui.exe")
			$exeargs = @("/pid:$pid", "/config:""$SetupUIConfigFile""", "/info:""$RtfDoc""")
			
			# Get OS Version
			$osver =  $([Environment]::OSVersion.Version.Major)
			if ($osver -eq 6)
			{
				if ((Test-Path $($RESOURCESFOLDER + "\ServiceUI.exe")) -eq $true)
				{
					$SessionID = GetCurrentUserSessionID
					
					if ($SessionID -ne $null)
					{
						[System.IO.File]::Copy($($RESOURCESFOLDER + "\edgemo.soft2go.package.installprogressui.exe"), $([environment]::ExpandEnvironmentVariables("%TEMP%")+ "\edgemo.soft2go.package.installprogressui.exe"), $true)
						$UI = $([environment]::ExpandEnvironmentVariables("%TEMP%")+ "\edgemo.soft2go.package.installprogressui.exe")
						
						[System.IO.FileInfo]$f1 = ($SetupUIConfigFile)
						[System.IO.FileInfo]$f2 = ($RtfDoc)
					
						[System.IO.File]::Copy($f1, $([environment]::ExpandEnvironmentVariables("%TEMP%")+ "\" + $($f1.Name)), $true)
						[System.IO.File]::Copy($f2, $([environment]::ExpandEnvironmentVariables("%TEMP%")+ "\" + $($f2.Name)), $true)
						
						[System.IO.FileInfo]$f1 = ($([environment]::ExpandEnvironmentVariables("%TEMP%")+ "\" + $($f1.Name)))
						[System.IO.FileInfo]$f2 = ($([environment]::ExpandEnvironmentVariables("%TEMP%")+ "\" + $($f2.Name)))
						
						$exec = $($RESOURCESFOLDER + "\ServiceUI.exe")
						$exeargs = @("-session:$SessionID", """$($UI)""", "/pid:$pid /config:""\""$f1\"""" /info:""\""$f2\""""")
						
						$psi.CreateNoWindow = $true
						$psi.UseShellExecute = $false
					}
					
				}
			
			}
		
    		$psi.FileName = $exec
			$psi.Arguments = $exeargs
			
    		$proc = [Diagnostics.Process]::Start($psi)
		
		    if ([System.Convert]::ToBoolean($WaitExit)) 
			{
		        $proc.WaitForExit()
		    }
			
			return $true
		}
		else
		{
			return $false
		}
	}
	else
	{
		return $false
	}
}

function ExecuteCommandLine
{
	Param([string]$Executable, [string]$Parameters, $DoWait)

	$psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.FileName = $Executable
    $psi.Arguments = $Parameters
    $proc = [Diagnostics.Process]::Start($psi)
	
    if ([System.Convert]::ToBoolean($DoWait)) 
	{
        $proc.WaitForExit();
    }
	
	Set-MainRC $($proc.ExitCode)
	
    return $proc.ExitCode

}

function Set-MainRC
{
	param([Int]$RC)
	
	Set-Variable -Name "MainRC" -Value $RC -Scope "Global"
}

function WriteToLogFile
{

	param([string]$Message)

	$LogFile =  [Environment]::ExpandEnvironmentVariables('%TMP%') + "\eSPTScript.log"
	

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($LogFile, $true)
	
	$Output = "$([DateTime]::Now): $Message"
	
	Write-Host $Output
	
	$Log.WriteLine($Output)
	$Log.Close()

}

function FileExists
{
	param($File)
	
	return Test-Path -Path $File
}

function RegKeyOrValueExists
{
	param($RegHive, $RegView, $RegKey, $RegVal)
	
	if ($([System.Runtime.InteropServices.RuntimeEnvironment]::GetSystemVersion().Substring(1, 1)) -eq "4")
	{
		$BaseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegHive, $RegView)
	}
	else
	{
		$BaseKey = [Microsoft.Win32.Registry]::$RegHive
	}
	
	$Key = $BaseKey.OpenSubKey($RegKey)
	
	if ($Key -eq $null)
	{
		return $false
	}
	else
	{
		if ($RegVal -eq "")
		{
			return $true
		}
		else
		{
			$val = $Key.GetValue($RegVal)
			
			If ($val -eq $null)
			{
				return $false
			}
			else
			{
				return $true
			}
			
		}
	}
}

function ServiceExists
{
	param ($ServiceName)
	
	$Service = Get-WmiObject -Namespace "root\Cimv2" -Query "Select * from Win32_Service Where Name = '$ServiceName'"
	
	if ($Service -eq $null)
	{
		return $false
	}
	else
	{
		return $true
	}
}

function ProcessExists
{
	param($ProcessName)

	$Process = Get-WmiObject -Namespace "root\cimv2" -Query "Select * from win32_process where Name = '$ProcessName'"
	
	if ($Process -eq $null)
	{
		return $false
	}
	else
	{
		return  $true
	}
}

function TerminateProcess
{
	param ($ProcessName)
	
	$Process = Get-WmiObject -Namespace "root\cimv2" -Query "select * from win32_process where name like '%$ProcessName%'" | ForEach-Object {$_.Terminate()}
	
	return $true
}

function StartStopService
{
	param($ServiceName, $Action)
	
	$Service = Get-WmiObject -Namespace "root\cimv2" -Query "select * from Win32_service where name = '$ServiceName'"
	
	if ($Service -ne $null)
	{
		if ($Action -eq "Stop")
		{
			$obj = $Service.StopService()
		}
		else
		{
			$obj = $Service.StartService()
		}
	}
	
	return $obj.ReturnValue
}

function ReplaceInTextFile
{
	param ($TextFile, $TextToReplace, $Value)

	(Get-Content $TextFile) | 
	Foreach-Object {$_ -replace $TextToReplace, $Value} |
	Set-Content $TextFile
	
	return $true
}

function WriteToXMLFile
{
}

function ReadValueFromXMLFile
{
}

function GetADObjectAttribute
{
	
}

function ExecuteLDAPQuery
{

}

function ExecuteSQLQuery
{
}

function ExecuteWQLQuery
{
	param ($Namespace, $Query, $PropertyName)
	
	$wmi = Get-WmiObject -Namespace $Namespace -Query $Query
	
	$wmi | ForEach-Object {
		return $_.$PropertyName
	}
	
}

function CopyFilesToFolder
{

	param($SourceFile, $DestinationFolder)
	
	Copy-Item -Path $SourceFile -Destination $DestinationFolder -Force -Recurse  
	
	if ($Error -ne $null)
	{
		return $false
	}
	else
	{
		return $true
	}


}

function WriteToRegistry
{
	param ($RegHive, $RegKey, $RegValueName, $RegValue, $RegType)
	
	try
	{
		[Microsoft.Win32.Registry]::SetValue($("$RegHive\$RegKey"), $RegValueName, $RegValue, $RegType)
		return $true
	}
	catch [System.Exception]
	{
		return $false
	}
}

function DeleteRegistryValue
{

	param ($RegHive, $RegKey, $RegValueName, $RegView)
	
	if ($([System.Runtime.InteropServices.RuntimeEnvironment]::GetSystemVersion().Substring(1, 1)) -eq "4")
	{
		$BaseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegHive, $RegView)
	}
	else
	{
		$BaseKey = [Microsoft.Win32.Registry]::$RegHive
	}

	$Key = $BaseKey.OpenSubKey($RegKey)
	
	try
	{
		$Key.DeleteValue($RegValueName)
		return $true
	}
	catch [System.Exception]
	{
		return $false 
	}
	finally
	{
		$Key.Close()
		$BaseKey.Close()
	}

}

function DeleteRegistryKey
{
	param ($RegHive, $RegKey, $RegView)
	
	if ($([System.Runtime.InteropServices.RuntimeEnvironment]::GetSystemVersion().Substring(1, 1)) -eq "4")
	{
		$BaseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegHive, $RegView)
	}
	else
	{
		$BaseKey = [Microsoft.Win32.Registry]::$RegHive
	}
	
	try
	{
		$Basekey.DeleteSubKey($RegKey)
		return $true
	}
	catch [System.Exception]
	{
		return $false 
	}
	finally
	{
		$BaseKey.Close()
	}
}

function FolderExists
{
	param ($FolderPath)
	
	return Test-Path -Path $FolderPath
}

function GetComputerName
{
	return [Environment]::MachineName
}

function GetLoggedOnUserName
{
	$userid = (Get-WmiObject -Query "select UserName from Win32_ComputerSystem" -Namespace "root\cimv2").UserName
	$userid = $userid.Remove(0, ($userid.IndexOf("\") + 1))
	
	return $($userid)
}

function GetSubString
{
	param($String, $Start, $Length)
	
	return $string.tostring().SubString($Start, $Length)
}

function CreateShortcut
{
}

function CopyFolder
{
	param($SourceFolder, $DestinationFolder, $Overwrite)
	
	if ([System.Convert]::ToBoolean($Overwrite) -eq $true)
	{
		Copy-Item -Path $SourceFolder -Destination $DestinationFolder -Force -Recurse  
	}
	else
	{
		Copy-Item -Path $SourceFolder -Destination $DestinationFolder -Recurse
	}
	
	if ($Error -ne $null)
	{
		return $false
	}
	else
	{
		return $true
	}
}

function CreateFolder
{
	param($FolderPath)


	try
	{
		[System.IO.Directory]::CreateDirectory($FolderPath) | Out-Null
		return $true
	}
	catch [System.Exception]
	{
		return $false
	}
}

function WaitForProcessToEnd
{
	param ($ProcessName)
	
	$Exists = $true
	
	while ($Exists -eq $true)
	{
		$Exists = ProcessExists $ProcessName
		start-sleep 1
	}
	
	return $true
}

function WaitForProcessToStart
{
	param ($ProcessName)
	
	$Exists = $false
	
	while ($Exists -eq $false)
	{
		$Exists = ProcessExists $ProcessName
		start-sleep 1
	}
	
	return $true
}

function GetMSIProductID
{

	param ($DisplayName, $RegView)
	
	$returnvalue = $null
	
	if ($([System.Runtime.InteropServices.RuntimeEnvironment]::GetSystemVersion().Substring(1, 1)) -eq "4")
	{
		$BaseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegHive, $RegView)
	}
	else
	{
		$BaseKey = [Microsoft.Win32.Registry]::$RegHive
	}
	
	$Uninstkey = $BaseKey.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
	
	$prods = $Uninstkey.GetSubKeyNames()
	
	
	for ( $i=0; $i -le ($prods.length - 1); $i++)  
	{
		$prodkey = $Uninstkey.OpenSubKey($prods[$i])
		
		$dispName = $prodkey.GetValue("DisplayName")
		$prodkey.Close()
		
		if ($dispName -eq $DisplayName)
		{
			$returnvalue = $($prods[$i])
			break
		}
	
	}
	
	$Uninstkey.Close()
	$BaseKey.Close()
	
	return $returnvalue
}

function InstallFont
{
}

function SetEnvironmentVariable
{
	param ($VariableName, $Value, $Context)
	
	[Environment]::SetEnvironmentVariable($VariableName, $Value, $Context)
	
	return 0
}

function GetEnvironmentVariable
{
	param ($VariableName, $Context)
	
	return [Environment]::GetEnvironmentVariable($VariableName, $Context)
}

function RemoveEnvironmentVariable
{
	param ($VariableName, $Context)
	
	[Environment]::SetEnvironmentVariable($VariableName, $null, $Context)
	
	if ([Environment]::GetEnvironmentVariable($VariableName) -eq $null)
	{
		return $true
	}
	else
	{
		return $false
	}
}

function SetScriptVariable
{
	param ($VariableName, $Value)
	
	New-Variable -Name $VariableName -Value $Value -Scope "Global" -Force
	
	if ($Error)
	{
		return $false
	}
	else
	{
		return $true
	}
}

function GetScriptVariable
{
	param ($VariableName)
	
	$value = Get-Variable -Name $VariableName -ValueOnly
	
	return $value
}

function RemoveScriptVariable
{
	param ($VariableName)
	
	Remove-Variable -Name $VariableName -Scope "Global"
	
	if ($Error)
	{
		return $false
	}
	else
	{
		return $true
	}
}

function DisableOpenFileSecurityWarning
{
	[Environment]::SetEnvironmentVariable("SEE_MASK_NOZONECHECKS", "1", "PROCESS")
	
	return $true
}

function DeleteFolder
{
	param($Folder)
	
	if (Test-Path -Path $Folder)
	{
		try
		{
			[IO.Directory]::Delete($Folder, $true)
			
			return $true
		}
		catch [System.Exception]
		{
			return $false
		}
	
	}
	else
	{
		return $true
	}
	
}

function DeleteFile
{
	param ($File)
	
	if (Test-Path -Path $File)
	{
		try
		{
			[IO.File]::Delete($File)
			
			return $true
		}
		catch [System.Exception]
		{
			return $false
		}
	
	}
	else
	{
		return $true
	}

}

function GetCurrentUserSessionID
{
	$SessionID = $null

	$userid = (Get-WmiObject -Query "select UserName from Win32_ComputerSystem" -Namespace "root\cimv2").UserName
	$userid = $userid.Remove(0, ($userid.IndexOf("\") + 1))

	$Process = (Get-WmiObject -class win32_process)

	foreach ($proc in $process)
	{
		$owner = $proc.GetOwner().User
		if ($owner -ne $null)
		{
			if ($owner.ToUpper() -eq $userid.ToUpper())
			{
				$SessionID = $proc.SessionId
				break
			}
		}
	}
	
	return $SessionID
}

function WriteToOfflineRegHive
{
	param([string]$HiveFile, [string]$RegKey, [string]$RegValueName, [string]$RegValue, [string]$RegType)
	
	# Does file exist
	if ((Test-Path $HiveFile) -eq $false)
	{
		return $false
	}
	
	try
	{
		# Load hive
		Invoke-Expression  "reg load HKLM\_TMP_ $HiveFile" | Out-Null 
		
		# Write value
		return $(WriteToRegistry -RegHive "HKEY_LOCAL_MACHINE" -RegKey $("_TMP_\$RegKey") -RegType $RegType -RegValue $RegValue -RegValueName $RegValueName)
	}
	catch
	{
		return $false
	}
	finally
	{
		# Unload hive
		Invoke-Expression "reg unload HKLM\_TMP_" | Out-Null
	}
}

# SIG # Begin signature block
# MIIVSgYJKoZIhvcNAQcCoIIVOzCCFTcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTW/Z0YAdcDPJ0sERDlVLgDBk
# aE6gghABMIIEkzCCA3ugAwIBAgIQR4qO+1nh2D8M4ULSoocHvjANBgkqhkiG9w0B
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
# BgkqhkiG9w0BCQQxFgQUbjTY5lSapBH6GrwkSkIFWruy/PgwDQYJKoZIhvcNAQEB
# BQAEggEAHwuHKVKTasu9Aj/YhG6QDREp7SUXtYq1XgOXXf3LNknFC5vQeYflt6Hl
# XVqkCEmK8eq2GI4W/UUCdek8U/mg8ReYutUW7X8yOwmfJEznCM07ZVJRyiZxXiFc
# 2hG90mmy1BmVnq3oWYhXVH9m7oWp37t0lI5z8UanWQTtS0tMBqJhi9l9RX9Q3p9b
# t3e4n4zlJ+4v/7QqiJqU2oI1jd0jHh1iLOiq6pKNuz/0w+L3po6o912+LOwFjPIK
# Bv5MzrV6aDgfhipX9HS64eR6bVvnJEfUAPWngkQUXHVAEds2i7FabYnVhh0Ydufc
# YsM61Q3p8jxYtsIVKUneLnFmuvv+5aGCAkQwggJABgkqhkiG9w0BCQYxggIxMIIC
# LQIBADCBqjCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5T
# YWx0IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEw
# HwYDVQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1V
# U0VSRmlyc3QtT2JqZWN0AhBHio77WeHYPwzhQtKihwe+MAkGBSsOAwIaBQCgXTAY
# BgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDA0MDIx
# MjE0MTBaMCMGCSqGSIb3DQEJBDEWBBRb3QwiKFPZo0eJvKWAhtWGgD+k3jANBgkq
# hkiG9w0BAQEFAASCAQBtZFKPcQxyavpjje0S1Zr3iU35drE6sVNFfNke2fPrMJbX
# fD9RiOj9QnXzf6Pyn+ziOMEXEAZmAQngoNazKfC22BtR2VczMrxarqVTuEqzuv3B
# WkbX3VZc2PdPl4H+EC+gwRc5HgB7vBeLIhKXVSU6Vz9p3Ot1eatW6+ZhY9Mc6/pw
# G9pDyOq0d5UAevvUqCCre6s4MZSLMofCdfBiiMkjtR5eQutdQEO8Qs2dZuRrh6j7
# NpQ/Pct3gYOci7TH2qehMX5vZUv6kzB1Sz1HtuN8QYeWBm7LXP4i1vAzJO8pGGAK
# tRvULoXM3T3cYQ+lB8KoE0+XWxQU3jRjKe9uT3AL
# SIG # End signature block
