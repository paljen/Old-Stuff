Import-Module EccoUtil

function New-EccoAutomationScriptChange
{
    
}

function Set-EccoAutomationScript
{
    [CmdletBinding()]

    param
    (
        [String]$SourcePath,
        [Switch]$Publish
    )
   
    Begin
    {
        $ErrorActionPreference = "Stop"
        $psroot = "\\prd.eccocorp.net\it\PowerShell\Scripts\PJE\Draft"

        if ($Publish){
            $psroot = "\\prd.eccocorp.net\it\PowerShell\Scripts\PJE\Publish"
        }

        $bak = "$psroot\Backup"
    }
      
    Process
    {
        try
        {
            $file = Get-Item -Path $SourcePath

            if(Test-Path "$psroot\$($file.Name)")
            {
                Copy-Item -Path "$psroot\$($file.Name)" -Destination "$bak\$($file.Name)"
                Write-Verbose "BACKUP FILE `n$psroot\$($file.Name) to `n$bak\$($file.Name)"
                           
                Rename-Item -Path "$bak\$($file.Name)" -NewName "$($file.BaseName)@$(Get-date -f HHmmdMMyyyy).ps1"
                Write-Verbose "RENAME BACKUP `n$bak\$($file.Name) to `n$bak\$($file.BaseName)@$(Get-date -f HHmmdMMyyyy).ps1"


                Copy-Item -Path $($file.FullName) -Destination $psroot -Force
                Write-Verbose "COPY SOURCE `n$SourcePath to `n$psroot"
            }

            else
            {
                Copy-Item -Path $($file.FullName) -Destination $psroot
            }

            New-EccoScriptSigning -globalPath "$psroot\$($file.Name)" | Out-Null
        }

        catch
        {
            Write-Host $($_.Exception.Message) -ForegroundColor Red
        }
    }  
}

Set-EccoAutomationScript -SourcePath "C:\Scripts\ECCO\Test\MyTestScript.ps1" -Publish