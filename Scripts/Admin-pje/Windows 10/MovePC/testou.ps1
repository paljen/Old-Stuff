$computername = "dk4836"

# Declare Where to move computer objects
$OUDesktop = "OU=DESKTOPS GENERIC"
$OULaptop = "OU=LAPTOPS GENERIC"

# Split DistinguishedName into an ArrayList
[System.Collections.ArrayList]$current = (Get-ADComputer $computername | select DistinguishedName).DistinguishedName -split ","

# Remove computer CN from array
$current.RemoveAt(0)
$current.item(0)

# Set OUDN String
Switch ($current.item(0))
{
    "OU=DESKTOPS ELEVATED" {$current.item(0) = $OUDesktop}
    "OU=LAPTOPS ELEVATED" {$current.item(0) = $OULaptop}
}

# Join ArrayList to a string
$OUDN = $current -join ","
$OUDN | Out-File ./out.txt


