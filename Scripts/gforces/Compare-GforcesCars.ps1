<#
.Synopsis
    Compare 'config.xml' file in the Amazon server with local file 'cars/.src/config.xml'
    The Amazon XML file is updated daily at midnight
    The result excludes the cars with the 'countrycode' 'ie' as they're duplicated of all 'gb' cars
.EXAMPLE
    Run from any directory
    Compare-GforcesCars.ps1
#>

[CmdletBinding()]
Param()

Begin
{
    $ErrorActionPreference = "Stop"
    # Variables
    $gforcesList = "https://s3-eu-west-1.amazonaws.com/autofs/shared/interiors/v10setup/interiors.xml"
    $config = "E:\virtual_tours\gforces\cars\.src\config.xml"
    [Array]$tourIDArray
    [xml]$configXml = Get-Content $config
    foreach ( $country in $configXml.tour.country ) {
        foreach ( $brand in $country.brand) {
            foreach ($model in $brand.model) {
                foreach ($car in $model.car) {
                    $tour = $($car.id)
                    [Array]$tourIDArray += $tour
                }
            }
        }
    }
    # Add 'ie' cars, which are duplicates of all 'gb' cars
    # It's very important add them before adding the 'rename' cars...
    # otherwise it will add 'ie' versions of renamed 'gb' cars...
    # and the script only creates 'ie' duplicates inside <duplicate> section.
    foreach ($item in $tourIDArray | Where-Object { $_ -like "gb_*" }) {
        $countryCode = ($item -split "_")[0]
        $otherInfo = $item.substring(3)
        $ieCars = 'ie_' + $otherInfo
        [Array]$tourIDArray += $ieCars
    }
    # Add 'rename' cars
    foreach ( $rename in $configXml.tour.rename ) {
        foreach ( $car in $rename.car ) {
            $renameTo = $($car.renameTo)
            [Array]$tourIDArray += $renameTo
        }
    }

    Write-Output "No of cars in config.xml --------------> $($($tourIDArray).count)"

    [xml]$xml = (new-object System.Net.WebClient).DownloadString($gforcesList)
    #[xml]$xml = get-content "C:\Users\Rafael\Downloads\interiors.xml"
    $gforcesXml = $($xml.TOURS.ChildNodes).folder_name
    Write-Output "No of cars in gforces.xml --------------> $($($gforcesXml).count)"
    #$($gforcesXml.TOURS.ChildNodes).folder_name

    $diferences = Compare-Object $($gforcesXml) $($tourIDArray)
    Write-Output "gforces.CVS vs config.XML:"
    $diferences

}
End
{
    Write-Output "_EOF_"
}