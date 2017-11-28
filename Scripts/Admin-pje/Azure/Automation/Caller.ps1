Import-Module azurerm


## Webhook to runbook New-AzADAccessToken
$token = "P%2bRWjwXYpJtQT7ski8THvQy2IBnahtDj%2b7KS6lhihuE%3d"
$uri = "https://s2events.azure-automation.net/webhooks?token=$token"

## Headers
$headers = @{"Date"=$(Get-Date)}

## Body,
$params  = @{Alarmtype="critical";State="Open"}
$body = ConvertTo-Json -InputObject $params

try
{
    ## Call Runbook
    $job = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ErrorAction Stop

}
catch
{
    $_.Exception.Message
}