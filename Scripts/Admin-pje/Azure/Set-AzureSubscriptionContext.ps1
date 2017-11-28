<#
.SYNOPSIS
   Sets the specified Windows Azure Subscription as the current context
.DESCRIPTION
   First creates/updates the subscription profile
   Checks the required management certificate is installed
   Sets the subscription context for all WAZ cmdlets used in the session
.EXAMPLE
   Set-AzureSubscriptionContext -SubscriptionName “MySubscription” -SubscriptionId “00000000-0000-0000-0000-000000000000” -CertificateThumbprint “00000000000000000000000000000000000000000”
.OUTPUTS
   None
#>
function Set-EccoAzureSubscriptionContext
 {
    param
     (
        # Windows Azure Subscription Name
        [Parameter(Mandatory = $true)]
        [String]
        $SubscriptionName, 

                # Windows Azure Subscription Id
        [Parameter(Mandatory = $true)]
        [String]
        $SubscriptionId,

        # Management Certificate thumbnail
        [Parameter(Mandatory = $true)]
        [String]
        $CertificateThumbprint
     )

# Get management certificate from personal store
$certificate = Get-Item cert:\\CurrentUser\My\$CertificateThumbprint

if ($certificate -eq $null) 
{
    throw “Management certificate for $SubscriptionName was not found in the users personal certificate store. Check thumbprint or install certificate”
}

# Set subscription profile
Set-AzureSubscription -SubscriptionName $SubscriptionName -SubscriptionId $SubscriptionId -Certificate $certificate

# Select subscription as the current context
Select-AzureSubscription -SubscriptionName $SubscriptionName

}

$name = "PJE Test"
$subid = "dbbf9ca7-a6e8-423c-9483-fb16059c9f1e"
$print = "0A4CEC8D9FC530545463630E74EABB0C9480F33F"

#Set-EccoAzureSubscriptionContext $name $subid $print
Set-EccoAzureSubscription -SubscriptionName "PJE NY TEST" -SubscriptionId $subid


