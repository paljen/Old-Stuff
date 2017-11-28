cls

if(!(Get-Module SkypeForBusiness))
{Import-Module SkypeForBusiness}

function Write-LogFile
{
	param(
	
		[string]$Message
	)
	
	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($("$env:TEMP\UC.log"), $true)
	$Output = "$([DateTime]::Now): $Message"
	$Log.WriteLine($Output)
	$Log.Close()
}

## create array with full list of users with their telephone- and employeenumber
$users = Get-ADUser -Filter * -Properties Telephonenumber,Employeenumber

## traverse lync users and get ad properties for each user
(Get-CsUser | ? {$_.EnterpriseVoiceEnabled -ne $true}).Identity.DistinguishedName | ForEach-Object {
    Get-ADUser -Identity $_ -Properties Telephonenumber,Employeenumber | ForEach-Object {
        
        ## cast telephonenumber to string
        $tlf = [String]$_.telephonenumber

        ## create array with telephonenumbers from the users list that match the traversing user telephonenumber
        $match = $users.telephonenumber -eq $tlf

        try
        {
            ## if the match count is 1 the traversing user telephonenumber is unique. 
            ## if the match count is -gt 1 there are more users with the same telephonenumber as the traversing user
            if($match.count -gt 1)
            {
                write-host $($_.DistinguishedName)
                ## for users with non unique telephonenumber the lync lineuri is set to employeenumber
                Set-CsUser -Identity $_.DistinguishedName -LineURI "tel:+00$($_.Employeenumber)" -ErrorAction Stop
                Write-LogFile "Set-CsUser -Identity $($_.DistinguishedName) -LineURI `"tel:+00$($_.Employeenumber)`""
                      
            }
            else
            {
                ## telephonenumber not null and telephonenumber match format criteria
                if($_.Telephonenumber -ne $null -and $_.Telephonenumber -match "[+]\d*")
                {
                    Set-CsUser -Identity $_.DistinguishedName -LineURI "tel:$($_.Telephonenumber)"
                    Write-LogFile "Set-CsUser -Identity $($_.DistinguishedName) -LineURI `"tel:$($_.Telephonenumber)`""
                }

                ## telephonenumber is null and employeenumber not null and employeenumber match format criteria
                elseif($_.Telephonenumber -eq $null -and $_.EmployeeNumber -ne $null -and $_.EmployeeNumber -match "\d{8}\d*")
                {
                    Set-CsUser -Identity $_.DistinguishedName -LineURI "tel:+00$($_.Employeenumber)"
                    Write-LogFile "Set-CsUser -Identity $($_.DistinguishedName) -LineURI `"tel:+00$($_.Employeenumber)`""
                }

                ## write to log file if for some reason no numbers are present or format is'nt meet
                else
                {
                    Write-LogFile "$($_.DistinguishedName) $($_.Telephonenumber) $($_.EmployeeNumber) - both numbers were `$null or didnt match format"
                }
            }
        }

        catch
        {
            Write-Logfile $_.Exception.Message
        }
    }
}