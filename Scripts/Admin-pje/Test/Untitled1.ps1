function New-EccoScriptSigning2
{
	<#
		.SYNOPSIS
			Sign Remote Script with Self Signed Certificate - cert:\CurrentUser\My.

		.PARAMETER  ScriptPath
			The full script path  - "C:\Scripts\Add-Signing.ps1".

		.EXAMPLE
			PS C:\> New-RemoteScriptSigning -ScriptPath "C:\Scripts\Add-Signing.ps1"

		.EXAMPLE
			PS C:\> "C:\Scripts\Add-Signing.ps1" | New-RemoteScriptSigning

		.INPUTS
			System.String
	#>
	
	PARAM(

		[String]$globalPath
	)

	$cert = @(Get-ChildItem cert:\CurrentUser\My -codesigning)[0]
	Set-AuthenticodeSignature $globalPath $cert	
}