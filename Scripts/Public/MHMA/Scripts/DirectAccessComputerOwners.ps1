$compdata = Import-Csv C:\import\cmdb_ci_computer.csv
$DAdata = Import-Csv C:\Import\OldDirectAccess.csv

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Computer",([string]))
$Col2 = New-Object System.Data.DataColumn("PrimaryUser",([string]))
$Col3 = New-Object System.Data.DataColumn("AssignedTo",([string]))
$Col4 = New-Object System.Data.DataColumn("OS",([string]))
$Col5 = New-Object System.Data.DataColumn("InstallState",([string]))
$Col6 = New-Object System.Data.DataColumn("HardwareState",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)
$table.columns.add($Col5)
$table.columns.add($Col6)

foreach ($c in $compdata)
{
	foreach ($d in $DAdata)
	{
		if ($d.Name -eq $c.name)
		{
			$row = $table.NewRow();
			$row.Computer = $c.name
			$row.PrimaryUser = $c.u_primary_user
			$row.AssignedTo = $c.assigned_to
			$row.OS = $c.os
			$row.InstallState = $c.install_status
			$row.HardwareState = $c.hardware_status
			$table.Rows.Add($row);
		}
	}
}

$table | Export-Csv "C:\Report\DirectAccessCompUsers.csv" -NoTypeInformation