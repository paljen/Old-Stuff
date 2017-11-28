$session=New-PSSession -ComputerName DKHQVMM02CR
Invoke-Command –Session $Session {Import-Module –Name VirtualMachineManager}
Import-PSSession -Session $session -Module VirtualMachineManager