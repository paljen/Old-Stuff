$ErrorActionPreference = 'SilentlyContinue'
$servers = Get-QADComputer -SearchRoot 'prd.eccocorp.net/MEMBER SERVERS'

#Build datatable
$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("Server",([string]))
$Col2 = New-Object System.Data.DataColumn("PR",([string]))
$Col3 = New-Object System.Data.DataColumn("Data1",([string]))
$Col4 = New-Object System.Data.DataColumn("Data2",([string]))
$Col5 = New-Object System.Data.DataColumn("Data3",([string]))
$Col6 = New-Object System.Data.DataColumn("Data4",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)
$table.columns.add($Col4)
$table.columns.add($Col5)
$table.columns.add($Col6)

foreach ($server in $servers)
{
	$netstat = $null
	$aridx = $null
	
	if ($server.Name -like "DK*")
	{
		try
		{
			$Session = New-PSSession -ComputerName $server.Name
			
			$SB =
			{
				netstat -rn	
			}
			
			$netstat = Invoke-Command -Session $Session -ScriptBlock $SB
			Remove-PSSession $Session
			
			$aridx = [array]::IndexOf($netstat,"Persistent Routes:")
			$row = $table.NewRow();
			$row.Server = $server.Name
			$row.PR = $netstat[$aridx]
			
			if ($netstat[$aridx+1] -ne "None")
			{
				$row.Data1 = $netstat[$aridx+2]
				$row.Data2 = $netstat[$aridx+3]
				$row.Data3 = $netstat[$aridx+4]
				$row.Data4 = $netstat[$aridx+5]
			}
			else
			{
				$row.Data = $netstat[$aridx+1]
			}
			$table.Rows.Add($row)
		}
		catch
		{
			$row = $table.NewRow();
			$row.Server = $server.Name
			$row.PR = "-"
			$row.Data1 = "Could Not Connect"
			$table.Rows.Add($row)
		}
	}
}

$table | Export-Csv "C:\Test\PersistantRoutes.csv" -NoTypeInformation