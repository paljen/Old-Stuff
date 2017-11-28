## create array with full list of users and their telephonenumber
$users = Get-ADUser -filter * -Properties Telephonenumber | select name, telephonenumber

## Convert to arraylist to manipulate items
[System.Collections.ArrayList]$al = $users

$enum = $al.GetEnumerator()

$alClone = $al.Clone()

While ($alClone.Count -ne 0)
{
    $enum.Reset()

    While($enum.MoveNext())
    {
        if($enum.current.Telephonenumber -ne $null -and $enum.current.Telephonenumber -match "[+]\d*")
        {
            ## cast telephonenumber to string
            $tlf = [String]$enum.current.telephonenumber
            
            ## create array with telephonenumbers from the users list that match the traversing user telephonenumber
            $match = $alClone.telephonenumber -eq $tlf

            write-host $match
            ## Remove PrimaryUser from the cloned array
            $alClone.Remove($($enum.current))

            ## if the match count is 1 the traversing user telephonenumber is unique. 
            ## if the match count is -gt 1 there are more users with the same telephonenumber as the traversing user
            if($match.Count -gt 1)
            {
                ## $match will contain the same number multible times and we only need it ones
                $tlf = $match | select -First 1

                ## Get the names of the users with the same telephonenumber as the traversing user
                $usr = $alClone | ?{$_.telephonenumber -eq $tlf -and $_.name -ne $enum.current.name} | select name, telephonenumber

                $usr | foreach {

                    $index = $alClone.telephonenumber.IndexOf($($_.telephonenumber))

                    if ($index -ne -1)
                    {
                        $alClone.RemoveAt($index)
                    }
                }

                ## Structure output
                $props = [Ordered]@{
                            'Telephonenumber'=$enum.Current.telephonenumber
                            'PrimaryUser'=$enum.current.name
                            'Matches'=$usr.name -join ','}

                $out = New-Object -TypeName PSObject -Property $props
            
                $path = Split-Path -Parent $MyInvocation.MyCommand.Definition
                Export-Csv -InputObject $out -LiteralPath "$path\DubletSearch.csv" -Encoding UTF8 -NoTypeInformation -NoClobber -Append
               
            }
        }
    }  
}