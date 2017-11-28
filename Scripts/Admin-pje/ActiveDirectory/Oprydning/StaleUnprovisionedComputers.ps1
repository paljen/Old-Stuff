
# OU to exclude, regex pattern \b(name1|name2|name3)\b
$exclude = "\b(TERMINATED ACCOUNTS|MEMBER SERVERS)\b"

# Target OU, where the object is moved
$target = ""

# Object prior to staleDate except the preStaged period, the prestaged object is ignored
$staleDate = (Get-Date).AddDays(-90)
 
$csvPath = "c:\temp\StaleUnprovisionedComputers-$(Get-Date -f ddMMyyyyHHmm).csv"

# Properties to include in the computer object
$properties = @("PasswordLastSet","PasswordNotRequired","LastLogonDate","whenCreated","OperatingSystem")

# Unprovisioned computers in AD and removed from SCCM due to task "Delete Inactive Client Discovery Data"
filter StalePrestagedComputers{
    $input | where {
        $_.OperatingSystem -eq $null -and `
        $_.whenCreated -lt $staleDate -and `
        $_.LastLogonDate -eq $null -and `
        $_.DistinguishedName -notmatch $exclude}
}

$computers = Get-ADComputer -Filter * -Properties PasswordLastSet,PasswordNotRequired,LastLogonDate,whenCreated,OperatingSystem | StalePrestagedComputers # | Move-ADObject -TargetPath $target -PassThru

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

