
###### Automatic #######

## Removes all subscrioption in the session
#Get-AzureSubscription | Remove-AzureSubscription

## 1. Generate Subscriptionsfile
#Get-AzurePublishSettingsFile

## Import Subscriptionsfile
#$file = Import-AzurePublishSettingsFile C:\Scripts\ECCO\Projects\Azure\Subscriptions-9-22-2015-credentials.publishsettings

## Get the subscriptions (default is last)
#Get-AzureSubscription -SubscriptionDataFile $file

## Set default subscription
#Select-AzureSubscription -SubscriptionName <name>

## Get VM under selected subscription
cls

#Get-AzureVM

###### Controled ######

## Create self signed certificate
# makecert -sky exchange -r -n "CN=AzureSubscriptions" -pe -a sha1 -len 2048 -ss My "AzureSubscriptions.cer"

## Upload certificate key to Azure and bind to subscriptions

#Get-AzureSubscription

## Generate xml file with subscriptions
#$cert = get-item Cert:\CurrentUser\My\AF570667B837914296F4634F730F362A00DDEECE
#Set-AzureSubscription -SubscriptionName "PJE Test" -SubscriptionId dbbf9ca7-a6e8-423c-9483-fb16059c9f1e -Certificate $cert
#Set-AzureSubscription -SubscriptionName "Global Branding" -SubscriptionId cc28e395-4d42-4165-bdef-8372ead24017 -Certificate $cert

## Set working subscription
#Select-AzureSubscription -SubscriptionName <name>

## do something on working / selected subscription
foreach ($sub in (Get-AzureSubscription))
{
    ## Selecting subscription
    Select-AzureSubscription -SubscriptionName $sub.SubscriptionName
    Write-Output "$($sub.SubscriptionName)"
    #Get-AzureVM
}


#$name = "PJE Test"
#$subid = "dbbf9ca7-a6e8-423c-9483-fb16059c9f1e"
#$print = "0A4CEC8D9FC530545463630E74EABB0C9480F33F"

#Set-EccoAzureSubscriptionContext $name $subid $print
#Set-EccoAzureSubscription -SubscriptionName "PJE NY TEST" -SubscriptionId $subid


## Switch Module "mode"
#Switch-AzureMode -Name AzureResourceManager

## Gets all the subscriptions for the given account
#Add-AzureAccount

## This will show you the subscriptions under the account.
#Get-AzureSubscription

## Use the subscription name to select the one you want to work on.
#Select-AzureSubscription -SubscriptionName <subscription name>

## check role assignment for the selected subscription
# Get-AzureRoleAssignment

