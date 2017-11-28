param(
    [String]$filename = $args[0],
    [String]$dest = $args[1]
)

$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
<title>
Client Report
</title>
"@

$password = "76492d1116743f0423413b16050a5345MgB8AEsAUABwAGMAZABiAHkAagB6AEkARwBlAE0ANQBhAHEAcABxADUAWABSAHcAPQA9AHwANgAwAGIAMwBkADgANgA2ADUAMgA4ADkAYwA5ADMAMwA2ADEAMABmADgAOQAwAGIANQA0ADkAZgA1ADYAZAAxADIAOQAxAGIAMQBjADQAYwBlAGQAYwBhADAAZgA4ADMAYQBhAGIANwA5ADUANgA0ADYAMwAyAGEANwA0ADAANwA="
$key = "160 190 175 209 253 168 24 196 181 17 30 137 49 145 168 40 101 145 39 46 55 211 21 146 75 171 138 149 42 11 151 63"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("Service-SCCM-NAC@prd.eccocorp.net", $passwordSecure)

$temp = "C:\windows\temp"
$networkCred = $cred.GetNetworkCredential()

gwmi -Namespace root\ccm\ClientSDK -Class ccm_application | select FullName | ConvertTo-Html -Head $header -Body "<H2>Installed Applications</H2>" | Out-File -FilePath "$temp\$filename"
gwmi win32_QuickFixEngineering | Select CSName,InstalledBy,InstalledOn,Description,HotFixID | ConvertTo-Html -Head $header -Body "<H2>Installed Patches</H2>" | Out-File -FilePath "$temp\$filename" -Append
Get-AppxPackage -AllUsers | Select Name | ConvertTo-Html -Head $header -Body "<H2>AppxPackage</H2>" | Out-File -FilePath "$temp\$filename" -Append
Get-AppxProvisionedPackage -Online | Select PackageName | ConvertTo-Html -Head $header -Body "<H2>AppxProvisionedPackage</H2>" | Out-File -FilePath "$temp\$filename" -Append


$net = new-object -ComObject WScript.Network
$net.MapNetworkDrive("Z:", $dest, $false, $($networkCred.UserName),$($networkCred.Password))
Copy-Item -Path "$temp\$filename" -Destination "$dest\$filename"
$net.RemoveNetworkDrive("Z:")