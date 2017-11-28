function exchange
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Computername
    )

    Begin {}
    Process {

        [System.Collections.ArrayList]$chklst = (get-process | where name -eq "svchost").id
            $chklst.count

        if($chklst -ne $null)
        {
           Write-Verbose "`$chklst indeholder $chklst"
                

           while ($true)
           {
	         if ($chklst)
	         {
                Write-Verbose "`$chklist is true"
                $process = (get-process | where name -eq "svchost").id
                        
                 foreach ($proc in $process)
                 {
                   #$proc = get-process | where name -eq "svchost"
                   #(Get-MailboxDatabaseCopyStatus -Server $server | where {$_.Status -ne "Healthy"})

                   if($chklst -contains $proc) 
                   {
                        #$proc.Id
                        Write-Verbose "`$chklst contains $($proc.id)"
                        $chklst.Remove($proc)
                        $chklst
                   }
                   
                 }

                 

		         #break;
		                
	          }
              
              break;
            }
                
          }
       }
    
    End {}

}

exchange -Verbose

#| ForEach {$_.Servers | ForEach {Get-MailboxDatabaseCopyStatus -Server $_}} | sort name



<#
Switch værdi i runbook - 0 -----------------------------
(Get-DatabaseAvailabilityGroup) | ForEach {$_.Servers | ForEach {Get-MailboxDatabaseCopyStatus -Server $_}}
hvis healthy indenfor 5 minutter, (looping)
d:\Exchange\Scripts\RedistributeActiveDatabases.ps1 -DagName dkhqexc04DAG01 -BalanceDbsByActivationPreference –Confirm:$false
Ellers Error retur kode.


DKHQEXC04N01, DKHQEXC04N02, DKHQEXC04N03, DKHQEXC04N04 ------------------------------
(Get-DatabaseAvailabilityGroup) | ForEach {$_.Servers | ForEach {Get-MailboxDatabaseCopyStatus -Server $_}}
hvis healthy indenfor 5 minutter, (looping)
Move-ActiveMailboxDatabase -Server DKHQEXC04N04
Ellers Error retur kode.
#>
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHk8AZSEPhwBPzbucB7iCXNNj
# eG+gggI9MIICOTCCAaagAwIBAgIQRzDPg1KORr5MHco7Xou5YDAJBgUrDgMCHQUA
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
# FJUTJ1sU75Ry8g5QFUH2iSPjmk9NMA0GCSqGSIb3DQEBAQUABIGAEx0DAY64NcVB
# Ga7pts2nTOfWT6U+5IqAdMPgWW6INYqj+8NtxZuAOuWI+E0dJZLH9WdBrAAlgxPK
# JImc7pKC8j05JvX2L7F50lzHZ/j2rV8sGfyaumc+07ipYpLusryxowD26pN4SOyD
# krA+bkZtYRs2tPwILve1kwHtLHGYdZQ=
# SIG # End signature block
