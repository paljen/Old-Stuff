[Array]$a = @()

foreach ($g in (Get-Content C:\Scripts\ECCO\Projects\ActiveDirectory\Groups.txt))
{
    foreach ($m in (Get-ADGroupMember -Identity $g))
    {
        #$obj = New-Object -TypeName PSObject -Property @{Name=$($g);Member=$($m.name)}
        #$a += $obj

        $a += $g,$m.name,$m.objectClass -join "`t"
    }
}

$a #| Out-EccoExcel
