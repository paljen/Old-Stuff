$password = "76492d1116743f0423413b16050a5345MgB8AHAAdQBCAGwAaQBqAC8ANQBYAHQAZQBwAHQAVwBnAGUAdQBKAHIAUQBzAHcAPQA9AHwAYgA2AGUANwAzADQAMABkAGEANAA3AGMAOAAyADEANQA0ADMAMwBlAGEAOABmADEAMABkADQAYwA3AGUAYQBhAGEAYwAxADUANgA1ADgAOQAxADEAOABlADEAMAA3ADgAYQA1AGIAYgBiAGUAYQBmADUAOQAzADkAYgBlAGMAZgAwADUAMwA0AGYANABiADUAOAAzAGIANwAwADAAZQA2ADkAMwBhADIAMQBmADkANwBhADgAMAA3ADAANwA5AGQA"
$key = "60 243 190 189 12 33 209 178 246 152 202 52 81 161 122 47 88 114 64 20 159 65 34 198 26 150 61 161 40 139 23 119"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("prd\Service-SCORCHRAA", $passwordSecure)
$session = New-PSSession -ConnectionUri https://dkhquc02n01.prd.eccocorp.net/OcsPowershell -Credential $cred

Import-PSSession $session
$obj = get-csuser pje
$obj | gm
#Remove-PSSession $session