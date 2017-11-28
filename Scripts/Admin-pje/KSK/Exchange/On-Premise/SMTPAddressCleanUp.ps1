#$users = "dnk","uj","amta"
$user = @()
#$file = "$(split-path -parent $MyInvocation.MyCommand.Definition)\Output3.txt"

#foreach ($u in $users)
#{
#    $user += get-mailbox -Identity $u | select Samaccountname,displayname,emailaddresses    
#}

$user = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | select SamAccountName,DisplayName,EmailAddresses

$user | ForEach-Object {
    
    $sam = $_.SamAccountName
    $name = (($_.displayname).replace(" ","_")) -split "_" | select -First 1
    $name = "smtp:$($name)_*"
    
    $_.EmailAddresses | where {$_ -like $name -and $_ -notlike "smtp:CAS_{*" -and $_ -notlike "smtp:ArchiveMgr_*"} | ForEach-Object {    
        Set-Mailbox -Identity $sam -EmailAddresses @{remove=$_}
    }
}