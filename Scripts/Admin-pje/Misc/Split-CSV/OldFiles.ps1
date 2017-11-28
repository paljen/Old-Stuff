
if(@(Get-ChildItem "c:\temp").count -cgt 2)
{
	$files | Where {$_.LastWriteTime -le [System.DateTime]::Now.AddDays(-7)}
}
