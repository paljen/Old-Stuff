
function Ecco-ADTestSecurityGroup {
	
	param(
		[String]$name
	)
	
	try{
		AppendLog "Checking objectclass for group [$($Name)]"
		return $(Get-ADObject -Filter {(Name -eq $name) -and (objectClass -eq "group")})
	}

	catch {
		$ErrorMessage = $error[0].Exception.Message
		AppendLog "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	}
}

function Ecco-AD-TestUserValidation
{
	param(
		[String]$username,
		[int]$days
	)
	
	$CURRENTDATE=GET-DATE 	
	
	$user = Get-QADUser $username | select LastLogonTimeStamp, AccountIsDisabled

	if ($user.AccountIsDisabled -eq $true)
	{
		Write-Output "Account is Disabled: $($user.AccountIsDisabled)"
		
		if (($user.LastLogonTimestamp.AddDays($days) -lt $CURRENTDATE) -or ($user.LastLogonTimestamp -eq $null)){

			Write-Output "User has not been logged on for over $($numberdays) days"
			Write-Output "No action taken"
			return $false
			
		}
		else {
			return $true
			Write-Output "User has been logged on within $($numberdays) days"
			Write-Output "Adding full mailbox rights"
		}
	}
	else
	{
		Write-Output "Account is Disabled: $($user.AccountIsDisabled)"
		
	}
}

function get-something{
}