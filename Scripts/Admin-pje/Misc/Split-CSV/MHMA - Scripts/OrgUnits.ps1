if(!(Get-PSSnapin Quest*)){
	Add-PSSnapin quest*}

foreach ($item in (Get-QADObject -SearchScope OneLevel -SearchRoot "prd.eccocorp.net/Exchange/Distribution Lists").type) {
	
	"$item"
}