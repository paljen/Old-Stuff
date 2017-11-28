filter Logon{
    $input | where {$_.EntryType -eq "SuccessAudit" -AND $_.Source -eq "Microsoft-Windows-Security-Auditing"} #-AND $_.InstanceId -eq 4624 -AND $_.Message -like "*procut*" -AND "Source Network Address" }
}

$events = get-eventlog -LogName Security -ComputerName dkhqdc01 | Logon | ft -Wrap
$events.count
