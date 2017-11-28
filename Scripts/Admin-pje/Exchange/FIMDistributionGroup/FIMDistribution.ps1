
#region Variables

#Set trace and status variables to defaults

# Current error message
$ErrorMessage = ""

# Scriptpath set to where the script is run
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#endregion
	
#region Functions

function Write-LogFile
{
    [CmdletBinding()]

	param(

        [Parameter(Position=0)]
        [string]$Message,
        [Switch]$Trace	
	)
    
    if($Trace)
    {
        $Log = "$ScriptPath\Trace.log"	
	    $Output = "$([DateTime]::Now): $Message"
    }

    else
    {
        $Log = "$ScriptPath\Output.log"
        $output = $Message
    }

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

function Main
{
    try 
    {
        # Add startup details to tracelog
        Write-LogFile "-------------------------------------------------------------------------------------------------------------" -Trace
        Write-LogFile "PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process" -Trace
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)] " -Trace

        if(!(Get-Module ActiveDirectory))
        {
            Write-LogFile "Import-Module ActiveDirectory" -Trace
	        Import-Module ActiveDirectory
        }
    
        if(!(Get-PSSnapin Quest.ActiveRoles.ADManagement))
        {
            Write-LogFile "Add-PSSnapin Quest.ActiveRoles.ADManagement" -Trace
            Add-PSSnapin Quest.ActiveRoles.ADManagement
        }
		
	    Write-LogFile "Get filtered DistributionsGroups from SearchBase 'OU=Distribution Lists,OU=EXCHANGE,DC=prd,DC=eccocorp,DC=net' by DistinguisedName.." -Trace
        
	    $allDL = ((Get-ADGroup -SearchBase "OU=Distribution Lists,OU=EXCHANGE,DC=prd,DC=eccocorp,DC=net" -Filter `
		    {((GroupCategory -eq "Distribution") -and (Name -notlike "*O_*") -and (Name -notlike "*N_*"))} -ErrorAction Stop).DistinguishedName)
        

        Write-LogFile "Enumerating DistributionsGroups.." -Trace
	
	    foreach ($dl in $allDL) 
        {
		    Write-LogFile "Enumerating DistributionGroup $dl" -Trace
            (Get-QADGroupMember -Identity $dl -ErrorAction Stop | Where {($_.Classname -eq 'User' -OR $_.Classname -eq 'Contact')}) | ForEach-Object {
                Write-LogFile "Removing $($_.SamAccountName) from DistributionGroup $dl"
                Remove-QADGroupMember -Identity $dl -Member $_.DN -Confirm:$false -ErrorAction Stop
            }
			
		    Write-LogFile "Get InnerGroups by DistinguisedName.." -Trace

		    $iGroups = ((Get-QADGroupMember -Identity $dl -ErrorAction Stop | where {($_.name -like 'O_*' -or $_.name -like 'N_*') -and ($_.ClassName -match 'Group')}).DN)
							
		    foreach ($grp in $iGroups) 
            {	
                Write-LogFile "Enumerating InnerGroup [$grp]" -Trace
                Get-QADGroupMember $grp -ErrorAction Stop | ForEach-Object {
                    Write-LogFile "Adding $($_.SamAccountName) to DistributionGroup $dl"
                    Add-QADGroupMember -Identity $dl $_.DN -ErrorAction Stop
                }   
		    }
	    }
    }

    catch 
    {
        $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught: $ErrorMessage" -Trace
    }
}

#endregion

main