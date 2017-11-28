
# OU to exclude, regex pattern \b(name1|name2|name3)\b
$exclude = "\b(TERMINATED ACCOUNTS|MEMBER SERVERS)\b"

# Target OU, where the object is moved
$target = ""

# Object prior to staleDate except the preStaged period, the prestaged object is ignored
$staleDate = ((Get-Date).AddDays(-(Get-Date).DayOfYear))

$csvPath = "c:\temp\StaleComputers-$(Get-Date -f ddMMyyyyHHmm).csv"

# Properties to include in the computer object
$properties = @("PasswordLastSet","PasswordNotRequired","LastLogonDate","whenCreated","OperatingSystem")

# Provisioned workstations in AD where LastLogonDate is older then staleDate and removed from SCCM due to task "Delete Inactive Client Discovery Data"
filter StaleComputers{
    $input | where {
        ($_.OperatingSystem -ne $null -and $_.OperatingSystem -notlike "*Server*") -and `
         $_.PasswordLastSet -lt $staleDate -and `
         $_.LastLogonDate -lt $staleDate -and `
         $_.DistinguishedName -notmatch $exclude}
}

$computers = Get-ADComputer -Filter * -Properties $properties | StaleComputers #| Move-ADObject -TargetPath $target -PassThru

$computers | ForEach-Object {
    $props = [Ordered]@{
               'Computername'=$_.name
               'DistinguishedName'=$_.DistinguishedName
               'Created'=$_.whenCreated
               'PasswordLastSet'=$_.PasswordLastSet
               'LastLogonDate'=$_.LastLogonDate}

    $obj = New-Object -TypeName PSObject -Property $props
    Export-Csv -InputObject $obj -Path $csvPath -Encoding UTF8 -NoTypeInformation -Append
}

