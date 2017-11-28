$samAccountName = "PJE"
$resourceGroupName = "OaaSCSBDLWIEZCS3UYAXGJMEW7O5WM5QNK2API5QIR6SNVR2GUAUNBPSLA-West-Europe"
$automationAccountName = "AzureAutomation"
$scheduleName = "AccessToken-$($SamAccountName)-$([guid]::NewGuid().guid.replace('-',''))"
$subscriptionId = "PJE Test"

#$account = Add-AzureRmAccount

$subscription = Select-AzureRmSubscription -SubscriptionName $subscriptionId
#$subscription |fl *
#Get-AzureRmResourcegroup | fl * # | where subscriptionid -eq $subscriptionId

<#
Get-AzureRmResource | where {$_.ResourceType -eq "Microsoft.Automation/automationAccounts"} | ForEach-Object {
    Get-AzureRmAutomationSchedule -ResourceGroupName $_.ResourceGroupName -AutomationAccountName $_.Name | 
        where NextRun -eq $null | Remove-AzureRmAutomationSchedule -Confirm:$false -Force 
}#>

$scheduleName = "AccessToken-$($SamAccountName)-$([guid]::NewGuid().guid.replace('-',''))"

$schedule = @{
            "ResourceGroupName" = (Get-AzureRmAutomationAccount).ResourceGroupName
            "AutomationAccountName" = (Get-AzureRmAutomationAccount).AutomationAccountName
            "Name" = $scheduleName
            "StartTime" = (Get-Date).AddMinutes(6)
            "OneTime" = $true
        }

$linkRb = @{
            "ResourceGroupName" = (Get-AzureRmAutomationAccount).ResourceGroupName
            "AutomationAccountName" = (Get-AzureRmAutomationAccount).AutomationAccountName
            "ScheduleName" = $scheduleName
            "RunbookName" = "TEST"
            "Parameters" = @{"AzureSubscriptionName"=$((Get-AzureRmSubscription -SubscriptionId $subscription.Subscription).SubscriptionName);"CredentialName"=$SamAccountName}
        }




## Create new Azure Asset schedule
New-AzureRmAutomationSchedule @schedule

## Link Runbook to schedule
Register-AzureRmAutomationScheduledRunbook @linkRb

## Remove expired Schedules
#Get-AzureRmAutomationSchedule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName | 
#    where NextRun -eq $null | Remove-AzureRmAutomationSchedule -Confirm:$false -Force

#get-azurermautomationAccount