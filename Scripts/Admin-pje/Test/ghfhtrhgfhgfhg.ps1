$a = New-Object System.Collections.ArrayList

$a.Add("red") 
$a.Add("red") 
$a.Add("orange") 
$a.Add("green") 
$a.Add("blue") 
$a.Add("purple")




$red = ($a | ?{$_ -match "red"})
$red | foreach {
$index = $a.indexof($_)
 $a.RemoveAt($index)
}

Write-host "$a"