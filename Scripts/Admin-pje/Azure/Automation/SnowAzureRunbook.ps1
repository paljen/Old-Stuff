<#
Param
(
    ## Name of the user to be granted access
    $username = $args[0],
    ## Name of the group to witch the user should be granted membership
    $access = $args[1]
)#>

## Webhook to runbook New-AzADAccessToken
$uri = "https://s2events.azure-automation.net/webhooks?token=Js0Ce0ituouNgbYJAMEI%2f6CQNHshpxJKHCJ7W4oD0rE%3d"

## Headers
## From = "IssuedBy" in SNOW
## Date = "IssuedDate" in SNOW, Date format like get-date
## TaskID = TaskID from the calling task
$headers = @{"From"="IssuedBy";"Date"=$(Get-Date);"TaskID"="TaskID from SNOW"}

## Body, query parameters as hashtable converted to JSON
$params  = @{USERSAM="pjetestuser";GROUPSAM="testgroup"}
$body = ConvertTo-Json -InputObject $params

try
{
    ## Call Runbook
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
}
catch
{
    $_.Exception.Message
}