cls

$s = New-PSSession -ComputerName DKHQVMM02CR
Export-PSSession -session $s -module virtualmachinemanager -outputmodule RemVMM -allowclobber


$session=New-PSSession -ComputerName SCVMM1
Invoke-Command –Session $Session {Import-Module –Name VirtualMachineManager}
Import-PSSession -Session $session -Module VirtualMachineManager

