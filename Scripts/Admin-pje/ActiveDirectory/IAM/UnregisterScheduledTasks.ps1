
Get-Job | Where {$_.Name -like "AccessToken-*"} | ForEach-Object {
    if($_.State -eq "Completed")
    {
        Remove-Job -Name $_.Name
        Unregister-ScheduledJob $_.Name -Confirm:$false
    }
}