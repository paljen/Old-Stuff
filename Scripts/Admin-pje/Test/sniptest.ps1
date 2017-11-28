$psroot = "\\prd.eccocorp.net\it\PowerShell\ECCO"
$snip_Repository = Join-Path $psroot "Snippets"
#Import-IseSnippet -Path $snip_Repository -Recurse
Get-ChildItem $snip_Repository -Filter *.ps1xml | ForEach {$psise.CurrentPowerShellTab.Snippets.Load($_.FullName)}
