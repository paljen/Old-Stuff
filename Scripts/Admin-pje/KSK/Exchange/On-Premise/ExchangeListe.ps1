


Get-ADUser -Filter * -Properties Manager,EmployeeNumber,lastLogonTimestamp | ? {$_.enabled -eq $true} | foreach {
    $mb = Get-Mailbox -identity $_.samaccountname -ErrorAction ignore | ? {$_.RecipientTypedetails -eq "Usermailbox"} | select UserPrincipalName,OrganizationalUnit

    if($mb -ne $null)
    {
        $props = [ordered]@{
               'GivenName'=$_.GivenName;
               'SurName'=$_.SurName;
               'EmployeeNumber'=$_.EmployeeNumber;
               'UserPrincipalName'=$mb.UserPrincipalName;
               'OrganizationalUnit'=$mb.OrganizationalUnit
               'Manager'=$_.Manager;
               'LastLogonTimeStamp'=[datetime]::FromFileTime($_.lastLogonTimestamp).ToString('g')}

        $obj = New-Object -TypeName PSObject -Property $props
        $obj | Export-Csv "$env:temp\ExchangeUSers.csv" -Append -NoClobber -Encoding UTF8 -NoTypeInformation
    }  
} 