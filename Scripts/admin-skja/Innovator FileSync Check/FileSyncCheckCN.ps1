$UNCRootPath = "\\skfacplm01\d$\Aras\SKFACVault\Innovator" 

$SQLInstance = "DKHQSQL04DB02\PRD2"
$SQLDatabase = "Innovator"
$SQLQuery = "select source_id as 'File_ID', related_id as 'Vault_ID'
                from innovator.located
                where related_id = '604A92809DC04092B7178BE5AD20F14B'"

#Vaults:
# ID   NAME
# 4C3597284576459C83D567DE9921D5DF      CNFACVault     \\cnfacplm01\d$\Aras\CNFACVault\Innovator 
# 4F2934EE3A7841AA99B1D8513DBC3CAA      VNFACVault     \\vnfacplm01\e$\Aras\VNFACVault\Innovator 
# 604A92809DC04092B7178BE5AD20F14B      SKFACVault     \\skfacplm01\d$\Aras\SKFACVault\Innovator
# 67BBB9204FE84A8981ED8313049BA06C      Default        \\dkhqplm06\d$\Share\Innovator_DKHQ_Vault\Innovator 
# ACC0940DC4114CA4830765141649C7BB      IDFACVault     \\idfacplm01\D$\Aras\IDFACVault\Innovator 
# C6CC4EA96A3A429F92B56D49DE07A165      THFACVault     \\thfacplm01\D$\Aras\THFACVault\Innovator 
# DE5BE37541FD42ABBE1FF85E105D542B      PTFACVault     \\ptfacplm01\D$\Aras\PTFACVault\Innovator 

function Invoke-EcSqlcmd2 
{ 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$false)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$false)] [string]$Query, 
    [Parameter(Position=3, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=5, Mandatory=$false)] [Int32]$QueryTimeout=600, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$ConnectionTimeout=15, 
    [Parameter(Position=7, Mandatory=$false)] [ValidateScript({test-path $_})] [string]$InputFile, 
    [Parameter(Position=8, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow")] [string]$As="DataRow" 
    ) 
 
    if ($InputFile) 
    { 
        $filePath = $(resolve-path $InputFile).path 
        $Query =  [System.IO.File]::ReadAllText("$filePath") 
    } 
 
    $conn=new-object System.Data.SqlClient.SQLConnection 
      
    if ($Username) 
    { $ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}" -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout } 
 
    $conn.ConnectionString=$ConnectionString 
     
    #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
    if ($PSBoundParameters.Verbose) 
    { 
        $conn.FireInfoMessageEventOnUserErrors=$true 
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
        $conn.add_InfoMessage($handler) 
    } 
     
    $conn.Open() 
    $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn) 
    $cmd.CommandTimeout=$QueryTimeout 
    $ds=New-Object system.Data.DataSet 
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
    [void]$da.fill($ds) 
    $conn.Close() 
    switch ($As) 
    { 
        'DataSet'   { Write-Output ($ds) } 
        'DataTable' { Write-Output ($ds.Tables) } 
        'DataRow'   { Write-Output ($ds.Tables[0]) } 
    } 
 
}

$Vaults = @("\\dkhqplm06\d$\Share\Innovator_DKHQ_Vault\Innovator", 
            "\\ptfacplm01\D$\Aras\PTFACVault\Innovator", 
            "\\thfacplm01\D$\Aras\THFACVault\Innovator", 
            "\\idfacplm01\D$\Aras\IDFACVault\Innovator", 
            "\\skfacplm01\d$\Aras\SKFACVault\Innovator",
            "\\vnfacplm01\e$\Aras\VNFACVault\Innovator",
            "\\cnfacplm01\d$\Aras\CNFACVault\Innovator")

$SQLRecords = Invoke-EcSqlcmd2 -ServerInstance $SQLInstance -Database $SQLDatabase -Query $SQLQuery

$i = 0

Foreach ($record in $SQLRecords) {
    Write-Progress `
        -Activity "Checking file paths on vault: $($UNCRootPath)" `
        -Status "$i of $($SQLRecords.Count)" `
        -PercentComplete (($i / $SQLRecords.count ) * 100 ) `
        -Id 1

    $Folder1 = $record.File_ID.Substring(0,1)
    $Folder2 = $record.File_ID.Substring(1,2)
    $Folder3 = $record.File_ID.Substring(3)

    $path = "$($UNCRootPath)\$($folder1)\$($folder2)\$($folder3)"

    Write-Progress -Activity "$($path)" -Id 2 -ParentId 1 -status " "

    if((Test-Path -Path $path -PathType Container) -eq $true) {
       # write-host $path -ForegroundColor Green
    }
    Else {
         #Try other vaults
        $fileFound = $false
        $y = 1
        foreach ($vault in $Vaults) {
            $CopyfromTest = "$($vault)\$($folder1)\$($folder2)\$($folder3)"
            if((Test-Path -Path $CopyfromTest -PathType Container) -eq $true) {
                $fileFound = $true
                write-host "Missing folder $($Path) has been found in another vault: $($CopyfromTest)" -ForegroundColor Green
                "copy $($CopyfromTest) $($path)" | out-file -FilePath .\CopyBatch.txt -Append 
                $y++;
                break
            }
        }

        if ($fileFound -eq $false) {
            Write-Host "$($Path) not found in other vaults!" -ForegroundColor Red
            $MissingPaths | out-file -FilePath .\MissingPaths.txt -Append
        }
    }
    $i++;

}

