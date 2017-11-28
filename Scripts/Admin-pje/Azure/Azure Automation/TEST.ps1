workflow TEST
{
    [OutputType([string])]
    
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$CredentialName
        
    )
    
    # Get the credential to use for Authentication to Azure and Azure Subscription Name
    $Cred = Get-AutomationPSCredential -Name $CredentialName
    

    
    $CredIsNull = $Cred -eq $Null
    Write-Output $Cred
    Write-Output $CredIsNull
}