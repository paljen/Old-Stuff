<#
.DESCRIPTION
    Setting Skype LineURI attribute to tel:+00$($_.Employeenumber) for users with a valid employeenumber

    The script starts connecting to Azure, ActiveDirectory and skype OnPremise.
    
    A list of skype user objects are then populated from a valid employeenumber.
    
    Lastly the attribute LineURI is updated with the employeenumber in the format tel:+00$($_.Employeenumber)

.INPUTS
    NA

.OUTPUTS
    NA

.NOTES
    Version:        1.0.0
    Author:			Admin-PJE
    Creation Date:	22/02/2017
    Purpose/Change:	Initial runbook development
#>

Param(

)

# Continue = enable verbose
$VerbosePreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$RunbookName = "testskype"

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
    $modules += Import-Module ActiveDirectory -PassThru
    $trace += "$([DateTime]::Now.ToString())`tSuccessfully imported module from $($modules[0].Name)`n"

    $modules += .\Connect-SkypeOnPrem.ps1
    $trace += "$($modules[1].Trace)"

    # Throw error if one module dont get imported
    if($modules[0].count -lt 1 -or $modules[1].ObjectCount -lt 1)
    {
        Throw "Error - One or more modules was not imported"
    }
    #endregion

    (Get-CsUser | ? {$_.EnterpriseVoiceEnabled -ne $true -and $_.LineURI -eq ""})| ForEach-Object {
        try{
        # foreach skype user get AD property employeenumber
            Get-ADUser -Identity $($_.DistinguishedName) -Properties Employeenumber | ForEach-Object {
            
                # Check if employeenumber is not null and employeenumber match format criteria of minimum 8 digits
                if($_.EmployeeNumber -ne $null -and $_.EmployeeNumber -match "\d{8}\d*")
                {
                    try
                    {
                        #Set lineuri to the employeenumber for the given user
                        Set-CsUser -Identity $_.DistinguishedName -LineURI "tel:+00$($_.Employeenumber)" -ErrorAction Ignore
                        $trace += "$((Get-Date).ToString())`tUser $($_.UserPrincipalName), LineURI set to `"tel:+00$($_.Employeenumber)`"`n"
                    }
                    catch
                    {
                        $trace += "$((Get-Date).ToString())`t$($_.Exception.Message)`n"
                    }
                }
            }  
        }
        catch
        {
            $trace += "$((Get-Date).ToString())`t$($_.Exception.Message)`n"
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
    $props.Add('RunbookName',$runbookname)

    $out = New-Object -TypeName PSObject -Property $props

    #.\Invoke-LoggingErrorRoutine.ps1 -params $props

    Remove-PSSession -name $($modules[1].Connect.Session.Name)

    Write-Output $out
}     