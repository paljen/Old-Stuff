param(
    [String]$filename = $args[0],
    [String]$dest = $args[1]
)

$password = "76492d1116743f0423413b16050a5345MgB8AEsAUABwAGMAZABiAHkAagB6AEkARwBlAE0ANQBhAHEAcABxADUAWABSAHcAPQA9AHwANgAwAGIAMwBkADgANgA2ADUAMgA4ADkAYwA5ADMAMwA2ADEAMABmADgAOQAwAGIANQA0ADkAZgA1ADYAZAAxADIAOQAxAGIAMQBjADQAYwBlAGQAYwBhADAAZgA4ADMAYQBhAGIANwA5ADUANgA0ADYAMwAyAGEANwA0ADAANwA="
$key = "160 190 175 209 253 168 24 196 181 17 30 137 49 145 168 40 101 145 39 46 55 211 21 146 75 171 138 149 42 11 151 63"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("Service-SCCM-NAC@prd.eccocorp.net", $passwordSecure)

$temp = "C:\windows\temp"

gwmi win32_QuickFixEngineering | Select CSName,InstalledBy,InstalledOn,Description,HotFixID | ConvertTo-Html | Out-File -FilePath "$temp\$filename"

$networkCred = $cred.GetNetworkCredential()
$password = "$($networkCred.SecurePassword)"

Invoke-Command -ScriptBlock {"net use $dest /USER:$networkCred.UserName $password"}
Copy-Item -Path "$temp\$filename" -Destination "$dest\$filename"
Invoke-Command -ScriptBlock {"net use $dest /delete"}