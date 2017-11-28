function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope global).value
	Split-Path $Invocation.MyCommand.path
}

function Get-ModuleDirectory
{
	join-path $(Get-ScriptDirectory) "\Module\"
}

Get-moduleDirectory