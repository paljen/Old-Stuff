
Import-Module .\Ecco.Database

Function Test-PowerStatus
{
    [CmdletBinding()]

    param()

    try
    {
        $ErrorActionPreference = "Stop"

        ## Test if the system has access to AC so no battery is being discharged

        if((gwmi win32_battery).BatteryStatus -eq 2)
        {   
            $true
        }

        else
        {
            $false
        }
    }

    catch
    {
        Write-Output $_.Exception.Message
    }
}

Function Test-NetworkStatus
{
    [CmdletBinding()]

    param()

    filter Ethernet
    {
         $input | Where {$_.PhysicalAdapter -and $_.NetConnectionID -match "Ethernet" -or $_.NetConnectionID -match "Local Area Connection" -and $_.NetConnectionStatus -eq 2}
    }

    try
    {
        $ErrorActionPreference = "Stop"

        ## Test if the computers network is cabled

        If((Get-WmiObject -class Win32_NetworkAdapter | Ethernet).NetEnabled)
        {
            $true
        }
        else
        {
            $false
        }
    }

    catch
    {
        Write-Output $_.Exception.Message
    }
}

Function Test-USMTDataset
{
    param(

        [String]$Connection
    )
    
        $cn = (Get-WmiObject win32_computersystem).caption
        $query = "Select USMTSize From USMTData Where Computername='$cn'"
        $size = Get-EccoDBDataset -connectionString $connectionString -query $query -isSQLServer
        
        $Script:datasize = $($size[1].usmtsize)

        if($Script:datasize -gt 20000)
        {
            $true
        }
    
    else
    {
        $false
    }
}

Function Show-InformationForm 
{
    [CmdletBinding()]

    Param 
    (
        [String]$LeftButtonLabel,
        [String]$RightButtontLabel,
        [String]$FormText,
        [Switch]$Power,
        [Switch]$Network
    )

    Try 
    {
        $ErrorActionPreference = "Stop"
        
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $style = [System.Windows.Forms.FlatStyle]::System

        $objForm = New-Object System.Windows.Forms.Form        
        $objForm.Text = "Pre Windows 10 Installation"
        $objForm.Size = New-Object System.Drawing.Size(400,200)
        $objForm.StartPosition = "CenterScreen"
        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({
            if ($_.KeyCode -eq "Escape")
            {
                $objForm.Close()
                $objForm.Dispose()
            }
        })
        
        $leftButton = New-Object System.Windows.Forms.Button

        if(($RightButtontLabel).Length -ne 0)
        {
            $leftButton.Location = New-Object System.Drawing.Size(125,120)
            $leftButton.Size = New-Object System.Drawing.Size(75,23)
        }
        else
        {
            $leftButton.Location = New-Object System.Drawing.Size(112,120)
            $leftButton.Size = New-Object System.Drawing.Size(175,23)
        }

        $leftButton.Text = $leftButtonLabel
        $leftButton.FlatStyle = $style

        if($power)
        {
            $leftButton.Add_Click({
                if(Test-PowerStatus)
                {
                    $objForm.Close()
                    $objForm.Dispose()
                }
                else
                {   
                    $objForm.Close
                    $objForm.Dispose()
                    Show-InformationForm -Power -LeftButtonLabel $LeftButtonLabel -RightButtontLabel $RightButtontLabel -FormText $FormText
                }
            })
        }

        elseif($network)
        {
            $leftButton.Add_Click({
                if(Test-NetworkStatus)
                {
                    $objForm.Close()
                    $objForm.Dispose()
                }
                else
                {
                    $objForm.Close
                    $objForm.Dispose()
                    Show-InformationForm -Network -LeftButtonLabel $LeftButtonLabel -RightButtontLabel $RightButtontLabel -FormText $FormText
                }
            })
        }
        
        else
        {
            $leftButton.Add_Click({
                $objForm.Close()
                $objForm.Dispose()
                
            })
        }

        $objForm.Controls.Add($leftButton)

        if(($RightButtontLabel).Length -ne 0)
        {
            $rightButton = New-Object System.Windows.Forms.Button
            $rightButton.Location = New-Object System.Drawing.Size(200,120)
            $rightButton.Size = New-Object System.Drawing.Size(75,23)
            $rightButton.Text = $RightButtontLabel
            $rightButton.FlatStyle = $style
            $rightButton.Add_Click({
                $objForm.Close()
                $objForm.Dispose()           
                $Script:Terminate = $true
            })

            $objForm.Controls.Add($rightButton)
        }

        $objLabel = New-Object System.Windows.Forms.Label
        $objLabel.Location = New-Object System.Drawing.Size(10,20) 
        $objLabel.Size = New-Object System.Drawing.Size(380,70) 
        $objLabel.Text = $FormText
        $objForm.Controls.Add($objLabel)
        $objForm.Topmost = $True
        $objForm.Add_Shown({
            $objForm.Activate()
        })

        $objForm.ShowDialog() | Out-Null
    }

    Catch 
    {
        Write-Output $_.Exception.Message
    }
}

Function Main
{
    #Hide the progress dialog
    $TSProgressUI = new-object -comobject Microsoft.SMS.TSProgressUI
    $TSProgressUI.CloseProgressDialog()

    $Script:Terminate = $false
    $Script:Datasize = $datasize
    $connectionString = "server=dkhqsccm02;database=USMT_inventory;trusted_connection=True"
    
    $cmd = @{"NetSh"=@(netsh dns show state)}
    $mLoc = (((($cmd["NetSh"]) | Select-String -Pattern "Machine") -replace " ","") -replace "MachineLocation:","").TrimStart()

	if($mLoc -eq "InsideCorporateNetwork")
	{		 
        if(!(Test-PowerStatus))
        {
            ## If the system is running on battery instruct the user to use wired power, dock or cabel

            $text = "You are running on battery, please switch to wired power - cable or dock"

            Show-InformationForm -Power -LeftButtonLabel "Try Again" -RightButtontLabel "Cancel" -FormText $text
        
            if ($Script:Terminate){Exit 1}        
        }

        if(!(Test-NetworkStatus))
        {
            ## If the system network is not cabled instruct the user to use cabled network

            $text = "Your network is not cabled, please connect with a network cable or dock your computer"

            Show-InformationForm -Network -LeftButtonLabel "Try Again" -RightButtontLabel "Cancel" -FormText $text

            if ($Script:Terminate){Exit 1}
        }

        if(Test-USMTDataset -Connection $connectionString)
        {
            ## Inform the user that installation can last longer then 1 hour

            $text = "You have more then 20GB data that needs to be migrated. This could slow down the upgrade process to last more then 1 hour - do you want to proceed?"

            Show-InformationForm -LeftButtonLabel "OK" -RightButtontLabel "Cancel" -FormText $text

            if ($Script:Terminate){Exit 1}  
        }

        if($(Test-PowerStatus) -eq $true -and $(Test-NetworkStatus) -eq $true)
        {
            Write-Output "All tests ok"
        }

        else
        {
            Write-Output "Something went wrong"
            Exit 1
        }
    }

	else
	{
        ## not on corporate network

        $text = "Your computer is not connected to the corporate network, the upgrade process is only supported onsite. Please upgrade at another time"

        Show-InformationForm -LeftButtonLabel "Cancel Installation" -FormText $text

		Exit 1
	}
}

Main