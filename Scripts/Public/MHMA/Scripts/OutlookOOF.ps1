function Get-EWSOofSettings {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
        [System.String]
        [Alias("Identity")]
        $PrimarySmtpAddress,
        [Parameter(Position=1, Mandatory=$false)]
        [System.String]
        $ver = "Exchange2007_SP1"    
        )

    begin {
        Add-Type -Path "C:\Program Files (x86)\Microsoft\Exchange\Web Services\2.1\Microsoft.Exchange.WebServices.dll"
        $sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        $user = [ADSI]"LDAP://<SID=$sid>"
    }
    
    process {
        $service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -Arg $ver
        $service.AutodiscoverUrl($user.Properties.mail)    
        
        if($PrimarySmtpAddress -notmatch "@") {
          $PrimarySmtpAddress = (Get-Recipient $PrimarySmtpAddress).PrimarySMTPAddress.ToString()
        }
        
        $oof = $service.GetUserOofSettings($PrimarySmtpAddress)
        New-Object PSObject -Property @{
            State = $oof.State
            ExternalAudience = $oof.ExternalAudience
            StartTime = $oof.Duration.StartTime
            EndTime = $oof.Duration.EndTime
            InternalReply = $oof.InternalReply
            ExternalReply = $oof.ExternalReply
            AllowExternalOof = $oof.AllowExternalOof
            Identity = (Get-Recipient $PrimarySmtpAddress).Identity
        }
    }
}

Get-EWSOofSettings -PrimarySmtpAddress mhma@ecco.com