

$scriptPath = 'c:\Scripts\ECCO\Projects\Exchange\Set-MailBoxMoveAndRedistribution.ps1'
$commandLine = "-NoExit & $scriptPath '-DagName 'dkhqexc04DAG01'' '-BalanceDbsByActivationPreference' '-Confirm:$false' '-whatif:$true'"
##Start the process building the command line arguments dynamically
Start-Process powershell.exe -ArgumentList $commandLine -w

