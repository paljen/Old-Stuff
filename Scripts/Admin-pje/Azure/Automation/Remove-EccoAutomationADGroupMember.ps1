<#
.Synopsis
    An Azure Automation Runbook that adds a given user to a given group

.DESCRIPTION
    This runbook adds a given user to a specific group.

.PARAMETER UserSAM
    The Active Directory SamAccountName

.PARAMETER GroupSAM
    The Active Directory SamAccountName of the group, to witch the user will be given membership

.EXAMPLE
    Add-EccoAutomationADGroupMember -UserSAM "PJE" -GroupSAM "TestGroup"

.NOTES
   AUTHOR: Palle Jensen
   DATE: 17-02-2016
   CHANGES:
#>

workflow Remove-EccoAutomationADGroupMember 
{
    Param 
    (
        # User SamAccountName
        [Parameter(Mandatory=$true)]
        [String]$UserSAM,

        # Group SamAccountName
        [Parameter(Mandatory=$true)]
        [String]$GroupSAM
    )

    # Local credentials
    $cred = Get-AutomationPSCredential -Name 'Service-SCORCHRAA'
	
	# Remote computer
	$dc = "DKHQDC01"

    $result = InlineScript{
	    if(((Get-ADGroupMember -Identity $Using:GroupSAM).SamAccountName) -icontains $Using:UserSAM)
	    {
	        Remove-ADGroupMember -Identity $Using:GroupSAM -Members $Using:UserSAM -Confirm:$false
            $true
	    }
	    else
	    {
            $false
	    }
		       
    } -PSComputerName $dc -PSCredential $cred

    $result
}

Remove-EccoAutomationADGroupMember -UserSAM PJE -GroupSAM TestGroup