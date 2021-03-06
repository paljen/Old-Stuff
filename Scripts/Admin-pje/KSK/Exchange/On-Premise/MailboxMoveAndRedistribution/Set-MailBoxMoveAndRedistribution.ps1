#Function New-ECCOExchangeTask
#{
    [CmdletBinding(DefaultParameterSetName="NONE")]

    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="Move")]
        [String]$ComputerName,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="Redist")]
        [Switch]$RedistributeActiveDatabases,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="Move")]
        [Switch]$MoveActiveMailboxDatabase,
        [Parameter(Mandatory=$false)]
        [Switch]$ErrorLog
    )

    Begin {
	<#
        if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available"){
		    Write-Verbose "Importing Module Microsoft.Exchange from http://dkhqexc04n01.prd.eccocorp.net/powershell/"
            $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
	        Import-PSSession $ExSession}
	#>
	
	if (!(Get-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010)){
		Add-PSSnapin Microsoft.Exchange*
	}
	
        [int32]$eState = 1

        if(!$ComputerName){
            ## Typecast ComputerName String to ComputerName Array
            [System.Collections.ArrayList]$ComputerName = (Get-DatabaseAvailabilityGroup).Servers
        }

        if($ErrorLog){
            $ErrorLogFilePath = 'C:\Error.txt'
			Write-Verbose "ErrorLog enabled, Filepath $($ErrorLogFilePath)"
        }
    }

    Process 
    {
		try{
	        $timeout = New-TimeSpan -Seconds 10
	        $sw = [diagnostics.stopwatch]::StartNew()
	        Write-Verbose "Entering While Loop: TimeOut set to $($timeout) and `$eState equals $($eState)"

	        while (($sw.elapsed -lt $timeout) -and ($eState -eq 1)){
                foreach ($Server in $ComputerName)
                {   
				    $tmp = (Get-MailboxDatabaseCopyStatus -Server $Server -ErrorAction Stop | where {($_.Status -ne "Healthy" -and $_.status -ne "Mounted") -or ($_.ContentIndexState -ne "Healthy")})
                    if ($tmp.count -gt 0){
                      $bad = $tmp
                      Write-verbose "Get-MailboxDatabaseCopyStatus for $($Server) returned: $($bad.Count) results"
                    }
                }
                if (-not $bad){
	                $eState = 0
                    Write-Host "DB Status OK" -ForegroundColor "Green"
                    Write-verbose "`$eState set to 0 - Everything is healthy"
					Break;}

				else {
                    $bad = $null
					Start-Sleep 2
	                Write-verbose "`$eState equals 1 and $($sw.elapsed) - Refreshing Status"
                }
	        }

	        if($eState -eq 0){
	            if ($RedistributeActiveDatabases){
	                write-verbose "RedistributeActiveDatabases -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference"
	                Invoke-Expression "d:\Exchange\Scripts\RedistributeActiveDatabases.ps1 -DagName $((Get-DatabaseAvailabilityGroup).name) -BalanceDbsByActivationPreference -Confirm:`$false -whatif:`$true"
	                write-output "RedistributeActiveDatabases - TASK DONE!"
	            }

		        if ($MoveActiveMailboxDatabase){
		            write-verbose "MoveActiveMailboxDatabase -Server $($ComputerName)"
					#Move-ActiveMailboxDatabase -Server $ComputerName
					write-output "Move-ActiveMailboxDatabase - TASK DONE!" 
		        }
		    }

			else{
	            if($ErrorLog){
	                Write-Verbose "`$eState equals 1, ERRORS LOGGED - $($ErrorLogFilePath)"
	                $bad | out-file $ErrorLogFilePath -Append
	            }
                else{
                    Write-Host "DB Status NOT OK" -ForegroundColor "Red"
                    Write-Verbose "`$eState equals 1 - NO ACTION TAKEN"   
                } 
	        }
		}
		
		catch{
			Write-Error "Could not connect to $($ComputerName)"
        }
		
		finally{
		}
    }

    End {
        Write-verbose "Script ended"
	}
#}


#Get-MailboxDatabaseCopyStatus -Server "dkhqexc04n04"