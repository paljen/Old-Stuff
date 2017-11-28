<#
.SYNOPSIS
  Users with dublet telephonenumbers in AD

.NOTES
  Author:         Palle Jensen
  Creation Date:  31-03-2016
  Purpose/Change: Initial script development
#>

## create array with full list of users and their telephonenumber
$users = Get-ADUser -Filter * -Properties Telephonenumber | select name, telephonenumber

        ## Traverse through the users where condition is true
        foreach ($user in $users)
        {   
            if($user.Telephonenumber -ne $null -and $user.Telephonenumber -match "[+]\d*")
            {
                ## cast telephonenumber to string
                $tlf = [String]$user.telephonenumber 

                ## create array with telephonenumbers from the users list that match the traversing user telephonenumber
                $match = $users.telephonenumber -eq $tlf

                ## if the match count is 1 the traversing user telephonenumber is unique. 
                ## if the match count is -gt 1 there are more users with the same telephonenumber as the traversing user
                if($match.Count -gt 1)
                {
                    ## $match will contain the same number multible times and we only need it ones
                    $tlf = $match | select -First 1

                     <#
                $red = ($a | ?{$_ -match "red"})
                $red | foreach {
                $index = $a.indexof($_)
                 $a.RemoveAt($index)
                }#>

                    #$al.Remove($user.name)

                    ## Get the names of the users with the same telephonenumber as the traversing user
                    
                    $usr = @()
                    $users | ?{$_.telephonenumber -eq $tlf -and $_.name -ne $user.name} | foreach {
                        $usr += $_.telephonenumber
                    }

                    $usr | foreach {
                        Write-host $_
                        $index = $users.telephonenumber.IndexOf($_)
                        write-host $index
                        #$users.RemoveAt($index)
                    }

                    ## Structure output
                    $props = [Ordered]@{
                             'PrimaryUser'=$user.name
                             'Matches'=$usr.name -join ','}

                    $out = New-Object -TypeName PSObject -Property $props
            
                    $path = Split-Path -Parent $MyInvocation.MyCommand.Definition
                    Export-Csv -InputObject $out -LiteralPath "$path\DubletSearch.csv" -Encoding UTF8 -NoTypeInformation -NoClobber -Append
                }
            }
         }
    