#Clear-Host
function GetUserDisplayName
{
	$domain = $Env:USERDOMAIN
	$userid = $Env:USERNAME
	
	return ([adsi]"WinNT://$domain/$userid,user").fullname
}

$scriptdir = split-path($MyInvocation.MyCommand.Path)
$msrootdir = [Environment]::ExpandEnvironmentVariables("%APPDATA%\Microsoft")
$username = GetUserDisplayName

if ((Test-Path ($msrootdir + "\Signatures\Corporate Reply Signature.txt")) -eq $false)
{
	Copy-Item ($scriptdir + "\Signatures\Corporate Reply Signature_files") -Destination ($msrootdir + "\Signatures") -Recurse -Force
	Copy-Item ($scriptdir + "\Signatures\*.*") ($msrootdir + "\Signatures")

	# Write User Display name to signaturs
	foreach ($file in (Get-Item ($msrootdir + "\Signatures\Corporate Reply Signature.*")))
	{
		if ($file.Extension -ne ".rtf")
		{
		    	(Get-Content $file) | ForEach-Object {$_ -replace "%%USERNAME%%","$username"} | Set-Content $file -Encoding Unicode
		}
	}

	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Office\15.0\Outlook\Setup" -Name First-Run -Force -ErrorAction SilentlyContinue

	New-Item "HKCU:\SOFTWARE\Microsoft\Office\15.0\Common\MailSettings" -ErrorAction SilentlyContinue |Out-Null
	New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\15.0\Common\MailSettings" -Name ReplySignature -PropertyType ExpandString -Value "Corporate Reply Signature" -ErrorAction SilentlyContinue  | Out-Null
	New-Item "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\MailSettings" -ErrorAction SilentlyContinue |Out-Null
	New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\MailSettings" -Name ReplySignature -PropertyType ExpandString -Value "Corporate Reply Signature" -ErrorAction SilentlyContinue  | Out-Null
}

$Header = $null
$Message = $null
$Footer = $null

#Generate RTF header
$Header+="{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Century Gothic;}}`r`n"
$Header+="{\*\generator Riched20 6.2.8102}\viewkind4\uc1 `r`n"
$Header+="\pard\sl276\slmult1\f0\fs20\lang9 \par`r`n"

#Content
$Message+="Kind regards\par`r`n"
$Message+="$username\par`r`n"

#Footer
$Footer="}`r`n"

#Build file
$Content=$Header+$Message+$Footer
$path = $msrootdir + "\Signatures\Corporate Reply Signature.rtf"

SET-CONTENT -path $path -value $Content –force 