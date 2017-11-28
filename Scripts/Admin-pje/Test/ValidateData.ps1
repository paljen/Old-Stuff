function Validate-Parameters
{ 
    [CmdletBinding()]
    param( 
        [parameter(Mandatory=$true, ParameterSetName="Name")]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(6,50)]
        [String] $Name,
        [parameter(Mandatory=$true, ParameterSetName="Owner")]
        [ValidateNotNullOrEmpty()]
        [String] $Owner
    ) 

    Write-Output "Validate Success"
} 

Validate-Parameters -Name "pje-test"