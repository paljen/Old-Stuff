<#
.SYNOPSIS 
    Creates a new Virtual Machine (VM) on Azure

.DESCRIPTION
    This runbook creates a new Virtual Machine (VM) on Azure.
    The Connect-Azure runbook needs to be imported and published before this runbook can be sucessfully run.
    
    The runbook waits untill VM boots
    
.PARAMETER AzureConnectionName
    Name of the Azure connection asset that was created in the Automation service.
    This connection asset contains the subscription id and the name of the certificate asset that 
    holds the management certificate for this subscription.
    
.PARAMETER ServiceName
    Name of the cloud service which VM will belong to. A new cloud service will be created if cloud service by name ServiceName does not exists

.PARAMETER VMName    
    Name of the virtual machine. 

.PARAMETER VMCredentialName
   Name of the credential asset ( that has username/password) used for VM login
   
.PARAMETER VMSize
   Specifies the size of the instance. Supported values are as below with their (cores, memory) 
   "ExtraSmall" (shared core, 768 MB),
   "Small"      (1 core, 1.75 GB),
   "Medium"     (2 cores, 3.5 GB),
   "Large"      (4 cores, 7 GB),
   "ExtraLarge" (8 cores, 14GB),
   "A5"         (2 cores, 14GB)
   "A6"         (4 cores, 28GB)
   "A7"         (8 cores, 56 GB)
  
.PARAMETER OSName
    Name of the OS that need to be used for the VM 
    OSName can be found here:
    New -> Compute -> Virtual Machine -> From Gallery -> 'Choose an Image' page -> Pick OSName from the list
   
    Alternatively, get OS name by executing Azure activity
    Get-AzureVMImage
    (Look for 'Label' property for OS name)

.PARAMETER Location
    Location of the datacenter where VM will be created. One of the below
    Supported values for Location: "West US", "East US", "North US", "South US", "West Europe", "North Europe", "East Asia", 'Southeast Asia'
    If an existing Cloud Service is provided using ServiceName parameter, Location parameter won't be used
    
.PARAMETER StorageAccountName
   Name of storage account used for the subscription. If storage does not exists, new storage account will be created.
  Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only.
  
.EXAMPLE
 1) Create Certificate Asset "myCert":
    Use the certificate file (.pfx or .cer file) to create a Certificate asset for ex. "myCred" in 
    Azure -> Automation -> select automation account "MyAutomationAccount" -> Assets -> Add Setting -> Add Credential -> 
    Certificate -> Provide name "myCred" and upload the certificate file (.pfx or .cer)
    
    The same certificate must be associated with the subscription, You can verify the same for your subscription 
    at Azure -> Settings -> Management Certificates
2) Create Azure Connection Asset "AzureConnection"
    Azure -> Automation -> select automation account "MyAutomationAccount" -> Assets -> Add Setting 
    -> Add Connection -> Select 'Azure' from dropdown -> Provide name ex. "AzureConnection"  ->
    Provide AutomationCertificateName "myCert" you created in step 1 and subscription Id
    
3) To run runbook: Test or Start the runbook from Author tab
  
  to call from another runbook, ex:
  New-AzureVMSample -AzureConnectionName "AzureConnection" -ServiceName "myService" -VMName "myVM" -VMCredentialName "myVMCred" -OSName "Windows Server 2012 R2 Datacenter" -Location "East US" -VMSize "Large" -StorageAccountName "mystgacc"  

.NOTES
    AUTHOR: Viv Lingaiah
    LASTEDIT: Apr 15 , 2014 
#>
workflow New-AzureVM
{
    Param
    (
        [parameter(Mandatory=$true)] [String] $Subscription,
	    [parameter(Mandatory=$true)] [String] $ServiceName,
        [parameter(Mandatory=$true)] [String] $VMName,
        [parameter(Mandatory=$true)] [String] $VMCredentialName,
	    [parameter(Mandatory=$true)] [String] $OSName,
        [parameter(Mandatory=$true)] [String] $Location,
        [parameter(Mandatory=$true)] [String] $StorageAccountName,
        [parameter(Mandatory=$false)] [String] $VMSize = "ExtraSmall"  
    )
     
    # Call the Connect-Azure Runbook to set up the connection to Azure using the Automation connection asset
    Connect-Azure -AzureConnectionName $AzureConnectionName 
    
    $VMCred = Get-AutomationPSCredential -Name $VMCredentialName
    if($VMCred -eq $null)
    {
        throw "No Credential asset was found by name {0}. Please create it." -f  $Using:VMCredentialName
    } 
    
    $VMUserName = $VMCred.UserName
    $VMPassword = $VMCred.GetNetworkCredential().Password
   
    InlineScript
    {
        # Select the Azure subscription we will be working against
        Select-AzureSubscription -SubscriptionName $Using:AzureConnectionName
        $sub = Get-AzureSubscription -SubscriptionName $Using:AzureConnectionName
            
        # Check whether a VM by name $VMName already exists, if does not exists create VM
         Write-Output ("Checking whether VM '{0}' already exists.." -f $Using:VMName)
        $AzureVM = Get-AzureVM -ServiceName $Using:ServiceName -Name $Using:VMName
        if ($AzureVM -eq $null)
        {
            Write-Output "VM does not exist"
        }
    }
}