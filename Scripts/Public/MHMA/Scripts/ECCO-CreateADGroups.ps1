Function Create-Groups
{
	foreach ($d in $Data)
	{
		New-ADGroup -Name $d.Name -GroupCategory Security -GroupScope Global -Path $d.OU
		Write-Output "Creating $($d.Name) in $($d.OU)"
	}
	
	Write-Output "Suspending thread for 10 seconds"
	Sleep -Seconds 10
	
	foreach ($d in $Data)
	{
		#Create O/N Groups
		$O_Name = "O_" + $d.Name
		$N_Name = "N_" + $d.Name
		
		New-ADGroup -Name $O_Name -GroupCategory Security -GroupScope Global -Path $d.OU
		New-ADGroup -Name $N_Name -GroupCategory Security -GroupScope Global -Path $d.OU
		Write-Output "Creating $($O_Name) in $($d.OU)"
		Write-Output "Creating $($N_Name) in $($d.OU)"
		
		#Nest groups
		Add-ADGroupMember $d.Name -Members $O_Name,$N_Name
		Write-Output "Adding $($O_Name) and $($N_Name) as members of $($d.Name)"
	}
}

Function Get-FileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$input = Get-FileName
$Data = import-csv $input -Delimiter ";"
Create-Groups