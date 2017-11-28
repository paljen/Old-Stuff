$global:ctx = $null
$global:spoPeopleManager = $null
$global:Credentials = $null

Function Connect-EcO365CSOM {
    $password = "76492d1116743f0423413b16050a5345MgB8AEIAOQBuADIASgBBAEcAegA1AEEAZwA3AFIAQQBFAGIAVQAxAHUASwBvAFEAPQA9AHwAYQA5ADgAMAA3ADIAYgA2ADAAZABjADIAMgAyAGIAYQA3AGEAMAA2ADQAOABjAGEAZQBkADEANgAyADEAYQBlADIAYgAxADMAYwAyAGUANwA5ADQAYwA1ADMAOQA5ADUAMgAwAGYAOQA2AGMANQAyAGQAZgBmADUANAA5ADIANAA="
    $key = "96 99 65 89 28 45 161 230 46 154 249 65 90 196 141 173 102 56 238 28 67 178 245 110 243 137 12 179 140 175 232 137"
    $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
    $cred = New-Object system.Management.Automation.PSCredential("AzService-SPAdmin@ecco.onmicrosoft.com", $passwordSecure)

    $spoAdminUrl = "https://ecco-admin.sharepoint.com"

    try {
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.GetNetworkCredential().Username, (ConvertTo-SecureString $cred.GetNetworkCredential().Password -AsPlainText -Force))
        $global:Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.GetNetworkCredential().Username, (ConvertTo-SecureString $cred.GetNetworkCredential().Password -AsPlainText -Force))
        $global:ctx = New-Object Microsoft.SharePoint.Client.ClientContext($spoAdminUrl)
        $global:ctx.Credentials = $spoCredentials
        $global:spoPeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($ctx)
    }
    catch {
        Write-Host -ForegroundColor DarkCyan $_.Exception.Message
    }
}

Function Get-EcSPOUserProfileProperties {
    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true)]
	    [String]$UserPrincipalName
    )

    try {
        $targetSPOUserAccount = ("i:0#.f|membership|" + $UserPrincipalName)
        $UserProfile = $spoPeopleManager.GetPropertiesFor($targetSPOUserAccount)
        $global:ctx.Load($UserProfile)
        $global:ctx.ExecuteQuery()
        write-output $UserProfile.UserProfileProperties
    }
    catch {
        Write-Host -ForegroundColor DarkCyan $_.Exception.Message
    }
}

Function Get-EcSPOUserProfiles {
#    Param
#    (
#	    #User Principal Name of the user [xxx@xxx.xxx]
#	    [Parameter(Mandatory=$true)]
#	    [String]$UserPrincipalName
#    )
                     
    try {
        $SiteURL = "https://ecco.sharepoint.com"
        $LocalContext = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $LocalContext.Credentials = $global:Credentials
        $Users = $LocalContext.Web.SiteUsers
        $LocalContext.Load($Users)
        $LocalContext.ExecuteQuery()
                     
        #Create People Manager object to retrieve profile data
        $PeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($LocalContext)
        $AllUsers = @()
                     
        Foreach ($User in $Users)
            {
            $UserProfile = $PeopleManager.GetPropertiesFor($User.LoginName)
            $LocalContext.Load($UserProfile)
            $LocalContext.ExecuteQuery()
                                 
            If ($UserProfile.Email -ne $null) {
                $AllUsers += $UserProfile
            } 
        }
        write-output $AllUsers
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

Function Set-EcSPOUserProfileProperty {
    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true,Position=1)]
	    [String]$UserPrincipalName,

	    #Value of the sharepoint property to set
	    [Parameter(Mandatory=$true,Position=3)]
	    [String]$PropertyValue,

        #Override if not blank?
        [Parameter(Mandatory=$false,Position=4)]
        [Bool]$OverWriteExisting=$false
    )

    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'PropertyName'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 3

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = (Get-EcSPOUserProfileProperties -UserPrincipalName $UserPrincipalName).Keys
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }
    begin {
        # Bind the parameter to a friendly variable
        $PropertyName = $PsBoundParameters[$ParameterName]
    }

    Process{
        try {
            $targetSPOUserAccount = ("i:0#.f|membership|" + $UserPrincipalName)
        
            #Get the user profile property
            $targetUserProperty = $spoPeopleManager.GetUserProfilePropertyFor($targetSPOUserAccount, $PropertyName)
            $ctx.ExecuteQuery()

            #Set the new Profile Property if different from
            if ($targetUserProperty.Value -ne $PropertyValue) {
                if ([string]::IsNullOrEmpty($targetUserProperty.Value) -or ($OverwriteExisting -eq $true)) {
                    $spoPeopleManager.SetSingleValueProfileProperty($targetspoUserAccount, $PropertyName, $PropertyValue)
                    $ctx.ExecuteQuery()
                    Write-Output "$($UserPrincipalName): [$($PropertyName)]: Property updated with value: $($PropertyValue)"
                }
                else {
                    Write-Output "$($UserPrincipalName): [$($PropertyName)]: Property has value and OverWriteExisting not set, current value: $($targetUserProperty.Value)"
                }
            }
            else {
                Write-Output "$($UserPrincipalName): [$($PropertyName)]: Same value, no update needed"
            }

        }
        catch {
            Write-Output $_.Exception.Message
        }
    }
}

Function Sync-EcSPOUserProfileProperties {
    Param
    (
	    #User Principal Name of the user [xxx@xxx.xxx]
	    [Parameter(Mandatory=$true,Position=1)]
	    [String]$UserPrincipalName
    )

   Process{
    ## Mapping table 
    function Mapping($in)
    {
        switch ($in)
        {
            'EmployeeId' {"Ec-EmployeeId"}
            'departmentNumber' {"Ec-CostCenter"}
            'othertelephone' {"Ec-PhoneExtension"}
            'mobile' {"CellPhone"}
            'co' {"Ec-Country"}
            'telephoneNumber' {"WorkPhone"}
            'physicalDeliveryOfficeName' {"Ec-Location"}
            default{"Property not found in mapping table: $in"}
        } 
    }    

        $props = @("EmployeeId", "departmentNumber", "telephoneNumber", "othertelephone", "mobile", "co", "physicalDeliveryOfficeName")
        
        $ADUser = get-aduser -Filter {UserPrincipalName -eq $UserPrincipalName} -Properties $props | select EmployeeId, @{Name="departmentNumber";Expression={$_.departmentNumber[0]}}, telephoneNumber, @{Name="othertelephone";Expression={$_.othertelephone[0]}}, mobile, co, physicalDeliveryOfficeName
        $SPOUser = Get-EcSPOUserProfileProperties -UserPrincipalName $UserPrincipalName

        $SPOUpdated = $false

        Write-Verbose "[AD Property Name]: AD Property Value `t- [SPO Property Name]:`t SPO Property Value"
        foreach ($prop in $props) {
            $spoprop = Mapping $prop
            $spopropvalue = $SPOUser."$spoprop"
            if ($ADUser."$prop" -eq $spopropvalue -or $ADUser."$prop" -eq $null) {
                Write-Verbose "No change on [$($prop)]: $($ADUser."$prop") `t- [$($spoprop)]:`t $($spopropvalue)"
            }
            else {
                Write-Verbose "Update needed on [$($prop)]: $($ADUser."$prop") `t- [$($spoprop)]:`t $($spopropvalue)"
                Set-EcSPOUserProfileProperty -UserPrincipalName $UserPrincipalName -PropertyName $spoprop -PropertyValue $ADUser."$prop" -OverWriteExisting $false
                $SPOUpdated = $true
            }
        }

        if ($SPOUpdated) {
            Write-Output "SPO User profile for $($UserPrincipalName) updated"
        }
        else {
            Write-Output "SPO User profile for $($UserPrincipalName) already in sync with AD"
        }
    }
}

function Get-EcSPOWebs(){
param(
    [Parameter(Mandatory)]
    $Url = $(throw "Please provide a Site Collection Url"),
   
    [Parameter(DontShow)]
    $IsRoot = $true
)
    $localcontext = New-Object Microsoft.SharePoint.Client.ClientContext($Url)  
    $localcontext.Credentials = $global:Credentials 

    $rootWeb = $localcontext.Web
    Invoke-LoadMethod -ClientObject $rootWeb
    $localcontext.ExecuteQuery()

    $sites = $localcontext.LoadQuery($rootWeb.Webs)
    $localcontext.ExecuteQuery()

    if ($IsRoot) {
        "$($rootweb.Title) - $($rootWeb.Url)"
        $Site = $rootweb | select Title, Url
        Write-Output $Site
    }

    $sites | % {
        #"$($_.Title) – $($_.Url)";
        $Site = $_ | select Title, Url;
        Write-Output $Site;
        Get-EcSPOWebs -Url $_.url -IsRoot $false;
    }
}

Function Invoke-LoadMethod() {
param(
   $ClientObject = $(throw "Please provide an Client Object instance on which to invoke the generic method")
) 
   $ctx = $ClientObject.Context
   $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load") 
   $type = $ClientObject.GetType()
   $clientObjectLoad = $load.MakeGenericMethod($type) 
   $clientObjectLoad.Invoke($ctx,@($ClientObject,$null))
}

# SIG # Begin signature block
# MIITxQYJKoZIhvcNAQcCoIITtjCCE7ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUeFNXUOSSBgZLHTcuSJHemRV1
# +2GgghAZMIIHiDCCBXCgAwIBAgITIgAAAAR+s2mH1OhLhwAAAAAABDANBgkqhkiG
# 9w0BAQsFADAVMRMwEQYDVQQDEwpFQ0NPUm9vdENBMB4XDTE2MTIyMjEwMjQwM1oX
# DTI0MTIyMjEwMzQwM1owXjETMBEGCgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT
# 8ixkARkWCGVjY29jb3JwMRMwEQYKCZImiZPyLGQBGRYDcHJkMRgwFgYDVQQDEw9F
# Q0NPSXNzdWluZ0NBMDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCP
# uOGk33IgLqvcPllj/vbsqISe0S1VGQacC/IEeiPxtuhvVA7U4WyJxeZoKPsHcN6+
# cpDYKov34VOBCshSYAYpefqodOCw4zE8ipGO/f7zM7b7ydKAEMU4c+VV/Xwzizza
# FGt93Rhavxv/1bO4Fh6hgmOFM7OvSNDnRglXmMsjYfV9givwcXZyJ/e6M7ErvJAl
# BrrbiQJC8PrjR0EZfrovuK8cLlu0H4VbgySCWbsv7wIRc5VfqOb6tCOQhdULmeCD
# cKQ0ZXAdPeRBNrb6Q+rBm8uOghrGDQrn/mzZYaSVv3rPBL5UbJpDool3oEggd30j
# ayi+BCwR1cvPipcTgqdnsZAR0Xs84LElYnVRA61BMNvoe0Fjlu8vqYKq2p3NUiSt
# EEOFIIz/CRtbP3zbekmt2/NcTwiu/9LJgQSy1Vczx/fu5Xx67CH06hQ7NfTBNvhK
# MYoJiRr6GEsFhoh7yNf7KNvdtY24N7qqs7yrKsR8r+DfW4UH3NuuKc/huLSMDvaJ
# RrsA9tQgoYWqIHbLzMH7jCbnxuu93N3eKGK2DzFlRF/o7zA4i82KXvptMdJ2Biby
# UCl+0nClObPXo5/WBg2oF5DT5xNG1DSvoTf2SSyR8lThOsPuWdbPZWqqWQd0TugC
# Dyrg1HKCYLnEFhihbfnGYZzDMKSeH5B0YqVqfku70wIDAQABo4IChjCCAoIwEAYJ
# KwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNJVEMp5fcoirx3xIciKItWld94gMDsG
# CSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCPu9RofHhWCJjyGHnMxpge+ZNnqG3O00
# gqyKYAIBZAIBAzALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
# GDAWgBQIoYBnds5rmr8Js4sKRn8KGnUTbjCB4gYDVR0fBIHaMIHXMIHUoIHRoIHO
# hiJodHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3JshoGnbGRhcDovLy9D
# Tj1FQ0NPUm9vdENBLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
# Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERDPW5ldD9j
# ZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlz
# dHJpYnV0aW9uUG9pbnQwge0GCCsGAQUFBwEBBIHgMIHdMC4GCCsGAQUFBzAChiJo
# dHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3J0MIGqBggrBgEFBQcwAoaB
# nWxkYXA6Ly8vQ049RUNDT1Jvb3RDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29y
# cCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwDQYJKoZIhvcNAQELBQADggIBAEXsS0mN57SbxXvzep4M
# C3tCBnkS1j51OKNC/ttGyLRlATF/OZrrsVbnqVtHZUyiUfBmx1ynOzjb44Cp/lAP
# ldJSe/zFpFVIIUyEDeP+I4H3cMoNDI1aKoDdhlJ9A3JyKKYQbVra4iF0u22pNv8X
# jUN5k8Uuyl7N817t7ji1UAhK4ikf+9Ad6u4b5w6WX9QRl1tsj5jw1zO5WQ0lQhN+
# t2axajDDvnUfw3lqJiQzhg0UMyrAovzDMksXw7qR3SeiEfxKzAmMrPs5taHFN2PU
# zU8osto5RGBx99BKDPWw/QL339Pvsu9bGVqgZ5Bi1L8Iv1XsY4jkRupXsPY1qw3l
# ToREuuE2Ti/IhJb/EZchTtqDfmJUH/TYweTu2wDoAzXwonTQNWpHBHf4ftmiRNWw
# i4fUWi4oJchH4CQ0NTJE1hTkRCJum/CS70Dm/8iIickPCw89figUqnK3D9CnRkpL
# cMyPgCstOrOLyyUntRMEzPXBUT2Ah8RBNZ248kTfeRvQgfXMKISJopRKqv7RDItD
# cJl9ThlujbwJoJtWxWm6NgXIXzFIqKB5SioJ3DXy56UylI7O1XygGAR+mqBJQ35A
# IR7fD1YPjD5sv6Ag3ccs5YbU5nrIaAcO6xtmofbtiD8tPyChKkkdcPZVBXImvUM8
# UUa2uTj7CPSTqDcTXFhPfGoXMIIIiTCCBnGgAwIBAgITSwAABaD8SNQO0C7mNAAA
# AAAFoDANBgkqhkiG9w0BAQsFADBeMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYK
# CZImiZPyLGQBGRYIZWNjb2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxGDAWBgNV
# BAMTD0VDQ09Jc3N1aW5nQ0EwMjAeFw0xNzAxMDUwNzAzMjZaFw0xOTAxMDUwNzAz
# MjZaMIGbMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYIZWNj
# b2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxDTALBgNVBAsTBEVDQ08xCzAJBgNV
# BAsTAkRLMQswCQYDVQQLEwJIUTELMAkGA1UECxMCSVQxHzAdBgNVBAMMFlPDuHJl
# biBLasOmcmh1cyAoU0tKQSkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDISpdeD0ivvCdBBH6C98u8aXy+015e9uVTrCrUfLtu//rMuE8XN880is209XAq
# 2Ei9o0EikkQX8MAcQj2lqHf0SIrmG67dRbyBpUrxrU7oZ0tRs0L9dM7NsCMajSBZ
# wBptK89+HEzXAfmN2qWqhrh6WhtXV4WRbaWSjaK3f92vd0GBe5wSn+FdeVd7R+DU
# Z9ZC3cwmdbbHeGXChyxn44+fjhBvFBafL7NiCBORG8dFpBgRi8uUvwuARPss1pe5
# CO/G2JXyoIqyPU0p8q2LMX1MVnOkQSfl/X/8Cq/B7sqrbEbvMNX/9D4FByX1tWNs
# H3qrVn06MEzqOgffjwFwnXF86q6QF5tEFsQ5lS6+dFZis46xs1sXeXfpVE3LahKd
# fNwdTivxYuBayWp3BoFWmbPwO59bLa72P3rsYRKrMFW/F3r8o5zUbiTBVVxVfWF9
# 5f2mxbTdcmiX6MBAEDuCZbpcFbHfY8G7KzpOclwDXx1Aw5WABtC/NVxtkoEX9z9V
# goPJxIOYh/vRqs8ZxKrAIpdrXVnDG/jTPfyxdfBXBC4p6IdHVh4SXzGCeRvtT3yT
# cFTRp8uvff4wCxLVx8GoUpQEjHcdq1vpn0c8LBP+MNVyzErfeObozLox8OTDouBr
# EvrS6g3f7jW/ETIVfKQ6taopeukqsu/f80PGfA5P5eKHAwIDAQABo4IDADCCAvww
# OwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUI+71Gh8eFYImPIYeczGmB75k2eoXL
# zWOF3IFDAgFkAgEkMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIH
# gDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBSixtshpuX+
# WRBzAk9AbylcyxXM5jAfBgNVHSMEGDAWgBTSVRDKeX3KIq8d8SHIiiLVpXfeIDCB
# 7AYDVR0fBIHkMIHhMIHeoIHboIHYhidodHRwOi8vY2RwLmVjY28uY29tL0VDQ09J
# c3N1aW5nQ0EwMi5jcmyGgaxsZGFwOi8vL0NOPUVDQ09Jc3N1aW5nQ0EwMixDTj1D
# RFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29u
# ZmlndXJhdGlvbixEQz1lY2NvY29ycCxEQz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0
# aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIB
# IAYIKwYBBQUHAQEEggESMIIBDjAzBggrBgEFBQcwAoYnaHR0cDovL2NkcC5lY2Nv
# LmNvbS9FQ0NPSXNzdWluZ0NBMDIuY3J0MIGvBggrBgEFBQcwAoaBomxkYXA6Ly8v
# Q049RUNDT0lzc3VpbmdDQTAyLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERD
# PW5ldD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlv
# bkF1dGhvcml0eTAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AuZWNjby5jb20vb2Nz
# cDAoBgNVHREEITAfoB0GCisGAQQBgjcUAgOgDwwNU0tKQUBlY2NvLmNvbTANBgkq
# hkiG9w0BAQsFAAOCAgEAZD1JZLl5RVTYv3QtrHeQMMQU8Ds61uDE5n4Si1pROneR
# nSSUN9/QJI6pyHno0U3GCdIJ4fJr8ZhNeQi0/wLHJ3otEIGTlkYPChhTIRs1Ea7Z
# UiD5ps84RDXm13GYYESwVnmJNX3G6jRetUdChMx6a1FjYrmgD0di/hh7Mwe5tFUz
# Km2lK8jwHscgCMTL/nJ4UdWxcGw16xjEG3wcp+UX+UaegJguYTB6saEoDYojiwyq
# 3zA8Csux6IiMzwg9946PeHo/h5Eokh6LmREjzN7tLvcBRsjmnOjawmpOlcV5uGaS
# BQWWyvcz5dhExw6yEOj8XWf2FGNTfIpgd/P3741YkXA4TDd6JhjBZEXwTceChvLB
# G7UCWnzmKhNJ/d2ny9nUTLXWqYybmgdf3gIo/xioP5tf2Z8K4+SruoeoJl5vgFyf
# PRevaHIuoo+ODscAxrlFRiO/M66NK3UgszXQ9U4cdJ4yfTp9yveGq2wno5qqtOaG
# bTytpYYwRWkdzl7c0KY7fvwfDv2D+a2AH+cSr85SQnzTyE449qgim3MzO8T/hkUg
# 7Uo0Oesn9V2/iNE6rQc890VU1e/1VC69703XGDZMz3yI3sh9AvD5Y6ItiAfZQ/Uc
# F97p3+/Upvwmd4s9nec03bt4pO78fe66L8oOwQ6AHVLS+13YPGi3JRzlrLssYagx
# ggMWMIIDEgIBATB1MF4xEzARBgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJk/Is
# ZAEZFghlY2NvY29ycDETMBEGCgmSJomT8ixkARkWA3ByZDEYMBYGA1UEAxMPRUND
# T0lzc3VpbmdDQTAyAhNLAAAFoPxI1A7QLuY0AAAAAAWgMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBQI66+6GHqR7sFIku++Onm6llCOBTANBgkqhkiG9w0BAQEFAASCAgAEKFIVlZgX
# AFWZOb69jAfCq4CuZALpx5o0aAEBt5n7079fjwIHg72Ta3dw6FhflDbPeVw9K/Jf
# j5DlTzza2GBv3GIoNtlqXTUfjZnV6QHWBUDen/f8dWJ4KzvihPhtD12kSXH3Ln9r
# ksB3kn42j5SiPkrnZgvK5R+dJFknwjVcPnWRYsHUX6tLCAUSByEDyX+jczTtatU5
# BZuZzwDLj9s5AxxCveEmV1ig0RrllauMFSivXy82yb2yVTDZ6qG5inUWupQ5itVh
# ekwepbWGkmkMbil5QA0bfp2MjrfTsCppS+FeZtw9ku+R9s6y+BjJT1ZqBXW1gLbS
# YsLJLCsE8mvSU1r0WbvG5dKeTE3IXMIUOoz2sD22hcBbCKfm/BRvIRm5b+ZfhH02
# lRoPWFyfkhV0OHMgOmXlKoV5zkDnZC1XwPULezWQrqNFHgwok2jgaOVMz/G25eVF
# ngXI5MPhijm+JvF3irb6GKeHiONv7kfvFkOW2G4jqNwQ+Q/9/MWqMdoXRYdXq5jF
# SmqToQSqGCZ+AOsB2X8nb6szl+lu/SHZwaD7ZrJeVVkmyKlOwfstzJzsMe9FoNhh
# zw7F8TGb/C25gwRV1XYEYq8ltVKpaZljnImEtB7JUrnZlSpzPcLZGjel/0IwY0+n
# M1qTQFzYgHo3kQwsZ2NXMybZM39D1ZEyJA==
# SIG # End signature block
