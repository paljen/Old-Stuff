@{
GUID="{431d3720-607e-4997-9cfa-b859a5d7a440}"
Author="SCOrch Dev"
CompanyName="SCOrch Dev"
Copyright=""
ModuleVersion="1.0.0.0"
PowerShellVersion="2.0"
CLRVersion="2.0"
RequiredAssemblies="OrchestratorInterop.dll"
ModuleToProcess="scorch.PoSH.module.dll"
CmdletsToExport = @('Start-SCORunbook','Get-SCOSubfolder','Stop-SCOJob','Get-SCORunbookServer','Get-SCOJob','New-SCOWebserverURL','Get-SCOEvent','Get-SCOMonitorRunbook','Get-SCORunbook')
FunctionsToExport = '*'
AliasesToExport = '*'
}