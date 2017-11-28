$PingList = @(
    "LocalHost;127.0.0.1"; 
    "Google;8.8.8.8";
    "Random;192.1.1.1"
    )

# Import the neccesary libraries
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Set font values
$FontBold = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[Drawing.FontStyle]'Bold' )
$FontHeader = New-Object System.Drawing.Font("Microsoft Sans Serif",14,[Drawing.FontStyle]'Bold' )
$FontNormal = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[Drawing.FontStyle]'Regular')
$FontItalic = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[Drawing.FontStyle]'Italic')

# Function for pinging several servers/computers
Function Ping-Servers
{
	# Get all the servers/computers
	$computers = $PingList
	# Start the loop
	foreach ($strComputer in $computers)
	{
        $curName = $strComputer.split(";")[0]
        $CurIp = $strComputer.split(";")[1]
		# Create a new Ping object
		$ping = New-Object System.Net.NetworkInformation.Ping
		# Ping the server/computer
		$reply = $ping.send($CurIp)
		# If the reply has the status "Success"
		if ($reply.status –eq “Success”) 
		{
			# Set the font
			$TextBox.selectionFont  = $FontNormal
            $TextBox.SelectionColor = "Green"
			# Append the text to the textfield
            $TextBox.appendText($curName + " - ONLINE")
            $TextBox.appendText("`n")			
		}
		# If the reply isn't succesfull
		else 
		{
			# Set the font
			$TextBox.selectionFont  = $FontBold
            $TextBox.SelectionColor = "Red"
			# Indent the text so it shows up
            #$TextBox.SelectionIndent = 20
			# Append the text
			$TextBox.appendText("* " + $curName + " - OFFLINE")
            $TextBox.appendText("`n")
			# Set the font back to normal
            $TextBox.selectionFont  = $FontNormal
		}
	}
}

# Create a new form object
$Form = New-Object System.Windows.Forms.Form

# Set the preferences of the window
$Form.width = 400
$Form.height = 600
$Form.Text = ”Connection Test”

# Create a new rich textbox object 
$TextBox = New-Object System.Windows.Forms.RichTextBox
# Set the preferences of the rich textbox
$TextBox.Location = New-Object System.Drawing.Size(5,10)
$TextBox.Size = New-Object System.Drawing.Size(375,510)
$Form.Controls.Add($TextBox)

# Create a new button
$StartButton = New-Object System.Windows.Forms.Button
# Set the preferences of the button
$StartButton.Location = New-Object System.Drawing.Size(140,530)
$StartButton.Size = New-Object System.Drawing.Size(100,23)
$StartButton.Text = "Start"
$StartButton.Add_Click({Ping-Servers})
$Form.Controls.Add($StartButton)

# Acticate the form
$Form.Add_Shown({$Form.Activate()})
$Form.ShowDialog()