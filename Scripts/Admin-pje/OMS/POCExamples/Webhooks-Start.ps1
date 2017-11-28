<#
#example 1
$uri = "https://s2events.azure-automation.net/webhooks?token=Js0Ce0ituouNgbYJAMEI%2f6CQNHshpxJKHCJ7W4oD0rE%3d"
$headers = @{"From"="user@contoso.com";"Date"="05/28/2015 15:47:00"}
$vms  = @([pscustomobject]@{UserSAM="pjetest";GroupSAM="testgroup"})

$body = ConvertTo-Json -InputObject $vms 
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
$jobid = ConvertFrom-Json $response 
#>


#example 2

$uri = "https://s2events.azure-automation.net/webhooks?token=Js0Ce0ituouNgbYJAMEI%2f6CQNHshpxJKHCJ7W4oD0rE%3d"

$headers = @{"From"="IssuedBy";"Date"=$(Get-Date);"TaskID"="TaskID from SNOW"}
$params  = @{USERSAM="Username";GROUPSAM="Access"}

$body = ConvertTo-Json -InputObject $params

try
{
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
}
catch
{
    $_.Exception.Message
}


<#
$doLoop = $true

While ($doLoop) {
   $job = Get-AzureAutomationJob –AutomationAccountName "MyAutomationAccount" -Id $job.Id
   $status = $job.Status
   $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped")
}

Get-AzureAutomationJobOutput –AutomationAccountName "MyAutomationAccount" -Id $job.Id –Stream #>