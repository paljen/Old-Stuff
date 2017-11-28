
function ELCTimeStamp
{
    [CmdletBinding()]

    param(

        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [String]$MailboxLog
    )

    process
    {
        if($MailboxLog -ne "")
        {
            $props = @{}
            $MailboxLog | Out-File c:\temp\tmp.txt
            $cont = Get-Content c:\temp\tmp.txt
           
            $line = ($cont | Select-String -Pattern DisplayName).LineNumber
            $props.add('DisplayName',$(((($cont | Select -Index $line -ErrorAction Ignore).trim()) -replace "<value>","") -replace "</value>",""))

            $line = ($cont | Select-String -Pattern ELCLastSuccessTimestamp).LineNumber
            $props.add('ELCLastSuccessTimestamp',$(((($cont | Select -Index $line -ErrorAction Ignore).trim()) -replace "<value>","") -replace "</value>",""))
            
            $obj = New-Object -TypeName psobject -Property $props
            Write-Output $obj
        }
    }
}

(Get-Mailbox -ResultSize Unlimited | where {$_.ServerName -like "DKHQEXC04*"}) | foreach {
    (Export-MailboxDiagnosticLogs -Identity $_.DistinguishedName -extendedproperties -ErrorAction Ignore).MailboxLog | ELCTimeStamp
} | Out-File c:\temp\ELCTimeStamp.txt