function quickping{ping -n 1 -w 100 $args}


(Measure-Command {quickping 10.10.10.10}).TotalSeconds

(Measure-Command {Test-Connection 10.10.10.10 -Count 1 -Quiet}).TotalSeconds