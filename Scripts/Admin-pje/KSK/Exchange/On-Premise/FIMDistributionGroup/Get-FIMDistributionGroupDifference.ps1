function AppendLog ([string]$Message){
    $script:CurrentAction = $Message
    $script:TraceLog += ((Get-Date).ToString() + "`t" + $Message + " `r`n")
}

#region Set trace and status variables to defaults
$ErrorMessage = ""
$script:TraceLog = ""
$script:CurrentAction = ""
$LogFile = 'C:\Scripts\Powershell - Projects\Exchange\FIMDistributionGroupSync\Output\TraceLog.txt'
#endregion

try{
	if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available"){
		AppendLog "Importing Module Microsoft.Exchange from http://dkhqexc04n01.prd.eccocorp.net/powershell/"
	    $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
		Import-PSSession $ExSession}
}
catch{
	$ErrorMessage = $error[0].Exception.Message
	AppendLog "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
}

## Add startup details to trace log
$script:TraceLog = (Get-Date).ToString() + "`t" + "Script started" + " `r`n"
AppendLog "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

foreach ($dst in (Get-DistributionGroup -Filter {RecipientType -eq "MailUniversalDistributionGroup"}).displayname) {
	$Members = @()
	$diff = $null
	
	foreach ($group in (Get-DistributionGroupMember -Identity $dst | where {($_.name -like 'O_*' -or $_.name -like 'N_*') -and ($_.RecipientType -match 'Group')}).name) {
		$Members +=	(Get-ADGroupMember $group).SamAccountName
	}
		
	if ($Members){
		try{
			AppendLog "Compare $dst against members of $group"
			$diff = $(Compare-Object -ReferenceObject $Members -DifferenceObject (Get-DistributionGroupMember -Identity $dst | `
					where {($_.RecipientType -match 'User')}).SamAccountName -ErrorAction SilentlyContinue | Where {$_.SideIndicator -Match "=>"})
			$diff | Select @{l="DistributionsGroup";e={$dst}},@{l="SamAccountName";e={$_.inputobject}} | `
					Export-Csv c:\DIFF.CSV -NoTypeInformation -Encoding UTF8 -Append
		}
		
		catch{
			$ErrorMessage = $error[0].Exception.Message
			AppendLog "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
		}
	}
	else{
		AppendLog "$dst got no N_ and O_ Group Objects members"
	}
}

## Record end of activity script process
$script:TraceLog += (Get-Date).ToString() + "`t" + "Script finished" + " `r`n"
Out-File -FilePath $LogFile -InputObject $script:TraceLog