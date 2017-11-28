
# Cred
$password = "76492d1116743f0423413b16050a5345MgB8AHoAdgBkAGwAeABrAFoAYQBVAEsAbgBoAHAAbABaAHUAYwBCAFcAQgBlAGcAPQA9AHwAYQA5AGIAYQAzADcANgAzADcAMQA5ADIAOQBjADkAZQBiADUAZgA2ADkAZABjADkAZgA0ADYAZgBmADQAZgA0AGEAYwBjAGUAYgBiADcAMAAxAGQAMQAxADUAYQA5ADEAMgBhAGUAOQBjAGIAOAAxADEAYQAyAGUANgA1ADUAOAA="
$key = "25 87 22 128 58 55 6 185 163 103 128 234 246 56 146 167 35 19 193 164 124 125 54 132 216 127 241 172 102 18 163 207"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred =  New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "prd\admin-pje",$passwordSecure

# Establish an external session (to DC) to ensure 64bit PowerShell runtime using the latest version of PowerShell installed on the DC
$Session = New-PSSession -ComputerName dkhqexcman02 -Credential $cred -Authentication Credssp

# Invoke-Command used to run scriptcode in the external session. Return data are stored in the $ReturnArray variable
$ReturnArray = Invoke-Command -Session $Session -ScriptBlock {
 

    try 
	{

        # Add startup details to trace log
        Write-host "Script now executing in external PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process"
        Write-host "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
        
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn		

        #$ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://dkhqexc04n01.prd.eccocorp.net/powershell/ -Authentication Kerberos
        #Import-PSSession $ExSession

        $user = "ksk"
        
        $test = (Get-Date).AddYears(-2)
        
        # Script specific Variables
        $dc = "dkhqdc01.prd.eccocorp.net"
        $exportPath = "\\dkhqBackup04\Exchange-PST-Export$"

        New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter {(Received -lt $test)} -FilePath "$exportPath\$user-2.pst" -confirm:$false
    }
	
    catch
	{
        # Catch any errors thrown above here, setting the result status and recording the error message to return to the activity for data bus publishing
        $ResultStatus = "Failed"
        $ErrorMessage = $error[0].Exception.Message
        Write-host "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
    }
	
   
	
}#End Invoke-Command


# Close the external session
Remove-PSSession $Session