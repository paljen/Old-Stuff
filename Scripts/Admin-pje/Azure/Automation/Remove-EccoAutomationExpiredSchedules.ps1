param(

	[Parameter(Mandatory=$true)]
	[String]$SubscriptionId = "PJE Test"
)
	 
$ErrorActionPreference = "Stop"
	
$cred = Get-AutomationPSCredential -Name ''
$account = Add-AzureRmAccount -Credential $cred
	
$subscription = Select-AzureRmSubscription -SubscriptionName $subscriptionId
	
Get-AzureRmResource | where {$_.ResourceType -eq "Microsoft.Automation/automationAccounts"} | ForEach-Object {
   	Get-AzureRmAutomationSchedule -ResourceGroupName $_.ResourceGroupName -AutomationAccountName $_.Name | 
       	Where NextRun -eq $null | Remove-AzureRmAutomationSchedule -Confirm:$false -Force 
}