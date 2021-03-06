#############################################################################
 #
 # Get-Runbooks.ps1
 # Date: 28/10/2014
 # Version: 1.0
 # Website: http://www.culham.net
 #
 # Happy to hear of any bugs, feedback, ideas for improvement.
 # Contact me at the above website.
 #
 # Remember to change $OrchestratorServer to the name of your own
 # Orchestrator Server
 #
 # Version 1.1 – added parameters – David Wallis blog.wallis2000.co.uk
 ##############################################################################
 
function Get-Runbooks {
	 param(
	 [Parameter(Position=0, Mandatory=$true)]
	 [System.String]$OrchestratorServer,
	 
	[Parameter(Position=1, Mandatory=$False)]
	 [string]$OrchestratorProtocol="http",
	 
	[Parameter(Position=2, Mandatory=$false)]
	 [System.String]$OrchestratorPort="81",
	 
	[Parameter(Position=3, Mandatory=$false)]
	 [bool]$UseDefaultCreds=$true
	 )
 
# The URL to your Orchestrator Runbook Server
 $baseurl = "$($OrchestratorProtocol)://$($OrchestratorServer):$($OrchestratorPort)/Orchestrator2012/Orchestrator.svc/"
 
# Base URL for Jobs collection
 $url = "$baseurl/Runbooks"
$request = [System.Net.HttpWebRequest]::Create($url)
 
# Set the credentials to use the default ones (the ones you are logged on with right now) or prompt for credentials.
 if ($UseDefaultCreds) {
 $request.UseDefaultCredentials = $true
 }Else{
 $request.Credentials = Get-Credential
 }
 
# Build the request header
 $request.Method = "GET"
$request.UserAgent = "Microsoft ADO.NET Data Services"
 
# Get the response from the request
 [System.Net.HttpWebResponse] $response = [System.Net.HttpWebResponse] $Request.GetResponse()
 
# Write the Http Web Response to String
 $reader = [IO.StreamReader] $response.GetResponseStream()
 $output = $reader.ReadToEnd()
 [xml]$output = $output
 $reader.Close()
 
# Array to hold the results
 $OutData =@()
 
# Output properties of each job in page to our array
 foreach ($runbook in $output.feed.entry)
 {
 Write-Output $runbook.content.Properties
 $RunbookDetail = New-Object PSObject
 $RunbookDetail | Add-Member -Name "Name" -MemberType NoteProperty -Value $runbook.content.properties.Name
 $RunbookDetail | Add-Member -Name "ID" -MemberType NoteProperty -Value $runbook.content.properties.ID.InnerText
 $RunbookDetail | Add-Member -Name "Status" -MemberType NoteProperty -Value $runbook.content.properties.Status
 $OutData += $RunbookDetail
 }
 
$OutData #| Sort-Object "Runbook Name" | ft -autosize
 #Write-Host "Total Number of Jobs is" $OutData.Count
 }
 
# Call Function
Get-Runbooks -OrchestratorServer DKHQSCORCH01.PRD.ECCOCORP.NET | Select Name, Status
