Function Connect-EcMsolService
{
    if(!(Get-Module MSOnline))
    {
        Import-Module MSOnline
    }

    $password = "76492d1116743f0423413b16050a5345MgB8AFkAZQBLAGMAQQB2AC8AKwBDADIAWABGAGgARgBHAEIAZgBtAHIAMABOAFEAPQA9AHwAMwB`
                 mAGMAZQAzADgAOABjADkAZgBmAGYAZQBlADAAMQAwAGYAYwA3AGQAYQAxAGUAYQAzADEAMQBhADQAZQA3AGUAZQBjADcAMQA2AGIANAA3AD`
                 EAOQA5AGMANgA3ADAAMABmADMAYwA4ADkANAA4ADEANQA1AGMAOQAzAGQAMQA="

    $key = "71 198 125 211 118 80 23 112 234 228 138 157 208 129 193 40 131 143 105 42 161 41 69 72 1 5 197 118 73 29 59 50"
    $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
    $cred = New-Object system.Management.Automation.PSCredential("pje@ecco.com", $passwordSecure)

    $conn = Connect-MsolService -Credential $cred
}



Function Get-EcMsolUserLicence
{
    [CmdletBinding(DefaultParametersetName="P1")]

    Param 
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName="P1",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String]$UserPrincipalName,
        [Parameter(Mandatory=$true,
                   ParameterSetName="P2")]
        [ValidateSet("E1","E4","E5","Intune","Visio_Pro","Project_Pro","Power_BI_Free",
                     "ECAL_Services","PSTN_Conferencing","Azure_AD_Premium","Global_Service Monitor",
                     "Exchange_Online_Plan_1","Exchange_Online_Archiving")]
        [String]$LicenseType
    )

    Process
    {           
        switch ($PsCmdlet.ParameterSetName) 
        { 
            "P1"  {$User = Get-MsolUser -UserPrincipalName $UserPrincipalName;$Type=""} 
            "P2"  {$User = Get-MsolUser -All;
                   $Type = switch ($($PsCmdlet.MyInvocation.BoundParameters.Values)){
                    'E1'{"ecco:STANDARDPACK"}
                    'E4' {"ecco:ENTERPRISEWITHSCAL"}
                    'E5' {"ecco:ENTERPRISEPREMIUM_NOPSTNCONF"}
                    'Intune' {"ecco:INTUNE_A_VL"}
                    'Visio_Pro' {"ecco:VISIOCLIENT"}
                    'Project_Pro' {"ecco:PROJECTCLIENT"}
                    'Power_BI_Free' {"ecco:POWER_BI_STANDARD"}
                    'ECAL_Services' {"ecco:ECAL_SERVICES"}
                    'PSTN_Conferencing' {"ecco:MCOMEETADV"}
                    'Azure_AD_Premium' {"ecco:AAD_PREMIUM"}
                    'Global_Service_Monitor' {"ecco:GLOBAL_SERVICE_MONITOR"}
                    'Exchange_Online_Plan_1' {"ecco:EXCHANGESTANDARD"}
                    'Exchange_Online_Archiving' {"ecco:EXCHANGEARCHIVE"}
                    }
               } 
        }

        filter LicenseType
        {
            if($type -ne "")
            {
                $input | ? {$_.Licenses.AccountSkuId -contains $type}
            }
            else
            {
                $input
            }
        }
        
        $user | LicenseType | ForEach-Object {
            $license = $_ | ForEach-Object {
                switch ($_.Licenses.AccountSkuId)
                {
                    'ecco:STANDARDPACK' {"E1"}
                    'ecco:ENTERPRISEWITHSCAL' {"E4"}
                    'ecco:ENTERPRISEPREMIUM_NOPSTNCONF' {"E5"}
                    'ecco:EXCHANGESTANDARD' {"Exchange Online Plan 1"}
                    'ecco:EXCHANGEARCHIVE' {"Exchange Online Archiving"}
                    'ecco:VISIOCLIENT' {"Visio Pro"}
                    'ecco:PROJECTCLIENT' {"Project Pro"}
                    'ecco:POWER_BI_STANDARD' {"Power BI Free"}
                    'ecco:ECAL_SERVICES' {"ECAL Services"}
                    'ecco:MCOMEETADV' {"PSTN Conferencing"}
                    'ecco:INTUNE_A_VL' {"Intune"}
                    'ecco:AAD_PREMIUM' {"Azure AD Premium"}
                    'ecco:GLOBAL_SERVICE_MONITOR' {"Global Service Monitor"}
                }
            }

            if($license -ne $null)
            {
                $props = @{}
                $props.add('UserPrincipalName',$($_.UserPrincipalName))
                $props.add('Licenses',$license)

                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
            }
        }
    }
}