<#  
.SYNOPSIS  

.DESCRIPTION  
 
.PARAMETER Credential  
    Credentials stored as an Azure Automation credential asset  
    When using in the Azure Automation UI, please enter the name of the 
    credential asset for the "Credential" parameter
    
.EXAMPLE  

  
.NOTES  
    Author: Palle Jensen   
    Last Updated: 16/02/2016     
#> 

workflow Server-Credentials
{
    param
    (
        # Credentials stored as an Azure Automation credential asset
        # When using in the Azure Automation UI, please enter the name of the credential asset for the "Credential" parameter
        [parameter(Mandatory=$true)] 
        [PSCredential] $Credential
    )
    
    inlinescript
    {    
        # Establish credentials for Azure server 
        $Servercredential = new-object System.Management.Automation.PSCredential($Using:Credential.UserName, (($Using:Credential).GetNetworkCredential().Password | ConvertTo-SecureString -asPlainText -Force)) 
        
        Write-Output $Servercredential
    }
}