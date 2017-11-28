function int_LogFile
{
    $Invocation = Get-Variable MyInvocation -Scope 1 -ValueOnly
    Set-Variable -name LogFile -Value ($($Invocation.MyCommand.Source -replace ".ps1",".log"))
    Get-Variable -Name LogFile
}

$LogFile = (int_LogFile).Value

Out-EccoGeWriteToLog -LogFile $LogFile "test"

