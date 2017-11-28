workflow Copy-LocalFiles
{
    Param
    (
        [parameter(Mandatory=$true)]
        [String] $SourcePath,

        [parameter(Mandatory=$true)]
        [String] $DestinationPath
    )
 
    Write-Output "Executing runbook on hybrid runbook worker: $env:ComputerName"
    Write-Output "Source: $SourcePath"
    Write-Output "Destination: $DestinationPath"
    $result = InlineScript
    {
        try
        {
            Copy-Item -Path "$using:SourcePath" -Destination "$using:DestinationPath"
        }
        catch
        {
            $errorMessage = $error[0].Exception.Message
        }
  
        if($errorMessage -eq $null)
        {
            return "Successfully copied files"
        }
        else
        {
            return "Failed: Encountered error(s) while copying files. Error message=[$errorMessage]"
        }
    }
 
    Write-Output $result
    Write-Output "Execution finished"
}