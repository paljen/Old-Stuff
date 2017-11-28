function Stop-CompanyXyzServices
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]

    Param(
        [Parameter(
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]      
        [string]$Name
    )


    process
    {
        if($PSCmdlet.ShouldProcess($env:COMPUTERNAME,"Stop service '$Name'"))
        {                   
            Stop-Service $name -WhatIf:([bool]$WhatIf) -Confirm:([bool]$confirm)
        }                       
    }
}

Stop-CompanyXyzServices bits