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
    "Set-aduser $($userDN.SamAccountName) -HomeDrive 'H:' -HomeDirectory $($userDN.Share)"

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
