function Get-DistributionGroupMembers
{
    [CmdletBinding()]

    Param (

        [String]$DistributionGroup,
        [Switch]$isGroup,
        [Switch]$isUser
    )

    filter ExchFilter
    {
        if($isGroup)
        {
            $input | where {($_.Name -like 'O_*' -or $_.Name -like 'N_*') -and ($_.RecipientType -match 'Group')}
            #$input | where {($_.name -like 'O_*' -or $_.name -like 'N_*') -and ($_.ClassName -match 'Group')}
        }
        if($isUser)
        {
            $input | Where {($_.RecipientType -eq 'UserMailbox' -OR $_.RecipientType -eq 'MailContact')}
            #$input | Where {($_.Classname -eq 'User' -OR $_.Classname -eq 'Contact')}
        }
        else
        {
            $input
        }
    }
    
   # Get-Qadgroupmember -Identity $DistributionGroup | ExchFilter
   Get-DistributionGroupMember -Identity $DistributionGroup | ExchFilter
}

Get-DistributionGroupMembers -DistributionGroup "SP.SALES"