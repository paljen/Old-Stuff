function Get-ScriptLocation
{
	$Invocation = (Get-Variable MyInvocation -Scope global).value
	Split-Path $Invocation.MyCommand.path
}

Join-Path (Get-ScriptLocation) "\TraceScript.log"
