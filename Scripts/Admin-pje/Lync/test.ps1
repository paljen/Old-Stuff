
$password = "76492d1116743f0423413b16050a5345MgB8ACsATAB0ADUARQAyADQAWQBmAGsAdwBaAHQAQgBtAEgARgBVAEMAYQBoAGcAPQA9AHwAMQA2AGIAMwAyAGMAYwA4AGEAYQA5ADIANwAxAGYAYQA4ADUANgBiAGIAMgAwADMAMwBhAGYAYgAzAGYAOQA4ADYAMQA3ADgANgA5ADkAZABmAGYAYwA3ADMAMwAzADUAOQA2ADIAOQA4AGIAYwAzAGMAMwA0ADEAMQBmAGUAYQA2ADcAOQA2ADcAZAAyADYANABlADEAZAAzADUAYQAwADkAZgBiADEAZgBmADcANwA1AGYAMABjAGIAOAA4ADUA"
$key = "86 238 141 64 11 66 201 110 204 26 199 11 55 151 172 232 38 153 188 64 18 75 132 90 18 190 222 122 218 166 91 144"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$cred = New-Object system.Management.Automation.PSCredential("service-scorchraa", $passwordSecure)

# Create session on UC server
$session = New-PSSession -ComputerName DKHQUC02N01.prd.eccocorp.net -Credential $cred -Authentication Credssp

# Invoke-Command used to run scriptcode in the external session. Return data are stored in the $ReturnArray variable
Invoke-Command -Session $session -ScriptBlock {
	
    Function Write-LogFile
    {
        [CmdletBinding()]

	    param(

            [Parameter(Position=0)]
            [string]$Message

	    )
    
        $Output = "$([DateTime]::Now): $Message"
	    [System.IO.StreamWriter]$Log = New-Object System.IO.StreamWriter("$env:TEMP\UC-LineURI.log", $true)

	    $Log.WriteLine($Output)
	    $Log.Close()
    }

    try 
    {
        # Add startup details to trace log
        Write-LogFile "Script now executing in external PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process"
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"
		
        # Import Module               
        if(!(Get-Module SkypeForBusiness))
        {Import-Module SkypeForBusiness}

        # CODE START

        (Get-CsUser | ? {$_.EnterpriseVoiceEnabled -ne $true}).Identity.DistinguishedName | ForEach-Object {
            Get-ADUser -Identity $_ -Properties Telephonenumber,Employeenumber | ForEach-Object {
                if($_.Telephonenumber -ne $null -and $_.Telephonenumber -match "[+]\d*")
                {
                    ## Set-CsUser -Identity $_.Name -LineURI "tel:$($_.Telephonenumber)"
                    Write-LogFile "$($_.Name) $($_.Telephonenumber) $($_.EmployeeNumber) - LineURI = $($_.Telephonenumber)"
                }
                elseif($_.Telephonenumber -eq $null -and $_.EmployeeNumber -ne $null -and $_.EmployeeNumber -match "\d{8}\d*")
                {
                    ## Set-CsUser -Identity $_.Name -LineURI "tel:+00$($_.Employeenumber)"
                    Write-LogFile "$($_.Name) $($_.Telephonenumber) $($_.EmployeeNumber) - LineURI = +00$($_.EmployeeNumber)"
                }
                else
                {
                    Write-LogFile "$($_.Name) $($_.Telephonenumber) $($_.EmployeeNumber) - both numbers were `$null or didnt match format"
                }
            }
        }

        ## CODE END
    }
	
    catch
    {
        $rErrorMessage = $error[0].Exception.Message
        Write-LogFile "Exception caught: $rErrorMessage"
    }
}

# Close the external session
Remove-PSSession $Session