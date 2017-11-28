$advFunction = @'
Function verb-noum 
{
    <#
    .SYNOPSIS
	    A brief description of the function.

    .DESCRIPTION
	    A detailed description of the function.

    .PARAMETER  <Parameter-Name>
	    The description of a parameter. Add a .PARAMETER keyword for
	    each parameter in the function syntax.

    .EXAMPLE
	    A sample command that uses the function, optionally followed
	    by sample output and a description. Repeat this keyword for each example.

    .INPUTS
	    The Microsoft .NET Framework types of objects that can be piped to the
	    function. You can also include a description of the input objects.

    .OUTPUTS
	    The .NET Framework type of the objects that the cmdlet returns. You can
	    also include a description of the returned objects.

    .NOTES
	    Version:		1.0.0
	    Author:			
	    Creation Date:	
	    Purpose/Change:	Initial function development
    #>

    [CmdletBinding(DefaultParametersetName="Parameter Set 1")]

    Param 
    (
        # Param1 help description
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName="Parameter Set 1")]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateCount(0,5)]
        [ValidateSet("sun", "moon", "earth")] 
        $Param1,

        # Param2 help description
        [Parameter(ParameterSetName="Parameter Set 1")]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [ValidateScript({$true})]
        [ValidateRange(0,5)]
        [int]$Param2,

        # Param3 help description
        [Parameter(ParameterSetName="Another Parameter Set")]
        [ValidatePattern("[a-z]*")]
        [ValidateLength(0,15)]
        [String]$Param3
    
    )

    Begin 
    {
        
    }

    Process 
    {
        Try 
        {
            ## <code goes here>             
        }

        Catch 
        {
            $_.Exception.Message
            Break
        }
    }

    End 
    {
        
    }
}
'@
New-IseSnippet -Force -Title "ECCO Advanced Function" -Description "Advanced function" -Author "Palle Jensen" -Text $advFunction