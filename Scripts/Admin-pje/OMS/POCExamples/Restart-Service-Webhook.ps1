workflow Test-Webhook01
{
    param ( 
        [object]$WebhookData
    )

    # If runbook was called from Webhook, WebhookData will not be null.
    if ($WebhookData -eq $null) { 
        throw "this runbook is designed to be triggered from a webhook"  
    }

    # Collect properties of WebhookData
    $WebhookName    =   $WebhookData.WebhookName
    $WebhookHeaders =   $WebhookData.RequestHeader
    $WebhookBody    =   $WebhookData.RequestBody

    $Data = ConvertFrom-Json -InputObject $WebhookBody

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

}