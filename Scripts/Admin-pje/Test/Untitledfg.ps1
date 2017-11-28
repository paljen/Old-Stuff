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
				
                $props.Add('OSVersion',($os.Version).toString())
				$props.Add('SPVersion',$os.ServicePackMajorVersion)

                $cpu = gwmi -ComputerName $computer win32_processor -ErrorAction Stop
                $cpuCount = ($cpu.deviceid | Measure).count

                $props.Add('CPUCount',$cpuCount)
                $props.Add('CPUName',$cpu.Name)
                $props.Add('NumberOfCores',($cpu.NumberOfCores * $cpuCount))
                $props.Add('NumberOfLogicalProcessors', ($cpu.NumberOfLogicalProcessors * $cpuCount))
                $props.Add('MaxClockSpeed',$cpu.MaxClockSpeed)

                $mem = gwmi -class Win32_PhysicalMemory 
                $props.Add('MemoryGB',$($mem.capacity / 1GB -as [int]))

				$out = New-Object -TypeName PSObject -Property $props

				Write-Output $out
			}
			
			catch
            {
				$props = [Ordered]@{
                         'Name'=$Computer;
						 'Model'=$null;
						 'Manufacturer'=$null;
                         'OSVersion'=$null
                         'SPVersion'=$null}

                $out = New-Object -TypeName PSObject -Property $props

				Write-Output $out
			}
		}		
	}
}

get-eccoserverinfo -ComputerName DKHQSCORCH01, DKHQFILE01, DKHQDC01 | fl -Property *