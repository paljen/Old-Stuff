$user = "afe"

$size = @()

$size = (((Get-Mailbox $user | Get-MailboxStatistics).TotalItemSize.value) -split '[\(]')
$size = $size[0].Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

if ($size[1] -eq 'GB' -and [int]$size[0] -gt 4)
{
    Write-host "yes"
}

else
{
    write-host "no"
    $size[0]
    $size[1]

}