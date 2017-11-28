
	#$cmd = @{"NetSh"=@(netsh dns show state)
			 #"GPUpdate"=@(GPUpdate /Target:Computer /Force)}
$rbGuid = "5342b516-9204-46da-9ab6-54db58a06600"
	$rbServer = "10.129.12.64" #DKHQSCORCH01.PRD.ECCOCORP.NET
	$rbParams = @{}
$rbParams.Add("ComputerName",$($env:COMPUTERNAME))

$rbWebURL = New-SCOWebserverURL -ServerName $rbServer
			
$cmd = @{"NetShDns"=@(netsh dns show state)
			 "NetShInterface"=@(netsh interface teredo show state)}


$DAGServer =((((($cmd["NetShInterface"]) | select-String "Server") -replace " ","") `
                -replace "ServerName:","").TrimStart()).TrimEnd()


if($DAGServer -eq "dahq.ecco.com(GroupPolicy)")
{
    Write-host "jay"
}
