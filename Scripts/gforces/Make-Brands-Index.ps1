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
$dir = get-item "E:\virtual_tours\gforces\allcars"
$config = Join-Path $dir \.src\config.xml

# Krpano version number
$krver = '1.17'

# Inclide files
. C:\Users\rafael\Documents\WindowsPowerShell\scripts\gforces\Functions.ps1

function Start-Script {
    [xml]$xml = get-content $config
    $tour = $xml.tour.brand
    if ( $Param1 -ne $null ) { 
        $Param1 = $Param1.replace('.\', '') 
        foreach ($brand in $tour) {
            $tour = $xml.tour.brand | where { $_.id -match $Param1 } 
        }
    }
    measure-command {
        Write-Verbose 'Generate HTML Brand file' -Verbose
        $param1 = 0
        $param2 = 0
        $tempfile = "$dir\.src\html\index.temp"
        $brandsfile = "$dir\brands\index.html"
        $morebrandsfile = "$dir\brands\more.html"
        New-Item -ItemType File $tempfile -Force
        foreach ($brand in $tour) {
            $brand_name = $brand.id           
            Write-Verbose ('Brand: ' + $brand.name ) -Verbose
            Add-Content $tempfile ('                <article class="one-fifth" style="transform:translate(' + $param1 + 'px,' + $param2 + 'px); -webkit-transform: translate3d(' + $param1 + 'px,' + $param2 + 'px,0px);"><a href="../' + $($brand.id) + '/brand.html" class="project-meta" title="Click me"><img src="./img/logos/' + $($brand.id) + '.jpg" alt="' + $($brand.name) + '"/></a><a href="../' + $($brand.id) + '/brand.html" class="project-meta"><h5 class="title">' + $($brand.name) + '</h5></a></article>')
            $param1 = $param1 + 192
            if ($param1 -eq 960) {
                $param1 = 0
                $param2 = $param2 + 220
            }
        }
        $template_content = Get-Content $dir\.src\html\brands_index_template.html
        $brands_content = Get-Content $tempfile
        $template_content | foreach $_ {
            if ($_ -match 'ADDCONTENT' ) {
                $brands_content
            } elseif ($_ -match 'PARAM3') {
               ($_).replace('PARAM3',$param2)
            } else {
                $_
            }
        } | Set-Content $brandsfile
        Remove-Item $tempfile -Force
        Get-Content $brandsfile |
        foreach { ($_).replace('brand.html','more_brands.html') } | 
        Out-File -Encoding utf8 $morebrandsfile
    } | select @{n="Total Time";e={$_.Minutes,"minutes",$_.Seconds,"seconds" -join " "}}

}

Start-Script $Param1