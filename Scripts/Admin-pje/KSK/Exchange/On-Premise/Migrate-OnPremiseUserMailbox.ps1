<#
.DESCRIPTION
    Workflow for migrating mailbox to Office365 (hybrid).

    The script starts connecting to Azure, MSOnline and Exchange On-Premise.

    A list of mailbox objects are then populated that has an E1 License in MSOnline.

    If the list is not empty, a runbook, to make the move requests (migrations), 
    are then called with the polulated list of mailbox objects.

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
$RunbookName = "Migrate-OnPremiseUserMailbox"

try
{

    #region Connect to Azure
    $conn = .\Connect-AzureRMAutomation.ps1

    $trace = ""
    $trace += "$([DateTime]::Now.ToString())`t[Starting Workflow: $runbookname]`n"
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

    # Get all onprem mailboxes in ECCO OU that have an Office 365 license 
    $ou = "OU=ECCO,DC=prd,DC=eccocorp,DC=net"
    $exclude = "\b(TERMINATED USERS)\b"     
    
    $mb = Get-Mailbox -ResultSize Unlimited -Filter {UserPrincipalName -like "*@ecco.com"} -OrganizationalUnit $ou |  foreach {
        try
        {
            Get-ADUser -identity $_.Guid | Where-Object {$_.enabled -eq $true -and $_.DistinguishedName -notmatch $exclude} | Foreach {            
                try
                {
                    Get-MsolUser -UserPrincipalName $_.UserPrincipalName | ? {$_.Islicensed -eq $true} | foreach {
                        try
                        {
                            Get-Mailbox $_.UserPrincipalName
                            $trace += "$([DateTime]::Now.ToString())`t$($_.UserPrincipalName) : Is Licensed and has an On-Premis Mailbox`n"
                        }
                        catch
                        {
                            $trace += "$([DateTime]::Now.ToString())`t$($user) : Error - $($_.exception.message)`n"
                        }
                    }
                }
                catch
                {
                        $trace += "$([DateTime]::Now.ToString())`tError - $($_.exception.message)`n"
                }
            }
        }
        catch
        {
            $trace += "$([DateTime]::Now.ToString())`tError - $($_.exception.message)`n"
        }
    }  

    if($mb -ne $null)
    {
        $par = @{'UserPrincipalName'=$mb.UserPrincipalName}
        $out = Start-AzureRmAutomationRunbook -Name New-O365MailboxMigration -Parameters $par -ResourceGroupName $conn.AutomationAccount.ResourceGroupName -AutomationAccountName $conn.AutomationAccount.AutomationAccountName -RunOn ECCO-DKHQ -Wait
        $trace += "$($out.Trace)"
    }
    else
    {
        $trace += "$([DateTime]::Now.ToString())`tNo Mailboxes to migrate`n"
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