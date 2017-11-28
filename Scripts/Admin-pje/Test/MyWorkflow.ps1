workflow MyWorkFlow
{
    param
    (
        [String]$myVariable
    )

    Write-Output $MyVariable

    inlineScript
    {
    
    }  # Optional workflow common parameters such as -PSComputerName and -PSCredential
 }

 Get-service bits

 MyWorkFlow test

 
$objOption = New-CimSessionOption -Protocol Dcom
$objSession = New-CimSession -ComputerName dk4836.prd.eccocorp.net -SessionOption $objOption

$objSession | Get-CimClass -Namespace ROOT/cimv2 -ClassName Win32_ComputerSystem


$objOption = New-CimSessionOption -Protocol Dcom
$objSession = New-CimSession -ComputerName dk4836.prd.eccocorp.net -SessionOption $objOption

$objSession | Get-CimInstance -Namespace ROOT/cimv2 -ClassName Win32_ComputerSystem | select BootOptionOnLimit | ft -AutoSize
