Import-Module Scorch

$rbGuid = "4dfc64f8-7f02-4810-a370-67fb368e1d86"
$rbServer = "DKHQSCORCH01.PRD.ECCOCORP.NET"      
$rbWebURL = New-SCOWebserverURL -ServerName $rbServer
        

## Garther Computer Information
$rbparams = @{'GUID'="558081CC-338B-11B2-A85C-D8E7EFD206B6";
              'Computername'="sccm_p50_cert";
              'PrimaryUser'="mig";
              'OSDCollectionID'="P01001F5";
              'RoleCollectionID'="P010002E";}


## Call Scorch Runbook with computer data and wait for the runbook to finish
Start-SCORunbook -webserverURL $rbWebURL -RunbookGuid $rbGuid -InputParameters $rbparams -WaitForExit