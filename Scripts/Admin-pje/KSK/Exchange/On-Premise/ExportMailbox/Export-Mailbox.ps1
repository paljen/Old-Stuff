
# ------------------------------------------------------------------------
# NAME: Export-Mailbox.ps1
# AUTHOR: Palle Jensen, Ecco shoes A/S
# DATE: 01/10/2015
#
# KEYWORDS: Exchange, PST
#
# COMMENTS: 05/10/2015 - Bug in exchange content filter using variables
#           http://blogs.microsoft.co.il/scriptfanatic/2010/12/04/using-variables-in-ems-filter-parameter/
#
#           09/10/2015 - Bug Exchange errorhandling in implicit remote session
#           http://www.michev.info/Blog/Post/71/Error-handling-in-Exchange-Remote-PowerShell-sessions 
#
#           15/10/2015 - Bug Using NON US date formats
#           http://rp-it.blogspot.dk/2013/05/new-mailboxexportrequest-fails-when.html
#
#           16/10/2015 - Using new-mailboxexportrequest with NON-US dates, last thread
#           http://occasionalutility.blogspot.com.au/2014/03/everyday-powershell-part-17-using-new.html
#    
# ---------------------------------------------------------------------

#region Variables

#Set trace and status variables to defaults

# 0=Success,1=Warning,2=Error
$ErrorState = 0

# Current error message
$ErrorMessage = ""

# Scriptpath set to where the script is run
$ScriptPath = "C:\logs\Orchestrator\2.2.2.5 - MailboxExportRequest"
#split-path -parent $MyInvocation.MyCommand.Definition 
#"C:\logs\Orchestrator\2.2.2.5 - MailboxExportRequest"

#endregion
	
#region Functions

function Write-LogFile
{
    [CmdletBinding()]

	param(
        [Parameter(Position=0)]
        [string]$Message,
        [Switch]$Trace	
	)
    
    if($Trace)
    {
        $Log = "$ScriptPath\Trace.log"	
	    $Output = "$([DateTime]::Now): $Message"
    }

    else
    {
        $Log = "$ScriptPath\Output.log"
        $output = $Message
    }

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

function Remove-EccoMailboxExportRequest
{
    [CmdletBinding()]

    Param(
        
        [System.Collections.ArrayList]$JobRequests

    )
    
    $jobs = $JobRequests.GetEnumerator()
    $jobsClone = $jobRequests.Clone()
    
    While ($jobsClone.Count -ne 0)
    {
        ## Reset pointer
        $jobs.Reset()

        While($jobs.MoveNext())
        {
            $delete = Get-MailboxExportRequest -Name $jobs.Current | where {$_.status -ne "InProgress" -and $_.status -ne "Queued"}
            
            if($delete)
            {
                Write-LogFile "Cleaning up $($jobs.Current) with status $($delete.status)" -Trace
                Write-LogFile "Get-MailboxExportRequest $($jobs.Current) | Remove-MailboxExportRequest -Confirm:`$false" -Trace
                Get-MailboxExportRequest -Name $jobs.Current | Remove-MailboxExportRequest -Confirm:$false
                $jobsClone.Remove($($jobs.Current))
            }

            Start-Sleep -Seconds 30
        }
    }
}

function New-EccoMailboxExportRequest
{
    [CmdletBinding()]
    
    param(
        
        [String]$User
    )
        
    if (!(Get-MailboxPermission -Identity $User -User $(whoami)))
    {
        ## To be able to perform the move request administrative permissions is required
        Write-LogFile "Adding administrative permissions to perform the export request.." -Trace
        Write-LogFile "Add-MailboxPermission –Identity $User –User $(whoami) –AccessRights FullAccess –Confirm:`$false -ErrorAction stop" -Trace
        Add-MailboxPermission –Identity $User –User $(whoami) -DomainController $dc –AccessRights FullAccess –Confirm:$false -ErrorAction stop
    }

    ## ArrayList with names of the export requests
    $requests = New-Object System.Collections.ArrayList

    $dateY0 = Get-Date
    $dateY1 = $dateY0.AddYears(-1)
    $dateY2 = $dateY0.AddYears(-2)
    $dateY3 = $dateY0.AddYears(-3)
    $dateY4 = $dateY0.AddYears(-4)
        
    ## ArgumentList for invoke-command
    $argsArray = @()
    $argsArray += $User
    $argsArray += $dc
    $argsArray += $dateY0
    $argsArray += $dateY1
    $argsArray += $dateY2
    $argsArray += $dateY3
    $argsArray += $dateY4
    $argsArray += $unc
    
    ## Get Session details
    $session = Get-PSSession | ? {$_.ConfigurationName -eq 'Microsoft.Exchange' -and $_.Availability -eq "Available"}
           
    ## There is no Errorhandling for the Get-Mailbox if you run a Proxy function in a implicit remote session, therefor 
    ## Instead of using the proxy function, we 'wrap' it in Invoke-Command to come around it

    Write-LogFile "Getting Mailbox for user $user" -Trace
    $mbUser = Invoke-Command -Session $session -ArgumentList $User -ScriptBlock { param($user);Get-Mailbox $user} -ErrorAction Stop

    ## due to remote call the returning object is deserialized and does not have the toGB method
    ## therefor the returning string object is split into an array for then to measure the size
        
    $mbSize = ((($mbUser | Get-MailboxStatistics).TotalItemSize.value) -split '[\(]')
    $mbSize = $mbSize[0].Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

    $mbSizeArc = ((($mbUser | Get-MailboxStatistics -Archive).TotalItemSize.value) -split '[\(]')
    $mbSizeArc = $mbSizeArc[0].Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
       
    Write-LogFile "Mailbox Export Requests.." -Trace
    
    ## If mailbox total size is greater then 20 gb, split the export request into 3 files
    if ($mbSize[1] -eq 'GB' -and [int]$mbSize[0] -gt 20)
    {
        Write-LogFile "Mailbox size for user [$user] is [$mbSize] - Splitting output into 3 files"
        Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY0) -and (Received -gt $dateY1)} -FilePath $unc\$user Year0-Year1.pst -confirm:`$false" -Trace
        $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
            param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
            New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY0') -and (Received -gt '$dateY1')" -FilePath "$unc\$user Year0-Year1.pst" -confirm:$false} -ErrorAction Stop
        
        $requests.Add($req.name)

        Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY1) -and (Received -gt $dateY2)} -FilePath $unc\$user Year1-Year2.pst -confirm:`$false" -Trace
        $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
            param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
            New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY1') -and (Received -gt '$dateY2')" -FilePath "$unc\$user Year1-Year2.pst" -confirm:$false} -ErrorAction Stop

        $requests.Add($req.name)

        Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY2) -and (Received -gt $dateY3)} -FilePath $unc\$user Year2-Year3.pst -confirm:`$false" -Trace
        $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
            param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
            New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY2') -and (Received -gt '$dateY3')" -FilePath "$unc\$user Year2-Year3.pst" -confirm:$false} -ErrorAction Stop

        $requests.Add($req.name)

        Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY3) -and (Received -gt $dateY4)} -FilePath $unc\$user Year3-Year4.pst -confirm:`$false" -Trace
        $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
            param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
            New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY3') -and (Received -gt '$dateY4')" -FilePath "$unc\$user Year3-Year4.pst" -confirm:$false} -ErrorAction Stop

        $requests.Add($req.name)

        Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {Received -lt $dateY4} -FilePath $unc\$user Year4-YearX.pst -confirm:`$false" -Trace
        $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
            param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
            New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "Received -lt '$dateY4'" -FilePath "$unc\$user Year4-YearX.pst" -confirm:$false} -ErrorAction Stop
        
        $requests.Add($req.name)


    } 
    
    else
    {
        Write-LogFile "New-MailboxExportRequest -Mailbox $user -FilePath $unc\$user.pst -confirm:`$false" -Trace
        $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
            param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
            New-MailboxExportRequest -Mailbox $user -DomainController $dc -FilePath "$unc\$user.pst" -confirm:$false} -ErrorAction Stop

        $requests.Add($req.name)
    }

    ## Mailbox with IsArchive switch
    if($mbUser.ArchiveState -notlike "Hosted*")
    {
        
        Write-LogFile "Mailbox Export Requests -Archive.." -Trace

        if($mbSizeArc[1] -eq 'GB' -and [int]$mbSizeArc[0] -gt 20)
        {   
            Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY0) -and (Received -gt $dateY1)} -FilePath $unc\$user Archive Year0-Year1.pst -IsArchive -confirm:`$false" -Trace
            $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
                param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
                New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY0') -and (Received -gt '$dateY1')" -FilePath "$unc\$user Archive Year0-Year1.pst" -IsArchive -confirm:$false} -ErrorAction Stop

            $requests.Add($req.name)

            Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY1) -and (Received -gt $dateY2)} -FilePath $unc\$user Archive Year1-Year2.pst -IsArchive -confirm:`$false" -Trace            
            $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
                param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
                New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY1') -and (Received -gt '$dateY2')" -FilePath "$unc\$user Archive Year1-Year2.pst" -IsArchive -confirm:$false} -ErrorAction Stop

            $requests.Add($req.name)

            Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY2) -and (Received -gt $dateY3)} -FilePath $unc\$user Archive Year2-Year3.pst -IsArchive -confirm:`$false" -Trace            
            $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
                param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
                New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY2') -and (Received -gt '$dateY3')" -FilePath "$unc\$user Archive Year2-Year3.pst" -IsArchive -confirm:$false} -ErrorAction Stop

            $requests.Add($req.name)

            Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {(Received -lt $dateY3) -and (Received -gt $dateY4)} -FilePath $unc\$user Archive Year3-Year4.pst -IsArchive -confirm:`$false" -Trace            
            $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
                param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
                New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "(Received -lt '$dateY3') -and (Received -gt '$dateY4')" -FilePath "$unc\$user Archive Year3-Year4.pst" -IsArchive -confirm:$false} -ErrorAction Stop

            $requests.Add($req.name)

            Write-LogFile "New-MailboxExportRequest -Mailbox $user -ContentFilter {Received -lt $dateY4} -FilePath $unc\$user Archive Year4-YearX.pst -IsArchive -confirm:`$false" -Trace
            $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
                param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
                New-MailboxExportRequest -Mailbox $user -DomainController $dc -ContentFilter "Received -lt '$dateY4'" -FilePath "$unc\$user Archive Year4-YearX.pst" -IsArchive -confirm:$false} -ErrorAction Stop

            $requests.Add($req.name)
        }

        else
        {
            Write-LogFile "New-MailboxExportRequest -Mailbox $user -FilePath $unc\$user Archive.pst -IsArchive -confirm:`$false" -Trace
            $req = Invoke-Command -Session $session -ArgumentList $argsArray -ScriptBlock { 
                param($user, $dc, $dateY0, $dateY1, $dateY2, $dateY3, $dateY4, $unc)
                New-MailboxExportRequest -Mailbox $user -DomainController $dc -FilePath "$unc\$user Archive.pst" -IsArchive -confirm:$false} -ErrorAction Stop

            $requests.Add($req.name)
        }
    }

    else
    {
        ## status og state istedet
        Write-LogFile "Archive Status is [$($mbUser.ArchiveStatus)] and Archive State [$($mbUser.ArchiveState)] - No Action taken" -Trace
    }

    Remove-EccoMailboxExportRequest -JobRequests $requests

}

#endregion

#region main
function Main
{
    ## Initializing TraceLog
    Write-LogFile "------------------------------------------------------------------------------------------------------------" -Trace
    Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace

    try 
    {
        ## Set Culture to en-US for current thread to overcome an Exchange NON US date format bug, 
        ## this should be run before creating implicit remoting session
        [System.Reflection.Assembly]::LoadWithPartialName("System.Threading")
        [System.Reflection.Assembly]::LoadWithPartialName("System.Globalization")
        [System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-us") 
        
        ## Importing exchange module
        if(!((Get-PSSession | ?{$_.ConfigurationName -eq "Microsoft.Exchange"}).Availability -eq "Available"))
        {
            Get-PSSession | ?{$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession -ErrorAction SilentlyContinue 
            $Uri = "http://dkhqexc04n01.prd.eccocorp.net/powershell/"
            Write-LogFile "Importing Remote Exchange 2010 Cmdlets - $Uri" -Trace
            $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $Uri -Authentication Kerberos
            Import-PSSession $ExSession -ErrorAction SilentlyContinue
        }
       	
	  #------------------------------------------------------------
      # Declaring Variables
      #------------------------------------------------------------       
        # Runbook input Variables
        $user = Read-Host "Please enter the username of user, to backup?"

        # Script specific Variables
	    $dc = "dkhqdc01.prd.eccocorp.net"
        $unc = "\\dkhqBackup04\Exchange-PST-Export$"
      
      #------------------------------------------------------------
        
        New-EccoMailboxExportRequest -User $user -ErrorAction Stop

    }

    catch 
    {
	    $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught: $ErrorMessage" -Trace
	    $ErrorState = 2
    }
	
    if($ErrorState -lt 2)
    {	
        if(!($ErrorState -eq 0))
        {
            Write-LogFile "[`$ErrorState:$($ErrorState) - Warning]" -Trace
        }

        Write-LogFile "Script Ended Successfully.." -Trace
        
    }

    else
    {
	    Write-LogFile "[`$ErrorState:$($ErrorState)] - Error" -Trace
        Write-LogFile "Script Terminated.." -Trace
	    Exit 1
    }
}

#endregion

Main