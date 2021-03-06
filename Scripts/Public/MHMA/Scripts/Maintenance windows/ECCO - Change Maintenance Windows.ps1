<# 
********************************************************************************************************** 
*                                                                                                        * 
*** This Powershell Script is used to set maintenance windows on SU Collections for any month          *** 
*                                                                                                        * 
********************************************************************************************************** 
* Created by Octavian Cordos, 28/03/2015  | Requirements Powershell 2.0, SCCM 2012 R2                    * 
* =======================================================================================================* 
* Modified by                   |    Date    | Revision  | Comments                                      * 
*________________________________________________________________________________________________________* 
* Octavian Cordos               | 28/03/2015 | v1.0      | First version                                 * 
* Octavian Cordos/Ioan Popovici | 30/03/2015 | v1.1      | Second version                                * 
* Octavian Cordos               | 31/03/2015 | v1.2      | Third version                                 *
* DBPE - ECCO					| 19/01/2016 | v1.2		 | ECCO Customisation
*--------------------------------------------------------------------------------------------------------* 
*                                                                                                        * 
********************************************************************************************************** 

    .SYNOPSIS 
       Used to set maintenance windows 
    .DESCRIPTION 
       Calculating second tuesday of any month and setting Maintenance window offset by any number of days/weeks
	   Using a CSV With Collection IDs and offset times for each Maintenance window collection.
#> 
 
#Run on Site server 
 
#Initialising 
	import-module "I:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
	cd P01:
	

#Parameters
    $MW=Import-CSV "C:\Scripts\MainetenanceWindows.csv" -Delimiter ";"
	$MonthArray = New-Object System.Globalization.DateTimeFormatInfo 
    $MonthNames = $MonthArray.MonthNames 
  
  
# Get Patch Tuesday for the current Month.		
    Function Get-PatchTuesday
     { 
        $FindNthDay=2 #Aka Second occurence 
        $WeekDay='Tuesday' 
        $Today=get-date
        $todayM=$Today.Month.ToString() 
        $todayY=$Today.Year.ToString() 
        [datetime]$StrtMonth=$todayM+'/1/'+$todayY 
        while ($StrtMonth.DayofWeek -ine $WeekDay ) { $StrtMonth=$StrtMonth.AddDays(1) } 
        $PatchDay=$StrtMonth.AddDays(7*($FindNthDay-1)) 
        Return $PatchDay 
     }

	
#Create Maintenance Windows.	
    Function Set-PatchMW
        { 
 			Foreach ($MWName in $MW)
    			{
        		#Set Patch Tuesday for each Month 
        		$PatchDay=Get-PatchTuesday	##	($PatchMonth)	## No longer used as script uses Current month 
         
        		#Set Maintenance Window Naming Convention (Months array starting from 0 hence the -1)
                $todayM=$PatchDay.Month.ToString()
        		$MWDisplayName = $MonthNames[$PatchDay.Month-1]+".MaintenanceWindow."+$MWName.Name
 
		        #Set Device Collection Maintenace interval
        		$StartTime=$PatchDay.AddDays($MWName.OffSetDay -as [int]).Addhours(2)
		        $EndTime=$StartTime.Addhours(2)
                $OffsetW=$MwName.OffsetWeek -as [int]
                $OffsetD=$MwName.OffsetDay -as [int]
 
        		#Create The Schedule Token  
       			$Schedule = New-CMSchedule -Nonrecurring -Start $StartTime.AddDays($OffsetW*7) -End $EndTime.AddDays($OffsetW*7) 
 
		        #Set Maintenance Windows 
        		New-CMMaintenanceWindow -CollectionID $MWName.CollectionID -Schedule $Schedule -Name $MWDisplayName
        		} 
         }
		 
		 
#Remove all existing Maintenance Windows for all Collection 
    Function Remove-MaintnanceWindows  
        {
			Foreach ($MWName in $MW)
    		{
		    Get-CMMaintenanceWindow -CollectionId $MWName.CollectionID | ForEach-Object { 
        	Remove-CMMaintenanceWindow -CollectionID  $MWName.CollectionID -Name $_.Name -Force 
        	$Coll=Get-CMDeviceCollection -CollectionId $MWName.CollectionID 
        	Write-Host "Removing MW:"$_.Name"- From Collection:"$Coll.Name 
    		} 
			} 
 		}
		
# Do the magic.
Remove-MaintnanceWindows

Set-PatchMW