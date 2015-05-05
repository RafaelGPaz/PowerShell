<#
.SYNOPSIS

.DESCRIPTION
        
.PARAMETER TourName
    The Name of the Tour to build.
.EXAMPLE
    C:\PS>New-Tour scene1
#>
[CmdletBinding()]
Param (                        
[Parameter(Mandatory=$False, 
    ValueFromPipeline=$True,
    #ValueFromPipelineByPropertyName=$True,
    Position=0)]  
    [String]$TourName
)
Measure-Command {
. C:\Users\Rafael\Documents\WindowsPowerShell\Scripts\tours\New-Tour\New-Tour-Functions.ps1
$krVersion = "1.17"
#Clear-Host
Confirm-ConfigFile
Add-SrcDirectory
Add-TourXml

# Source XML files
[xml]$configXml = Get-Content ".\config.xml"
[xml]$tourXml = Get-Content ".\tour.xml"

# If param is given, run the script only for that tour
if ($TourName -ne "") {
    # Remove dot and backslashes from it
    $TourName = $TourName.replace('.', '')
    $TourName = $TourName.replace('\', '')
    # Stop if the given param isn't a real tour name
    if(!(Test-Path .\.src\panos\$TourName)){ Throw "Folder .src\panos\$TourName NOT FOUND. Have you type the tour forder correctly?" }
    $TourXml | ForEach-Object { $tour = $_.vt.tour | where { $_.id -match $TourName } }
# If no param, run the script for ALL tours
} else {
    $tourXml | ForEach-Object { $tour = $_.vt.tour } 
}

Add-CustomDirectory $tour
    
$tour | ForEach-Object {

    Add-FolderStructure $_
    Remove-OldFiles $_       

    #Add-SceneNames
    #Add-SceneTitle
    #Add-IncludePluginAndData
    #Add-PluginsInCustom
    #Add-IncludePlugin
    #Add-InfoBtn
    Add-Includes $_ $configXml
    Add-IncludePanolist $_ $krVersion
    Add-IncludeMovecamera $_ $krVersion
    Add-IncludeLogoClient $_ $configXml
    Add-IncludeHotspots $_ $configXml
    #Add-Scroll
    #Add-PluginsData
    #Add-Tour
        
    Add-DevelXml $_ $krVersion       
    #Merge-XmlFiles
    #Add-CrossDomain
    Add-KrpanoPlugins $_
    Add-HtmlFiles $_ $configXml
}
Add-HtmlList $tour

} | select @{n="Total Time";e={$_.Minutes,"minutes",$_.Seconds,"seconds" -join " "}}  