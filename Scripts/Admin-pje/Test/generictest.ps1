#region dot-Sourcing functions
. c:\Scripts\ECCO\Modules\Func_Ecco_Generic.ps1
. c:\Scripts\ECCO\Modules\Func_Ecco_Exchange.ps1
. c:\Scripts\ECCO\Modules\Func_Ecco_ActiveDirectory.ps1
#endregion


#Get-Process | ?{$_.MainWindowTitle} | Out-EccoGeExcel
#Get-Process | ?{$_.MainWindowTitle} | Out-EccoGeHTML
#Remove-Module ecco*
#Import-Module ecco*

#gcm *ecco* |sort verb
gcm -Name *ecco* -Syntax



