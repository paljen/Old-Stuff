
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

gwmi -Namespace root\ccm\ClientSDK -Class ccm_application | select FullName, InstallState | ConvertTo-Html -Head $header -Body "<H2>Installed Applications</H2>" | Out-File -FilePath C:\TEMP\test.html
gwmi win32_QuickFixEngineering | Select CSName,InstalledBy,InstalledOn,Description,HotFixID | ConvertTo-Html -Head $header -Body "<H2>Installed Patches</H2>" | Out-File -FilePath C:\TEMP\test.html -Append

Invoke-Expression C:\TEMP\test.html