$data = Import-Csv 'C:\Import\SEC-Global PORTAL NEWS LOCATION.csv'

foreach ($d in $data)
{	
	$GroupName = $d.Group
	$Ngrp = "N_" + $GroupName
	$Ogrp = "O_" + $GroupName
	
	$Members = Get-ADGroupMember -Identity $GroupName | Select Name, SamAccountName
	$file = $GroupName
	$folder = "C:\Report\Portal\"
	$path = $folder + $file + ".csv"
	
	$Members | Export-Csv $path -NoTypeInformation -Encoding Unicode
	
	$N_Members = Get-ADGroupMember -Identity $Ngrp | Select Name, SamAccountName
	$file = $Ngrp
	$folder = "C:\Report\Portal\"
	$path = $folder + $file + ".csv"
	
	$N_Members | Export-Csv $path -NoTypeInformation -Encoding Unicode
	
	$O_Members = Get-ADGroupMember -Identity $Ogrp | Select Name, SamAccountName
	$file = $Ogrp
	$folder = "C:\Report\Portal\"
	$path = $folder + $file + ".csv"
	
	$O_Members | Export-Csv $path -NoTypeInformation -Encoding Unicode
}