function test
{
	$path = Split-Path -Parent $MyInvocation.MyCommand.Definition
	$path
}

Split-Path -Parent $MyInvocation.MyCommand.Definition