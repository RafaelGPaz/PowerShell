<#
.Synopsis
Get day of year
.Description
Get the day of the year for a given integer. The default year is the current.
#>
[cmdletbinding()]
Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter an integer for the day of the year.")]
[ValidateRange(1,366)]
[int]$DayOfYear,
[ValidateRange(1,9999)]
[int]$Year=(Get-Date).Year
)
 
#define the first day of the year
[datetime]$dt= "1/1/$Year"
 
#the smart way
$dt.AddDays($DayOfYear-1)