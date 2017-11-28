    $pwd = Read-Host 'Enter Password' -AsSecureString
     
    $key = 1..32 | ForEach-Object { Get-Random -Maximum 256 } 
    write-host $key.GetType()
    $pwdencrypted = $pwd | ConvertFrom-SecureString -Key $key 
     write-host $pwdencrypted.GetType()
    $password = "{0}" -f $pwdencrypted
    $key = "{0}" -f "$key"
    #write-host $pwdencrypted
    #write-host $password
    write-host $key.GetType()