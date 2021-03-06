# ECCO Shoes A/S - Server Post Deployment Script
# Written by Michael Hjort Madsen / IT Specialist / MHMA@ECCO.COM
#
# PS> ./PostDeploy.ps1 <servername> 
# Execute from folder where the script is located, on the server you're doing Post-Deployment on, with administrative priviledges.

#----------------------- Construct -----------------------#
#Sets $ServerName to computer hostname and finds the nearest DC based on Site

Set-ExecutionPolicy Unrestricted
[string] $ServerName = $Env:COMPUTERNAME 
$Site = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
$DC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindDomainController($Site)

[bool]$ADGrp = $false
[bool]$SCCM = $false
[bool]$Patch = $false
[bool]$LclGrp = $false

#----------------------- Start of Post Deployment Actions -----------------------#
#Create groups in AD, Install SCCM and SCOM agents, Choose Patch Groups and populate the groups locally on the server, with the groups created in step 1

Write-Progress -Activity "Deployment for $ServerName" -Status "Creating ActiveDirectory Server Groups" -CurrentOperation "10% Complete" -PercentComplete 10

if ($ServerName -ne "") 
{
	#Clear runspace
   	#cls
    #Write-Host -ForegroundColor green "Starting post deployment for $ServerName";
	#Write-Host ""
	#Write-Host -ForegroundColor Yellow "Creating ActiveDirectory Server Groups"



	#----------------------- Create Server Admin Groups -----------------------#
	#This creates a Remote PowerShell Session to the closest DC, and executes the contents of the ScriptBlock
	#The ScriptBlock includes the creation of all Srv groups in AD. The $ServerName variable is passed over as an argument, available as $args[0]
	
	$result = $null
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
		
		try
		{
			$Admin = "Srv-" + $args[0] + "-Admin"
			Get-ADGroup $Admin
		}
		catch
		{
			$Admin = "Srv-" + $args[0] + "-Admin"
			New-ADGroup -Name $Admin -GroupCategory Security -GroupScope Global -Path "OU=SERVER ADMIN ROLES,OU=CENTRALLY MANAGED,OU=GROUPS,DC=prd,DC=eccocorp,DC=net"
		}
		try
		{
			$PowerUser = "Srv-" + $args[0] + "-PowerUser"
			Get-ADGroup $PowerUser
		}
		catch
		{
			$PowerUser = "Srv-" + $args[0] + "-PowerUser"
			New-ADGroup -Name $PowerUser -GroupCategory Security -GroupScope Global -Path "OU=SERVER ADMIN ROLES,OU=CENTRALLY MANAGED,OU=GROUPS,DC=prd,DC=eccocorp,DC=net"
		}
		try
		{
			$Remote = "Srv-" + $args[0] + "-RemoteDesktop"
			Get-ADGroup $Remote
		}
		catch
		{
			$Remote = "Srv-" + $args[0] + "-RemoteDesktop"
			New-ADGroup -Name $Remote -GroupCategory Security -GroupScope Global -Path "OU=SERVER ADMIN ROLES,OU=CENTRALLY MANAGED,OU=GROUPS,DC=prd,DC=eccocorp,DC=net"
		}
	}

	$result = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ArgumentList $ServerName
	Remove-PSSession $Session
	$Session = $null
	
	if ($result -eq $False)
	{
		$ADGrp = $false
	}
	else
	{
		$ADGrp = $true
	}
	
	#----------------------- END OF ACTION -----------------------#



	#----------------------- Install SCCM Agent -----------------------#
	#This runs the ccmsetup.cmd located on DKHQSCCM02. This sometimes fails due to latency
	#Since it's running a .cmd file, you will get a security warning. So be aware that you need to click on the Run button
	
	Write-Progress -Activity "Deployment for $ServerName" -Status "Triggering SCCM Agent Installation (Please click Run at the security prompt)" -CurrentOperation "25% Complete" -PercentComplete 25
		
	$result = $null
	#Write-Host ""
	#Write-Host -ForegroundColor Yellow "Triggering SCCM Agent Installation";
	#Write-Host -ForegroundColor Red "This will require user interaction! Please click Run on the security prompt"
	$result = Test-Path "C:\Windows\CCM\"
	
	if ($result -eq $false)
	{
		Start-Process -FilePath "\\DKHQSCCM02\CMClient\ccmsetup.cmd" -WindowStyle Hidden
		Start-Sleep -Seconds 5
	}
	
	if ($result -eq $False)
	{
		$SCCM = $false
	}
	else
	{
		$SCCM = $true
	}
	
	#----------------------- END OF ACTION -----------------------#



	<#----------------------- Install SCOM Agent -----------------------#
	#This creates a Remote PowerShell Session to DKHQSCOM01, because we do not have the SCOM PS Modules installed locally
	#Depending on the location of the server, a different PrimaryManagementServer is selected, and the agent is pushed to the server
	#$ServerName is once again passed to the remote session, available as $args[0]
	
	Write-Host ""
	Write-Host -ForegroundColor Yellow "Triggering SCOM Agent Installation";

	if ($ServerName -like "DK*")
	{
		Write-Host -ForegroundColor Cyan "INFO: Server located in DK"
		$RemoteSession = New-PSSession -ComputerName "DKHQSCOM01"
		$SB = 
		{
			Import-Module OperationsManager
			$PrimaryMgmtServer = Get-SCOMManagementServer | Where {$_.Name -match 'DKHQSCOM01.prd.eccocorp.net'}
			Install-SCOMAgent -DNSHostName $args[0] -PrimaryManagementServer $PrimaryMgmtServer
		}
		$result = Invoke-Command -Session $RemoteSession -ScriptBlock $SB -Args $ServerName
		Remove-PSSession $RemoteSession
	}
	else
	{
		Write-Host -ForegroundColor Cyan "INFO: Server located outside of DK"
		$RemoteSession = New-PSSession -ComputerName "DKHQSCOM01"
		$SB = 
		{
			Import-Module OperationsManager
			$PrimaryMgmtServer = Get-SCOMManagementServer | Where {$_.Name -match 'DKHQSCOM03.prd.eccocorp.net'}
			Install-SCOMAgent -DNSHostName $args[0] -PrimaryManagementServer $PrimaryMgmtServer
		}
		$result = Invoke-Command -Session $RemoteSession -ScriptBlock $SB -Args $ServerName
		Remove-PSSession $RemoteSession
	}
	Start-Sleep -Seconds 5
	
	if ($result -eq $null)
	{
		$SCOM = $false
	}
	else
	{
		$SCOM = $true
	}
	
	#----------------------- END OF ACTION -----------------------#>



	#----------------------- Patch Group Assignment -----------------------"
	#Creates a Remote PowerShell session to the nearest DC, and executes the scriptblock which lists all groups present in the Patch Management groups, with an iterated number pre-fix
	#Depending on Patch Group, select the number corresponding to the one you want the server part of
	#$ServerName is once again passed as $args[0], and used to create the SAMAccountName of the computer

	Write-Progress -Activity "Deployment for $ServerName" -Status "Patch Group Assignment (Please select a patchgroup for this server)" -CurrentOperation "55% Complete" -PercentComplete 55

	#Write-Host ""
	#Write-Host -ForegroundColor Yellow "Patch Group Assignment"
	
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

		$PatchGroups = Get-ADGroup -SearchBase "OU=PATCH MANAGEMENT,OU=CENTRALLY MANAGED,OU=GROUPS,DC=PRD,DC=ECCOCORP,DC=NET" -filter {GroupCategory -eq "Security"} -Properties *
		$counter = 1

		foreach ($obj in $PatchGroups)
		{
			Write-Host -ForegroundColor Green $counter ":" $obj.Name 
			Write-Host $obj.Description
			Write-Host ""
			$counter++
		}
	
		$Selection = Read-Host "Please select Patch Group"
		$Selected = $PatchGroups[$Selection - 1]
		$ServerSAM = $args[0] + "$"
	
		try
		{
			Add-ADGroupMember $Selected $ServerSAM
			return $true
		}
		catch
		{
			return $false
		}
	}

	$result = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ArgumentList $ServerName
	Remove-PSSession $Session
	$Session = $null
	
	if ($result -eq $false)
	{
		$Patch = $false
	}
	else
	{
		$Patch = $true
	}
	
	cls
	
	#----------------------- END OF ACTION -----------------------#
	
	
	
	#----------------------- Populate Local Groups -----------------------#
	#Creates a Hashtable, and goes through each object.
	#Depending on object name and value, it populates the corresponding local group with the groups from AD
	#These can now be used to control access rights to the server
	
	Write-Progress -Activity "Deployment for $ServerName" -Status "Populating local groups on server" -CurrentOperation "80% Complete" -PercentComplete 80
	Start-Sleep -Seconds 5
	
	#Populate local groups on server
	#Write-Host ""
	#Write-Host -ForegroundColor Yellow "Populating local groups on server";

	$GroupTypes = @{"Administrators" = "-Admin"; "Power Users" = "-PowerUser"; "Remote Desktop Users" = "-RemoteDesktop"}
	foreach ($GroupType in $GroupTypes.GetEnumerator())
	{				
		[string]$domainName = ([ADSI]'').name
		$GroupName = "Srv-" + $ServerName + $GroupType.Value
		$Correlated = "WinNT://" + $ServerName + "/" + $GroupType.Name + ",group"
    	([ADSI]"$Correlated").Add("WinNT://$domainName/$GroupName")
	}
	
	$Group = [ADSI]("WinNT://" + $ServerName + "/Administrators")
	$Members = @($Group.psbase.Invoke("Members"))
	$Members | ForEach-Object {$MemberNames += $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
	$GroupTest = "*Srv-" + $ServerName + "-Admin*"

	if ($MemberNames -like $GroupTest)
	{
		$LclGrp = $true
	}
	else
	{
		$LclGrp = $false
	}
	
	#----------------------- END OF ACTION -----------------------#
} 
else 
{ 
	#----------------------- Failure action -----------------------#
	#Outputs the following to the console, in case the $ServerName variable is empty
    Write-Host -ForegroundColor green "Server Name empty."; 
}

#----------------------- Registry Settings -----------------------#
Write-Progress -Activity "Deployment for $ServerName" -Status "Writing registry values and finishing up" -CurrentOperation "95% Complete" -PercentComplete 95

Push-Location
Set-Location HKLM:
[bool] $exists = Test-Path ".\Software\ECCO IT"
$Name = "DeploymentVersion"
$Path = "HKLM:\SOFTWARE\ECCO IT\"
$DeplVersion = "1.1"

if ($exists -eq $true)
{
	Set-ItemProperty -Path $Path -Name $Name -Value $DeplVersion
	Set-ItemProperty -Path $Path -Name "HasADGrp" -Value $ADGrp
	Set-ItemProperty -Path $Path -Name "HasSCCM" -Value $SCCM
	Set-ItemProperty -Path $Path -Name "HasPatch" -Value $Patch
	Set-ItemProperty -Path $Path -Name "HasLocalGrps" -Value $LclGrp
}
else
{
	New-Item -Path $Path
	Set-ItemProperty -Path $Path -Name $Name -Value $DeplVersion
	Set-ItemProperty -Path $Path -Name "HasADGrp" -Value $ADGrp
	Set-ItemProperty -Path $Path -Name "HasSCCM" -Value $SCCM
	Set-ItemProperty -Path $Path -Name "HasPatch" -Value $Patch
	Set-ItemProperty -Path $Path -Name "HasLocalGrps" -Value $LclGrp
}
c:
cls

Write-Progress -Activity "Deployment for $ServerName" -Completed -Status "All done"
Start-Sleep -Seconds 5
cls
#----------------------- END OF Script -----------------------#