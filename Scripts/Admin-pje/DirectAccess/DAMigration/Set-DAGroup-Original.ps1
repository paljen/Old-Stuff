
function Write-LogFile
{
	param(
	
		[string]$Message
	)
	
	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($("$LogPath\TraceLog.Log"), $true)
	
	$script:CurrentAction = $Message	
	$Output = "$([DateTime]::Now): $Message"

	$Log.WriteLine($Output)
	$Log.Close()
}


function Invoke-CommandLine
{
	Param(

        [string]$Executable, 
        [string]$Parameters, 
        [Switch]$Wait
    )

	$psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.Verbs
    $psi.FileName = $Executable
    $psi.Arguments = $Parameters
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $proc = [Diagnostics.Process]::Start($psi)
	
    if ($Wait) 
	{
        $proc.WaitForExit();
    }

    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    
    $stdout | Out-File "$LogPath\klistlog.log" -Append
    $stderr | Out-File "$LogPath\klistlog.log" -Append
}



#region Set trace and status variables to defaults

	# 0=Success,1=Warning,2=Error
	$ErrorState = 0
	
	# Current error message
	$ErrorMessage = ""
	
	# Last write to log
	$script:CurrentAction = ""
	
	#Script Path
    $ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

    #Log Path
    $LogPath = "C:\Windows\Temp"

    # Delete old log file
	"$LogPath\TraceLog.log" | Remove-Item -ErrorAction SilentlyContinue
    "$LogPath\klistlog.log" | Remove-Item -ErrorAction SilentlyContinue
	
#endregion

## Add startup details to log
Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]"

try
{
	Write-LogFile "Importing SCORCH Module.."
    Write-LogFile "$($ScriptPath)\scorch\scorch.psd1)"
    Import-Module $("$ScriptPath\scorch\scorch.psd1")
		
	$rbGuid = "4ded94b9-af09-40ca-90ab-b3d6eb90dba1"
	$rbServer = "10.129.12.64" #DKHQSCORCH01.PRD.ECCOCORP.NET
	$rbParams = @{}
	
    Write-LogFile "Declaring `$cmd"
	$cmd = @{"NetSh"=@(netsh dns show state)
			 "GPUpdate"=@(GPUpdate /Target:Computer /Force)}

	Write-LogFile "Executing command NetSh dns show state"
	$mLoc = (((($cmd["NetSh"]) | Select-String -Pattern "Machine") -replace " ","") -replace "MachineLocation:","").TrimStart()
	Write-LogFile "Machine Location: [$($mLoc)]"
	
	if($mLoc -eq "InsideCorporateNetwork")
	{
		Write-LogFile "Test-Connection 10.129.1.12 -Count 1 -Quiet"
		
		If($(Test-Connection 10.129.1.12 -Count 1 -Quiet))
		{
			$sid = (gwmi win32_process -filter "name='Explorer.exe'" | select -First 1).GetOwnerSid().Sid
			$logonserver = $(get-ItemProperty -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$sid\Volatile Environment").logonserver
            [String]$logonserver = ($logonserver -replace "\\","").TrimStart()

			$rbParams.Add("ComputerName",$($env:COMPUTERNAME))
			$rbParams.Add("Logonserver",$($logonserver))
			
			Write-LogFile "Start-SCORunbook -webserverURL $($rbWebURL) -RunbookGuid $($rbGuid) -InputParameters $($rbParams.get_Item('Computername'),$rbParams.get_Item('Logonserver')) -WaitForExit"
			$rbWebURL = New-SCOWebserverURL -ServerName $rbServer
			Start-SCORunbook -webserverURL $rbWebURL -RunbookGuid $rbGuid -InputParameters $rbParams -WaitForExit
			
			$count = 4
			
			for ($index = 0; $index -lt $count; $index++) 
			{
				Write-LogFile "Executing klist.exe purge"
                #Invoke-CommandLine "$ScriptPath\klist.exe" purge -Wait
                Invoke-CommandLine C:\windows\sysnative\klist.exe "-li 0x3e7 purge" -Wait
				#Invoke-Command -ScriptBlock {$cmd["KlistPurge"]} -ErrorAction Stop
				
				Write-LogFile "Start-Sleep 20"
				Start-Sleep -Seconds 20
				
				Write-LogFile "Executing GPUpdate /Target:Computer /Force"
				Invoke-CommandLine C:\windows\system32\gpupdate.exe "/target:computer /force" -Wait
			}
		}
		
		Else
		{
			Throw "Ping timeout"
		}
	}

	if($mLoc -eq "OutsideCorporateNetwork")
	{
		Throw "Computer is Outside Corporate Network"
	}	
}

catch 
{
	$ErrorMessage = $error[0].Exception.Message
	Write-LogFile "Exception caught during action [$script:CurrentAction]: $ErrorMessage"
	Write-LogFile "Terminating script - Exit 1"
	Exit 1
}

Write-LogFile "Script Finished..."
