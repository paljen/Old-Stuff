function Select-Item
{
PARAM 
(
    [Parameter(Mandatory=$true)]
    $options,
    [Parameter(Mandatory=$true)]
    $displayProperty
)
    function processOK
    {
        if ($lstOptions.SelectedIndex -lt 0)
        {
            $script:selectedItem = $null
        }
        else
        {
            $global:selectedItem = $options[$lstOptions.SelectedIndex]
        }
        $form.Close()
    }
    $script:selectedItem = $null
    
    #Create the form
	[Windows.Forms.form]$form = new-object Windows.Forms.form
	$form.Size = new-object System.Drawing.Size @(225,250)   
	$form.text = "Select Item"  
	
	#Create the list box.
	[System.Windows.Forms.ListBox]$lstOptions = New-Object System.Windows.Forms.ListBox
	$lstOptions.Name = "lstOptions"
	$lstOptions.Width = 200
	$lstOptions.Height = 175
	$lstOptions.Location = New-Object System.Drawing.Size(5,5)
    $lstOptions.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        
    #Create the OK button
	[System.Windows.Forms.Button]$btnOK = New-Object System.Windows.Forms.Button 
	$btnOK.Width=100
	$btnOK.Location = New-Object System.Drawing.Size(50, 180)
	$btnOK.Text = "OK"
    $btnOK.add_click({processOK})
    $btnOK.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $form.Controls.Add($lstOptions)
    $form.Controls.Add($btnOK)
    
    #Populate ListBox
    foreach ($option in $options)
    {
        $lstOptions.Items.Add($option.$displayProperty) | Out-Null
    }
    
    $form.ShowDialog() | Out-Null
    return $script:selectedItem
}

$values = Get-Service
$val = Select-Item $values "DisplayName"
$val

