filter Homedir
{
    $input | where {
        $_.HomeDirectory -eq $null -and 
        $_.Enabled -eq $true -and
        $_.GivenName -ne $null -and
        $_.GivenName -notmatch "kursus" -and
        $_.GivenName -notmatch "test" -and
        $_.GivenName -inotmatch "MUL-" -and
        $_.GivenName -inotmatch "CON-" -and
        $_.GivenName -notmatch "admin" -and
        $_.GivenName -notmatch "pilot"
        #samaccountname -gt 6
    }
}

#(Get-ADUser -filter * -properties HomeDirectory -SearchBase "OU=Ecco,dc=prd,dc=eccocorp,dc=net").count
#(Get-ADUser -filter * -properties HomeDirectory -SearchBase "OU=Ecco,dc=prd,dc=eccocorp,dc=net" | Homedir).count
Get-ADUser -filter * -properties HomeDirectory, DisplayName -SearchBase "OU=Ecco,dc=prd,dc=eccocorp,dc=net" | Homedir | select Displayname,Givenname, SamaccountName | Out-EccoExcel
#$(dir -force -recurse) | Measure-Object -Property length -Sum | select @{l='Sum Mb';e={$_.sum/1MB}}

<#
$path = Split-Path -Parent $MyInvocation.MyCommand.Definition

$userDN = get-aduser "PJETESTUSER" -Properties SamAccountName,DistinguishedName | select SamAccountName,DistinguishedName

$fixedStrCount = 34
$startindex = ($userDN.DistinguishedName).Length-$fixedStrCount
$pattern = ($userDN.DistinguishedName).Remove($startindex,$fixedStrCount)
$pattern = $pattern.substring($pattern.Length-2,2)
$pattern = "^$pattern"
$pattern

$sel = Select-String -Pattern $pattern -Path "$path\HomeDirServereTest.txt" -CaseSensitive

if($sel.Matches.Count -eq 1)
{
    $userDN = $userDN | Add-Member @{Share=(($sel.Line -replace "$pattern=","").TrimStart())} -PassThru
    #Set-aduser $userDN.SamAccountName -HomeDrive "H:" -HomeDirectory $userDN.Share
    #"Set-aduser $($userDN.SamAccountName) -HomeDrive 'H:' -HomeDirectory $($userDN.Share)"

}
elseif ($sel.Matches.Count -gt 1)
{
    $sel
    Write-host "To many Servers"
}
else
{
    Write-host "No server Available"
}
#>