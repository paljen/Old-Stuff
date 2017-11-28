$global:ctx = $null
$global:o365

Function Connect-EcO365CSOMv2 {
    $password = "76492d1116743f0423413b16050a5345MgB8AEIAOQBuADIASgBBAEcAegA1AEEAZwA3AFIAQQBFAGIAVQAxAHUASwBvAFEAPQA9AHwAYQA5ADgAMAA3ADIAYgA2ADAAZABjADIAMgAyAGIAYQA3AGEAMAA2ADQAOABjAGEAZQBkADEANgAyADEAYQBlADIAYgAxADMAYwAyAGUANwA5ADQAYwA1ADMAOQA5ADUAMgAwAGYAOQA2AGMANQAyAGQAZgBmADUANAA5ADIANAA="
    $key = "96 99 65 89 28 45 161 230 46 154 249 65 90 196 141 173 102 56 238 28 67 178 245 110 243 137 12 179 140 175 232 137"
    $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
    $cred = New-Object system.Management.Automation.PSCredential("AzService-SPAdmin@ecco.onmicrosoft.com", $passwordSecure)

    $spoAdminUrl = "https://ecco-admin.sharepoint.com"

    try {
        #$uri = New-Object System.Uri -ArgumentList $adminUrl
        $global:ctx = New-Object Microsoft.SharePoint.Client.ClientContext($spoAdminUrl)

        $global:ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.GetNetworkCredential().Username, (ConvertTo-SecureString $cred.GetNetworkCredential().Password -AsPlainText -Force))
        $global:o365 = New-Object Microsoft.Online.SharePoint.TenantManagement.Office365Tenant($global:ctx)
        $global:ctx.Load($o365)


#        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.GetNetworkCredential().Username, (ConvertTo-SecureString $cred.GetNetworkCredential().Password -AsPlainText -Force))
#        $global:ctx = New-Object Microsoft.SharePoint.Client.ClientContext($spoAdminUrl)
#        $global:ctx.Credentials = $spoCredentials
#        $global:spoPeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($ctx)
    }
    catch {
        Write-Host -ForegroundColor DarkCyan $_.Exception.Message
    }
}


Function Sync-EcSPOUserProfilesJSON {

    # Get needed information from end user
#    $adminUrl = Read-Host -Prompt 'Enter the admin URL of your tenant'
#    $userName = Read-Host -Prompt 'Enter your user name'
#    $pwd = Read-Host -Prompt 'Enter your password' -AsSecureString
    $importFileUrl = Read-Host -Prompt 'Enter the URL to the file located in your tenant'

    # Get instances to the Office 365 tenant using CSOM
#    $uri = New-Object System.Uri -ArgumentList $adminUrl
#    $global:ctx = New-Object Microsoft.SharePoint.Client.ClientContext($uri)

#    $global:ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($userName, $pwd)
#    $o365 = New-Object Microsoft.Online.SharePoint.TenantManagement.Office365Tenant($global:ctx)
#    $global:ctx.Load($o365)

    # Type of user identifier ["Email", "CloudId", "PrincipalName"] in the User Profile Service
    $userIdType=[Microsoft.Online.SharePoint.TenantManagement.ImportProfilePropertiesUserIdType]::PrincipalName

    # Name of user identifier property in the JSON
    $userLookupKey="userprincipalname"

    # Create property mapping between on-premises name and O365 property name
    # Notice that we have here 2 custom properties in UPA called 'City' and 'OfficeCode'
    $propertyMap = New-Object -type 'System.Collections.Generic.Dictionary[String,String]'
    $propertyMap.Add("EmployeeId", "Ec-EmployeeId")
    $propertyMap.Add("departmentNumber", "Ec-CostCenter")
    $propertyMap.Add("othertelephone", "Ec-PhoneExtension")
    $propertyMap.Add("mobile", "CellPhone")
    $propertyMap.Add("co", "Ec-Country")
    $propertyMap.Add("telephoneNumber", "WorkPhone")
    $propertyMap.Add("physicalDeliveryOfficeName", "Ec-Location")


    # Call to queue UPA property import 
    $workItemId = $global:o365.QueueImportProfileProperties($userIdType, $userLookupKey, $propertyMap, $importFileUrl);

    # Execute the CSOM command for queuing the import job
    $global:ctx.ExecuteQuery();

    # Output unique identifier of the job
    Write-output "Import job created with following identifier:" $workItemId.Value 
}