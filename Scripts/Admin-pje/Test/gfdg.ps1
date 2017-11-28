function Invoke-EccoGeCommand
{
    [CmdLetBinding()]

	Param(

        [string]$Executable, 
        [string]$Parameters, 
        [Switch]$Wait
    )

	$psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.Verbs
    $psi.FileName = $Executable
    $psi.Arguments = $Parameters
    #$psi.RedirectStandardError = $true
    #$psi.RedirectStandardOutput = $true
    #$psi.UseShellExecute = $false
    $proc = [Diagnostics.Process]::Start($psi)
	
    if ($Wait) 
	{
        $proc.WaitForExit();
    }

    #$proc.StandardOutput.ReadToEnd()
    #$proc.StandardError.ReadToEnd()

}

Invoke-EccoGeCommand klist.exe "-li 0x3e7 purge" -Wait