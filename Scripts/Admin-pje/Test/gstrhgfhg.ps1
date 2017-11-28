Function Get-PatchThuesday ([int] $Month)  
 { 
    $FindNthDay=2
    $WeekDay='Tuesday' 

    $Today=get-date -Month $Month 
    $todayM=$Today.Month.ToString() 
    $todayY=$Today.Year.ToString()
     
    [datetime]$StrtMonth=$todayM+'/1/'+$todayY 
    while ($StrtMonth.DayofWeek -ine $WeekDay ) 
    {$StrtMonth=$StrtMonth.AddDays(1)}
     
    $PatchDay=$StrtMonth.AddDays(7*($FindNthDay-1)) 
    return $PatchDay
 }


 $date = Get-PatchThuesday 10
 
 $date.AddDays(1).AddHours(22)
 $date.adddays(7).AddHours(22)
 $date.adddays(11).AddHours(22)
 $date.adddays(15).AddHours(22)
