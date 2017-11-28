

if((Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Microsoft\CCM\CCMExec -Name ProvisioningMode) -eq "true"){
    Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false
}