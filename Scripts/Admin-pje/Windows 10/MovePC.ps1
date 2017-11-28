$ErrorActionPreference = "STOP"

$OUDesktop = "OU=DESKTOP GENERIC,OU=COMPUTERS,OU=IT,OU=HQ,OU=DK,OU=ECCO,DC=prd,DC=eccocorp,DC=net"
$OULaptop = "OU=LAPTOPS GENERIC,OU=COMPUTERS,OU=IT,OU=HQ,OU=DK,OU=ECCO,DC=prd,DC=eccocorp,DC=net"

switch ($((gwmi win32_systemenclosure).ChassisTypes))
{
    1 {$type = "Other"}
    2 {$type = "Unknown"}
    3 {$type = "Desktop"}#
    4 {$type = "Low Profile Desktop"}#
    6 {$type = "Mini Tower"}#
    7 {$type = "Tower"}#
    8 {$type = "Portable"}#
    9 {$type = "Laptop"}#
    10 {$type = "Notebook"}#
    12 {$type = "Docking Station"}
    13 {$type = "All in One"}#
    14 {$type = "Sub Notebook"}#
    24 {$type = "Sealed-Case PC"}#
    default {$type = "Unknown"}
}
$type
switch ($type)
{
    "Laptop" {$OU = $OULaptop}
    "Notebook" {$OU = $OULaptop}
    "Sub Notebook" {$OU = $OULaptop}
    "Desktop" {$OU = $OUDesktop}
    "Low Profile Desktop" {$OU = $OUDesktop}
    "Mini Tower" {$OU = $OUDesktop}
    "Tower" {$OU = $OUDesktop}
    "Portable" {$OU = $OUDesktop}
    "All in One" {$OU = $OUDesktop}
    "Sealed-Case PC" {$OU = $OUDesktop}
    default {$OU = ""}
}

$OU

try
{
    #Get-ADComputer -Identity DK4836 | Move-ADObject -TargetPath $OU -WhatIf
}
catch
{
    $_.Exception.Message
}