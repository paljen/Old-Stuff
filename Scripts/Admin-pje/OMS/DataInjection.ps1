

# Replace with your Workspace ID
$CustomerId = "7a1e79ac-1c97-48d2-9d93-49aaa930ca2c"  

# Replace with your Primary Key
$SharedKey = "KYxKF6k6KxQr4iuEjMUWadb9HEU8RzQiU1Dw9qwRJQPKLzzEkY8Dm87XKAQ5eURN3M8YopdN55BXUaYmKABo5g=="

# Specify the name of the record type that you'll be creating
$LogType = "MyCustomLog"

# Specify a field with the created time for the records
$TimeStampField = "DateValue"

#YYYY-MM-DDThh:mm:ssZ 
# Create two records with the same set of properties to create
$json = @"
[{  "String": "MyString3",
    "Number": 42,
    "Boolean": true,
    "Date": "2016-11-21T20:00:00.62Z",
    "GUID": "9909ED01-A74C-4874-8ABF-D2678E3AE23D"
},
{   "String": "MyString4",
    "Number": 43,
    "Boolean": false,
    "Date": "2016-11-21T20:00:00.62Z",
    "GUID": "8809ED01-A74C-4874-8ABF-D2678E3AE23D"
}]
"@

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}


# Create the function to create and post the request
Function Post-OMSData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -fileName $fileName `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}

# Submit the data to the API endpoint
Post-OMSData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType
