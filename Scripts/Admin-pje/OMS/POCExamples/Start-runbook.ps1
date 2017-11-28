#Switch-AzureMode AzureResourceManager
#Select-AzureSubscription "Individual Subscription - JGS"
Login-AzureRmAccount
$PSDefaultParameterValues = @{
                              "*AzureAutomation*:ResourceGroupName" = "xxxxx" 
                              "*AzureAutomation*:AutomationAccountName" = "xxx"
                            }

$Params = @{"ComputerName" = "Test01"; "ServiceName" = "spooler" }
$Job = Start-AzureRMAutomationRunbook -Name "Test-JSONOutput" -Parameters $params

Write-Output "Job Started:" 
$Job
