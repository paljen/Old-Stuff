if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available")
{	$ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
	Import-PSSession $ExSession}

function exchange
{
    [CmdletBinding(DefaultParameterSetName="None")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$ComputerName,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="Redist")]
        [Switch]$RedistributeActiveDatabases,
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ParameterSetName="Move")]
        [Switch]$MoveActiveMailboxDatabase,
        [Parameter(Mandatory=$false)]
        [Switch]$ErrorLog
    )

    Begin {
        #if(!$ComputerName){
        #    $ComputerName = (Get-DatabaseAvailabilityGroup).Servers
        #}
		
		$ErrorActionPreference = "Stop"
		
        if($ErrorLog){
            $ErrorLogFilePath = 'C:\Error.txt'
        }
    }

    Process 
    {
		try{
	        foreach ($Server in $ComputerName){            
	            ## Collection containing node names where status is NOT EQUAL healthy and Mounted
				[System.Collections.ArrayList]$colObj += (Get-MailboxDatabaseCopyStatus -Server $server -ErrorAction Stop | where {$_.Status -ne "Healthy"}).Name
	        }

	        ## Remove empty lines from Collection
	        $colObj = $colObj | ? {$_}
	        Write-Verbose "UNHEALTHY COLLECTION $(($colObj).Count)"

	        $timeout = new-timespan -Seconds 10
	        $sw = [diagnostics.stopwatch]::StartNew()
	        Write-Verbose "WHILE WILL RUN FOR $($timeout) IF `$colOnj IS NOT EMPTY"

	        while (($sw.elapsed -lt $timeout) -and ($colObj)){
	            foreach($server in $computername){
	                if ($colObj){
	                    Start-Sleep 2
	                    Write-Verbose "REFRESH NODES FROM - $($server)"
	                    $name = (Get-MailboxDatabaseCopyStatus -Server $server | where {$_.Status -eq "Healthy"}).Name        
	                            
	                    foreach ($n in $name){                                 
	                        if($colObj -contains $n){                            
	                            Write-Verbose "REMOVING HEALTHY NODE $n FROM COLLECTION `t - UNHEALTHY NODES STILL IN COLLECTION = $($colObj.count)"
	                            ## Remove healthy node from unhealty collection
	                            $colObj.Remove($n)
	                        }
	                    }
	                }  
	            }
	        }
	        
	        if(!$colObj){
	            if ($RedistributeActiveDatabases){
	                write-verbose "RedistributeActiveDatabases -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference"
	                #&.\RedistributeActiveDatabases.ps1 -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference –Confirm:$false;
	                write-verbose "TASK DONE!" 
	            }

		        if ($MoveActiveMailboxDatabase){
		            foreach ($Server in $ComputerName){
		                write-verbose "MoveActiveMailboxDatabase -Server $($Server)"
						#Move-ActiveMailboxDatabase -Server $server -whatif
					}
		            
					write-verbose "TASK DONE!"  
		        }
		    }

			else{
	            Write-Verbose "NODES NOT REMOVED FROM COLLECTION $($colObj)"

	            if($ErrorLog){
	                Write-verbose "UNHEALTY COLLECTION LOGGED TO $($ErrorLogFilePath)"
	                $colObj | out-file $ErrorLogFilePath -Append
	            }    
	        }
		}
		
		catch{
			Write-Error "Could not connect to $Server"}
		
		finally{
			Write-Output "CleanUp"}
    }

    End {
	#Write-output $error
	#$error = $null
	}
}

exchange -ComputerName dkhqexc04n01 -MoveActiveMailboxDatabase -Verbose -ErrorLog
			
			