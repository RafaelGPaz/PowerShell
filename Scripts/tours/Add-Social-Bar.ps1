<#
.Synopsis
Add social bar
.Description
Add social bar with Twitter, Facebook and Google+ buttons.
Files are in .custom/social
The file url_new.xml will be generated everytime the script runs.
If url.xml file doesn't exist, url_new.xml will be renamed as it.
If the <url> tag is empty, the Social Bar will not be added and it will be show as [ -- ] in the output 

.Parameter tours
Name of the directory in which run this script. 
If this parameter is omitted, the script will run though all the folders.
.Example
Add-Social-Bar scene1
#>
[cmdletbinding()]
Param(
[string[]]$tours
)

# Global variables
$src_dir = "E:\virtual_tours\.archives\bin\newvt\src"
$src_html = (Join-Path "$src_dir" html)
$conf_dir = ".custom\social"
$conf_file = (Join-Path $conf_dir _social_conf.ps1)
$url_file  = ".custom\social\url.xml"
$url_new_file = ".custom\social\url_new.xml"

# Generate url_new.xml with all the manufacturers and cars
function generate-url-new-xml-file {
    New-Item -Force -ItemType File $url_new_file | Out-Null
    Add-Content $url_new_file '<tour>'
    Add-Content $url_new_file ""
    $tours = dir .\.src\panos -Directory 
    foreach ($tour in $tours)
    {
        $tour = Get-Item $tour
        Add-Content $url_new_file "    <$($tour.BaseName)>"
        $scenes = dir ".src\panos\$($tour.BaseName)" -Filter *.jpg
        foreach ($scene in $scenes)
        {
            Add-Content $url_new_file "        <scene name=`"$($scene.Basename)`">"
            Add-Content $url_new_file '            <url></url>'
            Add-Content $url_new_file '        </scene>'
        }
        Add-Content $url_new_file "    </$($tour.BaseName)>"
        Add-Content $url_new_file ""
    }
    Add-Content $url_new_file '</tour>'
}

# Add configuration folder
if ((Test-Path $conf_dir) -notlike "True") { New-Item -ItemType Directory $conf_dir | Out-Null }

# Add configuration file
if ((Test-Path $conf_file) -notlike "True") 
{ 
    New-Item -ItemType File $conf_file | Out-Null 
    Add-Content $conf_file '$vt_host = ""'
    Add-Content $conf_file '$via = ""'
    Add-Content $conf_file '$hashtag = ""'
    Add-Content $conf_file '$type = "website"'
    Add-Content $conf_file '$admins = "100006391898674"'
}
. $conf_file

# If the file "url.xml" is not present, use the generated xml file above
if ((Test-path $url_file ) -notlike "True")
{
    generate-url-new-xml-file
    mv $url_new_file $url_file
}

# If there is no parameters, execute the script for all the tours
if ($tours.Length -eq "0")
{
    $tours = dir .\.src\panos -Directory 
}

# Foreach folder in ".src\panos"
foreach ($tour in $tours)
{
    #$tour = "$pwd\$($tour.Basename)"
    $tour = Get-Item $tour
    if ((Test-Path $tour) -notlike "True")
    {
        throw "The following directory doesn't exists: " + $tour
    }
    else
    {
        if ((Test-Path $tour/social.css) -notlike "True")
        {
            Copy-Item $src_html/social.css $pwd
        }
        # Foreach jpg panorama
        $scenes = dir ".src\panos\$($tour.BaseName)" -Filter *.jpg
        foreach ($scene in $scenes) 
        {   
            # Create "scenes_conf.ps1" getting information from "tour.xml"
            [xml]$tourfile = Get-Content  $tour\files\tour.xml 
            # When the tour has only 1 scene
            if ($tourfile.krpano.layer.pano.title.Rank -ne "1") 
            { 
                $vt_title = $tourfile.krpano.layer.pano.title
            }
            # When the tour has more than 1 scene
            else 
            {
                #$vt_title = $tourfile.krpano.layer.pano.title[$i]
                $vt_title = ($tourfile.krpano.layer.pano | where {$_.name -eq $scene.BaseName}).title
            }
            # Get carl url getting information from "url.xml" file
            [xml]$car_url = Get-Content  $url_file
            if ($car_url.tour.$($tour.BaseName).scene.Rank -ne "1") 
            { 
                $vt_url = $car_url.tour.$($tour.BaseName).scene.url
            }
            else
            {
                $vt_url = $($car_url.tour.$($tour.basename).scene | where {$_.name -eq $scene.BaseName}).url
            }
            $vt_img = $vt_host + ($tour.BaseName) + "/" + $scene.BaseName + ".jpg"
            $vt_image_src = ($tour.BaseName) + "/" + $scene.BaseName + ".jpg"
            $vt_social_css = $vt_host + "social.css"
            # Get krpano lines of code from the html before delete it
            $scene_html = $tour.Fullname + "\" + $($scene.BaseName) + ".html"
            $scene_html = dir $scene_html           
            $kr1 = Get-Content  $scene_html | sls "tour.js"
            $kr2 = Get-Content  $scene_html | sls "activatepano"
            $kr3 = Get-Content  $scene_html | sls "embedpano"
            # Add an html file foreach scene ONLY if <scene> is not empty
            if ($($vt_url).Length -gt "0") {
                #rm $scene_html
                $temp_html = $tour.FullName + "\temp.html"
                Copy-Item "$src_html\social.html" $temp_html
                # Add wmode:"transparent" to the krpano code
                $check_wmode = dir $temp_html | sls wmode 
                # Restore krpano code 
                Get-Content $temp_html | Foreach-Object {$_ -replace 'kr1', $kr1} | 
                    Foreach-Object {$_ -replace 'kr2', $kr2} | 
                    Foreach-Object {$_ -replace 'kr3', $kr3} | 
                    Foreach-Object {$_ -replace 'vt_type', $vt_type} | 
                    Foreach-Object {$_ -replace 'vt_title', $vt_title} | 
                    Foreach-Object {$_ -replace 'vt_description', $vt_title} | 
                    Foreach-Object {$_ -replace 'vt_img', $vt_img} | 
                    Foreach-Object {$_ -replace 'vt_image_src', $vt_image_src} |
                    Foreach-Object {$_ -replace 'vt_social_css', $vt_social_css} |
                    Foreach-Object {$_ -replace 'vt_url', $vt_url} | 
                    Foreach-Object {$_ -replace 'vt_admins', $vt_admins} | 
                    Foreach-Object {$_ -replace 'vt_via', $vt_via} | 
                    Foreach-Object {$_ -replace 'vt_hashtags', $vt_hashtags} |
                    Foreach-Object {if ($check_wmode.Length -eq 0) {$_ -replace ', vars', ', wmode:"transparent", vars'} } | 
                    Set-Content  $scene_html
                rm $temp_html
                Write-Verbose "[ ok ] $($scene.BaseName)" -Verbose
            }
            else
            {
                Write-Verbose "[ -- ] $($scene.BaseName)" -Verbose
            }
        }
    }
}

# Generate url_new.xml file to use as reference
generate-url-new-xml-file