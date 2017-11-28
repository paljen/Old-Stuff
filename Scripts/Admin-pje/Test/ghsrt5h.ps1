$ps = new-object System.Diagnostics.Process

$ps.StartInfo.Filename = "ipconfig.exe"

$ps.StartInfo.Arguments = " /all"

$ps.StartInfo.RedirectStandardOutput = $True

$ps.StartInfo.UseShellExecute = $false

$ps.start()

$ps.WaitForExit()

[string] $Out = $ps.StandardOutput.ReadToEnd();

Write-Output $out