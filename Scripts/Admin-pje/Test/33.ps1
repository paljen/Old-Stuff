Import-Module EccoUtil

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
        
        $psroot = "\\prd.eccocorp.net\it\PowerShell\Scripts\PJE\TEST"

    }
      
    Process
    {
        try
        {
            $file = Get-Item -Path $SourcePath -ErrorAction Stop

            if(Test-Path "$psroot\$($file.Name)")
            {
                Write-Verbose "File already exist"
                $dest = "$psroot\Backup\$($file.Name)"
                Copy-Item -Path $($file.FullName) -Destination $dest               
                Rename-Item -Path $dest -NewName "$($file.BaseName)$(Get-date -f HHmmdMMyyyy).ps1"

            }
            else
            {
                Copy-Item -Path $($file.FullName) -Destination $psroot
            }

            
    
            $props = @{}
            $props.Name = "Ecco.Automation.Workspace"
            $props.Path = "C:\Ecco.Automation.Workspace"
            $workspace = New-Object -TypeName PSObject -Property $props

            $workspace

            #New-EccoScriptSigning -globalPath "$psroot\$file"
        }
        catch
        {
            Write-Host $($_.Exception.Message) -ForegroundColor Red
        }
    }  
}

Set-EccoAutomationScript -SourcePath "C:\Scripts\ECCO\Test\33.ps1" -Verbose