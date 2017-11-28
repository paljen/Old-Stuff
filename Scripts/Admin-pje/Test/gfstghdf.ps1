
$users = Get-ADUser -Filter * -Properties Telephonenumber | select name, telephonenumber

$users -match "74911849"



foreach ($user in $users)
{   
    if($user.Telephonenumber -ne $null -and $user.Telephonenumber -match "[+]\d*")
    {
        $tlf = [String]$user.telephonenumber
        #$tlf = $tlf.replace("+","")
        #Write-host $tlf       
        
        $match = $users.telephonenumber -eq $tlf
        #$res.Add($user.name)
        #$res.Count
        if($match.Count -gt 1)
        {
           $tlf = $match | select -First 1
           $usr = $users | ?{$_.telephonenumber -eq $tlf -and $_.name -ne $user.name} | select name
           Write-host "$($user.name) has same telephonenumber as $($usr.name)"
        }
    }
    <#
    if($user.telephonenumber -ne $null)
    {
        $tlf =  [String]$user.telephonenumber
        $tlf
     
        $count = (Get-ADUser -Properties Telephonenumber).Telephonenumber | ? {$($_.Telephonenumber) -match $user.telephonenumber}
        
        write-host $count
        #if($tlf -match "74911849" )
        #{
        #      $user.name
        #}
    }#>
    
}
#>
<#
if(($($users.Telephonenumber) -contains (Get-ADUser emn -Properties Telephonenumber).telephonenumber))
{
    
    
}#>

#$contains = Get-ADUser -Filter * -Properties Telephonenumber | ? {$($users.Telephonenumber) -contains $_.Telephonenumber -and $users.Name -not}
#$contains.count