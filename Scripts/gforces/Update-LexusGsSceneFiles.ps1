<#
.DESCRIPTION
  
.EXAMPLE
  
#>

[cmdletbinding()]

    Param (
        [Parameter(
            Mandatory=$False,
            ValueFromPipeline=$false)]
        [Switch] $IgnoreUndercores
        )

$VerbosePreference = "Continue"
# Stop if there is any error
$ErrorActionPreference = "Stop"
$root = 'E:\virtual_tours\gforces\manufacturers\lexus_manufacturer\ae_lexus_gs350_2016\ae_lexus_gs350_2016\files\scenes'
$selectedFolder = Get-Childitem $root

foreach ($carModel in $selectedFolder) {
    Write-Verbose $carModel
    foreach ($xmlFile in Get-ChildItem $root\$carModel -Filter "*.xml") {
        #write-host $xmlFile.FullName
        $template_content = Get-Content $xmlFile.FullName
        #Write-Host $template_content
        $sceneName = 'name="' + $($carModel) + '_scene'
        $tilesPath = 'scenes/' + $($carModel) + '/scene'
        #write-host = $sceneName
        $template_content |
        foreach { ($_).replace('name="scene',$sceneName)} |
        foreach { ($_).replace('scenes/scene',$tilesPath)} |
        Out-File -Encoding utf8 $xmlFile.FullName
    }
}

Write-Verbose "EOF"