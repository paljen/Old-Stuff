$lines = @('a', 'b', 'c') 
 $enumerator = $lines.GetEnumerator() 
 $enumerator.Reset()

while ($enumerator.MoveNext()) { 
  $line = $enumerator.Current
  "$line"  
 }
