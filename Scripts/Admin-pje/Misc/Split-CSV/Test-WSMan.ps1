cls

(Get-ADComputer -identity dk4836).name | foreach-object {
	if(!(Test-WSMan -ComputerName $_ -ErrorAction Ignore)){
		Write-Host "$_ Remote Management NOT configured"
	}
	else {"$_ ok"}
}
