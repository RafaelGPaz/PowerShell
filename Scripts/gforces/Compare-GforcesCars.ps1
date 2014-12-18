<#
.Synopsis
   Compare the folders inside my local 'gforces/cars/' directory and the 'interiors' directory in Amazon's server
.EXAMPLE
   Compare-GforcesCars.ps1
#>

[xml]$xmlFile=Invoke-WebRequest 'https://s3-eu-west-1.amazonaws.com/autofs/shared/interiors/v10setup/interiors.xml'
$remoteFolders= $xmlFile.TOURS.ChildNodes.FOLDER_NAME
$localFolders = $(Get-ChildItem -path "E:\virtual_tours\gforces\cars\" -Exclude ".no_scenes", ".src", "brands", "shared", "crossdomain.xml" ).basename

foreach ($carFolder in $localFolders){
    
}