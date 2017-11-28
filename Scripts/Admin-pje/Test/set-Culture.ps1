# Script to configure language settings for each user

# Import 'International' module to Powershell session
 Import-Module International

# Set regional format (date/time etc.) to English (Australia) - this applies to all users
 Set-Culture en-US

# Check language list for non-US input languages, exit if found
$currentlist = Get-WinUserLanguageList
$currentlist | ForEach-Object {if(($_.LanguageTag -ne "en-AU") -and ($_.LanguageTag -ne "en-US")){exit}}

# Set the language list for the user, forcing English (Australia) to be the only language
 Set-WinUserLanguageList en-US -Force