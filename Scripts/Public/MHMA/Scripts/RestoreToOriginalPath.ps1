$Files = Get-ChildItem \\DKHQFILE01\h$\Restore\ -Recurse | where {$_.PSIsContainer -eq $false} #| Select-Object -First 70
$counter = 0
foreach ($file in $Files)
{
	$SubPath = $file.FullName.Substring(23)
	$Root = "\\DKHQFILE01\j$\Shared Data\DKSM-Common"
	
	$FullPath = $Root + $SubPath + ".encrypted"
	
	[bool]$TestPath = Test-Path $FullPath
	
	if ($TestPath -eq $true)
	{
		$tbd = Get-ChildItem $FullPath

		Copy-Item -Path $file.FullName -Destination $tbd.Directory
		Remove-Item $FullPath -Force
	}
}