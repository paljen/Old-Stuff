
workflow test
{
    Param
    (
        # Param1 help description
        [string]
        $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    $collection = "dkhqscorch01","dkhqdc01","dkhqdc02"

    foreach -parallel ($item in $collection)
    {
        (gwmi -ComputerName $item -Class win32_computersystem).name
    
    }

    write-output "all done"

}


test