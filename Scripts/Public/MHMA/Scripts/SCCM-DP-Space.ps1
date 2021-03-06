$data = import-csv C:\Import\SCCMdistributionPoints.csv
$Filter = "*"

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("ComputerName",([string]))
$Col2 = New-Object System.Data.DataColumn("Drive",([string]))
$Col3 = New-Object System.Data.DataColumn("FreeSpace",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)
$table.columns.add($Col3)

foreach($c in $data)
        {
            try 
            {
                gwmi win32_volume -ComputerName $c.Servername -ErrorAction Stop | Where {$_.DriveLetter -Like "$filter*"} | ForEach-Object {
                
                    $props = [Ordered]@{'Computername'=$c.Servername}
                    $props.add('Label',$_.Name)
                    $props.add('FreeSpace GB',($_.FreeSpace / 1GB -as [int]))

                    $obj = New-Object -TypeName PSObject -Property $props
                    
					$row = $table.NewRow();
					$row.ComputerName = $obj.Computername
					$row.Drive = $obj.Label
					$row.FreeSpace = $obj."FreeSpace GB"
					$table.Rows.Add($row);
                }
            }

            catch
            {
                Write-Output "$c.Servername`: $($_.Exception.Message)"
                
            }
            
        }
		
		
		$table | Export-Csv "C:\Report\SCCM-DP-Space.csv" -NoTypeInformation