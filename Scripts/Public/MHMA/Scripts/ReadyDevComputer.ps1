[string] $ServerName = $Env:COMPUTERNAME 
$Site = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
$DC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindDomainController($Site)

	$Session = New-PSSession -ComputerName $DC.Name
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
		$Admin = "Dev-" + $args[0] + "-Admin"
		$PowerUser = "Dev-" + $args[0] + "-PowerUser"
		$Remote = "Dev-" + $args[0] + "-RemoteDesktop"
		New-ADGroup -Name $Admin -GroupCategory Security -GroupScope Global -Path "OU=COMPUTER ADMIN ROLES,OU=GROUPS,OU=DEVELOPMENT,DC=prd,DC=eccocorp,DC=net"
		New-ADGroup -Name $PowerUser -GroupCategory Security -GroupScope Global -Path "OU=COMPUTER ADMIN ROLES,OU=GROUPS,OU=DEVELOPMENT,DC=prd,DC=eccocorp,DC=net"
		New-ADGroup -Name $Remote -GroupCategory Security -GroupScope Global -Path "OU=COMPUTER ADMIN ROLES,OU=GROUPS,OU=DEVELOPMENT,DC=prd,DC=eccocorp,DC=net"
	}

	Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ArgumentList $ServerName
	Remove-PSSession $Session
	$Session = $null
	
	
	
	$GroupTypes = @{"Administrators" = "-Admin"; "Power Users" = "-PowerUser"; "Remote Desktop Users" = "-RemoteDesktop"}
	foreach ($GroupType in $GroupTypes.GetEnumerator())
	{				
		[string]$domainName = ([ADSI]'').name
		$GroupName = "Dev-" + $ServerName + $GroupType.Value
		$Correlated = "WinNT://" + $ServerName + "/" + $GroupType.Name + ",group"
    	([ADSI]"$Correlated").Add("WinNT://$domainName/$GroupName")
	}
	


