



cls

$old = Get-ADGroupMember "SEC-Global DirectAccess Clients"
$win7 = Get-ADGroupMember "SEC-Global DirectAccess HQ Access Win7 Clients"
$win8 = Get-ADGroupMember "SEC-Global DirectAccess Win8 Clients"
$win9 = Get-ADGroupMember "SEC-Global DirectAccess Win8 Clients"

Write-Output "Equals: SEC-Global DirectAccess Clients - SEC-Global DirectAccess HQ Access Win7 Clients"
Write-output "`t$((diff -ReferenceObject $old -DifferenceObject $win7 -ExcludeDifferent -IncludeEqual -Property name).name)`n"
Write-Output "Equals: SEC-Global DirectAccess Clients - SEC-Global DirectAccess Win8 Clients"
Write-output "`t$((diff -ReferenceObject $old -DifferenceObject $win8 -ExcludeDifferent -IncludeEqual -Property name).name)`n"
Write-Output "Equals: SEC-Global DirectAccess HQ Access Win7 Clients - SEC-Global DirectAccess Win8 Clients"
Write-output "`t$((diff -ReferenceObject $win7 -DifferenceObject $win8 -ExcludeDifferent -IncludeEqual -Property name).name)`n"

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPDfirGKhPVnFmRkCeCvuhoSK
# RVGgggI9MIICOTCCAaagAwIBAgIQRzDPg1KORr5MHco7Xou5YDAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNTA5MjUwODQ0MjJaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAu2TRdWHiGAEf
# TXeynR8qOPONsIG/XBSkN8AAz5IJZgawpCHWnkb0lXL1zIswEW7IFV+l/3f6f258
# iUH+XFdIDHd6nKnPDTPRBxqqvRdogBPmf2HRpLjdRYsgIqlvRjZgqSkSUzG15EV2
# lSlSRbnHKR2T5ebn9JGNgdUyTcP2fQsCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQCo2DRLKTpRLU0HO2vhsIE6EuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQdv41EPm1r5JFpDY7
# oE+4nDAJBgUrDgMCHQUAA4GBAGE2VQITijTQ7E+wtd13q0+wxZ5B5pFTa2cyqvYq
# W/s9z+IWgPBxWiINXhlhmsTujl8eElwB9XBrtHen3lgCLgfRvvUgwdxzEhpUkX5y
# 11qgDOs4TG9C0PCXAYo40dkLhDMlu2uzSLEWJuq/Y81w5eyLmz7hW81/W03WXyW7
# HuB9MYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEEcwz4NSjka+TB3KO16LuWAwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FLSqqm+bsI2IFgIf5Zvr24r1p5urMA0GCSqGSIb3DQEBAQUABIGAD2B+/oZ8EUsk
# a1QM49JE2hepdzWLyHvyie3pTHuEh7SPxVJgL6Ug8xbQ5fYVkpxUVVZyxqysLM1a
# uehZe/rJ8p+QAZMxn34Ek2tQRXF44sfRH/F5Baw/i66LaZ04YEF+H8wu7Xw2zMZi
# kCBFtOuQV+9NUZO1K4WmhN/28Bv7PHM=
# SIG # End signature block
