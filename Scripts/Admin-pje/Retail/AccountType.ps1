$Country = "AU"
$type = "dutyfree"

$ErrorActionPreference = "Stop"

try
{
    Switch ($country) 
    {
       AU{
            switch ($type){
                Store {$type = '202'}
                Outlet {$type = '203'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       CA{
            switch ($type){
                Store {$type = '303'}
                Outlet {$type = '304'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       CN{
            switch ($type){
                Store {$type = '205'}
                Outlet {$type = '206'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       HK{
            switch ($type){
                Store {$type = '200'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       JP{
            switch ($type){
                Store {$type = '950'}
                Outlet {$type = '952'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       KR{
            switch ($type){
                Store {$type = '208'}
                Outlet {$type = '209'}
                DutyFree {$type = '951'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       MO{
            switch ($type){
                Store {$type = '204'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       SG{
            switch ($type){
                Store {$type = '201'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       TR{
            switch ($type){
                Store {$type = '952'}
                default{Throw "Type $type doesn't exist for $country"}
            } 
       }
       TW{
            switch ($type){
                Store {$type = '207'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       US{
            switch ($type){
                Store {$type = '301'}
                Outlet {$type = '302'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
       DK{
            switch ($type){
                Store {$type = '018'}
                Outlet {$type = '019'}
                default{Throw "Type $type doesn't exist for $country"}
            }
       }
    }
}
catch
{
    $ErrorMessage = $_.exception.message
    $ErrorMessage
    Exit
}

$SAMAccount = $Country + $type + "f"  + "ei"
