<#
.Synopsis
    Compares files in '.src/panos/' and '.src/masks/
.DESCRIPTION
    I need to make sure each car has its corresponding mask file.
#>

[CmdletBinding()]
Param()

Begin
{
    $ErrorActionPreference = "Stop"
    # Variables
    $importFolder ="E:\virtual_tours\gforces\cars\.src\import\*.jpg"
    $masksFolder ="E:\virtual_tours\gforces\cars\.src\masks\*.psb" 

    [Array]$panosArray = ""
    foreach ($pano in $(Get-Item $importFolder)) {
        [Array]$panosArray += $($pano).BaseName
    }
    #Write-host $panosArray

    [Array]$masksArray = ""
    foreach ($mask in $(Get-Item $masksFolder)) {
        [Array]$masksArray += $($mask).BaseName
    }
    #Write-host $panosArray
    
    Write-Output "No of panoramas in 'import' folder --------------> $($($panosArray).count)"
    Write-Output "No of panoramas in 'masks' folder --------------> $($($masksArray).count)"
    
    $comparation = Compare-Object $($panosArray) $($masksArray)
    Write-Output "Masks vs Panos:"
    write-output $comparation
}
End
{
    Write-Output "_EOF_"
}