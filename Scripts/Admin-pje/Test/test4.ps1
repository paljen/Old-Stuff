function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope global).value
	Split-Path $Invocation.MyCommand.path
}

Join-Path (Get-ScriptDirectory) "\scorch\scorch.psd1"
