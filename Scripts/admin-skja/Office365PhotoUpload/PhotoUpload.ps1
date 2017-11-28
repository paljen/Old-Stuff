#region References
#Add-Type -Path ([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client").location)
#Add-Type -Path ([System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.runtime").location)
#endregion

#region Global Variables
$Global:SPOMySiteUrl = "https://ecco-my.sharepoint.com"
$Global:SPOAdminUrl = "https://ecco-admin.sharepoint.com"
$Global:SPOUserPhotoDocLibrary = "User Photos"
$Global:SPOUserPhotoLibraryFolder = "Profile Pictures"
$Global:SPOPeopleManager = $Null
$Global:SPOAdminCtx = $Null
$Global:SPOMySiteCtx = $Null
$Global:SPOCredentials = $null

$Global:SourceImageFolderUNC = "\\zeus\images"
$Global:SourceImageFolderMapped = "ZeusImages:\"
$Global:SourceImageProcessedFolder = "$($Global:SourceImageFolderMapped)Processed\"
$Global:SourceImageResizeFolder = "$($env:temp)\PhotoUploadTemp\"

$Global:EXOsession = $null
#endregion

#region Credentials
#Sharepoint Online
$password = "76492d1116743f0423413b16050a5345MgB8AEIAOQBuADIASgBBAEcAegA1AEEAZwA3AFIAQQBFAGIAVQAxAHUASwBvAFEAPQA9AHwAYQA5ADgAMAA3ADIAYgA2ADAAZABjADIAMgAyAGIAYQA3AGEAMAA2ADQAOABjAGEAZQBkADEANgAyADEAYQBlADIAYgAxADMAYwAyAGUANwA5ADQAYwA1ADMAOQA5ADUAMgAwAGYAOQA2AGMANQAyAGQAZgBmADUANAA5ADIANAA="
$key = "96 99 65 89 28 45 161 230 46 154 249 65 90 196 141 173 102 56 238 28 67 178 245 110 243 137 12 179 140 175 232 137"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$SPOcred = New-Object system.Management.Automation.PSCredential("AzService-SPAdmin@ecco.onmicrosoft.com", $passwordSecure)

#Exchange Online
$password = "76492d1116743f0423413b16050a5345MgB8AFYAZwBIADUAMgBiAGMAbABEAC8AdABGAE4AMQAxAFAAVQByADgAUwBvAEEAPQA9AHwAYQA3ADkANwBjAGEAOQBlADAAZgAzADYAOQBlADIAZABkAGQAZAA5AGEAZgBhADMANQBkADAAYwBkADcAYwBhADgAYwAwADYAOQBjADkAZQA1ADIANgAzADIAMQBkADIANABiADAANgAxADUAMgA2ADUANQA5ADAAZgBhADkAMgA="
$key = "116 142 203 92 114 62 96 53 197 210 77 44 163 172 128 82 112 132 32 187 209 119 242 97 112 54 220 240 141 43 1 112"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$EXOcred = New-Object system.Management.Automation.PSCredential("AzService-ExchAutomation@ecco.onmicrosoft.com", $passwordSecure)

#Zeus Pictures folder
$password = "76492d1116743f0423413b16050a5345MgB8AGYANgBvAC8AcABiAEQATgBPAFoAUwAzAEwAMwB2ADcANQBzAGgAVgBLAGcAPQA9AHwANwA3AGUANAAyAGIAYQA1AGYAYwA3ADMAYwAxADEAYwA2AGUANQAzAGIAZgAyADMAMgAxADcAMQA0AGIAMAA5ADEAYQBmADkANgAzADIANwBjADQAYwBkADkAMgBiAGYAZAA5ADUAZAA1AGUAMgA2AGIANwAxADIAOABkAGIAOQA="
$key = "232 93 55 247 249 154 104 136 170 63 30 69 156 31 96 164 130 188 201 111 174 18 146 50 201 2 143 185 185 25 37 43"
$passwordSecure = ConvertTo-SecureString -String $password -Key ([Byte[]]$key.Split(" "))
$ZEUScred = New-Object system.Management.Automation.PSCredential("zeus\portal", $passwordSecure)

#endregion

function Connect-SPOCSOM
{
    try {
        #Load DLL's
        Get-ChildItem ($PSScriptRoot) -Recurse -Verbose:$false | Where-Object -Verbose:$false { $_.Name -like "*.dll" } | Foreach-Object {
	        try{import-module $_.FullName}
	        catch{Write-Host -ForegroundColor DarkCyan $_.Exception.Message}} -Verbose:$false

        $Global:SPOCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($SPOcred.GetNetworkCredential().Username, (ConvertTo-SecureString $SPOcred.GetNetworkCredential().Password -AsPlainText -Force))
        #$global:Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($SPOcred.GetNetworkCredential().Username, (ConvertTo-SecureString $SPOcred.GetNetworkCredential().Password -AsPlainText -Force))
        
        $Global:SPOAdminCtx = New-Object Microsoft.SharePoint.Client.ClientContext($Global:SPOAdminUrl)
        $Global:SPOAdminCtx.Credentials = $Global:SPOCredentials
        
        $Global:SPOMySiteCtx = New-Object Microsoft.SharePoint.Client.ClientContext($Global:SPOMySiteUrl)
        $Global:SPOMySiteCtx.Credentials = $Global:SPOCredentials

        $Global:SPOPeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Global:SPOAdminCtx)
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

function Connect-EXO
{
    # Start EXO session
	$Global:EXOsession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionURI https://ps.outlook.com/powershell/?proxymethod=rps -Credential $EXOcred -Authentication Basic -AllowRedirection
    if (!$Global:EXOsession) {
        #Retry, fails for some reason on first attempt
        $Global:EXOsession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionURI https://ps.outlook.com/powershell/?proxymethod=rps -Credential $EXOcred -Authentication Basic -AllowRedirection
    }
	Import-PSSession $Global:EXOsession -DisableNameChecking -AllowClobber | Out-Null
        
	# Avoid naming conflict for Get-User cmdlet in EXO module and .Client
	#$moduleName = gcm Set-UserPhoto | select -expand modulename
	#Set-Alias Get-EXOUser "$moduleName\Get-User"  
}

Function Invoke-LoadMethod() {
param(
   $ClientObject = $(throw "Please provide an Client Object instance on which to invoke the generic method")
) 
   $ctx = $ClientObject.Context
   $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load") 
   $type = $ClientObject.GetType()
   $clientObjectLoad = $load.MakeGenericMethod($type) 
   $clientObjectLoad.Invoke($ctx,@($ClientObject,$null))
}

function Resize-Image
{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [io.FileInfo]$SourceImagePath,
        [Parameter(Mandatory=$true)]
		[int]$Width,
        [Parameter(Mandatory=$true)]
        [string]$TargetImagePath,
        [Parameter(Mandatory=$true)]
		[ValidateRange(0,100)]
        [int]$CompressionQuality = 75,
        [switch]$OnlyResizeIfLarger = $true,
        [switch]$WarnIfNotSquare = $true
    )
	begin
	{
		Add-Type -AssemblyName System.Drawing
	}
    process
    {
        if ( -Not (Test-Path $SourceImagePath ))
        {
            Write-Error "Resize-Image: ImagePath invalid [$SourceImagePath]"
        }
        $originalImage = [Drawing.Image]::FromFile($SourceImagePath.FullName)
        $newHeight = ($Width * $originalImage.Height) / $originalImage.Width

        if ( $WarnIfNotSquare.IsPresent -and $originalImage.Height -ne $originalImage.Width )
        {
            Write-Warning "`tOBS: Image [$SourceImagePath] is not square! Image was uploaded, but automatic cropping may occur!"
        }
        
        if ( $OnlyResizeIfLarger.IsPresent -and $originalImage.Width -lt $Width )
        {
            # Picture was smaller than new with so don't resize
            $originalImage.Save($TargetImagePath)
        }
        $encoder = [Drawing.Imaging.Encoder]::Quality
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($encoder, $CompressionQuality)
        # fetch codec based on extension
        $imageCodecInfo = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()| ? FilenameExtension -like "*$($SourceImagePath.Extension)*"
        $newImage = New-Object Drawing.Bitmap($Width,$newHeight)
        $graphics = [Drawing.Graphics]::FromImage($newImage)
        $graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($originalImage, (New-Object Drawing.Rectangle(0,0,$Width,$newHeight)))
        $newImage.Save($TargetImagePath, $imageCodecInfo, $encoderParams)
        $newImage.Dispose()
        $graphics.Dispose()
        $originalImage.Dispose()

        # return image path
        $TargetImagePath
    }
}

function Upload-SPOUserPhoto($File)
{
    $File = Get-Item -Path $File

    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($Global:SPOMySiteUrl)
    $Context.RequestTimeout = 16384000
    $Context.Credentials = $Global:SPOCredentials
    $Context.ExecuteQuery()

    $Web = $Context.Web
    $Context.Load($Web)
    $Context.ExecuteQuery()

    $SPODocLibName = "Documents"
    $SPOList = $Web.Lists.GetByTitle($Global:SPOUserPhotoDocLibrary)
    $Context.Load($SPOList.RootFolder)
    $Context.ExecuteQuery()

    $FolderRelativeUrl = $SPOList.RootFolder.ServerRelativeUrl
    $FileName = $File.Name
    $FileUrl = $FolderRelativeUrl + "/$($Global:SPOUserPhotoLibraryFolder)/" + $FileName
    [Microsoft.SharePoint.Client.File]::SaveBinaryDirect($Web.Context, $fileUrl, $File.OpenRead(), $true)
    Write-Output ($Global:SPOMySiteUrl + $FileUrl)
}

function Update-SPOUserInfo($UserPrincipalName, $PictureURL, $ExchangeSyncState, $PicturePlaceHolder)
{
    try {
        $targetSPOUserAccount = ("i:0#.f|membership|" + $UserPrincipalName)
        
        #Get the user profile property
        #$targetUserProperty = $Global:SPOPeopleManager.GetUserProfilePropertyFor($targetSPOUserAccount, $PropertyName)
        #$Global:SPOAdminCtx.ExecuteQuery()

        #Set the new Profile Property if different from
        #if ($targetUserProperty.Value -ne $PropertyValue) {
        $Global:SPOPeopleManager.SetSingleValueProfileProperty($targetspoUserAccount, "PictureURL", $PictureURL)
        $Global:SPOAdminCtx.ExecuteQuery()

        $Global:SPOPeopleManager.SetSingleValueProfileProperty($targetspoUserAccount, "SPS-PictureExchangeSyncState", $ExchangeSyncState)
        $Global:SPOAdminCtx.ExecuteQuery()

        $Global:SPOPeopleManager.SetSingleValueProfileProperty($targetspoUserAccount, "SPS-PicturePlaceholderState", $PicturePlaceHolder)
        $Global:SPOAdminCtx.ExecuteQuery()
            #Write-Output "$($UserPrincipalName): [$($PropertyName)]: Property updated with value: $($PropertyValue)"
        #}
        #else {
            #Write-Output "$($UserPrincipalName): [$($PropertyName)]: Same value, no update needed"
        #}

    }
    catch {
        [String]$ErrorMessage = $_.Exception.Message
        if ($ErrorMessage -Match "^*User Profile Error 1000:*") {
            Write-Warning "`tUser not found in Sharepoint Online, unable to set user info for $($UserPrincipalName)"
        }
        else {
            Write-Output $ErrorMessage
        }
    }
}

function Upload-EXOUserPhoto($UserPrincipalName, $File)
{
	# Avoid naming conflict for Get-User cmdlet in EXO module and .Client
	$moduleName = gcm Set-UserPhoto | select -expand modulename
	Set-Alias Get-EXOUser "$moduleName\Get-User"  

    # Check if user exists. Due to bad coding in EXO module we need to swallow exception if user does not exist
    $user = Get-EXOUser -Identity $UserPrincipalName -ErrorAction 0
    if ( -not $user )
    {
        Write-Warning "Set-UserProfilePhoto: Could not find user [$($UserPrincipalName)] in Exchange"
        #$skippedImages.Add($picture.FullName,"User not found in EXO")
        continue
    }

    $pictureData = Get-Content -Path $File -ReadCount 0 -Encoding Byte
    # check $pictureData.Count and skip with warning if larger 
    if ( $pictureData.Count -gt 18852 )
    {
        #Write-Warning "Set-UserProfilePhoto: Image [$($File)] was too large to be uploaded in Exchange"
        Write-Warning "Set-UserProfilePhoto: Image [$($File)] may be too large to upload, we will try but might fail."
        #$skippedImages.Add($picture.FullName,"Image too large!")
        #continue                
    }
    # Upload picture to EXO
    Set-UserPhoto -Identity $UserPrincipalName -PictureData $pictureData -Confirm:$false -Erroraction 2
    Write-Verbose "`tUploaded picture to EXO account [$($UserPrincipalName)]"

}

$StatusActivity = "Photo Upload to Sharepoint and Exchange Online"
$elapsedTime = [system.diagnostics.stopwatch]::StartNew()
Write-Progress -Id 1 -Activity "$($StatusActivity) - Run Time: $($elapsedTime.Elapsed)" -Status "Setting up connections" -PercentComplete 0 #-ParentId $Id

#### Main 

Connect-SPOCSOM
Connect-EXO

#Map the network drive.
New-PSDrive -Name ZeusImages -PSProvider FileSystem -Root \\zeus\pictures -Credential $ZEUScred

#Test folders and create if missing
If(!(test-path $Global:SourceImageResizeFolder))
{ New-Item -ItemType Directory -Force -Path $Global:SourceImageResizeFolder -ErrorAction SilentlyContinue }

If(!(test-path $Global:SourceImageProcessedFolder)) 
{ New-Item -ItemType Directory -Force -Path $Global:SourceImageProcessedFolder -ErrorAction SilentlyContinue }


### Process the source files
Write-Progress -Id 1 -Activity "$($StatusActivity) - Run Time: $($elapsedTime.Elapsed)" -Status "Getting Source Images" -PercentComplete 0
$SourceFiles = Get-ChildItem -Path $Global:SourceImageFolderMapped -File #| select -First 100

$i=0
Foreach ($Sourcefile in $SourceFiles) {
    $averageusertimeseconds = $elapsedTime.Elapsed.totalseconds / $i
    Write-Progress -Id 1 -Activity "$($StatusActivity) - Run Time: $($elapsedTime.Elapsed)" -Status "$($i) of $($sourcefiles.count) - Currently uploading photos for $($sourcefile.BaseName)" -PercentComplete (($i / $SourceFiles.Count) * 100) -SecondsRemaining ($averageusertimeseconds * ($SourceFiles.Count - $i))
    $i++
    
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Activity" -Status "Making thumbnails"
    Write-Output "Processing user: $($Sourcefile.BaseName)"
    #Create new thumbnails with correct file name format
    $newImageNamePrefix = $Sourcefile.BaseName -replace "@","_" -replace '\.',"_"

    $tempProfilePictureSmall = Resize-Image -SourceImagePath $Sourcefile.FullName -Width 48 -TargetImagePath ($Global:SourceImageResizeFolder + $newImageNamePrefix + "_SThumb" + $Sourcefile.Extension) -CompressionQuality 75
    $tempProfilePictureMedium = Resize-Image -SourceImagePath $Sourcefile.FullName -Width 72 -TargetImagePath ($Global:SourceImageResizeFolder + $newImageNamePrefix + "_MThumb" + $Sourcefile.Extension) -CompressionQuality 75 
    $tempProfilePictureLarge = Resize-Image -SourceImagePath $Sourcefile.FullName -Width 300  -TargetImagePath ($Global:SourceImageResizeFolder + $newImageNamePrefix + "_LThumb" + $Sourcefile.Extension) -CompressionQuality 85
    $tempProfilePictureEXO = Resize-Image -SourceImagePath $Sourcefile.FullName -Width 240  -TargetImagePath ($Global:SourceImageResizeFolder + $newImageNamePrefix + "_EXO" + $Sourcefile.Extension) -CompressionQuality 75
    
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Activity" -Status "Uploading to Sharepoint Online"
    $SPOSmallURL = Upload-SPOUserPhoto -File $tempProfilePictureSmall
    $SPOMediumURL = Upload-SPOUserPhoto -File $tempProfilePictureMedium
    $SPOLargeURL = Upload-SPOUserPhoto -File $tempProfilePictureLarge
        
    Update-SPOUserInfo -UserPrincipalName $Sourcefile.BaseName -PictureURL $SPOMediumURL -ExchangeSyncState 0 -PicturePlaceHolder 0
    
    Write-Progress -Id 2 -ParentId 1 -Activity "Current Activity" -Status "Uploading to Exchange Online"
    Upload-EXOUserPhoto -UserPrincipalName $Sourcefile.BaseName -File $tempProfilePictureEXO
    #Write-Output "Res: $($res)"

    Write-Progress -Id 2 -ParentId 1 -Activity "Current Activity" -Status "Cleaning up temp files"
    #move to processed folder
    Move-Item -Path $Sourcefile.FullName -Destination "$($Global:SourceImageProcessedFolder)" -Force 

    # clean up temp files
    Remove-Item $tempProfilePictureSmall
    Remove-Item $tempProfilePictureMedium
    Remove-Item $tempProfilePictureLarge
    Remove-Item $tempProfilePictureEXO

}

Get-PSSession | Remove-PSSession
Remove-PSDrive ZeusImages
# SIG # Begin signature block
# MIITxQYJKoZIhvcNAQcCoIITtjCCE7ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUu5wqaDf2tUOMrhJHAoeWvZnY
# JiqgghAZMIIHiDCCBXCgAwIBAgITIgAAAAR+s2mH1OhLhwAAAAAABDANBgkqhkiG
# 9w0BAQsFADAVMRMwEQYDVQQDEwpFQ0NPUm9vdENBMB4XDTE2MTIyMjEwMjQwM1oX
# DTI0MTIyMjEwMzQwM1owXjETMBEGCgmSJomT8ixkARkWA25ldDEYMBYGCgmSJomT
# 8ixkARkWCGVjY29jb3JwMRMwEQYKCZImiZPyLGQBGRYDcHJkMRgwFgYDVQQDEw9F
# Q0NPSXNzdWluZ0NBMDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCP
# uOGk33IgLqvcPllj/vbsqISe0S1VGQacC/IEeiPxtuhvVA7U4WyJxeZoKPsHcN6+
# cpDYKov34VOBCshSYAYpefqodOCw4zE8ipGO/f7zM7b7ydKAEMU4c+VV/Xwzizza
# FGt93Rhavxv/1bO4Fh6hgmOFM7OvSNDnRglXmMsjYfV9givwcXZyJ/e6M7ErvJAl
# BrrbiQJC8PrjR0EZfrovuK8cLlu0H4VbgySCWbsv7wIRc5VfqOb6tCOQhdULmeCD
# cKQ0ZXAdPeRBNrb6Q+rBm8uOghrGDQrn/mzZYaSVv3rPBL5UbJpDool3oEggd30j
# ayi+BCwR1cvPipcTgqdnsZAR0Xs84LElYnVRA61BMNvoe0Fjlu8vqYKq2p3NUiSt
# EEOFIIz/CRtbP3zbekmt2/NcTwiu/9LJgQSy1Vczx/fu5Xx67CH06hQ7NfTBNvhK
# MYoJiRr6GEsFhoh7yNf7KNvdtY24N7qqs7yrKsR8r+DfW4UH3NuuKc/huLSMDvaJ
# RrsA9tQgoYWqIHbLzMH7jCbnxuu93N3eKGK2DzFlRF/o7zA4i82KXvptMdJ2Biby
# UCl+0nClObPXo5/WBg2oF5DT5xNG1DSvoTf2SSyR8lThOsPuWdbPZWqqWQd0TugC
# Dyrg1HKCYLnEFhihbfnGYZzDMKSeH5B0YqVqfku70wIDAQABo4IChjCCAoIwEAYJ
# KwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNJVEMp5fcoirx3xIciKItWld94gMDsG
# CSsGAQQBgjcVBwQuMCwGJCsGAQQBgjcVCPu9RofHhWCJjyGHnMxpge+ZNnqG3O00
# gqyKYAIBZAIBAzALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSME
# GDAWgBQIoYBnds5rmr8Js4sKRn8KGnUTbjCB4gYDVR0fBIHaMIHXMIHUoIHRoIHO
# hiJodHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3JshoGnbGRhcDovLy9D
# Tj1FQ0NPUm9vdENBLENOPUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxD
# Tj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERDPW5ldD9j
# ZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlz
# dHJpYnV0aW9uUG9pbnQwge0GCCsGAQUFBwEBBIHgMIHdMC4GCCsGAQUFBzAChiJo
# dHRwOi8vY2RwLmVjY28uY29tL0VDQ09Sb290Q0EuY3J0MIGqBggrBgEFBQcwAoaB
# nWxkYXA6Ly8vQ049RUNDT1Jvb3RDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIw
# U2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1lY2NvY29y
# cCxEQz1uZXQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmlj
# YXRpb25BdXRob3JpdHkwDQYJKoZIhvcNAQELBQADggIBAEXsS0mN57SbxXvzep4M
# C3tCBnkS1j51OKNC/ttGyLRlATF/OZrrsVbnqVtHZUyiUfBmx1ynOzjb44Cp/lAP
# ldJSe/zFpFVIIUyEDeP+I4H3cMoNDI1aKoDdhlJ9A3JyKKYQbVra4iF0u22pNv8X
# jUN5k8Uuyl7N817t7ji1UAhK4ikf+9Ad6u4b5w6WX9QRl1tsj5jw1zO5WQ0lQhN+
# t2axajDDvnUfw3lqJiQzhg0UMyrAovzDMksXw7qR3SeiEfxKzAmMrPs5taHFN2PU
# zU8osto5RGBx99BKDPWw/QL339Pvsu9bGVqgZ5Bi1L8Iv1XsY4jkRupXsPY1qw3l
# ToREuuE2Ti/IhJb/EZchTtqDfmJUH/TYweTu2wDoAzXwonTQNWpHBHf4ftmiRNWw
# i4fUWi4oJchH4CQ0NTJE1hTkRCJum/CS70Dm/8iIickPCw89figUqnK3D9CnRkpL
# cMyPgCstOrOLyyUntRMEzPXBUT2Ah8RBNZ248kTfeRvQgfXMKISJopRKqv7RDItD
# cJl9ThlujbwJoJtWxWm6NgXIXzFIqKB5SioJ3DXy56UylI7O1XygGAR+mqBJQ35A
# IR7fD1YPjD5sv6Ag3ccs5YbU5nrIaAcO6xtmofbtiD8tPyChKkkdcPZVBXImvUM8
# UUa2uTj7CPSTqDcTXFhPfGoXMIIIiTCCBnGgAwIBAgITSwAABaD8SNQO0C7mNAAA
# AAAFoDANBgkqhkiG9w0BAQsFADBeMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYK
# CZImiZPyLGQBGRYIZWNjb2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxGDAWBgNV
# BAMTD0VDQ09Jc3N1aW5nQ0EwMjAeFw0xNzAxMDUwNzAzMjZaFw0xOTAxMDUwNzAz
# MjZaMIGbMRMwEQYKCZImiZPyLGQBGRYDbmV0MRgwFgYKCZImiZPyLGQBGRYIZWNj
# b2NvcnAxEzARBgoJkiaJk/IsZAEZFgNwcmQxDTALBgNVBAsTBEVDQ08xCzAJBgNV
# BAsTAkRLMQswCQYDVQQLEwJIUTELMAkGA1UECxMCSVQxHzAdBgNVBAMMFlPDuHJl
# biBLasOmcmh1cyAoU0tKQSkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDISpdeD0ivvCdBBH6C98u8aXy+015e9uVTrCrUfLtu//rMuE8XN880is209XAq
# 2Ei9o0EikkQX8MAcQj2lqHf0SIrmG67dRbyBpUrxrU7oZ0tRs0L9dM7NsCMajSBZ
# wBptK89+HEzXAfmN2qWqhrh6WhtXV4WRbaWSjaK3f92vd0GBe5wSn+FdeVd7R+DU
# Z9ZC3cwmdbbHeGXChyxn44+fjhBvFBafL7NiCBORG8dFpBgRi8uUvwuARPss1pe5
# CO/G2JXyoIqyPU0p8q2LMX1MVnOkQSfl/X/8Cq/B7sqrbEbvMNX/9D4FByX1tWNs
# H3qrVn06MEzqOgffjwFwnXF86q6QF5tEFsQ5lS6+dFZis46xs1sXeXfpVE3LahKd
# fNwdTivxYuBayWp3BoFWmbPwO59bLa72P3rsYRKrMFW/F3r8o5zUbiTBVVxVfWF9
# 5f2mxbTdcmiX6MBAEDuCZbpcFbHfY8G7KzpOclwDXx1Aw5WABtC/NVxtkoEX9z9V
# goPJxIOYh/vRqs8ZxKrAIpdrXVnDG/jTPfyxdfBXBC4p6IdHVh4SXzGCeRvtT3yT
# cFTRp8uvff4wCxLVx8GoUpQEjHcdq1vpn0c8LBP+MNVyzErfeObozLox8OTDouBr
# EvrS6g3f7jW/ETIVfKQ6taopeukqsu/f80PGfA5P5eKHAwIDAQABo4IDADCCAvww
# OwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUI+71Gh8eFYImPIYeczGmB75k2eoXL
# zWOF3IFDAgFkAgEkMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIH
# gDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBSixtshpuX+
# WRBzAk9AbylcyxXM5jAfBgNVHSMEGDAWgBTSVRDKeX3KIq8d8SHIiiLVpXfeIDCB
# 7AYDVR0fBIHkMIHhMIHeoIHboIHYhidodHRwOi8vY2RwLmVjY28uY29tL0VDQ09J
# c3N1aW5nQ0EwMi5jcmyGgaxsZGFwOi8vL0NOPUVDQ09Jc3N1aW5nQ0EwMixDTj1D
# RFAsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29u
# ZmlndXJhdGlvbixEQz1lY2NvY29ycCxEQz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0
# aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIIB
# IAYIKwYBBQUHAQEEggESMIIBDjAzBggrBgEFBQcwAoYnaHR0cDovL2NkcC5lY2Nv
# LmNvbS9FQ0NPSXNzdWluZ0NBMDIuY3J0MIGvBggrBgEFBQcwAoaBomxkYXA6Ly8v
# Q049RUNDT0lzc3VpbmdDQTAyLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWVjY29jb3JwLERD
# PW5ldD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlv
# bkF1dGhvcml0eTAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AuZWNjby5jb20vb2Nz
# cDAoBgNVHREEITAfoB0GCisGAQQBgjcUAgOgDwwNU0tKQUBlY2NvLmNvbTANBgkq
# hkiG9w0BAQsFAAOCAgEAZD1JZLl5RVTYv3QtrHeQMMQU8Ds61uDE5n4Si1pROneR
# nSSUN9/QJI6pyHno0U3GCdIJ4fJr8ZhNeQi0/wLHJ3otEIGTlkYPChhTIRs1Ea7Z
# UiD5ps84RDXm13GYYESwVnmJNX3G6jRetUdChMx6a1FjYrmgD0di/hh7Mwe5tFUz
# Km2lK8jwHscgCMTL/nJ4UdWxcGw16xjEG3wcp+UX+UaegJguYTB6saEoDYojiwyq
# 3zA8Csux6IiMzwg9946PeHo/h5Eokh6LmREjzN7tLvcBRsjmnOjawmpOlcV5uGaS
# BQWWyvcz5dhExw6yEOj8XWf2FGNTfIpgd/P3741YkXA4TDd6JhjBZEXwTceChvLB
# G7UCWnzmKhNJ/d2ny9nUTLXWqYybmgdf3gIo/xioP5tf2Z8K4+SruoeoJl5vgFyf
# PRevaHIuoo+ODscAxrlFRiO/M66NK3UgszXQ9U4cdJ4yfTp9yveGq2wno5qqtOaG
# bTytpYYwRWkdzl7c0KY7fvwfDv2D+a2AH+cSr85SQnzTyE449qgim3MzO8T/hkUg
# 7Uo0Oesn9V2/iNE6rQc890VU1e/1VC69703XGDZMz3yI3sh9AvD5Y6ItiAfZQ/Uc
# F97p3+/Upvwmd4s9nec03bt4pO78fe66L8oOwQ6AHVLS+13YPGi3JRzlrLssYagx
# ggMWMIIDEgIBATB1MF4xEzARBgoJkiaJk/IsZAEZFgNuZXQxGDAWBgoJkiaJk/Is
# ZAEZFghlY2NvY29ycDETMBEGCgmSJomT8ixkARkWA3ByZDEYMBYGA1UEAxMPRUND
# T0lzc3VpbmdDQTAyAhNLAAAFoPxI1A7QLuY0AAAAAAWgMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBSYZ8fQy2q0M+K82Nj1ClOawja0lTANBgkqhkiG9w0BAQEFAASCAgAQ2sr0rWZw
# MGtaVrqnZbYDkHxWkaEFvUOh4VPqE8pZdHAeL2H3A8viAm8SNaxSmDEne8ylni+S
# l7JDl8avN99w0cwvYDka/O3M/z30ENsyr8Ry28G3u/Pk1PQuNczOfK+cOKhBLueD
# FMs6QTmmPCWfAKQiW4qlyBVe8SdnKYa7kZAj4m+LeaNjVjukaj+FPmzYig0EL5+2
# Z7FL+L1bKfcZQFzUsvAOGTCpNnxJyLxfekwnTxPlWQYshwDWmbP0daKWQCU/+HBX
# fzVN0vrq51ABpRfwGU8WVy6dBwdEnklW4o+A7wgK/JLT13ow9SyKyuzqgUWPon58
# IgYZMos4dh6i7wnd2eaw1MwmoTm+ED0nfB2gG+GP84O5LntNxd9YwKZ2n2srny9z
# rVTaiW1F5tlARoMZh/X55elfrt2w+ST5RCk8TiW34PnPSqMv7lNExWWWZZxBbanb
# TXzwTSGJJG62fKGiL/CPcXEghKtlUb0QJ0N0c7mVURToUZ9DjgiuXLCmhYds1/Y2
# 8M+j39s5S05p+rZMVXkNbtG6xbrmsr0bXqQxRduR8u3YDHCG0M3c2SkSP8Ckoqcj
# m3GLadXo7AJtsQStO4VpMebfojMtN05cVZDhmori/2SMgYDJYjWqYsnvwVlXBjx4
# 0HFdZ5NWyaPfzOxLrE+nMfAjwuKrCmlc+g==
# SIG # End signature block
