# Import the SMlets Module
Import-Module -Name SMLets

# Query an Incident ticket
Get-SCSMObject -Class (Get-SCSMClass -Name System.WorkItem.Incident$) -filter "DisplayName -like 'IR30*'"


 