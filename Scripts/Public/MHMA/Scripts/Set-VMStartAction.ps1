Write-Progress -Activity "Gathering VMs"
#Get all current VM's
$VMs = Get-VM
[bool]$HasDC = $null
$DCcounter = 0
$VMcounter = 0

Write-Progress -Activity "Finding Domain Controllers" -CurrentOperation "Searching data"
#Loop through VM's, find DC if any
foreach ($v in $VMs)
{
	$DCcounter++
	if ($v.Name -like "*DC*")
	{
		Write-Progress -Activity "Finding Domain Controllers" -CurrentOperation "Domain Controller found, setting bool value to true" -PercentComplete (($DCcounter / $VMs.count) * 100)
		$HasDC = $true
	}
	else
	{
		Write-Progress -Activity "Finding Domain Controllers" -CurrentOperation "Searching data" -PercentComplete (($DCcounter / $VMs.count) * 100)
	}
}

foreach ($v in $VMs)
{
	$VMcounter++
	
	if ($HasDC -eq $true)
	{
		if ($v.Name -like "*DC*")
		{
			Write-Progress -Activity "Setting VM Startup Options" -CurrentOperation "Processing Domain Controller $v.Name" -PercentComplete (($VMcounter / $VMs.count) * 100)
			Set-VM $v -AutomaticStartAction Start -AutomaticStartDelay 0
		}
		else
		{
			Write-Progress -Activity "Setting VM Startup Options" -CurrentOperation "Processing VM $v.Name" -PercentComplete (($VMcounter / $VMs.count) * 100)
			Set-VM $v -AutomaticStartAction Start -AutomaticStartDelay 200
		}
	}
	else
	{
		Write-Progress -Activity "Setting VM Startup Options" -CurrentOperation "Processing VM $v.Name" -PercentComplete (($VMcounter / $VMs.count) * 100)
		Set-VM $v -AutomaticStartAction Start -AutomaticStartDelay 120
	}
}

$New = Get-VM
Write-Host "----SUMMARY----"
$New | select Name, AutomaticStartAction, AutomaticStartDelay | ft -AutoSize