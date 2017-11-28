function Get-EccoServerInfo
{
    <#
    .Synopsis
       Get server information
    .DESCRIPTION
       Get server information
    .EXAMPLE
       Get-EccoServerInfo -Computername server1
    .EXAMPLE
       Get-EccoServerInfo -computername $((Get-QADComputer -SearchRoot "prd.eccocorp.net/Servers").name) | ft -autosize
    .EXAMPLE
       (Get-QADComputer -SearchRoot "prd.eccocorp.net/Servers").name | Get-EccoServerInfo | Out-EccoGeExcel
    .INPUTS
       String
    .OUTPUTS
       PSCustom Objects
    .FUNCTIONALITY
       WMI
    #>
	
	[CmdletBinding()]

	param(
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
		[String[]]
        $ComputerName
	)
	
	begin
    {
		try
        {
            $Error.Clear()
			Add-EccoGeQADSnapin
		}

		catch
        {
			$_.Exception.Message
		}
	}
	
	process
    {
		foreach ($Computer in $ComputerName) 
        {
			try
            {
				if(Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop)
				{
					$cs = gwmi -ComputerName $Computer -Class Win32_ComputerSystem -ErrorAction Stop
				}

				$props = [Ordered]@{
                         'Name'=$cs.PSComputerName;
						 'Model'=$cs.model;
						 'Manufacturer'=$cs.Manufacturer;}
				
				$os = gwmi -ComputerName $Computer -Class Win32_OperatingSystem -ErrorAction Stop
				
                $props.Add('OSVersion',$os.Version)
				$props.Add('SPVersion',$os.ServicePackMajorVersion)
                
				$out = New-Object -TypeName PSObject -Property $props

				Write-Output $out
			}
			
			catch
            {
				$_.Exception.Message
			}
		}		
	}
}

Get-EccoServerInfo dkhqexc04n01

$script:TraceLog