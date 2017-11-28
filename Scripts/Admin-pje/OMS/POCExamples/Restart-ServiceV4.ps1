#With Log
Param
(
        [Parameter(Mandatory=$true)]
        [String] $ComputerName,
        [Parameter(Mandatory=$true)]
        [String] $ServiceName
)

$ErrorActionPreference = "stop"

Write-verbose "Getting Service $ServiceName from $computerName"

$Service = Get-Service -ComputerName $ComputerName -Name $ServiceName

#Test if service was retrieved
if ($Service -eq $null) 
{
    throw "Service $ServiceName not found on computer $ComputerName"
}

Write-verbose "Service $ServiceName from $computerName retrieved"

$Service | Restart-Service

Write-output "Service $ServiceName from $computerName sucessfully restarted"

