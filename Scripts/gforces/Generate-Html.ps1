<#
.Synopsis
   Makes ALL possible html files listing ALL the cars
.DESCRIPTION
   Makes index.html and brand/index.html file
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

Clear-Host

# All the files are relative to this script path
$dir = get-item .
$config = Join-Path $dir \.src\config.xml

# Inclide files
. $dir\Functions.ps1

function Start-Script {
    [xml]$xml = get-content $config
    $tour = $xml.tour.brand
    # Generate HTML files for each brand and within 'devel' directory
    generate-html-files
    # Generate main index.html file, containing all the brands and cars
    generate-all-cars-index-html
    # Generate carbrand/index.html file
    generate-carbrand-index-html
    # Generate files/carbrand/brands.html
    generate-brands-html
}

Start-Script