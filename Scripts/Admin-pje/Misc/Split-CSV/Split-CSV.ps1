
$csvFile = "C:\Scripts\ECCO\Projects\Misc\Split-CSV\Userswithlicense.csv"
$dstFile = "C:\Scripts\ECCO\Projects\Misc\Split-CSV\Files"

$split = 100
$csv = Import-csv $csvFile
$count = ($csv | Measure-Object).Count
$steps = [System.Math]::Ceiling($count/$split)

for ($i = 0; $i -lt $steps ; $i++)
{ 
    $count
    if ($count -ge $split)
    {
        $count -= $split
        $csv | select -Last $split | export-csv "$dstFile\UserWithLicense$i.csv" -NoTypeInformation
        $csv | select -First $count | export-csv "$dstFile\temp.csv" -NoTypeInformation -Force
        $csv = Import-csv "$dstFile\temp.csv"
    }
    else
    {
        $csv | export-csv "$dstFile\UserWithLicense$i.csv" -NoTypeInformation
        Remove-Item "$dstFile\temp.csv" -Force
    }

    
}