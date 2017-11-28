
$Path = Split-Path -Parent $MyInvocation.MyCommand.Definition

## Create credentails for MSOL, use SecurePassword.ps1 to create cred.txt
$Pass = Get-Content "$Path\cred.txt" | ConvertTo-SecureString
$Pass
$MSOCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "AzAdmin-pje@ecco.onmicrosoft.com",$Pass
## Connect to Azure AD 

Connect-MsolService -Credential $MSOCred

#Get-MsolSubscription

#Get-MsolUser -UserPrincipalName pje@ecco.com




Set-MsolUserPassword –UserPrincipalName AzService-Automation@ecco.onmicrosoft.com –NewPassword "`ZNg@sC>y3(?8L9" -ForceChangePassword $False
Get-MsolUser -userprincipalname AzService-Automation@ecco.onmicrosoft.com | set-msoluser -PasswordNeverExpires $true

#Import-Csv C:\Scripts\ECCO\Test\Users.csv | foreach-object { get-aduser $_.Alias } | where { $_.isLicensed -eq "TRUE" } | Select UserPrincipalName




