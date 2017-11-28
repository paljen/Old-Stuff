<#
.DESCRIPTION
    Enable archive on migrated mailbox, Hybrid environment.

    The script starts connecting to Azure, MSOnline and Exchange On-Premise.
    
    A list of mailbox objects are then populated with a filter where the ArchiveGuid 
    is 00000000-0000-0000-0000-000000000000 (Default guid where the archive is not enabled)
    and the Name is not DiscoverySearchMailbox. 
    
    Archive is then enabled for objects in that list.

.INPUTS
    NA

.OUTPUTS
    NA

.NOTES
    Version:        1.0.0
    Author:			Admin-PJE
    Creation Date:	21/02/2017
    Purpose/Change:	Initial runbook development
#>

Param(

)

$ErrorActionPreference = "Stop"
$RunbookName = "Enable-HybridArchive"

try
{

    #region Connect to Azure
    $conn = .\Connect-AzureRMAutomation.ps1

    $trace = ""
    $trace += "$([DateTime]::Now.ToString())`t[Starting Runbook: $runbookname]`n"
    $trace += "$($conn.Trace)"

    if($conn.status -ne "Success")
    {
        Throw "Error - Connecting to Azure failed"
    }

    Write-verbose "Successfully Logged into Azure!"
    #endregion
            
    #region Import Modules and connections
    $modules = @()
    $modules += .\Connect-MSOnline.ps1
    $modules += .\Connect-ExchangeOnPrem.ps1

    $trace += "$($modules[0].Trace)"
    $trace += "$($modules[1].Trace)"

    # Throw error if one module dont get imported
    if($modules[0].ObjectCount -lt 1 -or $modules[1].ObjectCount -lt 1)
    {
        Throw "Error - One or more modules was not imported"
    }
    #endregion

    # Get migrated mailboxes and enable remote archive
    $mb = Get-RemoteMailbox -Filter {ArchiveGuid -eq "00000000-0000-0000-0000-000000000000" -AND (Name -NotLike "DiscoverySearchMailbox*")}

    $mb | Foreach {
        try
        {
            Enable-RemoteMailbox -Identity $_.UserPrincipalName -Archive -Confirm:$false | Out-Null
            $trace += "$([DateTime]::Now.ToString())`tSuccessfully enabled archive for user: $($_.UserPrincipalName)`n"
        }
        catch
        {
            $trace += "$([DateTime]::Now.ToString())`t$($_.exception.message)`n"
        }
    }
       
    # Return values to component runbook
    $props = @{'Status' = "Success"
               'Message' = "Workflow Finished Successfully"
               'ObjectCount' = 1}
}

catch
{
    $trace += "$([DateTime]::Now.ToString())`tException Caught at line $($_.InvocationInfo.ScriptLineNumber)`n"

    if($_.Exception.WasThrownFromThrowStatement)
    {$status = "failed"}
    else
    {$status = "warning"}

    # Return values to component runbook
    $props = @{'Status' = $status
               'Message' = $(if($_.Exception.Message.Contains("`"")){$_.Exception.Message.Replace("`"","'")}else{$_.Exception.Message})
               'ObjectCount' = 0}
    
    Write-Error $status
}
finally
{
    $props.Add('Trace',$trace)
    $props.Add('RunbookName',$RunbookName)

    $out = New-Object -TypeName PSObject -Property $props

    Write-Output $out
}  