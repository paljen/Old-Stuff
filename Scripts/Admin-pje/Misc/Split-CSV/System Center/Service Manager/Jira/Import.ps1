##
$nr = 413 ## IR Start 
$usr = "paljen" ## AssignedTo
$jira = import-csv C:\Powershell\jira\JiraDataTest.csv ## Opgaver exporteret fra Jira

foreach($ir in $jira)
{
    $ht = @{
        Id = "IR"+$nr
        Urgency = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.UrgencyEnum.Medium
        Impact = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.ImpactEnum.Medium
        Title = $ir.key + " - " + $ir.Summary
        Classification = "Andet"
        Description = $ir.Description
        Source = "Console"
        TierQueue = "Statsforvaltning"
        Status = "Active"       
    }

    #New-SCSMObject -Class $iClass -PropertyHashtable $ht

    $id = "IR"+$nr
    $nr += 1
    
    $to = Get-SCSMObject -Class (Get-SCSMClass -name System.Domain.User$) -Filter "Username -eq $usr"
    $po = Get-SCSMObject -Class (Get-SCSMClass -name System.Domain.User$) -Filter "Username -eq 'metvon'"
    $au = Get-SCSMObject -Class (Get-SCSMClass -name System.Domain.User$) -Filter "Username -eq 'It helpdesk'"
    $ir = Get-SCSMObject -Class (Get-SCSMClass -name System.WorkItem.Incident$) -Filter "ID -eq $id"
    $ev = ((Get-SCSMObject -Class (Get-SCSMClass -name System.Environment$))[5])
    
    #New-SCSMRelationshipObject -RelationShip (Get-SCSMRelationshipClass -Name System.WorkItem.IncidentPrimaryOwner$) -Source $ir -Target $po -Bulk
    #New-SCSMRelationshipObject -RelationShip (Get-SCSMRelationshipClass -Name System.WorkItemAssignedToUser$) -Source $ir -Target $to -Bulk
    #New-SCSMRelationshipObject -RelationShip (Get-SCSMRelationshipClass -Name System.WorkItemAffectedUser$) -Source $ir -Target $au -Bulk
    #New-SCSMRelationshipObject -RelationShip (Get-SCSMRelationshipClass -Name IncidentBelongsToEnviroment) -Source $ir -Target $ev -Bulk
}