$y0date = (Get-Date).toString("MM/dd/yyyy")
$y1date = ((Get-Date).AddMonths(-2)).toString("MM/dd/yyyy")
$y2date = ((Get-Date).AddMonths(-3)).toString("MM/dd/yyyy")


        $y0date
        $y1date
        $y2date



$y3date = (Get-Date).toString("MM/dd/yyyy")
$y4date = ((Get-Date).AddMonths(-2)).toString("MM/dd/yyyy")
$y5date = ((Get-Date).AddMonths(-3)).toString("MM/dd/yyyy")


$date = get-date
"{0:dd/MM/yyyy}" -f $date
