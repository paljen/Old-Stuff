 function New-Request
 {
    [CmdletBinding()]
    param(
        [String]$User 
    )

    $dateY0 = Get-Date
    $dateY1 = $dateY0.AddYears(-1)
    $dateY2 = $dateY0.AddYears(-2)

    New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "Received -lt '$dateY0' -and Received -gt '$dateY1'" -FilePath "$unc\$user Year0-Year1.pst" -confirm:$false
    
    New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "Received -lt '$dateY1' -and Received -gt '$dateY2'" -FilePath "$unc\$user Year1-Year2.pst" -confirm:$false

    New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "Received -lt '$dateY2'" -FilePath "$unc\$user Year3-YearX.pst" -confirm:$false
    
}

try 
{
    ## Importing exchange module
    if(!((Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available"))
    {
        Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange" | Remove-PSSession -ErrorAction SilentlyContinue 
        $Uri = "http://dkhqexc04n01.prd.eccocorp.net/powershell/"
        $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $Uri -Authentication Kerberos
        Import-PSSession $ExSession
    }
       	
	#------------------------------------------------------------
    # Declaring Variables
    #------------------------------------------------------------       
    # Runbook input Variables
    $user = Read-Host "Please enter the username of user, to backup?"

    # Script specific Variables
	$dc = "dkhqdc01.prd.eccocorp.net"
    $unc = "\\dkhqBackup04\Exchange-PST-Export$"
      
    #------------------------------------------------------------
        
    New-Request -User $user -ErrorAction Stop

}

catch 
{
	$ErrorMessage = $error[0].Exception.Message
	Write-Host "Exception caught: $ErrorMessage"
	$ErrorState = 2
}