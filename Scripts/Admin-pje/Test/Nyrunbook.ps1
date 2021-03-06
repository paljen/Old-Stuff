
function Add-ComputerToGroup
{
	param(
		$Group,
		$ComputerName
	)
	try
	{
		Write-Output "`$Computer.OperatingSystem[$($Computer.OperatingSystem)]"
		Write-Output "Add-ADGroupMember -Identity $Group -Members $ComputerName -ErrorAction Stop"
		Add-ADGroupMember -Identity $Group -Members $ComputerName -ErrorAction Stop
	}
	Catch
	{
        $ErrorMessage = $error[0].Exception.Message
        Write-Output "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	}
}

function Remove-ComputerFromGroup
{
	param(
		$Group,
		$ComputerName
	)
	try
	{
		Write-Output "`$Computer.MemberOf[$($Group)]"
		Write-Output "Remove-ADGroupMember -Identity $Group -Members $ComputerName -ErrorAction Stop"
		Remove-ADGroupMember -Identity $Group -Members $ComputerName -Confirm:$false -ErrorAction Stop
	}
	
	Catch
	{
        $ErrorMessage = $error[0].Exception.Message
        Write-Output "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	}
}

#region Declaring variables
	$Computer = Get-ADComputer "DK4836" -Properties MemberOf,OperatingSystem
	$win7Group = "SEC-Pje-Testmailbox2"
	$win8Group = "SEC-Pje-Testmailbox3"
	$oldGroup = "SEC-Pje-Testmailbox"
#endregion

if($Computer.OperatingSystem -like "Windows 7*")
{
	Add-ComputerToGroup -Group $win7Group -ComputerName $Computer.SamAccountName
			
	if($($Computer.MemberOf) -match $oldGroup)
	{
		Remove-ComputerFromGroup -Group $oldGroup -ComputerName $Computer.SamAccountName
	}
}

elseif($Computer.OperatingSystem -like "Windows 8*")
{
	Add-ComputerToGroup -Group $win8Group -ComputerName $Computer.SamAccountName
	
	if($($computer.MemberOf) -match $oldGroup)
	{
		Remove-ComputerFromGroup -Group $oldGroup -ComputerName $Computer.SamAccountName	
	}
}

else
{
	Write-Output "`$Computer.OperatingSystem[$($Computer.OperatingSystem)]: No ation taken"
}


#hvis os = tilføj gruppe a ellers gruppe b
#fjern computer account fra den gamle gruppe hvis den er medlem
#returner resultat -> kør runbook