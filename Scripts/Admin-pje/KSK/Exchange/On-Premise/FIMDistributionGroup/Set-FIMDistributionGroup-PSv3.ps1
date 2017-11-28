$var = Powershell {

    #region Variables

    #Set trace and status variables to defaults

    # Current error message
    $ErrorMessage = ""

    # Scriptpath set to where the script is run
    $ScriptPath = "C:\logs\Orchestrator\2.2.1.2 - FIM DistributionGroup Sync"

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

    #endregion
    
    try {
        # Add startup details to tracelog
        Write-LogFile "Script now executing in external PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process" -Trace
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace

        Write-LogFile "Importing ActiveDirectory Module" -Trace
	    Import-Module ActiveDirectory
    
        if(!(Get-PSSnapin Quest.ActiveRoles.ADManagement))
        {
            Write-LogFile "Add Quest Snapin" -Trace
            Add-PSSnapin Quest.ActiveRoles.ADManagement
        }
		
	    Write-LogFile "Getting filtered DistributionsGroups from SearchBase 'OU=Distribution Lists,OU=EXCHANGE,DC=prd,DC=eccocorp,DC=net'" -Trace
        
	    $allDL = ((Get-ADGroup -SearchBase "OU=Distribution Lists,OU=EXCHANGE,DC=prd,DC=eccocorp,DC=net" -Filter `
		    {((GroupCategory -eq "Distribution") -and (Name -notlike "*O_*") -and (Name -notlike "*N_*"))} -ErrorAction Stop).DistinguishedName)
        

        Write-LogFile "Enumerating returned DistributionsGroups" -Trace
	
	    foreach ($dl in $allDL) 
        {
		    Write-LogFile "Processing DistributionGroup $dl" -Trace
            (Get-QADGroupMember -Identity $dl -ErrorAction Stop | Where {($_.Classname -eq 'User' -OR $_.Classname -eq 'Contact')}) | ForEach-Object {
                Write-LogFile "Removing $($_.SamAccountName) From $dl"
                Remove-QADGroupMember -Identity $dl -Member $_.DN -Confirm:$false -ErrorAction Stop
            }
			
		    Write-LogFile "Get InnerGroups" -Trace

		    $iGroups = ((Get-QADGroupMember -Identity $dl -ErrorAction Stop | where {($_.name -like 'O_*' -or $_.name -like 'N_*') -and ($_.ClassName -match 'Group')}).DN)
							
		    foreach ($grp in $iGroups) 
            {	
                Write-LogFile "Enumerate InnerGroups [$grp]" -Trace
                Get-QADGroupMember $grp -ErrorAction Stop | ForEach-Object {
                    Write-LogFile "Adding $($_.SamAccountName) to $dl"
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