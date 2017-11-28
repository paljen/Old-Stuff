Import-Module EccoUtil

function Get-LocalGroupMembers
{
    [CmdletBinding()]

    param(

        [parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]

        [string[]]$ComputerName
    )

    Process
    {
        try
        {

            $ErrorActionPreference = "Stop"

            foreach($c in $computername)
            {
                Write-host $c
                $group =[ADSI]"WinNT://$c/Administrators"
                $members = @($group.psbase.Invoke("Members"))
            
                $members | ForEach-Object {
                
                    $hash = [Ordered]@{'ComputerName' = $c;
                                       'Administrators' = ([ADSI]$_).InvokeGet("Name");
                                       'Class' = ([ADSI]$_).SchemaClassName}

                    $obj = new-object psobject -Property $hash
                
                    Write-Output -InputObject $obj
           
                }
             }
         }

         catch
         {
                $message = $_.Exception.Message
                "Exception: $message" | Out-File "C:\TEMP\Error.txt" -Append
                Write-host -Object "Exception: $message"
         }
    }
}

function Get-ServerInfo
{
	[CmdletBinding()]

	param(
		[Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
		
        [String[]]$ComputerName
	)
	
	process
    {
		foreach ($Computer in $ComputerName) 
        {
			try
            {
				if(Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop)
				{
                    $name = Get-WmiObject -Class win32_computersystem -ComputerName $computer -ErrorAction Stop | select name
                    Write-Output -InputObject $name.name
				}
			}
			
			catch
            {
                $message = $_.Exception.Message
                "Exception: $Computer - $message" | Out-File "C:\TEMP\Error.txt" -Append
                Write-host -Object "Exception: $message"
			}
		}		
	}
}

(Get-ADComputer -SearchBase "OU=SAP Systems,OU=Member servers,DC=prd,DC=eccocorp,DC=net" -Filter *).name | Get-ServerInfo | Get-LocalGroupMembers | Out-EccoExcel 