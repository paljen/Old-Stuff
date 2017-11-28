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
            Write-Output ("VM '{0}' does not exist. Will create it." -f $Using:VMName)
            
            Write-Output ("Getting the VM Image list for OS '{0}'.." -f $Using:OSName)
            # get OS Image list for $OSName
            $OSImages=Get-AzureVMImage | Where-Object {($_.Label -ne $null) -and ($_.Label.Contains($Using:OSName))}
            if ($OSImages -eq $null) 
       	    {
          	 throw "'Get-AzureVMImage' activity: Could not get OS Images whose label contains OSName '{0}'" -f $Using:OSName
            } 
            Write-Output ("Got the VM Image list for OS '{0}'.." -f $Using:OSName)
            
            # Get the latest VM Image info for OSName provided
            $OSImages = $OSImages | Sort-Object -Descending -Property PublishedDate 
            $OSImage = $OSImages |  Select-Object -First 1 
                                  
            if ($OSImage -eq $null) 
       	    {
          	 throw " Could not get an OS Image whose label contains OSName '{0}'" -f $Using:OSName
            } 
            Write-Output ("The latest VM Image for OS '{0}' is '{1}'. Will use it for VM creation" -f $Using:OSName, $Using:OSImage.ImageName)
            $stgAcc = Get-AzureStorageAccount -StorageAccountName $Using:StorageAccountName
            
            if( $stgAcc -eq $null)
            {
                Write-Output "Creating Storage Account"
                $result = New-AzureStorageAccount -StorageAccountName $Using:StorageAccountName -Location $Using:Location
                
                if ($result -eq $null)
                {
                   throw "Azure Storage Account '{0}' was not created successfully" -f $Using:StorageAccountName
                } 
                else
                {
                   Write-Output ("Storage account '{0}' was created successfully" -f $Using:StorageAccountName)
                }
            }
            else
            {
                 Write-Output ("Storage account '{0}' already exists. Will use it for VM creation" -f $Using:StorageAccountName)
            }        
            Set-AzureSubscription -SubscriptionName $Using:AzureConnectionName -CurrentStorageAccountName $Using:StorageAccountName
            
            #check cloud service by name $ServiceName already exists
            $CloudServiceInfo = Get-AzureService -ServiceName $Using:ServiceName
            
            Write-Output ("Creating VM with service name  {0}, VM name {1}, image name {2}, Location {3}" -f $Using:ServiceName, $Using:VMName, $OSImage.ImageName, $Location)
             
            # Create VM    
            if( $OSImage.OS -eq "Linux" )
            {
               if( $CloudServiceInfo -eq $null)
               {
                   $AzureVMConfig = New-AzureQuickVM -Linux -ServiceName $Using:ServiceName -Name $Using:VMName -ImageName $OSImage.ImageName -Password $Using:VMPassword -LinuxUser $Using:VMUserName -Location $Using:Location -InstanceSize $Using:VMSize -WaitForBoot 
               }
               else
               {
                    $AzureVMConfig = New-AzureQuickVM -Linux -ServiceName $Using:ServiceName -Name $Using:VMName -ImageName $OSImage.ImageName -Password $Using:VMPassword -LinuxUser $Using:VMUserName -InstanceSize $Using:VMSize -WaitForBoot 
               }
            }
            if( $OSImage.OS -eq "Windows" )
            {
               if( $CloudServiceInfo -eq $null)
               {
                    $AzureVMConfig = New-AzureQuickVM -Windows -ServiceName $Using:ServiceName -Name $Using:VMName -ImageName $OSImage.ImageName -Password $Using:VMPassword -AdminUserName $Using:VMUserName -Location $Using:Location -InstanceSize $Using:VMSize -WaitForBoot
               }
               else
               {
                   $AzureVMConfig = New-AzureQuickVM -Windows -ServiceName $Using:ServiceName -Name $Using:VMName -ImageName $OSImage.ImageName -Password $Using:VMPassword -AdminUserName $Using:VMUserName -InstanceSize $Using:VMSize -WaitForBoot
               } 
            }
    
            $AzureVM = Get-AzureVM -ServiceName $Using:ServiceName -Name $Using:VMName
            if ( ($AzureVM -ne $null) ) 
       	    {
          	    Write-Output ("VM '{0}' with OS '{1}' was created successfully" -f $Using:VMName, $Using:OSName)
            }
            else
            {
                throw "Could not retrieve info for VM '{0}'. VM was not created" -f $Using:VMName
            } 
        }
        else
        {
            Write-Output ("VM '{0}' already exists. Not creating it again" -f $Using:VMName)
        }      
    }