
# ------------------------------------------------------------------------
# NAME:   func_Generic.ps1
# AUTHOR: Palle Jensen, Ecco
# DATE:   01/08/2015
#
# KEYWORDS: 
#
# COMMENTS: 
# ---------------------------------------------------------------------

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