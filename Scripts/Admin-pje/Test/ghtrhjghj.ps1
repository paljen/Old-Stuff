function BuildVMHostGroupTree
{
    param (
        
    )
    
    $path = @()

    foreach ($g in (Get-SCVMHostGroup -VMMServer DKHQVMM02CR)){
        $path += $g.path
    }
    
    $path = $path | sort
    $groupRoot = $path[0]
    $groupRoot

    
    $path | ForEach-Object {
        
            $tmp = ($_).Split("\")
            
            for ($i = 0; $i -lt $tmp.count; $i++)
            {
                if (!($path -contains $tmp[$i]))
                {
                #    $i
                    $tmp[$i]
                }
                    #"{0}{01}" -f  $indent,$($tmp[$i])
                    #$indent += "`t"
            }
        }

    

}

BuildVMHostGroupTree