invoke-command {
    $members = net localgroup administrators | 
    where {$_ -and $_ -notmatch "command completed successfully"} | 
    select -skip 4
    
    New-Object PSObject -Property @{
        Computername = $env:COMPUTERNAME
        Group = "Administrators"
        Members=$members
     }
} -computer dkhqscorch01,dkhqdc01 -HideComputerName | select * -ExpandProperty Members -ExcludeProperty RunspaceId 

<#
foreach ($c in $comps)
{
    "$($c.Computername)`t$($c.Group)`t$([Array]$($c.Members  -split "`t") -join "`n`t`t")" | Out-EccoExcel
     
}#>
