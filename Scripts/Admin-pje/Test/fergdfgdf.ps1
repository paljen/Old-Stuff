$test = Invoke-Command -ComputerName dkhqscorch01 -ScriptBlock {
    
    $hash = @{}
    $hash.Add('Success',$true)
    $hash.Add('How','We did it')
    $hash

}

($test.Item('Success')).gettype()

write-host $test.Item('How')