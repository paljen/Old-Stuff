Function Check-PowerStatus
{
    [CmdletBinding()]

    param()

    try
    {
        $ErrorActionPreference = "Stop"

        if((gwmi win32_battery).BatteryStatus -eq 2) #should be 1
        {
            Show-InformationForm -LeftButtonLabel "Done" -RightButtontLabel "Cancel" -FormText "Connect to static power"
        }
        else
        {
            Check-NetworkStatus
        }
    }

    catch
    {
        Write-Output $_.Exception.Message
    }
}

Function Check-NetworkStatus
{
       [CmdletBinding()]

    param()

    filter Ethernet
    {
         $input | Where {$_.PhysicalAdapter -and $_.NetConnectionID -match "Ethernet" -and $_.NetConnectionStatus -eq 2}
    }

    try
    {
        $ErrorActionPreference = "Stop"

        If(!(Get-WmiObject -class Win32_NetworkAdapter | Ethernet).NetEnabled)
        {
            Show-InformationForm -LeftButtonLabel "Done" -RightButtontLabel "Cancel" -FormText "Connect to cabled network"
        }
    }

    catch
    {
        Write-Output $_.Exception.Message
    }
}

Function Validate-USMTData
{
    ##---##
}

Function Show-InformationForm 
{
    [CmdletBinding()]

    Param 
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $LeftButtonLabel,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $RightButtontLabel,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $FormText
    )

    Try 
    {
        $ErrorActionPreference = "Stop"
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    
        $objForm = New-Object System.Windows.Forms.Form
        $objForm.Text = "Win10 Preperation"
        $objForm.Size = New-Object System.Drawing.Size(300,200)
        $objForm.StartPosition = "CenterScreen"
        $objForm.KeyPreview = $True
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter"){Check-PowerStatus;$objForm.Close()}})
        $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape"){$objForm.Close()}})

        $leftButton = New-Object System.Windows.Forms.Button
        $leftButton.Location = New-Object System.Drawing.Size(75,120)
        $leftButton.Size = New-Object System.Drawing.Size(75,23)
        $leftButton.Text = $leftButtonLabel
        $leftButton.Add_Click({Check-PowerStatus;$objForm.Close()})
        $objForm.Controls.Add($leftButton)

        $rightButton = New-Object System.Windows.Forms.Button
        $rightButton.Location = New-Object System.Drawing.Size(150,120)
        $rightButton.Size = New-Object System.Drawing.Size(75,23)
        $rightButton.Text = $RightButtontLabel
        $rightButton.Add_Click({$objForm.Close()})
        $objForm.Controls.Add($rightButton)

        $objLabel = New-Object System.Windows.Forms.Label
        $objLabel.Location = New-Object System.Drawing.Size(10,20) 
        $objLabel.Size = New-Object System.Drawing.Size(280,20) 
        $objLabel.Text = $FormText
        $objForm.Controls.Add($objLabel)

        $objForm.Topmost = $True
        $objForm.Add_Shown({$objForm.Activate()})
        [void] $objForm.ShowDialog()
    }

    Catch 
    {
        Write-Output $_.Exception.Message
    }
}

function Main
{
    Check-PowerStatus
    #Check-NetworkStatus
}

Main