$jiradata = Import-Csv c:\Powershell\Jira\JiraDataTest.csv
$scsmfile = "c:\powershell\Jira\scsmdata.csv"
[String]$Impact

foreach ($item in $jiradata) {
	#$item
	
	$scsmhash = @{}
	switch($item.priority)
	{
		"minor" {$scsmhash.impact="low"}
	}
	$scsmhash.Title = $item.summary
	$scsmhash.Description = $item.Description
	$scsmhash.Source = "IncidentSourceEnum.Console"
	$scsmhash.status = "IncidentStatusEnum.Active"
	$scsmhash.classification = "IncidentClassificationEnum.Andet"
	$object = New-Object -TypeName psobject –Prop $scsmhash
	ConvertTo-Csv -InputObject $object -NoTypeInformation | Out-File c:\Powershell\Jira\scsmdata.csv
	
}


#$scsm = @{}
#$scsm.impact=$os.BuildNumber
#$info.OSVersion=$os.version
#$info.BIOSSerial=$bios.SerialNumber
