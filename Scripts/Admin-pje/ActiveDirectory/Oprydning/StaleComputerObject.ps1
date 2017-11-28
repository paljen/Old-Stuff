# Script run 17/1/2017

# OU to exclude, regex pattern \b(name1|name2|name3)\b
$exclude = "\b(TERMINATED ACCOUNTS|MEMBER SERVERS)\b"

# Target OU, where the object is moved
$target = "ou=COMPUTERS,ou=TERMINATED ACCOUNTS,dc=prd,dc=eccocorp,dc=net"

# Object prior to this date is filtered
$lastYear = (get-date -Day 30 -Month 9 -Year 2016).DayOfYear
$staleDate = ((Get-Date).AddDays(-((Get-Date).DayOfYear) - $lastYear))
$staleUnprovDate = (Get-Date).AddDays(-90)

$csvPath = "c:\temp\StaleComputers-$(Get-Date -f ddMMyyyyHHmm).csv"

# Properties to include in the computer object
$properties = @("PasswordLastSet","LastLogonDate","whenCreated","OperatingSystem")

# Stale Unprovisioned computer
filter StaleUnprovisionedComputer{
    $input | where {
        $_.OperatingSystem -eq $null -and `
        $_.whenCreated -lt $staleUnprovDate -and `
        $_.LastLogonDate -eq $null -and `
        $_.DistinguishedName -notmatch $exclude}
}

# Stale provisioned computer
filter StaleComputer{
    $input | where {
        ($_.OperatingSystem -ne $null -and $_.OperatingSystem -notlike "*Server*") -and `
         $_.PasswordLastSet -lt $staleDate -and `
         $_.LastLogonDate -lt $staleDate -and `
         $_.DistinguishedName -notmatch $exclude}
}

$computers = @()
$computers += Get-ADComputer -Filter * -Properties $properties | StaleUnprovisionedComputer
$computers += Get-ADComputer -Filter * -Properties $properties | StaleComputer

$computers | Move-ADObject -TargetPath $target
Get-ADComputer -Filter * -SearchBase $target | ? {$_.Enabled -eq $true} | Set-ADComputer -Enabled:$false

#$obj = @()
$computers | Sort whenCreated |ForEach-Object {
    $props = [Ordered]@{
               'Computername'=$_.name
               'OperatingSystem'=$_.OperatingSystem
               'DistinguishedName'=$_.DistinguishedName
               'Created'=$_.whenCreated
               'PasswordLastSet'=$_.PasswordLastSet
               'LastLogonDate'=$_.LastLogonDate}

    $obj = New-Object -TypeName PSObject -Property $props  
    Export-Csv -InputObject $obj -Path $csvPath -Encoding UTF8 -NoTypeInformation -Append
}

