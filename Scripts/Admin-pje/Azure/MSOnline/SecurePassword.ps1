
$Path = split-path -parent $MyInvocation.MyCommand.Definition
read-host -prompt "Enter password:" -assecurestring | convertfrom-securestring | out-file "$path\cred.txt"