function computerObject
{
    [CmdletBinding()]

    param(
        [Parameter(ValueFromPipeline=$true)]
        [String]$ComputerName
    )

    Process
    {
        foreach ($c in $computername)
        {
            
            $sys = Get-WmiObject -Class win32_computersystem -ComputerName $c
            
            $props = @{'ComputerName'=$c;
                       'Model'=$sys.Model}
            
            $cpu = Get-WmiObject -Class win32_processor -ComputerName $c | select -First 1

            $props.Add('Cpu',$cpu.name)

            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
    }
}

"dkhqscorch01","dkhqdc01","dkhqdc02","dk4836" | computerObject | sort Model -Descending | select computerName,Model,Cpu