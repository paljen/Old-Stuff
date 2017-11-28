
Get-ExchangeServer -Identity "DKHQEXC04*" | ForEach-Object {
    $track = Get-MessageTrackingLog -Server $_.name -Resultsize unlimited -MessageSubject "Important Document"
    $track |ForEach-Object {

        $props = [Ordered]@{'EventID'=$_.EventID
                   'Source'=$_.Source
                   'Sender'=$_.Sender
                   'MessageSubject'=$_.MessageSubject
                   'ReturnPath'=$_.ReturnPath
                   'TimeStamp'=$_.TimeStamp
                   'Directionality'=$_.Directionality
                   'TotalBytes'=$_.TotalBytes
                   'Recipients'=$_.Recipients}

        $obj = New-Object -TypeName PSObject -Property $props
        $obj | export-csv C:\Users\pje\desktop\Importent-Document.csv -Append
    }
}