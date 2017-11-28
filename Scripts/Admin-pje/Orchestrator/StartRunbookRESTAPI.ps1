# Details of the runbook we are going to run
$rbid = "7fc8834c-43f8-417c-bf35-0a5385a171ef"  
#$rbParameters = @{"5bef9609-2010-4647-900c-c5cc5da85881" = "Lenovo";" 00000000-0000-0000-00000000000000003" = " This is the value for Param2."}
$rbParameters = @{"5bef9609-2010-4647-900c-c5cc5da85881" = "Lenovo"}

# Create the request object
$request = [System.Net.HttpWebRequest]::Create("http://dkhqscorch01.prd.eccocorp.net:81/Orchestrator2012/Orchestrator.svc/Jobs")

# Set the credentials to default or prompt for credentials
$request.UseDefaultCredentials = $true
# $request.Credentials = Get-Credential

# Build the request header
$request.Method = "POST"
$request.UserAgent = "Microsoft ADO.NET Data Services"
$request.Accept = "application/atom+xml,application/xml"
$request.ContentType = "application/atom+xml"
$request.KeepAlive = $true
$request.Headers.Add("Accept-Encoding","identity")
$request.Headers.Add("Accept-Language","en-US")
$request.Headers.Add("DataServiceVersion","1.0;NetFx")
$request.Headers.Add("MaxDataServiceVersion","2.0;NetFx")
$request.Headers.Add("Pragma","no-cache")

# If runbook servers are specified, format the string
$rbServerString = "dkhqscorch01"
if (-not [string]::IsNullOrEmpty($RunbookServers)) {
   $rbServerString = -join ("<d:RunbookServers>",$RunbookServers,"</d:RunbookServers>")
}

# Format the Runbook parameters, if any
$rbParamString = ""
if ($rbParameters -ne $null) {
   
   # Format the param string from the Parameters hashtable
   $rbParamString = "<d:Parameters><![CDATA[<Data>"
   foreach ($p in $rbParameters.GetEnumerator())
   {
      #$rbParamString = -join ($rbParamString,"&lt;Parameter&gt;&lt;ID&gt;{",$p.key,"}&lt;/ID&gt;&lt;Value&gt;",$p.value,"&lt;/Value&gt;&lt;/Parameter&gt;")         
      $rbParamString = -join ($rbParamString,"<Parameter><ID>{",$p.key,"}</ID><Value>",$p.value,"</Value></Parameter>")
   }
   $rbParamString += "</Data>]]></d:Parameters>"
}

# Build the request body
$requestBody = @"
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<entry xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns="http://www.w3.org/2005/Atom">
    <content type="application/xml">
        <m:properties>
            <d:RunbookId m:type="Edm.Guid">$rbid</d:RunbookId>
            $rbserverstring
            $rbparamstring
        </m:properties>
    </content>
</entry>
"@

# Create a request stream from the request
$requestStream = new-object System.IO.StreamWriter $Request.GetRequestStream()
    
# Sends the request to the service
$requestStream.Write($RequestBody)
$requestStream.Flush()
$requestStream.Close()

# Get the response from the request
[System.Net.HttpWebResponse] $response = [System.Net.HttpWebResponse] $Request.GetResponse()

# Write the HttpWebResponse to String
$responseStream = $Response.GetResponseStream()
$readStream = new-object System.IO.StreamReader $responseStream
$responseString = $readStream.ReadToEnd()

# Close the streams
$readStream.Close()
$responseStream.Close()

# Get the ID of the resulting job
if ($response.StatusCode -eq 'Created')
{
    $xmlDoc = [xml]$responseString
    $jobId = $xmlDoc.entry.content.properties.Id.InnerText
    Write-Host "Successfully started runbook. Job ID: " $jobId
}
else
{
    Write-Host "Could not start runbook. Status: " $response.StatusCode
}