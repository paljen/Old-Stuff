#$shares = Get-WmiObject -Class Win32_Share -ComputerName "DKHQFILE01"

$lastYear = (Get-Date).AddDays(-365)

$CurrentShare = "C:\Users\mhma\Downloads" #"\\"+$share.PSComputerName+"\"+$share.Name
$files = Get-ChildItem $CurrentShare | Where-Object {$_.LastAccessTime -le $lastYear}

$files | Select-Object Name, @{Label='SizeMB'; Expression={"{0:N0}" -f ($_.Length/1MB)}} , DirectoryName,  Length, LastAccessTime | Sort-Object Length -Descending  | Select-Object Name, DirectoryName, SizeMB, LastAccessTime | Format-Table -AutoSize -Wrap

<#foreach ($share in $shares)
{
	if ($share.Type -eq 0)
	{
		$CurrentShare = "C:\Users\mhma\Downloads" #"\\"+$share.PSComputerName+"\"+$share.Name
		$files = Get-ChildItem $CurrentShare | Where-Object {$_.LastAccessTime -le $$lastYear}
	}
}#>



#| Select-Object Name, @{Label='SizeMB'; Expression={"{0:N0}" -f ($_.Length/1MB)}} , DirectoryName,  Length | Sort-Object Length -Descending  | Select-Object Name, DirectoryName, SizeMB -First $Top | Format-Table -AutoSize -Wrap