<#
.Synopsis
   Compare the config.XML file from Amazon server with my cars/.src/config.file
   The Amazon file is generated every several days
   The result excludes the cars with the 'countrycode' IE as they're duplicated created by Gforces
.EXAMPLE
    Run from any directory
   Compare-GforcesCars
#>

[CmdletBinding()]
Param()

Begin
{
    $ErrorActionPreference = "Stop"
    # Variables
    $gforcesList = "https://s3-eu-west-1.amazonaws.com/autofs/shared/interiors/v10setup/interiors.xml"
    $config = "E:\virtual_tours\gforces\cars\.src\config.xml"
    [Array]$tourIDArray = ""
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
    foreach ( $rename in $configXml.tour.rename ) {
        foreach ( $car in $rename.car ) {
            $renameTo = $($car.renameTo)
            [Array]$tourIDArray += $renameTo
        }
    }
    Write-Output "No of shot cars in config.xml --------------> $($($tourIDArray).count)"

    [xml]$xml = (new-object System.Net.WebClient).DownloadString($gforcesList)
    #[xml]$xml = get-content "C:\Users\Rafael\Downloads\interiors.xml"
    $xmlFilter = $xml.TOURS.ChildNodes | where { $_.countrycode -notlike "IE" }
    $gforcesXml = $xmlFilter.folder_name 
    Write-Output "No of shot cars in gforces.xml --------------> $($($gforcesXml).count)"
    #$($gforcesXml.TOURS.ChildNodes).folder_name

    $diferences = Compare-Object $($gforcesXml) $($tourIDArray)
    Write-Output "gforces.CVS vs config.XML:"
    $diferences


}
End
{
    Write-Output "_EOF_"
}