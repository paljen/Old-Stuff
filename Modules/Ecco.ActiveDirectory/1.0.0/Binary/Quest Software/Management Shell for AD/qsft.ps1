$global:hostname = $null

function prompt 
{ 
	if($global:hostname -eq $null) {$global:hostname = $(hostname)}
	$cwd = (get-location).Path
	
	$host.UI.RawUI.WindowTitle = "ActiveRoles Management Shell [$global:hostname]"
	$host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, "[PS]")
	" $cwd>" 
}

function OpenURL([string] $url)
{
	$ie = new-object -comobject "InternetExplorer.Application"
	$ie.visible = $true
	$ie.navigate($url)
}

## only returns Active Roles commands 
function get-qcommand
{
	if ($args[0] -eq $null)
	{
		get-command -pssnapin Quest.ActiveRoles*
	}
	else
	{
		get-command $args[0] | where { $_.psSnapin -ilike 'Quest.ActiveRoles*' }
	}
}

function Get-QARSProductInfo
{
	OpenURL('http://www.quest.com/activeroles-server/')
}

function Get-QARSCommunity
{
	OpenURL('http://communities.quest.com/community/activeroles/')
}

function prepare-host
{
	$ui = (get-host).UI.RawUI

	$bufferSize = $ui.BufferSize
	$bufferSize.Width = 120
	$bufferSize.Height = 3000

	$windowSize = $ui.WindowSize
	$windowSize.Width = 120
	$windowSize.Height = 50

	$ui.BufferSize = $bufferSize
	$ui.WindowSize = $windowSize
	$ui.BackgroundColor = 'DarkBlue'
	$ui.ForegroundColor = 'White'

	clear
}

function get-questBanner
{
	prepare-host

	write-host "`n         Welcome to ActiveRoles Management Shell 1.6.0, a part of Quest One ActiveRoles 6.8`n"
	
	write-host " View Quest One ActiveRoles product page:     " -no
	write-host -fore Yellow "Get-QARSProductInfo"
	
	write-host " Visit ActiveRoles community at Quest Software:  " -no
	write-host -fore Yellow "Get-QARSCommunity"

	write-host " List all cmdlets:                         " -no 
	write-host -fore Yellow "Get-Command"

	write-host " List only Management Shell cmdlets:       " -no
	write-host -fore Yellow "Get-QCommand"	

	write-host " View help:                                " -no
	write-host -fore Yellow "Get-Help"

	write-host " View help about a cmdlet:                 " -no
	write-host -fore Yellow "Get-Help <cmdlet-name> or <cmdlet-name> -?"		

	write-host " View full output for a cmd:               " -no
	write-host -fore Yellow "<cmd> | Format-List`n"
}

get-questBanner
# SIG # Begin signature block
# MIIVcgYJKoZIhvcNAQcCoIIVYzCCFV8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd5H1r8FpkRFgmTDfdi4LD798
# lsOgghFcMIIDnzCCAoegAwIBAgIQeaKlhfnRFUIT2bg+9raN7TANBgkqhkiG9w0B
# AQUFADBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzAp
# BgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EwHhcNMTIw
# NTAxMDAwMDAwWhcNMTIxMjMxMjM1OTU5WjBiMQswCQYDVQQGEwJVUzEdMBsGA1UE
# ChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAyBgNVBAMTK1N5bWFudGVjIFRpbWUg
# U3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0gRzMwgZ8wDQYJKoZIhvcNAQEBBQAD
# gY0AMIGJAoGBAKlZZnTaPYp9etj89YBEe/5HahRVTlBHC+zT7c72OPdPabmx8LZ4
# ggqMdhZn4gKttw2livYD/GbT/AgtzLVzWXuJ3DNuZlpeUje0YtGSWTUUi0WsWbJN
# JKKYlGhCcp86aOJri54iLfSYTprGr7PkoKs8KL8j4ddypPIQU2eud69RAgMBAAGj
# geMwgeAwDAYDVR0TAQH/BAIwADAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# LnZlcmlzaWduLmNvbS90c3MtY2EuY3JsMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AudmVyaXNp
# Z24uY29tMA4GA1UdDwEB/wQEAwIHgDAeBgNVHREEFzAVpBMwETEPMA0GA1UEAxMG
# VFNBMS0zMB0GA1UdDgQWBBS0t/GJSSZg52Xqc67c0zjNv1eSbzANBgkqhkiG9w0B
# AQUFAAOCAQEAHpiqJ7d4tQi1yXJtt9/ADpimNcSIydL2bfFLGvvV+S2ZAJ7R55uL
# 4T+9OYAMZs0HvFyYVKaUuhDRTour9W9lzGcJooB8UugOA9ZresYFGOzIrEJ8Byyn
# PQhm3ADt/ZQdc/JymJOxEdaP747qrPSWUQzQjd8xUk9er32nSnXmTs4rnykr589d
# nwN+bid7I61iKWavkugszr2cf9zNFzxDwgk/dUXHnuTXYH+XxuSqx2n1/M10rCyw
# SMFQTnBWHrU1046+se2svf4M7IV91buFZkQZXZ+T64K6Y57TfGH/yBvZI1h/MKNm
# oTkmXpLDPMs3Mvr1o43c1bCj6SU2VdeB+jCCA8QwggMtoAMCAQICEEe/GZXfjVJG
# Q/fbbUgNMaQwDQYJKoZIhvcNAQEFBQAwgYsxCzAJBgNVBAYTAlpBMRUwEwYDVQQI
# EwxXZXN0ZXJuIENhcGUxFDASBgNVBAcTC0R1cmJhbnZpbGxlMQ8wDQYDVQQKEwZU
# aGF3dGUxHTAbBgNVBAsTFFRoYXd0ZSBDZXJ0aWZpY2F0aW9uMR8wHQYDVQQDExZU
# aGF3dGUgVGltZXN0YW1waW5nIENBMB4XDTAzMTIwNDAwMDAwMFoXDTEzMTIwMzIz
# NTk1OVowUzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMSsw
# KQYDVQQDEyJWZXJpU2lnbiBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqcqypMzNIK8KfYmsh3XwtE7x38EP
# v2dhvaNkHNq7+cozq4QwiVh+jNtr3TaeD7/R7Hjyd6Z+bzy/k68Numj0bJTKvVIt
# q0g99bbVXV8bAp/6L2sepPejmqYayALhf0xS4w5g7EAcfrkN3j/HtN+HvV96ajEu
# A5mBE6hHIM4xcw1XLc14NDOVEpkSud5oL6rm48KKjCrDiyGHZr2DWFdvdb88qiaH
# XcoQFTyfhOpUwQpuxP7FSt25BxGXInzbPifRHnjsnzHJ8eYiGdvEs0dDmhpfoB6Q
# 5F717nzxfatiAY/1TQve0CJWqJXNroh2ru66DfPkTdmg+2igrhQ7s4fBuwIDAQAB
# o4HbMIHYMDQGCCsGAQUFBwEBBCgwJjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3Au
# dmVyaXNpZ24uY29tMBIGA1UdEwEB/wQIMAYBAf8CAQAwQQYDVR0fBDowODA2oDSg
# MoYwaHR0cDovL2NybC52ZXJpc2lnbi5jb20vVGhhd3RlVGltZXN0YW1waW5nQ0Eu
# Y3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIBBjAkBgNVHREE
# HTAbpBkwFzEVMBMGA1UEAxMMVFNBMjA0OC0xLTUzMA0GCSqGSIb3DQEBBQUAA4GB
# AEpr+epYwkQcMYl5mSuWv4KsAdYcTM2wilhu3wgpo17IypMT5wRSDe9HJy8AOLDk
# yZNOmtQiYhX3PzchT3AxgPGLOIez6OiXAP7PVZZOJNKpJ056rrdhQfMqzufJ2V7d
# uyuFPrWdtdnhV/++tMV+9c8MnvCX/ivTO1IbGzgn9z9KMIIE7TCCA9WgAwIBAgIQ
# OuScbAz4KqIqwQCS32wS1jANBgkqhkiG9w0BAQUFADCBtjELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVz
# dCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2UgYXQgaHR0cHM6Ly93d3cu
# dmVyaXNpZ24uY29tL3JwYSAoYykwOTEwMC4GA1UEAxMnVmVyaVNpZ24gQ2xhc3Mg
# MyBDb2RlIFNpZ25pbmcgMjAwOS0yIENBMB4XDTA5MTExNjAwMDAwMFoXDTEyMTEx
# NTIzNTk1OVowgaoxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRQw
# EgYDVQQHEwtBbGlzbyBWaWVqbzEXMBUGA1UEChQOUXVlc3QgU29mdHdhcmUxPjA8
# BgNVBAsTNURpZ2l0YWwgSUQgQ2xhc3MgMyAtIE1pY3Jvc29mdCBTb2Z0d2FyZSBW
# YWxpZGF0aW9uIHYyMRcwFQYDVQQDFA5RdWVzdCBTb2Z0d2FyZTCBnzANBgkqhkiG
# 9w0BAQEFAAOBjQAwgYkCgYEAvoMC/QVS+LPdjstraGiryPSwWWlke6+sijQZWrVc
# Pd4pM3Ee6LdZ+X5t3SdN30U7htw/jLMyztKQaFoGAduvlQfUwQ1Am93oqC2ocRVl
# BIR5Il3Oqk9/QqXjx24311BdT0SE20OKXUM6NGTPHdTUQroKlAb7/2anb2yRPhio
# pf0CAwEAAaOCAYMwggF/MAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgeAMEQGA1Ud
# HwQ9MDswOaA3oDWGM2h0dHA6Ly9jc2MzLTIwMDktMi1jcmwudmVyaXNpZ24uY29t
# L0NTQzMtMjAwOS0yLmNybDBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBxcDMCowKAYI
# KwYBBQUHAgEWHGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwdQYIKwYBBQUHAQEEaTBnMCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC52ZXJpc2lnbi5jb20wPwYIKwYBBQUHMAKGM2h0dHA6Ly9jc2MzLTIwMDkt
# Mi1haWEudmVyaXNpZ24uY29tL0NTQzMtMjAwOS0yLmNlcjAfBgNVHSMEGDAWgBSX
# 0GuoJnDIoT+UHwgtxDWbpKEe8jARBglghkgBhvhCAQEEBAMCBBAwFgYKKwYBBAGC
# NwIBGwQIMAYBAQABAf8wDQYJKoZIhvcNAQEFBQADggEBAKqlNWpRnbBZyYHltOt4
# IRrt+fivT91wRuZDh0iVkkDhpFUUc9NTHvF0wI06oSx4XSXlcgosGELuRZKCfTJ9
# 29/cXHEmwaoqdtu/iJChI3JGjM5vZ38YIdAAvLvJkFavw3tdrAU8TNfvuL4LeLng
# D+trOop033f5Vg31zT2urvZLS9YCM2Kty/JNaitUhnBflcgtQJo20brM5uzEJ/og
# 7lGhGYvpIl6poR/C2Rj41Y9NJljt6qHPj/EAz5fMIWPf7r7d19hTK5xeM759k4w3
# q8wS3r2sqJp4gkr0+3rJJdvL3p3iJZHbIgcAXL/N5Tz14IYmsdaePR6XuSSdMJ51
# p7wwggT8MIIEZaADAgECAhBlUibhsi4Y4VkPKYWsIudcMA0GCSqGSIb3DQEBBQUA
# MF8xCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjE3MDUGA1UE
# CxMuQ2xhc3MgMyBQdWJsaWMgUHJpbWFyeSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0
# eTAeFw0wOTA1MjEwMDAwMDBaFw0xOTA1MjAyMzU5NTlaMIG2MQswCQYDVQQGEwJV
# UzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZlcmlTaWduIFRy
# dXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBodHRwczovL3d3
# dy52ZXJpc2lnbi5jb20vcnBhIChjKTA5MTAwLgYDVQQDEydWZXJpU2lnbiBDbGFz
# cyAzIENvZGUgU2lnbmluZyAyMDA5LTIgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQC+Zx20YKoQSW9WF3xmyV6GDdXxrKdxg46LifiIBIkVBrothCGV
# 5NGcUEz70iK92vKyNTsej8MJ+/wTLlq/iXw9OyUe9vNYe5z0AbXGCriAzr4ndGFn
# J01q5eyBYVh5o+AXEBIVJ7DhTTR/K0cgRLneZiRmis1Puh/FOMhUkOFy9hlmdWq5
# SWjPOHkNqjCo2yxgSJ7XqhQBqYPXOJEwOROWAzp8QFS2reAvG4PcqBFSPgKz1yv9
# IbanXKMPC6mmEFAONC5Np87JXiXUjLzzbnwpvAFd/DGHWtWMhWdYiBmgvzXw6iuj
# IeeQ9oPlqO1geF57YIP9VwtdQQ1jVGDWQyHvAgMBAAGjggHbMIIB1zASBgNVHRMB
# Af8ECDAGAQH/AgEAMHAGA1UdIARpMGcwZQYLYIZIAYb4RQEHFwMwVjAoBggrBgEF
# BQcCARYcaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL2NwczAqBggrBgEFBQcCAjAe
# GhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhMA4GA1UdDwEB/wQEAwIBBjBt
# BggrBgEFBQcBDARhMF+hXaBbMFkwVzBVFglpbWFnZS9naWYwITAfMAcGBSsOAwIa
# BBSP5dMahqyNjmvDz4Bq1EgYLHsZLjAlFiNodHRwOi8vbG9nby52ZXJpc2lnbi5j
# b20vdnNsb2dvLmdpZjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwMwNAYI
# KwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2lnbi5j
# b20wMQYDVR0fBCowKDAmoCSgIoYgaHR0cDovL2NybC52ZXJpc2lnbi5jb20vcGNh
# My5jcmwwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEUNsYXNzM0NBMjA0OC0xLTU1
# MB0GA1UdDgQWBBSX0GuoJnDIoT+UHwgtxDWbpKEe8jANBgkqhkiG9w0BAQUFAAOB
# gQCLA8DdlNhBomFpsBWoeMcwxpA8fkL3JLbkg3MXBH8EEJyh4vqBL+vAykTncuBQ
# tlUQIINulpLkmlFqtDcx3KUt64wAxx1P500yuoX4Tr76Z1Vl8Gq+espkOBoQEHhF
# djHzhnoDD2DCs12d9otmdoIbWeGD5b1JpThW5d5Bdw5YDzGCA4AwggN8AgEBMIHL
# MIG2MQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNV
# BAsTFlZlcmlTaWduIFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVz
# ZSBhdCBodHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTA5MTAwLgYDVQQD
# EydWZXJpU2lnbiBDbGFzcyAzIENvZGUgU2lnbmluZyAyMDA5LTIgQ0ECEDrknGwM
# +CqiKsEAkt9sEtYwCQYFKw4DAhoFAKCBiDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUvWqeJskWti6+Nk0DHh3BX5nD/n0wKAYKKwYBBAGCNwIBDDEaMBihFoAUaHR0
# cDovL3d3dy5xdWVzdC5jb20wDQYJKoZIhvcNAQEBBQAEgYAw7fzwnUrKj4JTlAZ1
# oqKxQAX1gHYZVN0wCVve8w+GGDoifPj0zdj5pi4pfGPIR4JTZIIycMXm6MGLzle8
# BD+6TN9Ui8DshSjQX4XEm3K8TmIAMxIYGuDnjO2RnEwCNu06dpuG7Lgkk2TA9jLu
# Z5Na4pJvJijt30H2878DL+h5KqGCAX8wggF7BgkqhkiG9w0BCQYxggFsMIIBaAIB
# ATBnMFMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjErMCkG
# A1UEAxMiVmVyaVNpZ24gVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBDQQIQeaKlhfnR
# FUIT2bg+9raN7TAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEH
# ATAcBgkqhkiG9w0BCQUxDxcNMTIxMDA4MjMwMjA2WjAjBgkqhkiG9w0BCQQxFgQU
# IVHbOGFqhN8DAuOh7mEl78ADv7YwDQYJKoZIhvcNAQEBBQAEgYADbqKDzz9vDZuL
# cuUISsbPAQYNFYzFqEWvehBt+ylF1Ewze3YaSlypIG1bPoaAMrr6nLPG+vKX1MU8
# 9gVfYGQXAFCjjioTLizqK0mnAdbxny9/NbBczvQBqBXt3DzHjDq6AzslOArKja0o
# 39fS1RdCtBO1ICNhqzZaXQb/vtIRwA==
# SIG # End signature block
