$data = Import-Csv -Path "C:\Import\DeleteMaster.csv" -Delimiter "|"

<#foreach ($file in $data)
{
	Remove-Item -Path $file.FullName
}#>