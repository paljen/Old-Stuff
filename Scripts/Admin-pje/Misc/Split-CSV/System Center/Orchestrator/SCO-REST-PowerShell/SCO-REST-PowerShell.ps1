
function Query-RestService{
    [CmdletBinding()]
	PARAM (
        [Parameter(Mandatory=$true)]
        [String] $URL,
        
        [Parameter(Mandatory=$true)]
        [System.Net.NetworkCredential] $credentials,
                
        [Parameter(Mandatory=$false)]
        [String] $UserAgent = "PowerShell API Client",
        
        [Parameter(Mandatory=$false)]
        [Switch] $JSON,
        
        [Parameter(Mandatory=$false)]
        [Switch] $Raw
    
	)
    #Create a URI instance since the HttpWebRequest.Create Method will escape the URL by default.   
    $URL = Fix-Url $Url
    $URI = New-Object System.Uri($URL,$true)   

    #Create a request object using the URI   
    $request = [System.Net.HttpWebRequest]::Create($URI)   

    #Build the User Agent   
    $request.UserAgent = $(   
        "{0} (PowerShell {1}; .NET CLR {2}; {3})" -f $UserAgent, $(if($Host.Version){$Host.Version}else{"1.0"}),  
        [Environment]::Version,  
        [Environment]::OSVersion.ToString().Replace("Microsoft Windows ", "Win")  
        )

    $request.Credentials = $credentials
    
    if ($PSBoundParameters.ContainsKey('JSON'))
    {
        $request.Accept = "application/json"
    }
            
    try
    {
        [System.Net.HttpWebResponse] $response = [System.Net.HttpWebResponse] $request.GetResponse()
    }
    catch
    {
         Throw "Exception occurred in $($MyInvocation.MyCommand): `n$($_.Exception.Message)"
    }
    
    $reader = [IO.StreamReader] $response.GetResponseStream()  

    if (($PSBoundParameters.ContainsKey('JSON')) -or ($PSBoundParameters.ContainsKey('Raw')))
    {
        $output = $reader.ReadToEnd()  
    }
    else
    {
        [xml]$output = $reader.ReadToEnd()  
    }
    
    $reader.Close()  
    $response.Close()
    
    return $output
}

function Get-SCOCollections {
    [CmdletBinding()]
	PARAM (
        [Parameter(Mandatory=$true)]
        [String] $ScoServer,
        
        [Parameter(Mandatory=$true)]
        [System.Net.NetworkCredential] $credentials,
                
        [Parameter(Mandatory=$false)]
        [Int] $Port = 81
    
	)
    $url = "http://$($ScoServer):$($Port)/Orchestrator.svc/"
    $retVal = Query-RestService -url $url -credentials $credentials
    Write-Host $retval.get_outerxml()
    $collections = $retVal.SelectNodes("//collection")
    $titles = ""
    foreach ($collection in $collections)
    {
        $titles += $titles + $collection.href
    }
   
   return $titles
   
}

function Query-SCOService {
    [CmdletBinding()]
	PARAM (
        [Parameter(Mandatory=$true)]
        [String] $ScoServer,
        
        [Parameter(Mandatory=$true)]
        [System.Net.NetworkCredential] $credentials,
                
        [Parameter(Mandatory=$false)]
        [Int] $Port = 81,
        
        [Parameter(Mandatory=$false)]
        [String] $Query 
	)
    
    $url = "http://$($ScoServer):$($Port)/Orchestrator.svc/$($Query)"
    $retVal = Query-RestService -url $url -credentials $credentials    
   
    return $retVal.get_outerXml()
   
}

function ConvertTo-SCOObject {
[CmdletBinding()]
	PARAM (
        [Parameter(Mandatory=$true)]
        [String] $XmlFeed
    )
    $xml =[xml]$XmlFeed
   
    $ns = New-Object Xml.XmlNamespaceManager $xml.NameTable
    $ns.AddNamespace( "d", "http://schemas.microsoft.com/ado/2007/08/dataservices")
    $ns.AddNamespace( "m", "http://schemas.microsoft.com/ado/2007/08/dataservices/metadata")
    $ns.AddNamespace( "def", "http://www.w3.org/2005/Atom")
    
    $objarray = @()
    
    $entryNodes = $xml.SelectNodes("//def:entry",$ns)
    foreach ($entryNode in $entryNodes)
    {
        $obj = New-Object PSObject
        $objectType = $entryNode.SelectSingleNode(".//def:category", $ns).GetAttribute("term")
        
        $obj | add-member Noteproperty -Name "Object Type" -Value $objectType.Split(".")[-1]
        
        $propertiesNode = $entryNode.SelectSingleNode(".//m:properties", $ns)
        foreach($propertyNode in $propertiesNode.ChildNodes)
        {
            $obj | add-member Noteproperty -Name $propertyNode.LocalName -Value $propertyNode.get_InnerText()
        }
        
        $links = $entryNode.SelectNodes(".//def:link", $ns)
        foreach ($link in $links)
        {
            $obj | add-member NoteProperty -Name $link.title -Value $link.href
        }
        $objarray += $obj
    }
 
    return $objarray
}


function Format-XML { 
<#
.SYNOPSIS
   Takes an XML document and turns it into a "pretty" format for reading on screen.

.DESCRIPTION
    Takes an XML document without any formatting and seperates elements onto separate
    lines and indents child elements for better viewing.

.PARAMETER Xml
    The XML string to be formatted
    
.PARAMETER Indent
    The number of spaces to indent each child level (default = 2).
    
.EXAMPLE
    $xmldocument | Format-XML
.EXAMPLE
    Format-XML -xml $xmldocument 
.EXAMPLE
    $xmldocument | Format-XML -indent 4
    
#>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [xml]$xml, 
        
        [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
        [int]$indent=2
    ) 
    
    PROCESS
    {
        $StringWriter = New-Object System.IO.StringWriter 
        $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
        $xmlWriter.Formatting = "indented" 
        $xmlWriter.Indentation = $Indent 
        $xml.WriteContentTo($XmlWriter) 
        $XmlWriter.Flush() 
        $StringWriter.Flush() 
        Write-Output $StringWriter.ToString() 
    }
} 

Function Fix-Url ($url) {
    if($url.EndsWith('/') -Or $url.EndsWith('\')) {
        return $url
    }    
    "$url/"
}

function Create-Credentials{
    [CmdletBinding()]
	PARAM (
        [Parameter(Mandatory=$true)]
        [String] $domain,
        
        [Parameter(Mandatory=$true)]
        [String] $username,
                
        [Parameter(Mandatory=$true)]
        [String] $password 
    
	)
    $creds = New-Object System.Net.NetworkCredential($username,$password,$domain)  
    return $creds
}

Query-SCOService -scoserver "10.129.12.64” -credentials $cred -query (ConvertTo-SCOObject -XmlFeed $xmlfeed | ? {$_.Status -ne "Completed"}).Instances | Select ID