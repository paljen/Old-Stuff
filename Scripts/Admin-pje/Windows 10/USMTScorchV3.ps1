<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

  <Example explanation goes here>
#>

## Execute in Powershell v3 Process
$var = powershell {

function Write-LogFile
{
	param(
	
		[string]$Message
	)
	
	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($("$LogPath\USMTClientMigration.log"), $true)
	$Output = "$([DateTime]::Now): $Message"
	$Log.WriteLine($Output)
	$Log.Close()
}

function Get-EccoComputerNamesFromInventory 
{
    <#
        .SYNOPSIS
    #>
    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$True, 
                   ValueFromPipeline=$True)]

        [String]$query
    )
        
    Get-EccoDatabaseData -connectionString $ECCOConnectionString -isSQLServer -query $query 
}

function Set-EccoInventoryInDatabase 
{
    <#
        .SYNOPSIS
    #>

    #[CmdletBinding()]

    param(
        [Parameter(Mandatory=$True, 
                   ValueFromPipeline=$True)]

        [object[]]$inputObject
    )

    Process {

        foreach ($obj in $inputObject)
        {
            $query = "UPDATE USMTData SET
                      ComputerName = '$($Obj.ComputerName)',
                      PrimaryUser = '$($Obj.PrimaryUser)',
                      USMTSize = '$($Obj.USMTSize)',
                      Date = '$(Get-Date)'
                      WHERE computername = '$($obj.computername)'"

            Write-Verbose "Query will be $query"

            Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
        }
    }
}

function New-EccoComputerDataObject
{
    <#
        .SYNOPSIS
    #>

    [CmdletBinding()]

    param(

    )

    $props = @{
               'ComputerName'=$cn;
               'PrimaryUser'=$pu;
               'USMTSize'=$USMTSize;
               'Date'=Get-Date;
    }

    $out = New-Object -TypeName PSObject -Property $props

    Write-Output $out
}

function New-EccoInventoryInDatabaseRecord
{
    <#
        .SYNOPSIS
    #>

    [CmdletBinding()]

    param(
        [Parameter(Mandatory=$False, 
                   ValueFromPipeline=$True)]

        [Object[]]$inputObject
    )

    Process {

        $query = "INSERT INTO USMTData (Computername,PrimaryUser,USMTSize,Date) VALUES 
                 ('$($inputObject.ComputerName)','$($inputObject.PrimaryUser)',$($inputObject.USMTSize),'$(Get-Date)')"

        Write-Verbose "Query will be $query"

        Invoke-EccoDatabaseQuery -connection $ECCOConnectionString -isSQLServer -query $query
    }
}

function Set-EccoUSMTInventory
{
    param(
        [Parameter(Mandatory=$False, 
                   ValueFromPipeline=$True)]

        [Object[]]$cObj
    )
    
   if (Get-EccoComputerNamesFromInventory -query "SELECT [computername] FROM [USMT_Inventory].[dbo].[USMTData] WHERE [computername]='$($cObj.computername)'")
   {
        Write-Verbose "Set-EccoInventoryInDatabase -inputObject $($cObj)"
        Write-LogFile "Set-EccoInventoryInDatabase -inputObject $($cObj)"
        Set-EccoInventoryInDatabase -inputObject $cObj
   }
   else
   {
        Write-Verbose "New-EccoInventoryInDatabaseRecord -inputObject $($cObj)"
        Write-LogFile "New-EccoInventoryInDatabaseRecord -inputObject $($cObj)"
        New-EccoInventoryInDatabaseRecord -inputObject $cObj
   }    
}

function Main
{
   Write-LogFile "$cn"
   $cn = "\`d.T.~Ed/{1C6FA26A-3182-488F-AF9B-571D17857F7E}.{061161C8-80F5-4BD4-9456-37BCC85B42A6}\`d.T.~Ed/"
   Write-LogFile "$($pu)"
   $pu = "\`d.T.~Ed/{1C6FA26A-3182-488F-AF9B-571D17857F7E}.{172781FF-07E5-4F10-ABB0-A5D07CAC9CC2}\`d.T.~Ed/"
   Write-LogFile "$($USMTSize)"
   $USMTSize = "\`d.T.~Ed/{1C6FA26A-3182-488F-AF9B-571D17857F7E}.{FD0C019A-E778-4D88-AC98-343EFFA2BE72}\`d.T.~Ed/"
   $LogPath = $env:temp

   try
   {
      Import-Module 'c:\Scripts\Ecco\Functions\EccoDB\EccoDB.psm1' -ErrorAction Stop
      "$LogPath\USMTServerMigration.log" | Remove-Item -ErrorAction SilentlyContinue
      $ECCOConnectionString = "server=DKHQSCCM02;database=USMT_Inventory;trusted_connection=True"
      New-EccoComputerDataObject | Set-EccoUSMTInventory
   }
   catch
   {
      Write-LogFile "Exception caught: $($error[0].Exception.Message)"
      Write-LogFile "Terminating script"
   }
}

Main

} ##End Powershell v3 Process