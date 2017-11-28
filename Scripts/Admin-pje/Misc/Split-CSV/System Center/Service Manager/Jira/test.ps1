#get-scsmobject -Class (Get-SCSMClass system.workitem.incident$) | where id -eq "IR412" | select *

#Get-SCSMObject -Class (Get-SCSMClass system.environment*)
#(Get-SCSMEnumeration -Name system.environmentcategoryEnum.Production).gettype()

#$i = Get-SCSMEnumeration -Name System.WorkItem.TroubleTicket.ImpactEnum

#$test | select *
#New-SCSMRelationshipObject -RelationShip (Get-SCSMRelationshipClass -Name System.WorkItem.IncidentPrimaryOwner$) -Source $ir -Target $po -Bulk
$id = "IR394"
$ir = Get-SCSMObject -Class (Get-SCSMClass -name System.WorkItem.Incident$) -Filter "ID -eq $id"
$obj = ((Get-SCSMObject -Class (Get-SCSMClass -name System.Environment$))[5])
New-SCSMRelationshipObject -RelationShip (Get-SCSMRelationshipClass -Name IncidentBelongsToEnviroment) -Source $ir -Target $obj -Bulk
#get-help Get-SCSMRelatedObject -Examples


#((Get-SCSMObject -Class (Get-SCSMClass -name System.Environment$))[5])

