Import-Module ADSync

$attemps = 3

try
{
    for ($i = 0; $i -lt $attemps; $i++)
    { 
        Start-ADSyncSyncCycle -PolicyType Delta | Out-Null
    
        do
        {
            Start-sleep 20
        }
        until ((Get-ADSyncConnectorRunStatus).runstate -eq $null)

        $out = "Syncronization Successfully Completed"
    }
}
catch
{
    $out = $_.Exception.Message
}