#Import-Csv C:\Scripts\ECCO\Test\test.csv | ForEach-Object {($_.LastName).Replace("'","(")}

$pocketknife = New-Object -TypeName PSObject
Add-Member -Name Color -Value Red -MemberType NoteProperty -InputObject $pocketknife
Add-Member -Name Weight -Value 55 -MemberType NoteProperty -InputObject $pocketknife
Add-Member -InputObject $pocketknife -MemberType NoteProperty Manufacturer Idera
$pocketknife | Add-Member -MemberType NoteProperty Blades 3

Add-Member -MemberType ScriptMethod -InputObject $pocketknife -Name Cut -Value {"Cutting"}
$pocketknife | Add-Member -MemberType ScriptMethod Screw {"Done!"}
$pocketknife.cut.Script
$pocketknife.cut.OverloadDefinitions



