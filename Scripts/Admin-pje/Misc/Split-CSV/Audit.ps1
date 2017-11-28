## Prd.eccocorp.net admins
<#
get-ADGroupMember -Identity administrators | ? {$_.objectclass -eq "group" -and $_.DistinguishedName -match "DC=prd,DC=eccocorp,DC=net"} | ForEach-Object {
    
    $_.Name
    
    Get-ADGroupMember -Identity $_.Name | ForEach-Object {
        "`t$($_.Name)"
    }
}#>

## eccocorp.net


## local admins
invoke-command {
    $members = net localgroup administrators |  where {$_ -and $_ -notmatch "command completed successfully"} | select -skip 6
    New-Object PSObject -Property @{
    Computername = $env:COMPUTERNAME
    Group = "Administrators"
    Members=$members
    }
} | ForEach-Object {$_.members}
