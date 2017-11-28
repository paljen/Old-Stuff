function Push-Project( $project )
{
    $root = "C:\Scripts\ECCO\Projects"
    cd $root

    $path = "C:\Scripts\ECCO\Projects\$project"
    
    if( -not( Test-Path "$path" ) )
    {  
       $path = ls $root -Filter "$project*" | select -First 1
    }
     
    pushd $path
}

New-Alias -Name pp -Value Push-Project