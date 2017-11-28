function Get-TestObject
{
    param
    (

        [String]$obj
    )
    try
    {
        (Get-ADObject -Filter {(SamAccountName -eq $obj) -and (objectClass -eq "user")}).DistinguishedName
        }
        catch{$_.exception.message}
}

function Test
{
    <#
    .SYNOPSIS
       Evaluate AD ObjectClass

    .DESCRIPTION
       Evaluates the AD ObjectClass, returnes `$true if the ObjectClass is a group else `$false

    .INPUTS
       String, Name of the Object to evaluate

    .OUTPUTS
       True - If the ObjectClass group
       False - If the ObjectClass is not group

    .EXAMPLE
       Test-EccoADGroupObject TestGroup
    #>

    [CmdletBinding()]

	param
    (
        [Parameter(Mandatory=$true)]
		[String]$Object
	)
		
	try
    {
        $obj = Get-TestObject -obj $Object #$(Get-ADObject -Filter {(SamAccountName -eq $object)} -ErrorAction Stop)

        if ($obj.objectclass -eq "Group")
        {
            Write-Verbose "ObjectClass for object $object is $($obj.objectclass)"
            $true
        }

        else
        {        
            Write-Verbose "ObjectClass for object $object is $($obj.objectclass)"
            $false
        }
	}

	catch 
    {
        $_.Exception.Message
	}
}


test -Object "TestGroup" -Verbose
(Get-TestObject -obj PJE).ObjectClass