#import-module \\prd\it\automation\Repository\Modules\Ecco.AzureAutomation\1.0.0\Ecco.AzureAutomation.psd1

$conn = Connect-EcAzureAutomation
$aa = $conn.automationaccount.AutomationAccountName
$rg = $conn.automationaccount.ResourceGroupName

$a = Get-AzureRmAutomationRunbook -ResourceGroupName $rg -AutomationAccountName $aa 

$a | foreach {
    $Runbook = @{}
    $Runbook.Name = $_.Name
    $_.tags

    $Runbook.Tags = [String]($_.tags.GetEnumerator() | foreach {"$($_.key):$($_.Value)"})
    $Runbook.Description = $_.Description
    <#$Runbook.RunbookType = $_.RunbookType
    $Runbook.State = $_.State
    $Runbook.Location = $_.Location
    $Runbook.Parameters = [String]($_.parameters.GetEnumerator() | foreach {"$($_.key):$($_.Value)"})
    $Runbook.CreationTime = $_.CreationTime
    $Runbook.LastModifiedBy = $_.LastModifiedBy
    $Runbook.LastModifiedTime = $_.LastModifiedTime#>
    $obj = New-Object PSObject -Property $Runbook
    $obj
    #Export-Csv -InputObject $obj c:\temp\runbooks.csv -NoTypeInformation -Encoding UTF8 -Append
}











