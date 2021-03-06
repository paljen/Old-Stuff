#	Title: ECCO Delegation Model
#	Author: Michael Hjort Madsen / MHMA@ECCO.COM / 17-Oct 2013 / EDITED 25-Sep 2015 / EDITED 02-Nov 2015 / EDITED 05-Feb 2016 / EDITED 27-May 2016
#	Purpose: Adding the groups who need to have local admin access, together with the locally delegated IT Coordinators

$ErrorActionPreference = "SilentlyContinue"
[STRING]$Client = $Env:COMPUTERNAME
[ARRAY]$Regions = "OU=SA,OU=AE","OU=SA,OU=AT","OU=SA,OU=AU","OU=SA,OU=BE","OU=SA,OU=CA","OU=SA,OU=CH","OU=FAC,OU=CN","OU=SA,OU=CN","OU=TAN,OU=CN","OU=TEC,OU=CN","OU=SA,OU=CY","OU=SA,OU=CZ","OU=SA,OU=DE","OU=SA,OU=ES","OU=SA,OU=FI","OU=SA,OU=FR","OU=SA,OU=GR","OU=SA,OU=HK","OU=FAC,OU=ID","OU=TAN,OU=ID","OU=TEC,OU=IN","OU=SA,OU=IT","OU=SA,OU=JP","OU=SA,OU=KR","OU=SA,OU=LV","OU=INNO,OU=NL","OU=SA,OU=NL","OU=TAN,OU=NL","OU=SA,OU=NO","OU=SA,OU=PL","OU=FAC,OU=PT","OU=SA,OU=RO","OU=SA,OU=SE","OU=GP,OU=SG","OU=SA,OU=SG","OU=FAC,OU=SK","OU=FAC,OU=TH","OU=FAC2,OU=TH","OU=TAN,OU=TH","OU=SA,OU=TW","OU=SA,OU=UK","OU=SA,OU=US","OU=FAC,OU=VN"

#Create Eventlog source
$Eventlog = [System.Diagnostics.EventLog]::SourceExists("Delegation") -eq $false

if ($Eventlog -eq "True")
{
	New-EventLog –LogName Application –Source “Delegation”
}

#Get Computer object from AD
$rootDSE = [System.DirectoryServices.DirectoryEntry]("LDAP://RootDSE")
[String]$RootPath = "LDAP://{0}" -f $rootDSE.defaultNamingContext.ToString()
$root = [System.DirectoryServices.DirectoryEntry]$RootPath
if ($root -ne  $null)
{
	$search = [System.DirectoryServices.DirectorySearcher] $root
	
	#Search for group
	$search.Filter = "(&(objectClass=computer)(Name=$Client))"
	
	$ComputerADObject = $search.FindOne()
}

#Find Delegated Admin Group
foreach ($Region in $Regions)
	{
		#Split content of $Region, strip of unnecessary data then rejoin
		$Split1 = $Region.split("=")
		$Split2 = $Split1[1].ToString()
		$Split3 = $Split2.Split(",")
		$Join1 = $Split1[2].ToString()
		$Join2 = $Split3[0].ToString()
		
		$Join = $Join1 + $Join2
		
		#Add delegated admin group
		if ($ComputerADObject.Path -like "*" + $Region + "*")
		{
			$DelegatedGroupName = "Admin-" + $Join + " IT Coordinators"
			$RMCGroupName = "PRD/SEC-" + $Join + " Production Remote Control"
			break
		}
		else
		{
			$DelegatedGroupName = $null
		}
	}
	
#Computer type definition
$Production = $null
$Elevated = $null
$Generic = $null
$Type = $null

if ($ComputerADObject.Path -like "*Elevated*")
{
	$Elevated = $true
	$Type = "Elevated"
}
else
{$Elevated = $false}

if ($ComputerADObject.Path -like "*Generic*")
{
	$Generic = $true
	$Type = "Generic"
}
else
{$Generic = $false}

if ($ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=PT*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=CN*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=ID*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=SK*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=TH*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=HQ,OU=DK*" -or $ComputerADObject.Path -like "*OU=FACTORY,OU=FAC,OU=VN*")
{
	$Production = $true
	$Type += " Production"
}
else
{$Production = $false}

if ($Elevated -eq $false -and $Generic -eq $false -and $Production -eq $false)
{$Type = "System"}

#Assign Local Groups to Objects
$GroupLocalAdmin = [ADSI]("WinNT://" + $Client + "/Administrators")
$GroupRemoteUsers = [ADSI]("WinNT://" + $Client + "/Remote Desktop Users")
$GroupConfigMgr = [ADSI]("WinNT://" + $Client + "/ConfigMgr Remote Control Users")

#Define groups that will be added to local Administrators or Remote Desktop Users
[System.Collections.ArrayList]$DefaultGroupAdmins = "$Client/Administrator","PRD/Admin-DKHQ HELPDESK","PRD/Admin-DKHQ IT Specialists","PRD/Admin-DKHQ SAPBasis","PRD/Admin-Global IT Coordinators","PRD/Admin-Global IT Specialists","PRD/Domain Admins","PRD/Service-SMSClient","$Client/WKSAdmin"
[System.Collections.ArrayList]$DefaultGroupRDU = "PRD/Domain Users","PRD/Admin-Global IT Specialists","PRD/Admin-Global IT Coordinators","Admin-DKHQ IT Specialists","PRD/Admin-DKHQ HELPDESK"

#Set all group memberships
function SetAdmins
{
	if ($Elevated -eq $true)
	{$DefaultGroupAdmins.Add("NT AUTHORITY/INTERACTIVE")}
	if ($Production -eq $true)
	{$DefaultGroupAdmins.Add("PRD/Service-Acronis")}
	if ($DelegatedGroupName -ne $null)
	{$DefaultGroupAdmins.Add("PRD/$DelegatedGroupName")}

	#Remove current Admin Users and Add ECCO Defined Standard
	if ($Type -ne $false)
	{
        $members = @($GroupLocalAdmin.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
        foreach ($m in $members)
        {
            $GroupLocalAdmin.remove("WinNT://$m")
        }
         
		#Add Default Groups to Local Admins
		foreach ($group in $DefaultGroupAdmins)
		{
			$ToBeAdded = [ADSI]("WinNT://" + $group)
			$GroupLocalAdmin.PSBase.Invoke("Add",$ToBeAdded.PSBase.Path)
		}
		
		Write-EventLog –LogName Application –Source “Delegation” –EntryType Information –EventID 1 –Message “$Type Computer Detected - Administrators Group has been populated.”
	}

	#Remove current Remote Desktop Users and Add ECCO Defined Standard
	
	if ($Type -ne $false)
	{
		#Remove current Remote Desktop Users
        $members = @($GroupRemoteUsers.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
		foreach ($m in $members)
        {
            $GroupRemoteUsers.remove("WinNT://$m")
        }
		
		#Add Default Groups to Remote Desktop Users
		foreach ($RDUgroup in $DefaultGroupRDU)
		{
			$ToBeAdded = [ADSI]("WinNT://" + $RDUgroup)
			$GroupRemoteUsers.PSBase.Invoke("Add",$ToBeAdded.PSBase.Path)
		}
		
		Write-EventLog –LogName Application –Source “Delegation” –EntryType Information –EventID 1 –Message “$Type Computer Detected - Remote Desktop Users Group has been populated.”
	}
	
	if ($Production -eq $true)
	{
		#Remove current ConfigMgr Remote Control Users
        $members = @($GroupConfigMgr.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
		foreach ($m in $members)
        {
            $GroupConfigMgr.remove("WinNT://$m")
        }
		
		#Add Remote Group to ConfigMgr Remote Control Users
		$AddCM = [ADSI]("WinNT://" + $RMCGroupName)
		$GroupConfigMgr.PSBase.Invoke("Add",$AddCM.PSBase.Path)
		
		Write-EventLog –LogName Application –Source “Delegation” –EntryType Information –EventID 1 –Message “$Type Computer Detected - ConfigMgr Remote Control Users Group has been populated.”
	}
}

SetAdmins
