
$ses = Get-PSSession | ? {$_.ConfigurationName -eq 'Microsoft.Exchange' -and $_.Availability -eq "Available"}
    try{
        $userMB = Invoke-Command -Session $ses -ScriptBlock { Get-Mailbox ksk } -ErrorAction Stop
        }
        catch
        {
            $ErrorMessage = $error[0].Exception.Message
	        Write-host "Exception caught during action : $ErrorMessage" -Trace
	        $ErrorState = 2
        }




