function Get-Sample {
        [CmdletBinding()]
        Param ([String]$Name, [String]$Path)
 
        DynamicParam
        {
            if ($path -match ".*HKLM.*:")
            {
                $attributes = new-object System.Management.Automation.ParameterAttribute
                $attributes.ParameterSetName = "__AllParameterSets"
                $attributes.Mandatory = $false
                $attributeCollection = new-object `
                    -Type System.Collections.ObjectModel.Collection[System.Attribute]
                $attributeCollection.Add($attributes)

                $dynParam1 = new-object `
                    -Type System.Management.Automation.RuntimeDefinedParameter("dp1", [Int32], $attributeCollection)
            
                $paramDictionary = new-object `
                    -Type System.Management.Automation.RuntimeDefinedParameterDictionary
                $paramDictionary.Add("dp1", $dynParam1)
                return $paramDictionary
            }
        }
    }