#$users = "uj","dnk","amta"
$user = @()
$output = @()

#foreach ($u in $users)
#{
    $user = get-mailbox -ResultSize Unlimited | select displayname,emailaddresses    
#}

$user | ForEach-Object {
    $name = (($_.displayname).replace(" ","_")) -split "_" | select -First 1

    $output += $user | ForEach-Object {
    
        $_.EmailAddresses | ForEach-Object {
        
            $_ | where {$_ -like "smtp:$name*"}
        
        }
    }

}

$output | Out-GridView
