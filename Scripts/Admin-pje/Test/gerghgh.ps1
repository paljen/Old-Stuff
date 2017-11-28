$GroupSAM = "testgrourp"
$UserSAM = "ksk"

## test if the Group exist else return false
if ($(Get-ADObject -Filter {(SamAccountName -eq $Using:GroupSAM) -and (objectClass -eq "Group")}))
{
    ## test if the user exist else return false
    if ($(Get-ADObject -Filter {(SamAccountName -eq $Using:UserSAM) -and (objectClass -eq "User")}))
    {
        ## test if the user is not already member of the group else return false
        if(((Get-ADGroupMember -Identity $Using:GroupSAM).SamAccountName) -inotcontains $Using:UserSAM)
        {
            # Add user to group
    	    #Add-ADGroupMember -Identity $Using:GroupSAM -Members $Using:UserSAM
            $true
        }
        else
        {
            $false
        }
    }
    else
    {
        $false
    }
}
else
{
    $false
}           