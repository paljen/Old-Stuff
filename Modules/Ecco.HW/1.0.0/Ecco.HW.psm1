<#
.SYNOPSIS
	A brief description of the script module

.NOTES
	Version:		1.0.0
	Author:			Admin-PJE
	Creation Date:	22/11/16
	Purpose/Change:	Initial script module development - Ecco.TEST.psm1
#>

$ErrorActionPreference = "Continue"

Function Get-HW
{
     Write-Output $(hostname)
}

Export-ModuleMember -Function * -Alias * -Cmdlet * -Verbose:$false