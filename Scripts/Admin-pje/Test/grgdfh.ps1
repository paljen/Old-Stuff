## Encrypted Credentials Code Generator
$path = 'c:\windows\temp\template.ps1'
New-Item -ItemType File $path -Force -ErrorAction SilentlyContinue  
  
$pwd = Read-Host 'Enter Password' -AsSecureString  
$user = Read-Host 'Enter Username'  
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 }  
$pwdencrypted = $pwd | ConvertFrom-SecureString -Key $key 
  
$private:ofs = ' '  
('$password = "{0}"' -f $pwdencrypted) | Out-File $path  
('$key = "{0}"' -f "$key") | Out-File $path -Append  
  
'$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))' | Out-File $path -Append  
('$cred = New-Object system.Management.Automation.PSCredential("{0}", $passwordSecure)' -f $user) | Out-File $path -Append  
  
$EncryptedAccount = @'
'@

#$EncryptedAccount | Out-File $path -Append
ise $path

Get-Content $path | foreach {$EncryptedAccount += "$($_)`n"}

New-IseSnippet -Force -Title "test1" -Description "Basic script template including logging" -Author "Palle Jensen" -CaretOffset 100 -Text $EncryptedAccount

$password = "76492d1116743f0423413b16050a5345MgB8AGwAagByAEwAYgBWAFAAOQBKAGQAVgAwADYAUAAzAE4AaQBNAFAAbgBRAHcAPQA9AHwAZQBhADUAOABlAGIAOABlAGEAOQAxADIAOQBjAGQAZgBkADUAMgAwADAANAAyAGQAYgBmAGIAMwBjAGQANAAwAA=="
$key = "125 126 237 148 204 82 186 235 86 126 164 153 209 107 236 189 114 226 195 153 9 234 247 36 62 172 236 125 73 14 4 68"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("test", $passwordSecure)
