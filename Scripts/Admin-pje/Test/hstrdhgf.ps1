 $var = Powershell {

 ## return from powershell{}
        $returnArray = @()
        $returnArray += 1
        $returnArray += "test"
        return $returnArray
}

$ErrorState = $Var[0].ToString()
$ErrorMessage = $var[1].ToInt32()

$ErrorState
$ErrorMessage