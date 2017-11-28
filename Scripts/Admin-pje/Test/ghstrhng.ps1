

function New-Pass
{
    Param([int]$length = 12)

    #ASCII Password characters for New-Pass function
    $ascii = @()

    For ($a = 48;$a -le 122;$a++) 
    {
        $ascii += ,[char][byte]$a
    }

    For ($loop = 1; $loop -le $length; $loop++)
    {
        $TempPassword += ($ascii | Get-Random -SetSeed (Get-Random))
    }
    
    $TempPassword
}

New-Pass
