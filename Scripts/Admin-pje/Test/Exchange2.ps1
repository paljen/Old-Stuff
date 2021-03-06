			$computerName = "dkhqexc04n02"
			$timeout = new-timespan -Seconds 10
	        $sw = [diagnostics.stopwatch]::StartNew()
			
			[int32]$Error = 1
			
	        while (($sw.elapsed -lt $timeout) -and ($Error -eq 1)){
	            foreach($server in $computername){
						$done = (Get-MailboxDatabaseCopyStatus -Server $server | where {$_.Status -eq "Healthy"})
						if ($done){
	                    	Start-Sleep 2
	                    	Write-Output "REFRESH NODES FROM - $($server)"
	                } 
					else {$Error = 0;Break;}
	            }
	        }
			
			$Error