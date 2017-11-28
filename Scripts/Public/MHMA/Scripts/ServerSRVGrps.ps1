[string] $ServerName = $Env:COMPUTERNAME 
$Session = New-PSSession -ComputerName "DKHQDC02"
	$ScriptBlock = 
	{
		$loadedModules = Get-Module
		if ($loadedModules -like "ActiveDirectory")
		{
			#Do nothing
		}
		else
		{
			Import-Module ActiveDirectory
		}
		$Admin = "Srv-" + $args[0] + "-Admin"
		$PowerUser = "Srv-" + $args[0] + "-PowerUser"
		$Remote = "Srv-" + $args[0] + "-RemoteDesktop"
		New-ADGroup -Name $Admin -GroupCategory Security -GroupScope Global -Path "OU=SERVER ADMIN ROLES,OU=CENTRALLY MANAGED,OU=GROUPS,DC=prd,DC=eccocorp,DC=net"
		New-ADGroup -Name $PowerUser -GroupCategory Security -GroupScope Global -Path "OU=SERVER ADMIN ROLES,OU=CENTRALLY MANAGED,OU=GROUPS,DC=prd,DC=eccocorp,DC=net"
		New-ADGroup -Name $Remote -GroupCategory Security -GroupScope Global -Path "OU=SERVER ADMIN ROLES,OU=CENTRALLY MANAGED,OU=GROUPS,DC=prd,DC=eccocorp,DC=net"
	}

	Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ArgumentList $ServerName
	Remove-PSSession $Session
	$Session = $null

Write-Host "Waiting 20 seconds"
Start-Sleep -Seconds 20

$GroupTypes = @{"Administrators" = "-Admin"; "Power Users" = "-PowerUser"; "Remote Desktop Users" = "-RemoteDesktop"}
	foreach ($GroupType in $GroupTypes.GetEnumerator())
	{				
		[string]$domainName = ([ADSI]'').name
		$GroupName = "Srv-" + $ServerName + $GroupType.Value
		$Correlated = "WinNT://" + $ServerName + "/" + $GroupType.Name + ",group"
    		([ADSI]"$Correlated").Add("WinNT://$domainName/$GroupName")
	}
