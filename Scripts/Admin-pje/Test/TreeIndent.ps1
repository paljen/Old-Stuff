

function BuildVMHostGroupTree
{
    param (
        
    )
    
    $

    foreach ($group in (Get-SCVMHostGroup -VMMServer DKHQVMM02CR))
    {
        $indent = ""

        $group.path | ForEach-Object {
        
            $tmp = ($_).Split("\")

            for ($i = 0; $i -lt $tmp.count; $i++)
            {
                    "{0}{01}" -f  $indent,$($tmp[$i])
                    $indent += "`t"
            }
        }
    }

}

