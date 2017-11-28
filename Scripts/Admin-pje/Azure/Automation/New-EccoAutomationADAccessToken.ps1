<#
.Synopsis
    An Azure Automation Runbook to give a user, groupmembership for a limited period od time

.DESCRIPTION
    This runbook adds a given user to a specific group. It then creates a schedule, that after a defined period,
    triggeres runbook to remove the user from that group again

.PARAMETER SubscriptionId
    The id of the Azure subscription

.PARAMETER AutomationAccount
    The automation account where the runbook is stored

.PARAMETER UserSAM
    The Active Directory SamAccountName

.PARAMETER GroupSAM
    The Active Directory SamAccountName of the group, to witch the user should be given membership

.EXAMPLE
    New-EccoAutomationADAccessToken -SubscriptionId "PJE Test" -AutomationAccount "AzureAutomation" -UserSAM "PJE" -GroupSAM "Domain Admins"

.NOTES
   AUTHOR: Palle Jensen
   DATE: 17-02-2016
   CHANGES:
#>

workflow New-EccoAutomationADAccessToken 
{
    Param
    (
        # Suscription Id or Name for the automation account
	    [Parameter(Mandatory=$true)]
	    [String]$SubscriptionId,

        # Name of the automation account
        [Parameter(Mandatory=$true)]
        [String]$AutomationAccount,

        # SamAccountName of the user that should be granted access
        [Parameter(Mandatory=$true)]
        [String]$UserSAM,

        # SamAccountName of the group granted access to
        [Parameter(Mandatory=$true)]
        [String]$GroupSAM

    )

    #$cred = Get-AutomationPSCredential -Name ''
    $account = Add-AzureRmAccount #-Credential $cred
    $subscription = Select-AzureRmSubscription -SubscriptionName $subscriptionId

    InlineScript
    {
        $ErrorActionPreference = "Stop"

        # Generating unique schedule name
        $scheduleName = "AccessToken-$($Using:UserSAM)-$([guid]::NewGuid().guid.replace('-',''))"

        # Schedule hashtable
        $schedule = @{
            "ResourceGroupName" = (Get-AzureRmAutomationAccount).ResourceGroupName
            "AutomationAccountName" = (Get-AzureRmAutomationAccount).AutomationAccountName
            "Name" = $scheduleName
            "StartTime" = (Get-Date).AddMinutes(6)
            "OneTime" = $true
        }
        
        # Link runbook hashtable
        $linkRb = @{
            "ResourceGroupName" = (Get-AzureRmAutomationAccount).ResourceGroupName
            "AutomationAccountName" = (Get-AzureRmAutomationAccount).AutomationAccountName
            "ScheduleName" = $scheduleName
            "RunbookName" = "TEST"
            "Parameters" = @{"AzureSubscriptionName"=$((Get-AzureRmSubscription -SubscriptionId $subscription.Subscription).SubscriptionName);"CredentialName"=$Using:UserSAM}
        }

        try
        {
            ## Call runbook Add-EccoAutomationADGroupMember

            # Set up the scheduled task
            New-AzureRmAutomationSchedule @schedule

            # Link runbook to schedule
            Register-AzureRmAutomationScheduledRunbook @linkRb
        }

        catch
        {
            Write-Output $($_.Exception.Message)
        }
    }
}

New-EccoAutomationADAccessToken -SubscriptionId "PJE Test" -AutomationAccount "AzureAutomation" -SamAccountName "PJE"