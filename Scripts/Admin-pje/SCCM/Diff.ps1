$SiteServer = 'dkhqsccm02'
$SiteCode = 'P01'
$CollectionName = 'All Systems'
$cred = Get-credential
#Retrieve SCCM collection by name
$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Class SMS_Collection -Credential $cred  | where {$_.Name -eq "$CollectionName"}
#Retrieve members of collection
$SMSClients = Get-WmiObject -ComputerName $SiteServer -Credential $cred -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" | select Name

$ost = get-adgroupmember "SEC-Global DirectAccess Clients"


(Compare-Object -ReferenceObject $ost -DifferenceObject $smsclients -Property name | where {$_.sideindicator -match "<="}).name