<#
function test
{
	$input
	
}

(gwmi win32_computersystem) | test
#>
<#
function test2
{
	 $invocation = (Get-Variable MyInvocation -Scope global).value
	 $Invocation.mycommand.path
	 
	}
	
	test2
#>

$PSScriptRoot
