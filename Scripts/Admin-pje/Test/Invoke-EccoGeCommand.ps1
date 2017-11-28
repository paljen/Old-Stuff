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

    $klistlog = "C:\Windows\Temp"
    
    

    $stdout | Out-File "$klistlog\klistlog.log" -Append
    $stderr | Out-File "$klistlog\klistlog.log" -Append
}

Invoke-CommandLine C:\windows\system32\klist.exe "-li 0x3e7 purge" -Wait
Invoke-CommandLine C:\windows\system32\gpupdate.exe "/target:computer /force" -Wait