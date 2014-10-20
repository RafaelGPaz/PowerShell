<#
.DESCRIPTION
    Create 420 x 210 thumbnails to use by the scroll feature
    Run the script from the tour's root directory
    Mandatory param: tour's folder
.EXAMPLE
    Make-Thumbs bugatti_showroom/
#>
    [CmdletBinding()]
    [Parameter(Mandatory=$true, Position=0)]
    Param ($tourDir)
Write-Verbose "Starting..."
# Check the script is running in the right directory
if (!(Test-Path '.\.src')) { Throw "Cant find folder '.src'. Are you sure you're in the right directory?" }
# Create 'scroll_panos' directory
$thumbsDir = ".\$tourDir\files\content\scroll_thumbs"
if (!($thumbsDir)) { mkdir $thumbsDir }
# Create 'scroll_panos' directory for devel
$develThumbs = ".\$tourDir\devel\files\content\scroll_thumbs"
if (!($develThumbs)) { mkdir $develThumbs }
Get-ChildItem ".\.src\panos\$tourDir" -Filter "*.jpg" |
        foreach {
            $destThumb = "$thumbsDir\$($_.name)"
            # Create a thumbnail for each scene, if it doesn't exist already
            if (!(Test-Path $destThumb)) {
                Write-Verbose "Creating $destThumb ..."
                Invoke-Expression "C:\'Program Files (x86)'\ImageMagick-6.8.9-Q16\convert.exe $($_.FullName) -resize 420x210^ -gravity center -extent 200x120 $destThumb"                
            }
            # Copy each thumbnail to the devel directory if it's not already there
            if (!(Test-Path "$develThumbs\$($_.name)")) {
                copy $destThumb $develThumbs
                Write-Verbose "Copy $($_.name) to devel directory"
            }
        }
Write-Verbose "End of line."