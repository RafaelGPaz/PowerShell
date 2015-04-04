<#
.Synopsis
   Compares gforces.cvs list with config.xml 
.DESCRIPTION
   It compares all the cars marked as 'shot' in Gforces Google Spreadsheet with my confi.xml file.
   First I need to export the file as a CVS file to my 'Download' directory.
   The script compares them in both directions, so I'll know if there are any files missing in the spreadsheet or my config.xml.
   It also shows if there are duplicated entries in the spreadsheet. This will be shown as 'files not in my config.xml'
.EXAMPLE
   Run from any directory.
   Compare-GforcesLists
#>

[CmdletBinding()]
Param()

Begin
{
    $ErrorActionPreference = "Stop"
    # Variables
    $gforcesList = Import-Csv "C:\Users\Rafael\Downloads\GForces 360 Makes and Models (Responses) - Worksheet.csv"
    $config = "E:\virtual_tours\gforces\cars\.src\config.xml"
    [xml]$configXml = Get-Content $config

    # tourIDArray contains all cars defined in the file config.xml
    [Array]$tourIDArray = ""
    foreach ( $country in $configXml.tour.country | where {$_.id -like "gb"}) {
        foreach ( $brand in $country.brand) {
            foreach ($model in $brand.model) {
                foreach ($car in $model.car) {
                    $tour = $($car.id) 
                    [Array]$tourIDArray += $tour
                }
            }
        }
    }
    Write-Output "No of shot cars in config.xml --------------> $($($tourIDArray).count)"

    # renameArray contains all the cars within the .cvs file with the tag 'shot'
    $cvsShotCars = $gforcesList | where { $_.Status -like "shot"}
    [Array]$CvsShotCarsArray = ""
    foreach ($shotCar in $cvsShotCars.Filename) {
        [Array]$CvsShotCarsArray += $shotCar
    }
    Write-Output "No of shot cars in .csv --------------------> $($($CvsShotCarsArray).count)"

    # MISSING CARS IN THE CVS FILE
    # allCars = config.xml + shot cars in the .cvs file
    $allCars = $tourIDArray + $CvsShotCarsArray.id | select -Unique
    $missingCarsInCvs = $allCars | Where-Object { $CvsShotCarsArray -notcontains $_ }
    Write-Output "No of shot cars mising in the .cvs file ----> $($($missingCarsInCvs).count)"

    # MISSING CARS IN CONFIG.XML FILE
    $missingCarsInConfigXml = $CvsShotCarsArray | Where-Object { $tourIDArray -notcontains $_ }
    Write-Output "No of shot cars mising in config.xml file --> $($($missingCarsInConfigXml).count)"

    # Show comparation
    $duplicatedCars = Compare-Object $($CvsShotCarsArray) $($tourIDArray)
    Write-Output "gforces.CVS vs config.XML:"
    $duplicatedCars
}
End
{
    Write-Output "_EOF_"
}