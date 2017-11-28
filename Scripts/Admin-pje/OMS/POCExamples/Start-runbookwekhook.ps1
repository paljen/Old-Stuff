#requires -Version 3
# History:
# 1.0 - Lennart Passig (Orange Networks GmbH) - 20.10.2015 
 
<# .SYNOPSIS Invoke a Runbook via Webhook and send data from an csv file .DESCRIPTION This Powershell Script is used to create resource groups and making a role assingment in Azure by using a CSV file as data source. It triggers a Azure Automation Webhook. .LINK http://www.orange-networks.de/ #>
Param
(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$token,
 
    [Parameter(Mandatory = $true, Position = 1)]
    [String]$path
)
 
#Define variables 
 
#Get current date
$date = Get-Date
#Define Webhook URI
$uri = "https://s2events.azure-automation.net/webhooks?token=$token"
#Define HTTP Headers
$headers = @{
    'From' = "$env:USERNAME"
    'Date' = "$date"
}
#Import data from csv file
$importdata = Import-Csv -Path "$path"
 
 
Foreach($User in $importdata)
{
    try
    {
        $csvUser = $User.Mail
        $Users += @([pscustomobject]@{
                Mail = "$csvUser"
        })
    }
    catch
    {
        Write-Output -InputObject $_
    }
}
 
#Build JSON conform body
$body = ConvertTo-Json -InputObject $Users
 
#Call the runbook through http via RestMethod
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body
#Get response
$jobid = ConvertFrom-Json -InputObject $response
$jobid
$response
