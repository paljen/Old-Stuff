## Runspace PS v3.0
$var = Powershell{

    # ------------------------------------------------------------------------
    # NAME: 
    # MonitorServerImages-6.ps1
    #
    # AUTHOR: 
    # Palle Jensen, Ecco
    # 
    # DATE: 
    # 22/10/2015
    #
    # KEYWORDS: 
    # VM, Copy
    #
    # COMMENTS: 
    # The script is part of the runbook 3.4.1.1 Build Server Image 
    # The basics of this scripts is to monitor when the image has been applied 
    # to the VM and is shut down. After shutdown the VM will be copied to a CM
    # Distributionpoint and a backup of an already present VM will be made 
    # before overwriting.
    #
    # CHANGES:
    # 04/11/2015 Version 2, Minor function based changes
    # 12/11/2015 Version 3, Minor function based changes
    # 13/11/2015 Version 4, Minor function based changes
    # 16/11/2015 Version 5, CredSSP Authentication
    # 16/11/2015 Version 6, Minor code change, comment script, Script Analyzer
    # ---------------------------------------------------------------------

    #region Variables

    #------------------------------------------------------------
    # Declaring Variables
    #------------------------------------------------------------ 
    # Set trace and status variables to defaults
    # 0=Success,1=Warning,2=Error
      $ErrorState = 0
    #
    # Current error message
      $ErrorMessage = ""
    #
    # Last action been written to trace log
      $CurrentAction = ""
    #	
    # Path to logfile, (Split-Path -parent $MyInvocation.MyCommand.Definition)
      $LogPath = "C:\logs\Orchestrator\3.4.1.1 - Build Server Images"
    #
    # Paths where to copy VHD and backup files
      $Destination = "\\dkhqsql04fs\SCVMMLibrary\Server OS\Server 2012 R2 STD"
      $Backup = "\\prd.eccocorp.net\it\CMSource\Server Baseline VHD Backup\Server 2012 R2"
    #
    # Session specific variables
      $SessionHost = "dkhqvmtst02.prd.eccocorp.net"
      $SessionName = "HyperV"
    #
    # VM Specific variables
      $VM = "VHDBuild2012"      
    #------------------------------------------------------------

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
            $Log = "$LogPath\Trace.log"
            $script:CurrentAction = $Message	
	        $Output = "$([DateTime]::Now): $Message"
        }

        else
        {
            $Log = "$LogPath\Output.log"
            $output = $Message
        }

	    [System.IO.StreamWriter]$Log = New-Object  System.IO.StreamWriter($Log, $true)
	    $Log.WriteLine($Output)
	    $Log.Close()
    }


    function Test-BackupPath 
    {
        $success = $true

        try
        {
            ## Test if the backup folder exist, it will be created
            if($(Test-Path -Path $Backup -PathType Container) -eq $false)
            {
                Write-LogFile "New-Item -ItemType Directory -Path $Backup -ErrorAction Stop"
                New-Item -ItemType Directory -Path $Backup -ErrorAction Stop
            }
        }

        catch
        {
            $ErrorMessage = $error[0].Exception.Message
	        Write-LogFile "Exception caught: $ErrorMessage" -Trace
            $success = $false
        }

        $success
    }

    function Copy-VHDImage
    {
        [CmdletBinding()]

        Param(
        
            [String[]]$VMName,
            [String]$SessionName
        )

        ## Argument Array for remote session
        $args = @()
        $args += $VMName
        $args += $Destination
        $args += $Backup

        ## Test backup path, if unavailable, no backup is made
        if(Test-BackupPath)
        {
            try
            {
                ## Backing up old VHD file and wait for the job to finish
                Write-LogFile "Copy-VHD -VMName $VMName -Target $Destination\*.VHD -Destination $Backup" -Trace
                Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $args -ScriptBlock {
                    param($VMName,$destination,$backup)
                    Copy-Item -Path "$destination\*.VHD" -Destination $backup -Force -Confirm:$false -ErrorAction Stop} -AsJob | Wait-Job | Out-Null
            }

            catch
            {
                $ErrorMessage = $error[0].Exception.Message
	            Write-LogFile "Exception caught: $ErrorMessage" -Trace
            }
        }
   
        ## Copy and Overwrite old VHD file, this will happen even though no backup has been made
        Write-LogFile "Copy-VHD -VMName $VMName -Destination $Destination" -Trace
        Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $args -ScriptBlock {
            param($VMName,$destination,$backup)
            $target = (Get-VM –VMName $VMName | Select-Object -Property VMId | Get-VHD).Path
            Copy-Item -Path $target -Destination $destination -Force -Confirm:$false} -AsJob | Wait-Job | Out-Null
    }

    function Monitor-VMImage
    {
        [CmdletBinding()]

        Param(
        
            [String[]]$VMName,
            [String]$SessionName

        )

        $args = @()
        $args += $VMName

        ## Declaring and Initializing arraylist with VM's to monitor
        $vmList = New-Object -TypeName System.Collections.ArrayList
    
        foreach ($vm in $vmname)
        {
            $vmList.Add($vm)
        }
    
        ## Enumerate through the collection and store values in a new array
        $vm = $vmList.GetEnumerator()

        ## We need to clon the enumerated list to be able to manipulate the list
        $vmClone = $vmList.Clone()

        ## The loop will go as long as there is VM's in the cloned array
        While ($vmClone.Count -ne 0)
        {
            ## Reset the pointer
            $vm.Reset()

             ## As long as we have'nt reach the end of the collection
             While($vm.MoveNext())
            {
                ## The delete string, what ever in it will be deleted
                Write-LogFile "Get-VM -VMName $VMName | ?{`$_.state -eq 'Off'}" -Trace
                $delete = Invoke-Command -Session (Get-PSSession -Name $SessionName) -ArgumentList $vm.Current -ScriptBlock {
                            param($VMName)
                            return @(Get-VM -VMName $VMName | ?{$_.state -eq "Off"})}
            
                if($delete)
                {
                    ## Backup old VHDImage file and overwite with New VHDImage file
                    Write-LogFile "Cleaning up $($vm.Current) with status $($delete.state)"
                    Copy-VHDImage -VMName $delete.name -SessionName $SessionName -ErrorAction Stop

                    ## remove VM from collection
                    $vmClone.Remove($($vm.Current))
                }
            
                Start-Sleep -Seconds 60
            }
        }
    }

    #endregion

    #region Main

    function Main
    {
        ## Initializing Logs
        Write-LogFile "-------------------------------------------MonitorServerImages----------------------------------------------"
        Write-LogFile "-------------------------------------------MonitorServerImages----------------------------------------------" -Trace
        Write-LogFile "Running as user [$([Environment]::UserDomainName)\$([Environment]::UserName)] on host [$($env:COMPUTERNAME)]" -Trace
        Write-LogFile "Executing commands in order.." -Trace

        ## Credentials created with EncryptAutomationAccount.ps1
        $password = "76492d1116743f0423413b16050a5345MgB8AGgANAB5ADUAQwAxAHEAQwBiAFcAVwBhAGsATwA3AGcAUwB2AHMALwAwAFEAPQA9AHwANAAxADg`
        AMgA2AGEAMAA2ADkAYwBjADcAMgBiAGUAZQAwADUANgA1ADAAOAA3AGUAZAA4AGEAOAAyADUANAAzAGQANAA4ADIANgAyADcAZgBjADIAZgA3AGQAMgAwADMAOAA`
        wADUANgBhADgANgAzAGMAMQBlADEANwA0ADQAMABlADIAMQBiAGQANQA3AGQANwAyAGUAOQBhADEANgA5ADQAMgA4ADAAYQBhAGYAMgA1AGUAMwA2ADkAMgAyAGEA"

        $key = "138 80 194 66 156 157 189 91 119 99 79 211 225 245 228 70 124 181 119 49 51 100 100 19 149 49 113 136 132 123 229 112"
        $passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
        $cred = New-Object System.Management.Automation.PSCredential("Service-SCORCHRAA", $passwordSecure)

        try 
        { 
            ## Test if a Session with the same name is available and remove it
            Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
            
            ## Create session on cluster
            Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
            $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop
            Write-LogFile "Session Created on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"

            ## Get active cluster node from session
            $clusterNode = Invoke-Command –Session $session -ScriptBlock {(Get-WmiObject -Class win32_computersystem).Name}

            ## Remove cluster session 
            Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
            Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
            Write-LogFile "Session $($session.Name) removed - Script Finished"
                
            ## Overwriting session string with active cluster node
            $sessionHost = "$clusterNode.prd.eccocorp.net"

            ## Create new session with Authentication CredSSP on the clusternode
            Write-LogFile "New-PSSession -Name $sessionName -ComputerName $sessionHost -ErrorAction Stop" -Trace
            $session = New-PSSession -Name $sessionName -ComputerName $sessionHost -Credential $cred -Authentication CredSSP -ErrorAction Stop
            Write-LogFile "Session created on $sessionhost with Session Id $($session.Id) and Session name $($session.Name)"

            ## Import Hyper-V module within session
            Invoke-Command –Session $Session -ScriptBlock {Import-Module -Name Hyper-V}

            ## Starting monitoring
            Write-LogFile "Monitor-VM -VMName $vm -SessionName $sessionName -ErrorAction Stop" -Trace
            Write-LogFile "Monitoring VM $vm"
            Monitor-VMImage -VMName $vm -SessionName $sessionName -ErrorAction Stop
            Write-LogFile "No more VM's to monitor - Finalizing script"
        }

        Catch
        {
            $ErrorMessage = $error[0].Exception.Message
	        Write-LogFile "Exception caught: $ErrorMessage" -Trace
            $ErrorState = 1
        }

        Finally
        {
            ## Remove the open session used
            Write-LogFile "Get-PSSession | ?{`$_.Name -like $sessionName*} | Remove-PSSession" -Trace
            Get-PSSession | ?{$_.Name -like "$sessionName*"} | Remove-PSSession
            Write-LogFile "Session $($session.Name) removed - Script Finished"
        }

        ## return array from powershell{}, used in the runbook bus
        $returnArray = @()
        $returnArray += $ErrorState
        $returnArray += $ErrorMessage
        return $returnArray
    }

    #endregion

    main
}

## Setting the published runbook variables
$ErrorState = $Var[0]
$ErrorMessage = $var[1]