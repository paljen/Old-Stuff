workflow Test-Webhook01
{
    param ( 
        [object]$WebhookData
    )
	
	# Stop script if any error occour
	$ErrorActionPreference = "Stop"
    
	# Connect to Azure
    $cred = Get-AutomationPSCredential -Name 'AzService-Automation'
    $account = Add-AzureRmAccount -Credential $cred

    $onpremCred = Get-AutomationPSCredential -Name 'Service-SCORCHRAA'
	
	# Select Automation Subscription 
	$SubscriptionId = Get-AutomationVariable -Name 'AutomationSubscription'
    $subscription = Select-AzureRmSubscription -SubscriptionId $subscriptionId
	
	
	
	    # If runbook was called from Webhook, WebhookData will not be null.
	    if ($WebhookData -eq $null) { 
	        throw "this runbook is designed to be triggered from a webhook"  
	    }
		
		
	    # Collect properties of WebhookData
	    $WebhookName    =   $WebhookData.WebhookName
	    $WebhookHeaders =   $WebhookData.RequestHeader
	    $WebhookBody    =   $WebhookData.RequestBody
	
		inlineScript
	{    
	
	    $Data = ConvertFrom-Json -InputObject $Using:WebhookBody
	
	    $computerName = $Data.ComputerName
	    $ServiceName = $Data.ServiceName
	
	    $ErrorActionPreference = "stop"

	    Write-verbose "Getting Service $ServiceName from $computerName"
	
	    $Service = Get-Service -ComputerName $ComputerName -Name $ServiceName
	
	    #Test if service was retrieved
	    if ($Service -eq $null) 
	    {
	        throw "Service $ServiceName not found on computer $ComputerName"
	    }
	
	    Write-verbose "Service $ServiceName from $computerName retrieved"
	
	    $Service | Restart-Service
	
	    Write-output "Service $ServiceName from $computerName sucessfully restarted"
			
	} -PSCredential $onpremCred
	
	 Write-output "test"

}