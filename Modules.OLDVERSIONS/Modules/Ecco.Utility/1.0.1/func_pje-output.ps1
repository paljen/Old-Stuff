function Out-EccoExcel
{
    <#
    .SYNOPSIS
	    Output data to excel

    .DESCRIPTION
	    outputs the pipeline to a CSV file and invokes the file.

    .EXAMPLE
        Get-Process | Select name, cpu | Out-EccoGeExcel

    .INPUTS
	    $input variable

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  01/09/15
	    Purpose/Change: Initial function development
    #>
	
  	param
    (
		$Path = "c:\TEMP\$(Get-Date -Format yyyyMMddHHmmss).csv"
	)
 
  	$input | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
  	Invoke-Item -Path $Path
}

function Out-EccoHTML
{
    <#
    .SYNOPSIS
	    Output data to HTML.

    .DESCRIPTION
	    outputs the pipeline to a HTML file and invokes the file.

    .EXAMPLE
        Get-Process | Select name, cpu | Out-EccoGeHTML

    .INPUTS
	    $input variable

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  01/09/15
	    Purpose/Change: Initial function development
    #>
	
  	param
    (
		$Path = "c:\TEMP\$(Get-Date -Format yyyyMMddHHmmss).html"
	)
    
    [string]$CSS = @"
        <style>
        TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
        TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;font-size:120%;}
        TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
        </style>
"@

  	$input | ConvertTo-Html -Title "ECCO Shoes A/S" -Head $CSS | Out-File $path
  	Invoke-Item -Path $Path
}

function Out-EccoEasyView
{
    <#
    .SYNOPSIS
	    Output to console with Sleep 1s

    .DESCRIPTION
	    Output to console with Sleep 1s

    .EXAMPLE
        Get-ChildItem C: | Out-EasyView

    .INPUTS
	    $input variable

    .NOTES
	    Version:        1.0.0
	    Author:         Admin-PJE
	    Creation Date:  01/09/15
	    Purpose/Change: Initial function development
    #>

    process 
    { 
        $input
        Start-Sleep -seconds 1
    }
}