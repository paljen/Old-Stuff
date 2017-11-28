function Disable-ClientAccessSettings
{
    [CmdletBinding()]

	param(
		[Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
		[String[]]$users,
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
		[Switch]$DisablePOP3,
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
		[Switch]$DisableImap

        

	)
    
    begin
    {
        try
        {
            $Error.Clear()
		}

		catch
        {
			$_.Exception.Message
		}
    }

    process
    {
        if($DisablePOP3)
        {
            $DisablePOP3 = $false
        }

        if($DisableImap)
        {
            $DisableImap = $false
        }


        if($DisablePOP3 -or $DisableImap)
        {
            Write-Output $DisablePOP3
            Write-Output $DisableImap
            #Set-CASMailbox -Identity $user -PopEnabled $false -ImapEnabled $false
        }
    }
        
}

Disable-ClientAccessSettings -users "pje@ecco.com" -DisablePOP3 -DisableImap
