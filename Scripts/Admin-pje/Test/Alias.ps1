$box2 = Import-Csv C:\Scripts\ECCO\Projects\Exchange\MailboxAlias\E-mailaddressPolitydisabled.csv -Delimiter ';'

<#
$box2 | ForEach-Object {  
   $pos = ($_.PrimarySmtpAddress).IndexOf('@')
   $alias = ($_.PrimarySmtpAddress).Substring(0, $pos) 
   Set-Mailbox -Identity $_.Identity -Alias $alias
}#>


$box2 | ForEach-Object {  
    #Set-Mailbox $_.samaccountname -EmailAddressPolicyEnabled $true
}
