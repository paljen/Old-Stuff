import-module ecco.o365csom
Connect-EcO365CSOM

$Groups = @("SEC-GLOBAL PORTAL ESS", 
            "SEC-GLOBAL PORTAL MSS", 
            "SEC-GLOBAL PORTAL MSS LEAVE REQUEST", 
            "SEC-GLOBAL PORTAL MSS LEAVE REQUEST WITHOUT REPORTS", 
            "SEC-GLOBAL PORTAL MSS WITHOUT E-REC", 
            "SEC-GLOBAL PORTAL PDF TO SPOOL FILE", 
            "SEC-GLOBAL PORTAL TNT")

$ADOutPut = @()
$Groups | % {$CurGroup = $_; Get-ADGroupMember $CurGroup -Recursive | % {$ADOutPut += [pscustomobject]@{GroupName=$CurGroup;SamAccountName=$_.SamAccountName}}}

#GetAll sharepoint user profiles
$SPOUsers = Get-EcSPOUserProfiles

#Creating an ilist object to set multivalue field in spo user profile
$type = ("System.Collections.Generic.List"+'`'+"1") -as "Type"
$type = $type.MakeGenericType("system.string" -as "Type")
#Initiate a new instance: $GroupList = [Activator]::CreateInstance($type)

#Loop through SPO users with values in Ec-PortalGroups
foreach ($spouser in ($SPOUsers | ? {[string]($_.UserProfileProperties.'Ec-PortalGroups').Trim() -ne ""})) {
    $userprofilemgr = new-object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Global:ctx) 

    Write-Output "Updating user: $($SPOUser.Email)"
    $UsersGroups = $ADOutPut | ? {"$($_.SamAccountName)@ecco.com" -eq $spouser.UserProfileProperties.UserName}
    if ($UsersGroups) {
        $GroupList = [Activator]::CreateInstance($type)
        foreach ($UsersGroup in $UsersGroups) {
            $GroupList.add($UsersGroup.GroupName)
        }
        #Write-Debug $GroupList
        $userprofilemgr.SetMultiValuedProfileProperty($spouser.AccountName, 'Ec-PortalGroups', $GroupList)
        $Global:ctx.ExecuteQuery()

        $ADOutPut = $ADOutPut | ? {"$($_.SamAccountName)@ecco.com" -ne $spouser.UserProfileProperties.UserName}
    }
    Else {
        #No groups, clear the property
        Set-EcSPOUserProfileProperty -UserPrincipalName $spouser.UserProfileProperties.'SPS-UserPrincipalName' -PropertyName Ec-PortalGroups -PropertyValue " " -OverWriteExisting $true    
    }
}

#Loop trough remaining ADOutput object and update SPO users
$UUsers = $ADOutPut | select -Unique SamAccountName
$i=1
foreach ($User in $UUsers.SamAccountName) {
    Write-Progress -Activity "Processing Users" -Status "$($i) of $($UUsers.Count)" 
    Write-Output "Updating user: $($User)"
    $userprofilemgr = new-object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Global:ctx) 
    $UsersGroups = $ADOutPut | ? {$_.SamAccountName -eq $User}

    $GroupList = [Activator]::CreateInstance($type)
    foreach ($UsersGroup in $UsersGroups) {
        $GroupList.add($UsersGroup.GroupName)
    }
    $GroupList

    $SPOAccountName = "i:0#.f|membership|$($User)@ecco.com" 
    $userprofilemgr.SetMultiValuedProfileProperty($SPOAccountName, 'Ec-PortalGroups', $GroupList)
    $Global:ctx.ExecuteQuery()
    $i++
    #$ADOutPut = $ADOutPut | ? {"$($_.SamAccountName)@ecco.com" -ne $spouser.UserProfileProperties.UserName}
}

