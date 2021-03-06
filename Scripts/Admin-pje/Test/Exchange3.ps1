if(!(Get-PSSession | where ConfigurationName -eq "Microsoft.Exchange").Availability -eq "Available")
{	$ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://dkhqexc04n01.prd.eccocorp.net/powershell/" -Authentication Kerberos
	Import-PSSession $ExSession}

function Start-ECCOExchangeTask
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
		
		[int32]$eState = 1
		
        if($ErrorLog){
            $ErrorLogFilePath = 'C:\Error.txt'
        }
    }

    Process 
    {
		try{
	        $timeout = new-timespan -Seconds 10
	        $sw = [diagnostics.stopwatch]::StartNew()
	        Write-Verbose "WHILE WILL RUN FOR $($timeout) WHILE `$eState EQUALS 1"

	        while (($sw.elapsed -lt $timeout) -and ($eState -eq 1)){
	            foreach($server in $computername){
						## Filter - {($_.Status -ne "Healthy" -and $_.status -ne "Mounted") -or ($_.ContentIndexState -ne "Healthy")}
						$done = (Get-MailboxDatabaseCopyStatus -Server $server | where {($_.Status -ne "Healthy" -and $_.status -ne "Mounted") -or ($_.ContentIndexState -ne "Healthy")})
						
						if (!$done){
	                    	$eState = 0
							Break;}
	                } 
					else {
						Start-Sleep 2
	                    Write-Output "REFRESH NODES FROM - $($server)"
	            }
	        }
	        
	        if($eState -eq 0){
	            if ($RedistributeActiveDatabases){
	                write-verbose "RedistributeActiveDatabases -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference"
	                #Invoke-Expression ".\RedistributeActiveDatabases.ps1 -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference –Confirm:$false"
	                write-output "RedistributeActiveDatabases - TASK DONE!" 
	            }

		        if ($MoveActiveMailboxDatabase){
		            foreach ($Server in $ComputerName){
		                write-verbose "MoveActiveMailboxDatabase -Server $($Server)"
						#Move-ActiveMailboxDatabase -Server $server -whatif
						write-output "Move-ActiveMailboxDatabase - TASK DONE!" 
					}
		            
					write-verbose "TASK DONE!"  
		        }
		    }

			else{
	            Write-Verbose "`$eState EQUALS 1 - NO ACTION TAKEN"

	            if($ErrorLog){
	                Write-Error "`$eState EQUALS 1, FILTERED NODES LOGGED TO $($ErrorLogFilePath)"
	                $done | out-file $ErrorLogFilePath -Append
	            }    
	        }
		}
		
		catch{
			Write-Error "Could not connect to $Server"}
		
		finally{
		}
    }

    End {
	#Write-output $error
	#$error = $null
	}
}

Start-ECCOExchangeTask
			
			