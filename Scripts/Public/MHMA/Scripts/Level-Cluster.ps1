######### REMOTE VERSION! ##########
<#$Session = New-PSSession -ComputerName "DKHQVMTST02N01"

$ClusterData =
	{
		$CluData = Get-ClusterNode | select "Name"
		$CluData
	}

$VMData = 
	{
		$Data = Get-ClusterGroup | where {$_.GroupType -eq "VirtualMachine"}
		$Data
	}

$Cluster = Invoke-Command -Session $Session -ScriptBlock $ClusterData
$VMs = Invoke-Command -Session $Session -ScriptBlock $VMData
Remove-PSSession $Session#>

$Cluster = Get-ClusterNode
$VMs = Get-ClusterGroup | where {$_.GroupType -eq "VirtualMachine"}

foreach ($CluNode in $Cluster)
{
	if (Test-Path variable:$CluNode.Name)
	{ 
	}
	else
	{
		New-Variable -Name $CluNode.Name -Value @()
		[array]$Nodes += @($CluNode.Name)
	}
}

foreach ($vm in $VMs)
{
	$CurrentNode = $vm.OwnerNode
	<#if (Test-Path variable:$CurrentNode)
	{ 
	}
	else
	{
		New-Variable -Name $vm.OwnerNode -Value @()
		[array]$Nodes += @($CurrentNode)
	}#>
	
	Invoke-Expression "`$$CurrentNode += '$vm'"
}

[array]$TotalCount = $null

foreach ($node in $Nodes)
{
	$temp = Invoke-Expression "`$$node.count"
	$NodeCount += @{$node=$temp}
}

foreach ($value in $NodeCount.Values)
{
	$TotalCount += $value
}

$Avg = $TotalCount | Measure-Object -Average

foreach ($node in $Nodes)
{
	$CalcDiff = $null
	$Compare = Invoke-Expression "`$$node.count"
	$CalcDiff = $Compare - $Avg.Average
	
	if ($CalcDiff -le 0)
	{
		$abs = [Math]::Abs($CalcDiff)
		$round = [Math]::Floor($abs)
	}
	else
	{
		$abs = [Math]::Abs($CalcDiff)
		$round = [Math]::Ceiling($abs)
	}
	
	if ($round -ge 4)
	{	
		Write-Host -ForegroundColor Yellow "$node is too far above average"
		
		Write-Host -ForegroundColor Yellow "The number of guests available to move away from $node is: $round"
		Write-Host ""
		
		$Above += @{$node=$round}
	}
	if ($CalcDiff -le -2)
	{
		Write-Host -ForegroundColor Yellow "$node is too far below average"
		
		Write-Host -ForegroundColor Yellow "The number of guests to move over to $node is: $round"
		Write-Host ""
		
		$Below += @{$node=$round}
	}
}

foreach ($key in $Above.Keys)
{
	foreach ($obj in Invoke-Expression "`$$key")
		{
			if ($obj -notlike "*UAG*")
			{
				$PotentialMovers += @{$obj = 1}
			}
		}
		
	$Available += $Above.get_Item($key)
}

$Demand = $null
foreach ($obj in $Below.Keys)
{
	$Demand = $Demand + $Below.get_Item($obj)
}

foreach ($obj in $Below.Keys)
{
	$Movers += @{$obj = $PotentialMovers.Keys | Select-Object -First $Below.get_Item($obj)}
	foreach ($value in $Movers.get_Item($obj))
	{
		$PotentialMovers.Remove($value)
	}
}


foreach ($key in $Movers.Keys)
{
	foreach ($Mover in $Movers.get_Item($key))
	{
		Write-Host -ForegroundColor Red "Now moving $Mover to ClusterNode $key"
		#Move-ClusterVirtualMachineRole $Mover -MigrationType Live -Node $key -Wait 0
	}
}