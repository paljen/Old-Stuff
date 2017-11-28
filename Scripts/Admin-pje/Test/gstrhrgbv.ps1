
$user = "pjetestuser"

$size = (((Get-Mailbox $user | Get-MailboxStatistics).TotalItemSize.value) -split '[\(]')
$size = $size[0].Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
$size[0]
if ($size[1] -eq 'GB' -and $size[0] -lt "20.*")
{
   
}
