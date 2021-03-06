function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope global).value
	Split-Path $Invocation.MyCommand.path
}

function Get-ModuleDirectory
{
	join-path $(Get-ScriptDirectory) "\Module\"
}

function Set-Logfile
{
	Join-Path (Get-ScriptLocation) "\TraceScript.log" | Remove-Item -ErrorAction SilentlyContinue
	Join-Path (Get-ScriptLocation) "\TraceScript.log"
	
}

Set-logfile