
function Get-LocalGrpMembers
{
    [CmdletBinding()]

    param(

        [parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]

        [string[]]$computername = $env:COMPUTERNAME

    )

    Process
    {
        foreach($c in $computername)
        {
            $group =[ADSI]"WinNT://$c/Administrators"

            $members = @($group.psbase.Invoke("Members"))
            
            $members | ForEach-Object {
                $obj = new-object psobject -Property @{
                'Server' = $c
                'Admin' = ([ADSI]$_).InvokeGet("Name")
                'Class' = ([ADSI]$_).SchemaClassName}
             
                Write-Output $obj
           
            }
         }
    }
}

function Get-ServerInfo
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
	
	process
    {
		foreach ($Computer in $ComputerName) 
        {
			try
            {
				if(Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop)
				{
                    $c = (gwmi -Class win32_computersystem -ComputerName $computer).name
				    Write-Output $c
				}
			}
			
			catch
            {
                $message = $_.Exception.Message
			}
		}		
	}
}

(Get-ADComputer -SearchBase "OU=TEST,OU=Member servers,DC=prd,DC=eccocorp,DC=net" -filter *).name  | get-serverinfo | Get-LocalGrpMembers | Out-EccoExcel 