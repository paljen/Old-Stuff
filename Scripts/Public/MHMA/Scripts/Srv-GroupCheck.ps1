$Data = Get-ADComputer -Filter * -SearchBase "OU=MEMBER SERVERS,DC=prd,DC=eccocorp,DC=net"

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Servername",([string]))
$Col2 = New-Object System.Data.DataColumn("AdminGrp",([string]))
$Col3 = New-Object System.Data.DataColumn("PowerUserGrp",([string]))
$Col4 = New-Object System.Data.DataColumn("RemoteDesktopGrp",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)

foreach ($Obj in $Data)
{
	$Groups = $null

	$row = $table.NewRow();
	$row.Servername = $Obj.Name
	$row.AdminGrp = "No Admin Group Found"
	$row.PowerUserGrp = "No PowerUser Group Found"
	$row.RemoteDesktopGrp = "No RemoteDesktop Group Found"
	
	$ADGrp = "Srv-" + $Obj.Name + "*"
	
	try
	{
		$Groups = Get-ADGroup -Filter {Name -like $ADGrp}
		
		if ($Groups -eq $null)
		{
			$row.AdminGrp = "No Groups Found"
			$row.PowerUserGrp = "No Groups Found"
			$row.RemoteDesktopGrp = "No Groups Found"
		}
		
		else
		{
			foreach ($Group in $Groups)
			{
				if ($Group.Name -like "*Admin*")
				{
					$row.AdminGrp = $Group.Name
				}
				elseif ($Group.Name -like "*Power*")
				{
					$row.PowerUserGrp = $Group.Name
				}
				elseif ($Group.Name -like "*Remote*")
				{
					$row.RemoteDesktopGrp = $Group.Name
				}
			}
		}
	}
	catch
	{
		$row.AdminGrp = "Error"
		$row.PowerUserGrp = "Error"
		$row.RemoteDesktopGrp = "Error"
	}
	
	$table.Rows.Add($row)
}

$table | Export-Csv "C:\Test\SrvGroups.csv" -NoTypeInformation