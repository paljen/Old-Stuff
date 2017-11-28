$EncryptedAccount = @'
## Encrypted Credentials Code Generator
$path = 'c:\windows\temp\template.ps1'
New-Item -ItemType File $path -Force -ErrorAction SilentlyContinue  
  
$pwd = Read-Host 'Enter Password' -AsSecureString  
$user = Read-Host 'Enter Username'  
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 }  
$pwdencrypted = $pwd | ConvertFrom-SecureString -Key $key 
  
$private:ofs = ' '  
('$password = "{0}"' -f $pwdencrypted) | Out-File $path  
('$key = "{0}"' -f "$key") | Out-File $path -Append  
  
'$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))' | Out-File $path -Append  
('$cred = New-Object system.Management.Automation.PSCredential("{0}", $passwordSecure)' -f $user) | Out-File $path -Append  
  
ise $path
'@

New-IseSnippet -Force -Title "ECCO Comment Block" -Description "Basic Comment Block" -Author "Palle Jensen" -CaretOffset 50 -Text '
<#
.SYNOPSIS
	A brief description.

.DESCRIPTION
	A detailed description.

.PARAMETER  <Parameter-Name>
	The description of a parameter. Add a .PARAMETER keyword for each 
    parameter in the syntax.

.EXAMPLE
	A sample command , optionally followed by sample output and a description. 
    Repeat this keyword for each example.

.INPUTS
	The Microsoft .NET Framework types of objects that can be piped to the
	function. You can also include a description of the input objects.

.OUTPUTS
	The .NET Framework type of the objects that the function returns. You can
	also include a description of the returned objects.

.NOTES
	Version:		1.0.0
	Author:			
	Creation Date:	
	Purpose/Change:	Initial function development
#>
'

New-IseSnippet -Force -Title "ECCO Object (String based - Selected)" -Description "Custom object, simple string" -Author "Palle Jensen" -Text '
$newObj = "" | select "Property1","Property2"
$newObj.Property1 = "Value1"
$newObj.Property2 = "Value2"

$myObj = get-service bits | select name, priority
$myObj.priority = "high"
'

New-IseSnippet -Force -Title "ECCO Object (NoteProperty)" -Description "Standard custom object" -Author "Palle Jensen" -Text '
$newObj = New-Object PSObject
$newObj | Add-Member -Type NoteProperty -Name FirstName -Value "Mike"
$newObj | Add-Member -Type NoteProperty -Name LastName -Value "Tyson"
$newObj | Add-Member -Type NoteProperty -Name Mobile -Value 01010101
'

New-IseSnippet -Force -Title "ECCO Object (Hashtable1)" -Description "Custom Object with hashtable technique 1" -Author "Palle Jensen" -Text '
$props = [Ordered]@{
         Firstname="Mike";
         LastName="Tyson";
         Mobile="01010101"}

$newObj = New-Object -TypeName PSObject –Prop $props
'

New-IseSnippet -Force -Title "ECCO Object (Hashtable2)" -Description "Custom Object with hashtable technique 2" -Author "Palle Jensen" -Text '
$props = @{}

$props.Firstname = "Mike"
$props.Lastname = "Tyson"
$props.Mobile = "01010101"

$newObj = New-Object -TypeName PSObject –Prop $props
'

New-IseSnippet -Force -Title "ECCO Collection (Splatting)" -Description "Use hashtable as properties" -Author "Palle Jensen" -Text '
#http://blogs.technet.com/b/heyscriptingguy/archive/2010/10/18/use-splatting-to-simplify-your-powershell-scripts.aspx

$usr = @{
    SamAccountName = "PJ*"
    LastName = "Jensen"
}

Get-QADUser @usr
'

New-IseSnippet -Force -Title "ECCO Session (Kerboros)" -Description "Session with Kerboros" -Author "Palle Jensen" -Text '
# Create session using Kerberos with direct remoting, number of hubs -eq 1. ex. comp1 to comp2

$session = New-PSSession -Name "<SessionName>" -ComputerName "<RemoteHost>" -Credential $cred
'

New-IseSnippet -Force -Title "ECCO Session (CredSSP)" -Description "Session with CredSSP" -Author "Palle Jensen" -Text '
# Create session using CredSSP with indirect remoting, number of hubs -gt 1. ex. remoting from comp1 to comp3 via comp2
# This approach requires that the machines are configured to allow delegate credentials, test with Get-WSManCredSSP and set with Set-WSManCredSSP

$session = New-PSSession -Name "<SessionName>" -ComputerName "<RemoteHost>" -Credential $cred -Authentication CredSSP
'

New-IseSnippet -Force -Title "ECCO Session (Invoke-command)" -Description "Import modules inside remote sessions" -Author "Palle Jensen" -Text '
## Import module within session

$mName = "<modulename>"
Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name $Using:mName}
'

#New-IseSnippet -Force -Title "ECCO Encrypted Automation Account" -Description "Encrypt Automation Account" -Author "Palle Jensen" -Text $EncryptedAccount