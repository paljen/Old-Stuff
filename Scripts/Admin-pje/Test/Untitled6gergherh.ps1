
Function Get-ModuleDirectory {
    $Invocation = Get-Variable MyInvocation -Scope 1 -ValueOnly
    Split-Path -Parent $($Invocation.MyCommand.source)
}

#Get-ChildItem (Get-ModuleDirectory) -Recurse | Where-Object { $_.Name -like "Func_*" } | %{. $_.FullName}
Get-ModuleDirectory



