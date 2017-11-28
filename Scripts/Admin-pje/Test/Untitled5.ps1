function exit-script
{
    try
    {
        Invoke-Expression {Get-Content c:\exist.txt}
    }

    catch
    {
        exit 1
    }
}

exit-script