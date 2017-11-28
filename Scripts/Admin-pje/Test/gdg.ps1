
#------------------------------------------------------------
# Gobal Variables
#------------------------------------------------------------       
        
# Scriptpath set to where the script is run
$Global:ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#------------------------------------------------------------
	
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
        $Log = "$Global:ScriptPath\Trace.log"	
	    $Output = "$([DateTime]::Now): $Message"
    }

    else
    {
        $Log = "$Global:ScriptPath\Output.log"
        $output = $Message
    }

	[System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	$Log.WriteLine($Output)
	$Log.Close()
}

function Get-EccoDstList
{
    [CmdletBinding()]

    Param (

        [String]$DistinguishedName

    )

    Write-LogFile "Generate DistributionGroup List.." -Trace
    (Get-ADGroup -SearchBase $DistinguishedName -Filter {((GroupCategory -eq "Distribution") -and (Name -notlike "*O_*") -and (Name -notlike "*N_*"))}).DistinguishedName
}

function Remove-EccoDstGroupMembers
{
    [CmdletBinding()]

    Param (

        [String]$DistributionGroup
    )
    try
    {
        Get-EccoDstGroupMembers -DistributionGroup $DistributionGroup -isUser | ForEach-Object {
            Write-Host "Removing $($_.DistinguishedName) From $DistributionGroup"
            Remove-DistributionGroupMember -Identity $DistributionGroup -Member $_.DistinguishedName -ErrorAction Stop -Confirm:$false}
    }

    catch
    {
       $Global:ErrorMessage = $error[0].Exception.Message
	    Write-Host "Exception caught: $Global:ErrorMessage"
    }
}

function Add-EccoDstGroupMembers
{
   [CmdletBinding()]

    Param (

        [String]$DistributionGroup
    )

    try
    {
	    foreach ($g in (Get-EccoDstGroupMembers -DistributionGroup $DistributionGroup -isGroup)) 
        {	
            Write-Host "Enumerating InnerGroup [$($g.DistinguishedName)]"
            Get-QADGroupMember $($g.DistinguishedName) -ErrorAction Stop | ForEach-Object {
                Write-Host "Adding $($_.DN) To $DistributionGroup"
                Add-DistributionGroupMember -Identity $DistributionGroup -Member $_.DN -ErrorAction Stop}
        }
    }

    catch
    {
       $Global:ErrorMessage = $error[0].Exception.Message
	    Write-Host "Exception caught: $Global:ErrorMessage"
    }
}

function Get-EccoDstGroupMembers
{
    [CmdletBinding()]

    Param (

        [String]$DistributionGroup,
        [Switch]$isGroup,
        [Switch]$isUser
    )

    filter ExchFilter
    {
        if($isGroup)
        {
            $input | where {($_.Name -like 'O_*' -or $_.Name -like 'N_*') -and ($_.RecipientType -match 'Group')}
        }
        if($isUser)
        {
            $input | Where {($_.RecipientType -eq 'UserMailbox' -OR $_.RecipientType -eq 'MailContact')}
        }
        else
        {
            $input
        }
    }
    
   Get-DistributionGroupMember -Identity $DistributionGroup | ExchFilter
}

function Main
{
    try 
    {
        # Remove old log files
        Remove-Item "$Global:ScriptPath\Output.log" -ErrorAction SilentlyContinue
        Remove-Item "$Global:ScriptPath\Trace.log" -ErrorAction SilentlyContinue

        # Add startup details to tracelog
        Write-LogFile "-------------------------------------------------------------------------------------------------------------" -Trace
        Write-LogFile "PowerShell version [$($PSVersionTable.PSVersion.ToString())] session in a [$([IntPtr]::Size * 8)] bit process" -Trace
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)] " -Trace

      #------------------------------------------------------------
      # Declaring Variables
      #------------------------------------------------------------  
        
        # Current error message
        $ErrorMessage = "" 

        # SearchBase Distinguised Name
        $DN = "OU=Distribution Lists,OU=EXCHANGE,DC=prd,DC=eccocorp,DC=net"
     
      #------------------------------------------------------------
        
        if(!(Get-Module ActiveDirectory))
        {
            Write-LogFile "Import-Module ActiveDirectory" -Trace
	        Import-Module ActiveDirectory
        }
    
        if(!(Get-PSSnapin Quest.ActiveRoles.ADManagement))
        {
            Write-LogFile "Add-PSSnapin Quest.ActiveRoles.ADManagement" -Trace
            Add-PSSnapin Quest.ActiveRoles.ADManagement
        }

        # Importing exchange module
        if(!((Get-PSSession | ?{$_.ConfigurationName -eq "Microsoft.Exchange"}).Availability -eq "Available"))
        {
            Get-PSSession | ?{$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession -ErrorAction SilentlyContinue
            $Uri = "http://dkhqexc04n01.prd.eccocorp.net/powershell/"
            Write-LogFile "Importing Remote Exchange 2010 Cmdlets - $Uri" -Trace
            $ExSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $Uri -Authentication Kerberos
            Import-PSSession $ExSession -ErrorAction SilentlyContinue
        }
	    
        # Remove users from distributiongroup and add members from innergroups directly to the distributiongroup
	    foreach ($dl in (Get-EccoDstList -DistingiusedName $DN -ErrorAction Stop)) 
        {
		    Write-LogFile "Removing members from DistributionGroup $dl.." -Trace
            Remove-EccoDstGroupMembers -DistributionGroup $dl -ErrorAction Stop
			
		    Write-LogFile "Add members to DistributionGroup $dl.." -Trace
            Add-EccoDstGroupMembers -DistributionGroup $dl -ErrorAction Stop
	    }
    }

    catch 
    {
        $ErrorMessage = $error[0].Exception.Message
	    Write-LogFile "Exception caught: $ErrorMessage" -Trace
    }

    Finally
    {
        ## Remove open sessions
        Write-LogFile " Get-PSSession | ?{`$_.ConfigurationName -eq 'Microsoft.Exchange'} | Remove-PSSession -ErrorAction SilentlyContinue" -Trace
        Get-PSSession | ?{$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession -ErrorAction SilentlyContinue
        Write-LogFile "Session - Script Finished"
    }
}

#endregion

main