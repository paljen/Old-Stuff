#----------------------AZURE RESOURCE MANAGER-------------------

#--------------------------Connect--------------------------
## AZURE RESOURCE MANAGER AUTHENTICATION (Portal v2)
#Add-AzureRmAccount

## To view the current context
#Get-AzureRmContext

## To work on a specific subscription
$azSubscription = Get-AzureRmSubscription -SubscriptionName "PJE Test" | Select-AzureRmSubscription
#-----------------------------------------------------------


#------------------------Variables--------------------------
## GERERAL
$azLocation = "West Europe"
$azResourceGroupName = "PJETEST-RG"
$azAvailabilitySetName = "PJETESTAG-SQL"

## COMPUTE
## Sizing - https://azure.microsoft.com/en-us/pricing/details/virtual-machines/
$azVMName = "PJETEST-VM"
$azComputerName = "PJETEST-Server1"
$azVMSize = "Standard_A2"
$azOSDiskName = $VMName + "OSDisk"

## STORAGE
#Standard_LRS (locally-redundant storage) 
#Standard_ZRS (zone-redundant storage) 
#Standard_GRS (geo-redundant storage) 
#Standard_RAGRS (read access geo-redundant storage) 
#Premium_LRS
$azStorageName = "PJETEST-SA"
$azStorageName = [Regex]::Replace($sa.ToLower(), '[^(a-z0-9)]', '')
$azStorageType = "Standard_A2"

## NETWORK - Skal defineres
$azVNetName = "PJETEST-VNET"
$azInterfaceName = "PJETEST-VNETVM"
$azSubnet1Name = "PJETEST-SUBVM01"
$azVNetAddressPrefix = "192.168.0.0/20"
$azVNetSubnetAddressPrefix = "192.168.0.0/23"

## CREDENTIALS
## in runbook use the asset cred
$azVMCred = $Credential = Get-Credential
$azUsername = "AzService-Automation"
$azPassword = "Haxa2111"
#-----------------------------------------------------------


#-----------------------ResourceGroup-----------------------
## Create Resource group if needed
#New-AzureRmResourceGroup -Name $azResourceGroupName -Location $azLocation

## Store ResourceGroup Object
$azResourceGroup = Get-AzureRmResourceGroup -Name $azResourceGroupName
#-----------------------------------------------------------


#--------------------------Storage--------------------------
##Create Storage Account if needed
#New-AzureRmStorageAccount -ResourceGroupName $azResourceGroupName -Name $azStorageName -Type $azStorageType -Location $azLocation

##To select the default storage context for your current session
Set-AzureRmCurrentStorageAccount –ResourceGroupName $azResourceGroupName –StorageAccountName $azStorageName

## Store StorageAccount object
$azStorageAccount = Get-AzureRmStorageAccount -Name $azStorageName -ResourceGroupName $azResourceGroupName

##To list all of the blobs in all of your containers in all of your accounts
#Get-AzureRmStorageAccount | Get-AzureStorageContainer | Get-AzureStorageBlob
#-----------------------------------------------------------

#--------------------------Network--------------------------
## Create Network if needed
#$azPIp = New-AzureRmPublicIpAddress -Name $azInterfaceName -ResourceGroupName $azResourceGroupName -Location $azLocation -AllocationMethod Dynamic
#$azSubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $azSubnet1Name -AddressPrefix $azVNetSubnetAddressPrefix
#$azVNet = New-AzureRmVirtualNetwork -Name $azVNetName -ResourceGroupName $azResourceGroupName -Location $azLocation -AddressPrefix $azVNetAddressPrefix -Subnet $azSubnetConfig
#$azInterface = New-AzureRmNetworkInterface -Name $azInterfaceName -ResourceGroupName $azResourceGroupName -Location $azLocation -SubnetId $azVNet.Subnets[0].Id -PublicIpAddressId $azPIp.Id

## Store Interface object ID
$azInterface = Get-AzureRmNetworkInterface -Name $azInterfaceName -ResourceGroupName $azResourceGroupName
#-----------------------------------------------------------

#----------------------AvailabilitySet----------------------
## Create Availability Set if you have more of the same type of VM to get better SLA
## http://michaelwasham.com/windows-azure-powershell-reference-guide/understanding_configuring_availability_sets_powershell/

#New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name "PJETESTAG-SQL" -Location $Location

$azAvailabilitySet = Get-AzureRmAvailabilitySet -ResourceGroupName $azResourceGroupName -Name $azAvailabilitySetName
#-----------------------------------------------------------

#-----------------------VirtualMachine----------------------
## VMSize and pricing https://azure.microsoft.com/en-us/pricing/details/virtual-machines/

## The New-AzureRmVMConfig cmdlet creates a configurable local virtual machine object for Azure.
#$azVirtualMachine = New-AzureRmVMConfig -VMName $azVMName -VMSize $azVMSize -AvailabilitySetId $azAvailabilitySet.Id

## The Set-AzureRmVMOperatingSystem cmdlet sets operating system properties for a virtual machine.
#$azVirtualMachine = Set-AzureRmVMOperatingSystem -VM $azVirtualMachine -Windows -ComputerName $azComputerName -Credential $azVMCred -ProvisionVMAgent -EnableAutoUpdate

## The Set-AzureRmVMSourceImage cmdlet specifies the platform image to use for a virtual machine.
## Set values for an image
#$azVirtualMachine = Set-AzureRmVMSourceImage -VM $azVirtualMachine -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"

## Use the image reference method to set values
#$Publisher = (Get-AzureRmVMImagePublisher -Location "West Europe") | where { $_.PublisherName -eq 'MicrosoftWindowsServer' }
#$Offer = (Get-AzureRmVMImageOffer -Location "West Europe" -PublisherName $Publisher.PublisherName) | select -ExpandProperty Offer | where { $_ -like '*Windows*' } 
#$Sku = (Get-AzureRmVMImageSku -Location "West Europe" -PublisherName $Publisher.PublisherName -Offer $Offer) | select -ExpandProperty Skus
#$Versions = (Get-AzureRmVMImage -Location "West Europe" -Offer $Offer -PublisherName $Publisher.PublisherName -Skus $Sku[2]) | select -ExpandProperty Version
#$VMImage = Get-AzureRmVMImage -Location "West Europe" -Offer $Offer -PublisherName $Publisher.PublisherName -Skus $Sku[2] -Version $Versions[-1]
#$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -ImageReference $VMImage

## The Add-AzureRmVMNetworkInterface cmdlet adds a network interface to a virtual machine. 
## You can add an interface when you create a virtual machine or add one to an existing virtual machine.
#$azVirtualMachine = Add-AzureRmVMNetworkInterface -VM $azVirtualMachine -Id $azInterface.Id

## The Set-AzureRmVMOSDisk cmdlet set the operating system disk properties on a virtual machine.
#$azOSDiskUri = $azStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $azOSDiskName + ".vhd"
#$azVirtualMachine = Set-AzureRmVMOSDisk -VM $azVirtualMachine -Name $azOSDiskName -VhdUri $azOSDiskUri -CreateOption FromImage

## The New-AzureRmVM cmdlet creates a virtual machine in Azure. This cmdlet takes a virtual machine object as input. 
## Use the New-AzureRmVMConfig cmdlet to create a virtual machine object
#New-AzureRmVM -ResourceGroupName $azResourceGroupName -Location $azLocation -VM $azVirtualMachine
#-----------------------------------------------------------


#---------------------AZURE SERVICE MANAGEMENT------------------

## SERVICE MANAGEMENT CMDLETS MUST BE SEPARATELY AUTHENTICATED USING THE ADD-AZUREACCOUNT 
## OR IMPORT-AZUREPUBLISHSETTINGSFILE CMDLETS.)
#Add-AzureAccount

## To connect to Azure using a publish settings file
#Get-AzurePublishSettingsFile
#Import-AzurePublishSettingsFile '<file>'

#If you have multiple subscriptions, the first one is selected as default else use Select-AzureSubscription
#Select-AzureSubscription -SubscriptionId "PJE Test"

#Set the subscription to use a storage account
#Set-AzureSubscription -CurrentStorageAccountName "STORAGEACCOUNT"


#Get-AzureVMImage | where {$_.label -match "Windows Server 2012 R2 Datacenter"} | select imagename,label,location |ft -Wrap

#New-AzureQuickVM –Windows –ServiceName "PJETEST2012R2" –Name "PJETEST2012R2" –Location "West Europe" –AdminUsername $username –Password $password –InstanceSize "Small" –ImageName "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20151022-en.us-127GB.vhd"
#New-AzureQuickVM –Windows –ServiceName "PJETESTCS" –Name "PJETEST2012R2" –Location "West Europe" –AdminUsername $username –Password $password –InstanceSize "Small" –ImageName "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-20151022-en.us-127GB.vhd" -VNetName "PJETEST-Networking"

#Get-AzureRoleAssignment

#This will return all the role assignments in the subscription. Two things to notice:
#1.You'll need to have read access at the subscription level.
#2.If the subscription has a lot of role assignment, it may take a while to get all of them.

#You can also check existing role assignments for a particular role definition, at a particular scope to a particular user. Type:

#Get-AzureRoleAssignment -ResourceGroupName group1 -Mail <user email> -RoleDefinitionName Owner

#This will return all the role assignments for a particular user in your AD tenant, who has a role assignment of "Owner" for resource group "group1". The role assignment can come from two places:
#1.A role assignment of "Owner" to the user for the resource group.
#2.A role assignment of "Owner" to the user for the parent of the resource group (the subscription in this case) because if you have any permission at a certain level, you'll have the same permissions to all its children.

#All the parameters of this cmdlet are optional. You can combine them to check role assignments with different filters.


#Who you want to assign the role to: you can use the following Azure active directory cmdlets to see what users, groups and service principals you have in your AD tenant
#Get-AzureADUser
#Get-AzureADGroup
#Get-AzureADGroupMember
#Get-AzureADServicePrincipal

#What role you want to assign: you can use the following cmdlet to see the supported role definitions.

#Get-AzureRoleDefinition

Get-AzureRmContext



#---------------------------------------------------------------


<#
foreach ($sub in (Get-AzureSubscription))
{
    ## Selecting subscription
    Select-AzureSubscription -SubscriptionName $sub.SubscriptionName
    Write-Output "$($sub.SubscriptionName)"
    Get-AzureVM
}#>







