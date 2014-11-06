<#
.Synopsis
   Gforces interface
.DESCRIPTION
   Generates the new Gforces incerface. 
   It includes: Open a specific car, show other cars from the same manufacturer, show other manufacturers.
.EXAMPLE
   Run script as .\build-allcars.ps1
#>

[CmdletBinding()]
[OutputType([int])]
Param
(
    [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    $Param1
)

$DebugPreference = "Continue"
$ErrorActionPreference = "Stop"

Clear-Host

# All the files are relative to this script path
$dir = get-item "."
$config = Join-Path $dir \.src\config.xml

# Krpano version number
$krver = '1.18'

# Inclide files
. C:\Users\rafael\Documents\WindowsPowerShell\scripts\gforces\Functions.ps1

function Start-Script {
    [xml]$xml = get-content $config
    $tour = $xml.tour.brand
    if ( $Param1 -ne $null ) { 
        $Param1 = $Param1.replace('.', '')
        $Param1 = $Param1.replace('\', '') 
        foreach ($brand in $tour) {
            $tour = $xml.tour.brand | where { $_.id -match $Param1 } 
        }
    }
    measure-command {
    # Make sure there is a jpg for each car specified in config.xml 
    check-pano-exists
    # Create some folders inside each brand directory
    create-folders
    # Copy all contents within '.src\bin\' folder into each 'files' directory
    move-krpano-files
    # Generate HTML files for each brand and within 'devel' directory
    generate-html-files
    # Generate main index.html file, containing all the brands and cars
    generate-all-cars-index-html
    # Generate carbrand/index.html file
    generate-carmodel-index-html
    # Generate carbrand/index.html file
    generate-carbrand-index-html
    # Add crossdomain to files/include/global/index.xml
    add-crossdomain
    # Generate files/content/coord.xml file
    generate-coord-xml
    # Generate files/content/panolist.xml file
    generate-panolist-xml
    # Generate devel.xml file
    generate-devel-xml
    # Generate files/tour.xml mergin all the scatered xml files
    generate-tour-xml 
    # Generate files/carbrand/brands.html
    generate-brands-html
    # Generate devel-brand.xml file
    generate-devel-brand-xml
    # Generate files/content/items.xml used by the dark interface sidepanel
    generate-items-xml
    # Generate files/brand.xml used by brand.html
    generate-brand-xml
    # Generate brands/index.html and brands/more.html
    generate-brands-grid 
    # Backward compatibility for cars in the bg directory
    if ((Get-Item -Path ".\").Name -eq "gb") {
        if ($tour.id -eq "mercedes_benz") { fix-mercedes }
        if ($tour.id -eq "ford") { fix-ford }
        if ($tour.id -eq "renault") { fix-renault }
        if ($tour.id -eq "chevrolet_left") { fix-chevrolet-left }
    }
    } | select @{n="Total Time";e={$_.Minutes,"minutes",$_.Seconds,"seconds" -join " "}}
    #Write-Verbose 'EOF' -Verbose

}

Start-Script $Param1