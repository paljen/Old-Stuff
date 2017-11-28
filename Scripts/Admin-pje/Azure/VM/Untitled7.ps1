$session = New-PSSession -ComputerName Localhost

Invoke-Command -Session $session -scriptblock {

$OldGroupName = "SEC-Global DirectAccess Clients"
$NewGroupName = "SEC-Global DirectAccess HQ Access Win7 Clients"

#Get current computername
$ComputerName = "\`d.T.~Ed/{FB0E44AC-6F2F-4DE2-9C79-ACE53C5A6A83}.{43B042FD-1DAF-4B52-8132-017E363B9461}\`d.T.~Ed/"

#Group name

$rootDSE = [System.DirectoryServices.DirectoryEntry]("LDAP://RootDSE")
[String]$RootPath = "LDAP://{0}" -f $rootDSE.defaultNamingContext.ToString()
$root = [System.DirectoryServices.DirectoryEntry]$RootPath
 
if ($root -ne  $null)
{
	$search = [System.DirectoryServices.DirectorySearcher] $root
	
	#Search for old group
	$search.Filter = "(&(objectClass=group)(samaccountname=$OldGroupName))"
	
	$OldGroup = $search.FindOne()
    
	If ($OldGroup -ne $null)
	{
		$OldGroup = $OldGroup.GetDirectoryEntry()
	}
	else
	{
		exit
	}
	
	#Search for new group
	$search.Filter = "(&(objectClass=group)(samaccountname=$NewGroupName))"
	
	$NewGroup = $search.FindOne()
    
	If ($NewGroup -ne $null)
	{
		$NewGroup = $NewGroup.GetDirectoryEntry()
	}
	else
	{
		exit
	}	

	#Search for Computer
	$search.Filter = "(&(objectClass=Computer)(SamAccountName=$ComputerName$))"
	
	$Computer = $search.FindOne()

	[Boolean] $IsMember = $false 
	
	If ($Computer -ne $null)
	{	
	
		if ($OldGroup.Properties["member"].tostring().contains($Computer.Properties["distinguishedName"]))
		{
			#Must remote from group
			$OldGroup.remove($Computer.Path)
			$OldGroup.CommitChanges()
		}
		elseif ($NewGroup.Properties["member"].tostring().contains($Computer.Properties["distinguishedName"]))
		{
			$IsMember = $true	
			
		}
		
		#If computer is NOT member of group, we add it
		If ($IsMember -eq $false)
		{
			$NewGroup.add($Computer.Path)
			$NewGroup.CommitChanges()		
		}
	}
}
}