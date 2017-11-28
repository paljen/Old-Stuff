<#
.DESCRIPTION
    Disable POP3 and IMAP for all users in Office365.

    The script starts connecting to Azure, MSOnline and Exchange Online.
    
    A list of mailbox objects are then populated where pop3 or imap is enabled.
    
    Pop3 and Imap is then disabled for objects in that list.

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

try
{
    #region Connect to Azure
    $conn = .\Connect-AzureRMAutomation.ps1

    $trace = ""
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
    $modules += .\Connect-ExchangeOnline.ps1

    $trace += "$($modules[0].Trace)"
    $trace += "$($modules[1].Trace)"

    # Throw error if one module dont get imported
    if($modules[0].ObjectCount -lt 1 -or $modules[1].ObjectCount -lt 1)
    {
        Throw "Error - One or more modules was not imported"
    }
    #endregion

    # Get all user where client access setting pop3 or imap is enabled and disable
    $users = Get-CASMailbox -ResultSize Unlimited | where {($_.PopEnabled -eq $true -or $_.ImapEnabled -eq $true)}

    $users | ForEach-Object { 
        try
        {
            $user = $_.name

            # Set Client Access Settings (disable POP3 and Imap) for user
            Set-CASMailbox -Identity $user -PopEnabled $false -ImapEnabled $false
            $trace += "$([DateTime]::Now.ToString())`t$($user) : POP3 and IMAP Disabled Succesfully`n"
        }
        catch
        {
            $trace += "$([DateTime]::Now.ToString())`t$($user) : Error - $($_.exception.message)`n"
        }
    }

    # Return values to component runbook
    $props = @{'Status' = "Success"
               'Message' = "Successfully finished runbook flow"
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
    $props.Add('RunbookName',"Disable-O365ClientAccessSettings")

    $out = New-Object -TypeName PSObject -Property $props

    #.\Invoke-LoggingErrorRoutine.ps1 -params $props

    Write-Output $out
}
