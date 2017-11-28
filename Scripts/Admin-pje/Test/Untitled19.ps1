
$path = "\\dkhqsql04fs\SCVMMLibrary\Server OS\Server 2012 R2 STD\Backup"



if($(Test-Path $path) -eq $false)
{
    New-Item -ItemType Directory -Path $path | Out-Null
}
