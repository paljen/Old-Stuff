function Validate-Parameters
{ 
    [CmdletBinding()]

    param( 
        [parameter(Mandatory=$true)]
        [String] $Path,
        [parameter(Mandatory=$false)]
        [AllowEmptyString()]
        [String] $Parameter
    )
    
    Write-Output "Validation succeeded" 
} 

Validate-Parameters -Parameter  -Path 