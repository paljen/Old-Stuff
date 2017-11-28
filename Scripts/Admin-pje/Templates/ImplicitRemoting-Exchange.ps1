if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available"){
    Write-Verbose "Importing Module Microsoft.Exchange from http://dkhqexc04n01.prd.eccocorp.net/powershell/"
    $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
    Import-PSSession $ExSession
}
			
			