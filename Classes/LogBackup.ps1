﻿Class Log
{
    [DateTime]$TimeStamp
    [String]$Message

    Log()
    {
        
    }
   
    Log([DateTime]$TimeStamp,[String]$Message)
    {
        $this.TimeStamp = $TimeStamp
        $this.Message = $Message
    }

    [Log] WriteLogEntry([String]$Message)
    {
       return [Log]::new([DateTime]::Now,$Message)
    }
}

Class RunbookLog : Log
{
    [String]$RunbookName

    RunbookLog()
    {
    }

    RunbookLog([DateTime]$TimeStamp,[String]$RunbookName,[String]$Message)
    {
        $this.TimeStamp = $TimeStamp
        $this.Message = $Message
        $this.RunbookName = $RunbookName
    }

    [RunbookLog] WriteLogEntry([String]$RunbookName,[String]$Message)
    {
       return [RunbookLog]::new([DateTime]::Now,$RunbookName,$Message)
    }
}

Class FileLog
{
    [String]$LogFilePath
    [String]$ControllerRunbookName

    FileLog()
    {
        
    }

    FileLog([String]$FilePath,[String]$ControllerRunbookName)
    {
        $this.LogFilePath = $FilePath
        $this.ControllerRunbookName = $ControllerRunbookName
    }

    StartLogging()
    {
        Add-Content -Path $this.LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $this.LogFilePath -Value "Runbook Flow Started $(Get-Date)"
        Add-Content -Path $this.LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $this.LogFilePath -Value ""
        Add-Content -Path $this.LogFilePath -Value "Flow.............: $($this.ControllerRunbookName)"
        Add-Content -Path $this.LogFilePath -Value "Running On.......: $env:COMPUTERNAME"
        Add-Content -Path $this.LogFilePath -Value ""
    }

    WriteContentToLog([PSCustomObject]$obj)
    {
        Add-Content -Path $this.LogFilePath -Value "Runbook..........: $($obj.RunbookName)"

        $obj.Trace | foreach {
            Add-Content -Path $this.LogFilePath -Value "Trace............: $($_.TimeStamp), $($_.Message)"
        }
    }

    WriteContentToLog([String]$Message)
    {
        Add-Content -Path $this.LogFilePath -Value "Trace............: $([DateTime]::Now), $($Message)"
    }

    WriteContentToLog([String]$RunbookName,[String]$Message)
    {
        Add-Content -Path $this.LogFilePath -Value "Runbook..........: $($RunbookName)"
        Add-Content -Path $this.LogFilePath -Value "Trace............: $([DateTime]::Now), $($Message)"
    }

    StopLogging([PSCustomObject]$obj)
    {
        Add-Content -Path $this.LogFilePath -Value ""
        Add-Content -Path $this.LogFilePath -Value "Status...........: $($obj.Status)"
        Add-Content -Path $this.LogFilePath -Value "Message..........: $($obj.Message)"
        Add-Content -Path $this.LogFilePath -Value ""
        Add-Content -Path $this.LogFilePath -Value "***************************************************************************************************"
        Add-Content -Path $this.LogFilePath -Value "Runbook Flow Finished $(Get-Date)"
        Add-Content -Path $this.LogFilePath -Value "***************************************************************************************************" #>
        
    }
}

# SIG # Begin signature block
# MIITvQYJKoZIhvcNAQcCoIITrjCCE6oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYCv2YdvWQmuN/u0esd/lUYhy
# uwWgghARMIIHiDCCBXCgAwIBAgITIgAAAANuqCB3ki1Y+wAAAAAAAzANBgkqhkiG
# 9w0BAQsFADAVMRMwEQYDVQQDEwpFQ0NPUm9vdENBMB4XDTE2MTIyMjEwMDczM1oX
# DTI0MTIyMjEwMTczM1owXjETMBEGCgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT
# 8ixkARkWCGVjY29jb3JwMRMwEQYKCZImiZPyLGQBGRYDcHJkMRgwFgYDVQQDEw9F
# Q0NPSXNzdWluZ0NBMDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC4
# bjylJRz4vftDp6wo1g0NRbZtj0DG5DOxO1NK0yvw52xhNxP+BHubolylLEQVdIOn
# LYzNS4t+Iffo0m/FjMIxJ+ERRlNKhBZJepw2rWM2ALDSFFh+lXnkKxuqGBGS9XmY
# 9Z7C9b41zH6lu6fOzkHKd2NEZGeddEZyFOAsZgw89Oo1aTOhfHp5vm2D6z7kaa9i
# 1O0Sou3J6xVabUEGCOXGcPl17Sp+TRXrxZ1CnvAUQxdJ0WRCsH51JtI16f0vDVzf
# cxuIhsVUJEgVIjDIpterTFv0oy3fTs9NjvE4cE7ODN9puW5zIU+1XYRvX6yIFOHG
# DP8XQ3OJ1AQOZRv0sSFCzxiVyqGSwQsRHBS4si0V7xTh39RU2dmGVYGizCvFXV7k
# 14QBTk3aSQotn3tdhKdAeb57ZMAcVBMabRGIDTkyCyjSNU3jqWmhlC9rTG8gsO/k
# u8GbvCWFQzHS8uLVv/D3AtTcTc18mmpjl4nCkvfIAfNrqcxcRu0GnmUqSctNCjYo
# vFLh9r2du0xBBirzUVJ42vXUmY6dGV9Iomb1UIQHI4KOge57qKtr57sgm4xApxU/
# RYUByZGlnmtxLFUrWWuaiTXZdFt3u6VzkUpRJcIuKpIWMfkk0aIZF9r9zap+fWi6
# v7GnKjkL5SK+Zv2MDllpVNT0kHcA2+ldHCuRNGWL4wIDAQABo4IChjCCAoIwEAYJ
# KwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFLbCDMEBvI28gT1kS0tpuqRxvWixMDsG
# CSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCPu9RofHhWCJjyGHnMxpge+ZNnqG3O00
# gqyKYAIBZAIBAzALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
# GDAWgBQIoYBnds5rmr8Js4sKRn8KGnUTbjCB4gYDVR0fBIHaMIHXMIHUoIHRoIHO
# hiJodHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3JshoGnbGRhcDovLy9D
# Tj1FQ0NPUm9vdENBLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
# Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERDPW5ldD9j
# ZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlz
# dHJpYnV0aW9uUG9pbnQwge0GCCsGAQUFBwEBBIHgMIHdMC4GCCsGAQUFBzAChiJo
# dHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3J0MIGqBggrBgEFBQcwAoaB
# nWxkYXA6Ly8vQ049RUNDT1Jvb3RDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29y
# cCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwDQYJKoZIhvcNAQELBQADggIBABOsg692lfiAKLwWmTBZ
# R0FjA4Jukiae6FuK8pRO/0IhxZWkCm5m3wQ/naADWUIyKnJr8WNdsGXfOFWFCanj
# iC+29aRrAkv+Ajah6fFY/kMxZeBFPSQKb4mFHT5fqcYdrFtPfLlOdMayunifrGmx
# QTAEcDgedTHyo+x+ntg5ZcUzFGQ7DexiV3bL53+NaoVNfOIL86PMnYbpO0IAeoy5
# PfItO5v1jP2yAZ/r9/D6YPF+UNqSd/S881ljNIkrd65C5cHFpEhpE3TDaIy4Usyc
# 1pXoizws/ICX9mksILi9HhTyx0iz7li8qWbYWh5qTN/DBJc3w9mAGwJaYjGcxs3l
# DUFqEq3YRVnB2c0skG4wF+VyUrA7CFohELohW7C+zFvGed7Q8fbp9Nr4FT6VZqBf
# wt9W69ycBHmGpNOSjz+NXjc2s5MHwXzfy/wWCD/SdJj+3NNyMP1X0tJbQ006MfYQ
# yvwOnQB+NweEpu57yz12lPkIElXLqi6lK0jvQQJOcCbxt5tgr5XkZRw5OWAsWb7t
# ZbD5TafgNPnb3bXLJYP94WaY5/ET+B+vSe4G5Q9a9xsKJdKAaDcxTK1yukUlwEIJ
# CLD6+r9lO/RX/+XoFsNUQTYtCjixvPQbQNwGq+rpsDkDTKkzS3b8JRHbQyXutYEa
# JbCYNyL5tqWwxV4+GHkKogXgMIIIgTCCBmmgAwIBAgITbQAADULk5e+ImwxuEgAA
# AAANQjANBgkqhkiG9w0BAQsFADBeMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYK
# CZImiZPyLGQBGRYIZWNjb2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxGDAWBgNV
# BAMTD0VDQ09Jc3N1aW5nQ0EwMTAeFw0xNzAyMjIxNDQ2MTZaFw0xOTAyMjIxNDQ2
# MTZaMIGGMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYIZWNj
# b2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxIzAhBgNVBAsTGlNlcnZpY2UgYW5k
# IEFkbWluIEFjY291bnRzMRswGQYDVQQDExJBZG1pbi1QYWxsZSBKZW5zZW4wggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCzr3cnmVyHL1Nu0qhYbdmCDb+w
# UyJ0/T9EiGks1A781CxaKlCTykioTNQMVDqeGkRdICG0t3+2Fxxxx6oh6THOMb0z
# vtFjisCriF9w7XHD+zLu5VML1fPg15F4kFeY+O6+c2Rhs9M355bf1B5Y6hr3Wo/n
# 8Prgw3wfCb5kAA1KMwUws4L6ASHnYgSktXbq+aJkN5U7hR5t1JypTFSao42c+u39
# yK625vng6B9A+tZAsgfTqSLT6qcoKCoZrvFR6cLQHB426zqVidDc6d5+fTUkcgjd
# vzPYenA5s8L7z1EeEP0svQ0TdD6Yd1sek915iNIiRtENJEpZyirBfap7aLlfuqTP
# B9G2kKzTfHdfJqPRuPqt6oNAhNfLQhDKM+33/5qkO2BR/etQy3MevSfwCcjeoRTZ
# KeyITp4/zYqg57Tihrev6GcbGqV7IxfZz4e8gEB24dG+usaMSTa+JF2RJS9l0kTx
# 8BJMjFvo15rIo1de6U2hCQCbNkP1EdJJ6uWTraoyMcRml/gC/byWmL7kigQ6IAAZ
# tgOpgDaGt9gCNUQ/ieUImuve7DSPdm/yqWxGTg6Q+i7EZPJ6TThREhbDf/xwfHoS
# OnZ6j7CA/pg5MQ45YTI3MlgYDdefRw7StP2cWDkO86CM0HiRvczJeK1BRQcAaT9x
# n1ej6TLTrwEvUGkBTwIDAQABo4IDDTCCAwkwOwYJKwYBBAGCNxUHBC4wLAYkKwYB
# BAGCNxUI+71Gh8eFYImPIYeczGmB75k2eoXLzWOF3IFDAgFkAgElMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoG
# CCsGAQUFBwMDMB0GA1UdDgQWBBQAWryv/lzSTNywkpWlkJU1uim7ZzAfBgNVHSME
# GDAWgBS2wgzBAbyNvIE9ZEtLabqkcb1osTCB7AYDVR0fBIHkMIHhMIHeoIHboIHY
# hidodHRwOi8vY2RwLmVjY28uY29tL0VDQ09Jc3N1aW5nQ0EwMS5jcmyGgaxsZGFw
# Oi8vL0NOPUVDQ09Jc3N1aW5nQ0EwMSxDTj1DRFAsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29y
# cCxEQz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENs
# YXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIBIAYIKwYBBQUHAQEEggESMIIBDjAz
# BggrBgEFBQcwAoYnaHR0cDovL2NkcC5lY2NvLmNvbS9FQ0NPSXNzdWluZ0NBMDEu
# Y3J0MIGvBggrBgEFBQcwAoaBomxkYXA6Ly8vQ049RUNDT0lzc3VpbmdDQTAxLENO
# PUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1D
# b25maWd1cmF0aW9uLERDPWVjY29jb3JwLERDPW5ldD9jQUNlcnRpZmljYXRlP2Jh
# c2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTAlBggrBgEFBQcw
# AYYZaHR0cDovL29jc3AuZWNjby5jb20vb2NzcDA1BgNVHREELjAsoCoGCisGAQQB
# gjcUAgOgHAwaQWRtaW4tUEpFQHByZC5lY2NvY29ycC5uZXQwDQYJKoZIhvcNAQEL
# BQADggIBAJgvIbQwyrbBP1USU5W48WQaoEWDQX6ZVSjug/pSmPEZVhFRYGc+0KH5
# oJA5HOW1Qw6nmKkXkn0ZGKvQmeZfX4GHmtKYb9Gtpbdc7djFOu/fKAB7GsNNSZzQ
# 71K6uPKtiRr3jQeplPQH51Y9JJvYlsYb7AKhJEABc6JN8V17g1K6mMm0CWGsOOL4
# iHlebCzDjpFEjshYBTmI+91IftGmICscZ1KH0mReQkIpBOkjiQhKUVwK6HFwZRnE
# JFbJHgzYKLoOyce92lEK62L2+MFqnOp5WRdHN/pIVAODYY4T8JjHH2ZOBHWCNdcF
# vZVe8zT8yQF5fP9MOEz5O+Wh/68Dd8+tBN/wuvhw7K65/9yizNaNbSRNP4wDR6ii
# TQifp3caX3i+OD9insC56x1hDokd6JFIlL34tcWm1yJOxRpBnS5vHmEwxQV/Ff0n
# vuLh2E8DiD2FJLdlc3nX7LCK+gei4gHi4s0BwaXSobKLaosiGfeyMfEc2pBTqtDi
# Cw/JuFsaRYuF1Z3A3YFDW96x4x2RsFjgS0cpZ68EKtg56q1Nylaxfiksqg5A9Igq
# LsmNPvyxkqkRmsyCw/E11nFqZAKO3g6mCnPGLLjPpkk/qjpr5yYQz/d5mo4wxzOH
# H2pfEzaZip1sEcB7iFqnBUX17kk/2PYL2tDMmlC++/aDANqMecFmMYIDFjCCAxIC
# AQEwdTBeMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYIZWNj
# b2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxGDAWBgNVBAMTD0VDQ09Jc3N1aW5n
# Q0EwMQITbQAADULk5e+ImwxuEgAAAAANQjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUEoynR530
# v1Z3ujXOehsazMzX1F0wDQYJKoZIhvcNAQEBBQAEggIAPm7nZeemrJb1YvoxbO6h
# 6sExBciQKRMlnE/vz5ANkYw4h/wGErHU1CSYgoEedtFACsTv/DcxnecCUm6gILdV
# 4Ig91JT8+Jyh53etyYhqQphsprwACV12Rg0dwZ6iLeC1z++KojpSCTKeXXxqCyQd
# 37jwZ7zzFEVvsp4P5KXEfpyErJlSTMFPgL56x+GhxMTpIiH+TO2rPblFDSNDuj1u
# IHP88iQL3r8MwHxNziqDnNyz0mxSlUtjFfUSxj33FxKM2c6FXUSnNbeioE0IiSYj
# x6a/67KLlqP3jM5EI71YDO+IJXjS0XZYHl4GnjY1XrV6oTNgHzHf282jt7UImdjK
# KhW/R4/RixaTphtQjKguYrNR/8gjz2wYxc5m2sQvwtoVj7VQmDyKMs/WGc/JKMFM
# Mv84CTOmZ47y9+YCEZPjK83JvSF8T5/Gkq9wyeT1MVgawyh1bkQVjFFKbzYT5Tkr
# hWfY5eYspzxdZ0CffJ1PTV85Z+/tlo4uKUIgWql1prTQAC0MKqxzmEgh0+/aIlzu
# EicKiHktTxQiNTTW4ykTHp/k1rtEvpzwrTygKM79cEvLTP4QbocYrm1uS+XAcOW8
# RlzZor6t4WfSByulyNIWykJtiZoEi2drjlPbOuRdH++MLfTNrryGeiFbYyMA8a/d
# 9H8+6qN638sszAZE0LO9C84=
# SIG # End signature block
