#Steps to generate reports:

#1.	Run powershell as administrator

#2.	write in the powershell console following - or execute this script: 

import-module ActiveDirectory

#3.	To get the report from desktops and laptops to run the following:

GET-ADCOMPUTER -filter {OperatingSystem -NotLike "*server*"} -properties * |select-object "name","OperatingSystem","lastlogondate","PasswordLastSet","ipv4address","primarygroup","Enabled","isDeleted","LockedOut"| Export-csv C:\Report\Crayon\desktopsAD.csv -notypeinformation -encoding utf8

#4.	To get the report user to run the following:

GET-ADUSER –filter * -properties * |select-object "EmailAddress","mail","name","CN","DisplayName","GivenName","Surname","SamAccountName","UserPrincipalName","DistinguishedName","Created","LastLogonDate","PasswordLastSet","PrimaryGroup","primaryGroupID" ,"Enabled","isDeleted","LockedOut"| Export-csv C:\Report\Crayon\usersAD.csv -notypeinformation -encoding utf8

#5.	To get the report server to run the following:

GET-ADCOMPUTER -filter {OperatingSystem -Like "Windows *server*"} -properties * |select-object "name","OperatingSystem","lastlogondate","PasswordLastSet","ipv4address","primarygroup","Enabled","isDeleted","LockedOut"| Export-csv C:\Report\Crayon\serverAD.csv -notypeinformation -encoding utf8

#These commands generate files called desktopsAD.csv, usersAD.csv and serverAD.csv at the root of drive C.
