Import-Module ActiveDirectory

$RDCol = Get-RDSessionCollection
$RDUserGroups = New-Object System.Collections.ArrayList

$table = New-Object System.Data.DataTable
$Col1 = New-Object System.Data.DataColumn("UserName",([string]))
$Col2 = New-Object System.Data.DataColumn("Collection",([string]))
$table.columns.add($Col1)
$table.columns.add($Col2)

Function Enm-Collections
{
	foreach ($r in $RDCol)
	{
		$GrpData = Get-RDSessionCollectionConfiguration -CollectionName $r.CollectionName -UserGroup
		$RDUserGroups.Add($GrpData)
	}
}

function Enm-GroupMembers
{
	foreach ($g in $RDUserGroups)
	{
		$GroupName = $g.UserGroup.trimstart("PRD\")
		
		foreach ($Grp in $GroupName)
		{
			$ADusers = Get-ADGroup -Identity $Grp | Get-ADGroupMember -Recursive
			
			foreach ($a in $ADusers)
			{
				$row = $table.NewRow();
				$row.UserName = $a.SamAccountName
				$row.Collection = $g.CollectionName
				$table.Rows.Add($row);
			}	
		}
	}
}

Enm-Collections
Enm-GroupMembers

$table | Export-Csv C:\Report\RDSUsers.csv -NoTypeInformation -Encoding utf8